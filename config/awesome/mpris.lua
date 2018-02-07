local gears     = require("gears")
local wibox     = require("wibox")

local lgi       = require("lgi")
local gobject   = lgi.GObject
local glib      = lgi.GLib
local gio       = lgi.Gio

local function factory(args)
    local mpris    = { widget = wibox.widget.textbox() }
    local args     = args or {}
    local settings = args.settings or function() end

    -- mpris.player   = args.player or "Lollipop"

    local players = {}
    local current_player = nil

    local bus = gio.bus_get_sync(gio.BusType.SESSION)

    local function startswith(str, sub)
        return string.sub(str, 1, string.len(sub)) == sub
    end

    local function tableitem(tbl)
        for k, v in pairs(tbl) do
            return k, v
        end
    end

    function mpris.update()
        if not current_player then
            mpris_now = {
                state = "Stopped",
                title = "",
                album = "",
                artist = "",
                cover = "",
            }
        else
            local metadata = current_player:get_cached_property("Metadata")
            local artists = metadata and metadata.value["xesam:artist"]
            mpris_now = {
                state = current_player:get_cached_property("PlaybackStatus"),
                title = metadata and metadata.value["xesam:title"] or "",
                album = metadata and metadata.value["xesam:album"] or "",
                artist = artists and artists[1] or "",
                cover = metadata and metadata.value["mpris:artUrl"] or "",
            }
        end

        widget = mpris.widget
        settings()
    end

    local function make_current_player(proxy)
        current_player = proxy
        mpris.update()
        if not proxy then return end

        local properties_changed_handler
        properties_changed_handler = proxy.on_g_properties_changed:connect(function(_, changed, invalidated)
            if changed.value["PlaybackStatus"] or changed.value["Metadata"] then
                mpris.update()
            end
        end)

        local owner_changed_handler
        owner_changed_handler = proxy.on_notify:connect(function()
            if not proxy.g_name_owner then
                gobject.signal_handler_disconnect(proxy, properties_changed_handler)
                gobject.signal_handler_disconnect(proxy, owner_changed_handler)

                local _, next_player = tableitem(players)
                make_current_player(next_player)
            end
        end, "g-name-owner")

        gears.debug.print_warning("make_current_player: " .. tostring(proxy.g_name))
    end

    local function add_player(name)
        local proxy, err = gio.DBusProxy.async_new(
            bus,
            gio.DBusProxyFlags.NONE,
            nil,
            name,
            "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player")
        if err then error(err) end

        local handler_id
        handler_id = proxy.on_notify:connect(function()
            if not proxy.g_name_owner then
                gobject.signal_handler_disconnect(proxy, handler_id)
                players[name] = nil
            end
        end, "g-name-owner")

        gears.debug.print_warning("add_player: " .. tostring(name))
        if not current_player then make_current_player(proxy) end

        players[name] = proxy
        return proxy
    end

    bus:signal_subscribe(
        "org.freedesktop.DBus",   -- name
        "org.freedesktop.DBus",   -- interface
        "NameOwnerChanged",       -- signal
        "/org/freedesktop/DBus",  -- path
        "org.mpris.MediaPlayer2", -- namespace of names we'le listening to
        gio.DBusSignalFlags.MATCH_ARG0_NAMESPACE,
        function(conn, sender, path, iface, signal, args)
            local name, prev_owner, owner = unpack(args)
            local player_name = name:sub(1 + #"org.mpris.MediaPlayer2.")
            if prev_owner == "" then
                -- name acquired
                gio.Async.start(add_player)(name)
            elseif owner == "" then
                -- name lost
            else
                -- someone took over the name
            end
        end)

    local names, err = bus:call_sync(
        "org.freedesktop.DBus",   -- name
        "/org/freedesktop/DBus",  -- path
        "org.freedesktop.DBus",   -- interface
        "ListNames",              -- method
        nil,                      -- arguments
        glib.VariantType("(as)"), -- output type
        gio.DBusCallFlags.NONE,   --
        -1)                       -- timeout (-1 for default)
    if err then error(err) end

    -- names is of "type" (as), an array inside a tuple
    for _, name in ipairs(names[1]) do
        if startswith(name, "org.mpris.MediaPlayer2.") then
            gio.Async.start(add_player)(name)
        end
    end

    mpris.update()
    return mpris
end

return factory
