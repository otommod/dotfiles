local gears     = require("gears")
local wibox     = require("wibox")

local lgi       = require("lgi")
local gobject   = lgi.GObject
local glib      = lgi.GLib
local gio       = lgi.Gio

local function startswith(str, sub)
    return string.sub(str, 1, string.len(sub)) == sub
end

local function tableitem(tbl)
    for k, v in pairs(tbl) do
        return k, v
    end
end

local function factory(args)
    local mpris    = { widget = wibox.widget.textbox() }
    local args     = args or {}
    local settings = args.settings or function() end

    -- mpris.player   = args.player or "Lollipop"

    local player = nil
    local all_players = {}

    local bus = gio.bus_get_sync(gio.BusType.SESSION)

    function mpris.update()
        local metadata = {}
        local playback_status = "Stopped"
        if player then
            playback_status = player:get_cached_property("PlaybackStatus")
            local g_metadata = player:get_cached_property("Metadata")
            if g_metadata then metadata = g_metadata.value end
        end

        mpris_now = {
            state = playback_status,
            title = metadata["xesam:title"] or "",
            album = metadata["xesam:album"] or "",
            cover = metadata["mpris:artUrl"] or "",
            artist = metadata["xesam:artist"] and metadata["xesam:artist"][1] or "",
        }
        widget = mpris.widget
        settings()
    end

    local function make_player_current(name)
        gears.debug.print_warning("make_player_current: " .. tostring(name))
        if name == nil then
            player = nil
            mpris.update()
            return
        end

        gio.Async.start(function()
            local proxy, err = gio.DBusProxy.async_new(
                bus,
                gio.DBusProxyFlags.NONE,
                nil,
                name,
                "/org/mpris/MediaPlayer2",
                "org.mpris.MediaPlayer2.Player")
            if err then error(err) end

            player = proxy
            mpris.update()

            local props_changed_handler
            props_changed_handler = proxy.on_g_properties_changed:connect(function(_, changed, invalidated)
                if changed.value["PlaybackStatus"] or changed.value["Metadata"] then
                    mpris.update()
                end
            end)

            local owner_changed_handler
            owner_changed_handler = proxy.on_notify:connect(function()
                if not proxy.g_name_owner then
                    gobject.signal_handler_disconnect(proxy, props_changed_handler)
                    gobject.signal_handler_disconnect(proxy, owner_changed_handler)

                    local next_player = tableitem(all_players)
                    make_player_current(next_player)
                end
            end, "g-name-owner")
        end)()
    end

    local function add_player(name)
        gears.debug.print_warning("add_player: " .. tostring(name))
        all_players[name] = true
        if not player then make_player_current(name) end
    end

    local function remove_player(name)
        gears.debug.print_warning("remove_player: " .. tostring(name))
        all_players[name] = nil
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
                add_player(name)
            elseif owner == "" then
                -- name lost
                remove_player(name)
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
            add_player(name)
        end
    end

    mpris.update()
    return mpris
end

return factory
