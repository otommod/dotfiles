--
-- rc.lua
--

-- Includes             {{{1
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
              require("awful.autofocus")

-- Notification library
local naughty = require("naughty")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget and layout library
local wibox = require("wibox")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup.widget")
-- The above widget is not limited to awesome's hotkeys.  Given any definition
-- of keymaps, it can be used to display them and can even be associated with
-- clients using awesome's rule syntax.  To do that though, you need to supply
-- the afforemention definition.  Currently, there's only one for vim.
--
-- require("awful.hotkeys_popup.keys.vim")

local lain = require("lain")
lain.helpers = require("lain.helpers")

-- Error handling       {{{1
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

-- Options              {{{1
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_dir("config") .. "themes/pastel/theme.lua")
beautiful.wallpaper = "/home/otto/Pictures/Gare_de_Lyon_TGV_Sud-Est.jpg"

-- This is used later as the default terminal and editor to run.
terminal = "st"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- You can use another modifier like Mod1, but it may mess with other programs.
modkey = "Mod4"

tagnames = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    -- lain.layout.cascade,
    -- lain.layout.cascade.tile,
    -- lain.layout.centerwork,
    -- lain.layout.centerwork.horizontal,
    -- lain.layout.termfair,
    -- lain.layout.termfair.center,
}

-- lain.layout.termfair.nmaster           = 3
-- lain.layout.termfair.ncol              = 1
-- lain.layout.termfair.center.nmaster    = 3
-- lain.layout.termfair.center.ncol       = 1
-- lain.layout.cascade.tile.offset_x      = 2
-- lain.layout.cascade.tile.offset_y      = 32
-- lain.layout.cascade.tile.extra_padding = 5
-- lain.layout.cascade.tile.nmaster       = 5
-- lain.layout.cascade.tile.ncol          = 2

-- Helper functions     {{{1
local markup = lain.util.markup

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

-- Menu                 {{{1
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys",     function() return false, hotkeys_popup.show_help end},
   { "manual",      terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart",     awesome.restart },
   { "quit",        awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Conky                {{{1
local lgi       = require("lgi")
local gio       = lgi.Gio
local gdk       = lgi.Gdk
local gdkpixbuf = lgi.GdkPixbuf
local cairo     = lgi.cairo

local conky = wibox.widget {
    layout = wibox.layout.stack,
    {
        id = "cover",
        widget = wibox.widget.imagebox,
    },
    {
        widget = wibox.container.place,
        valign = "bottom",
        content_fill_horizontal = true,
        {
            widget = wibox.container.background,
            bg = "#000000cc",
            {
                widget = wibox.container.margin,
                margins = 10,
                {
                    layout = wibox.layout.fixed.vertical,
                    -- spacing = 15,
                    {
                        id = "title",
                        widget = wibox.widget.textbox,
                        align = "center",
                    },
                    {
                        id = "artist",
                        widget = wibox.widget.textbox,
                        align = "center",
                    },
                },
            },
        },
    },
}

local conkyprevcover = nil
local conkyinfo = require("mpris") {
    settings = function()
        conky.visible = mpris_now.state ~= "Stopped"
        if not conky.visible then return end

        local titlewidget = conky:get_children_by_id("title")[1]
        local artistwidget = conky:get_children_by_id("artist")[1]
        local coverwidget = conky.cover

        titlewidget:set_markup(("<span font='%s' weight='%s'>%s</span>"):format(
            "OpenSans 15", "black", gears.string.xml_escape(mpris_now.title)))
        artistwidget:set_markup(("<span font='%s' weight='%s'>%s</span>"):format(
            "OpenSans 10", "book", gears.string.xml_escape(mpris_now.artist .. " - " .. mpris_now.album)))

        coverwidget.visible = false
        if mpris_now.cover == "" then return end
        if mpris_now.cover == conkyprevcover then
            coverwidget.visible = true
            return
        end
        conkyprevcover = mpris_now.cover

        -- in case of file URL just decode it
        -- FIXME: use gears.string.startswith when awesome is updated
        if mpris_now.cover:sub(1, #"file://") == "file://" then
            local cover = mpris_now.cover
            cover = cover:sub(#"file://")
            cover = cover:gsub("%%(%x%x)", function(x)
                return string.char(tonumber(x, 16))
            end)
            coverwidget:set_image(cover)
            coverwidget.visible = true

        else
            gio.Async.start(function()
                gears.debug.print_warning("downloading cover")

                local gfile = gio.File.new_for_uri(mpris_now.cover)
                if not gfile then return end
                local stream = gfile:async_read()
                if not stream then return end
                local pb = gdkpixbuf.Pixbuf.async_new_from_stream(stream)
                if not pb then return end
                -- stream:async_close()

                local format = cairo.Format.ARGB32
                if pb.n_channels == 3 then
                    format = cairo.Format.RGB24
                end

                -- We create a cairo.Context then use the Gdk-cairo integration to turn
                -- the Pixbuf into a cairo.Surface.  This function was introduced in
                -- Gdk-3.10.  Also see https://github.com/awesomeWM/awesome/pull/2160
                local surface = cairo.ImageSurface(format, pb.width, pb.height)
                local cr = cairo.Context(surface)
                gdk.cairo_set_source_pixbuf(cr, pb, 0, 0)
                cr:paint()

                coverwidget:set_image(surface)
                coverwidget.visible = true
            end)()
        end
    end
}


local awfulconky = wibox {
    widget = conky,
    type = "desktop",
    visible = true,
    height = 400,
    width = 400,
    bg = gears.color.transparent,
}

awful.placement.bottom_left(awfulconky, {
    offset = { x = 120, y = -60 },
    attach = true,
})
awful.placement.no_offscreen(awfulconky)

-- Widgets              {{{1
-- Separators                {{{2
local spacer = wibox.widget {
    widget = wibox.widget.base.empty_widget,
    forced_width = 8,
}

local separator = wibox.widget {
    widget = wibox.widget.textbox,
    markup = markup("#333333", "|"),
    forced_width = 10,
    align = "center",
}

-- Mail                      {{{2
local mailicon = wibox.widget.imagebox(beautiful.widget_mail)
local mail = lain.widget.imap {
    timeout  = 180,
    server   = "imap.gmail.com",
    mail     = "ottomodinos@gmail.com",
    -- TODO: use a password manager
    password = {"cat", os.getenv("HOME") .. "/.my_mail_password"},
    settings = function()
        if mailcount == 0 then
            mailicon.visible = false
            widget:set_text("")
            return
        end

        mailicon.visible = true
        widget:set_markup(markup(beautiful.widget_mail_fg, mailcount))
    end
}

-- -- Battery                   {{{2
-- local baticon = wibox.widget.imagebox(beautiful.widget_bat)
-- local battery = lain.widget.bat {
--     settings = function()
--         local perc = bat_now.perc == "N/A" and "N/A" or bat_now.perc .. "%"

--         if bat_now.ac_status == 1 then
--             perc = perc .. " plug"
--         end

--         widget:set_markup(markup(beautiful.widget_bat_fg, perc))
--     end
-- }

-- Volume                    {{{2
local volicon = wibox.widget.imagebox(beautiful.widget_vol)
local volume = lain.widget.alsa {
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = "M" .. volume_now.level
        end

        widget:set_markup(markup(beautiful.widget_vol_fg, volume_now.level .. "%"))
    end
}

-- We call `volume.update()` as a callback so that it runs after the volume has changed.
volume.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function() awful.spawn("pavucontrol") end),
    awful.button({ }, 3, function() awful.spawn.easy_async("amixer -q set Master toggle",     volume.update) end),
    awful.button({ }, 4, function() awful.spawn.easy_async("amixer -q set Master 5%+ unmute", volume.update) end),
    awful.button({ }, 5, function() awful.spawn.easy_async("amixer -q set Master 5%- unmute", volume.update) end)
))


-- Net                       {{{2
local net = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        id = "wifi",
        widget = wibox.widget.imagebox,
        image = beautiful.widget_wifi,
        visible = false,
    },
    {
        widget = wibox.widget.imagebox,
        image = beautiful.widget_net_down,
    },
    {
        widget = wibox.container.constraint,
        strategy = "min",
        width = 32,
        {
            widget = wibox.container.background,
            fg = beautiful.widget_net_down_fg,
            {
                id = "down",
                widget = wibox.widget.textbox,
                align = "right",
            },
        },
    },
    {
        widget = wibox.widget.imagebox,
        image = beautiful.widget_net_up,
    },
    {
        widget = wibox.container.constraint,
        strategy = "min",
        width = 16,
        {
            widget = wibox.container.background,
            fg = beautiful.widget_net_up_fg,
            {
                id = "up",
                widget = wibox.widget.textbox,
                align = "right",
            },
        },
    },
}

local netinfo = lain.widget.net {
    iface = { "wlp4s6" },
    settings = function()
        -- if iface == "network off" then
        -- end

        local downwidget = net:get_children_by_id("down")[1]
        local upwidget = net:get_children_by_id("up")[1]
        local wifiwidget = net.wifi

        -- TODO: perhaps also try to detect if we have an IP too rather than
        -- just be connected to the network
        if net_now.carrier:match("0") then
            wifiwidget.visible = true
        elseif net_now.carrier:match("1") then
            wifiwidget.visible = false
        end

        downwidget:set_text(("%.0f"):format(net_now.received))
        upwidget:set_text(("%.0f"):format(net_now.sent))
    end
}

-- Memory                    {{{2
local memory = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.imagebox,
        image = beautiful.widget_mem,
    },
    {
        id = "ram",
        widget = wibox.container.background,
        fg = beautiful.widget_mem_ram_fg,
        {
            widget = wibox.widget.textbox,
        },
    },
    {
        id = "swap",
        widget = wibox.container.background,
        fg = beautiful.widget_mem_swap_fg,
        {
            widget = wibox.widget.textbox,
        },
    },
}

local mem_tt = awful.tooltip {
    objects = { memory }
}

local meminfo = lain.widget.mem {
    settings = function()
        local mempercent = (mem_now.used / mem_now.total) * 100
        if mempercent < 10 then
            memory.ram.widget:set_text(("%dMiB"):format(mem_now.used))
        else
            memory.ram.widget:set_text(("%.0f%%"):format(mempercent))
        end

        if mem_now.swap > 0 then
            memory.swap.widget:set_text(
                (" %.0f%%"):format(100 * mem_now.swapused / mem_now.swap))
        end

        mem_tt:set_text(
            ("RAM: %s MB (%s / %s MB)\nSwap: %s MB (%s / %s MB)"):format(
                mem_now.free, mem_now.used, mem_now.total,
                mem_now.swapf, mem_now.swapused, mem_now.swap))
    end
}

-- Music                     {{{2
local music = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.imagebox,
        image = beautiful.widget_mus,
    },
    {
        widget = wibox.container.background,
        fg = beautiful.widget_mus_artist_fg,
        {
            id = "artist",
            widget = wibox.widget.textbox,
        },
    },
    {
        widget = wibox.container.background,
        fg = beautiful.widget_mus_title_fg,
        {
            id = "title",
            widget = wibox.widget.textbox,
        },
    },
}

local musicinfo = require("mpris") {
    settings = function()
        music.visible = mpris_now.state ~= "Stopped"
        if not music.visible then return end

        local artistwidget = music:get_children_by_id("artist")[1]
        local titlewidget = music:get_children_by_id("title")[1]

        artistwidget.visible = false
        if mpris_now.artist ~= "" then
            artistwidget.visible = true
            artistwidget:set_text(mpris_now.artist .. " ")
        end
        titlewidget:set_text(mpris_now.title)
    end
}

-- Date and time             {{{2
os.setlocale(os.getenv("LANG")) -- to localize the clock

local clock = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.imagebox,
        image = beautiful.widget_clock,
    },
    -- FIXME: write as declerative when awesome is updated
    wibox.widget.textclock(
        markup("#7788af", "%a %d %b")
        .. markup("#de5e1e", " %H:%M ")),
}

-- Calendar                  {{{2
local calendar = lain.widget.calendar {
    attach_to = { clock },
}

-- -- Keyboard layout           {{{2
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- -- Power menu                {{{2
-- powermenu = awful.menu { items = {
--         { "lock", "slock" },
--         { "suspend", "systemctl suspend" },
--         { "reboot", "reboot" },
--         { "shutdown", "poweroff" },
--     }
-- }

-- powerwidget = wibox.widget.imagebox(beautiful.widget_power)
-- powerwidget:buttons(awful.util.table.join(
--     awful.button({ }, 1, function (c) powermenu:toggle() end)
-- ))

-- Wibar                {{{1
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Dropdown terminal
    s.quake = lain.util.quake { app = terminal, argname = "-n %s" }

    -- Each screen has its own tag table.
    awful.tag(tagnames, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create a layoutbox which will contains an icon indicating which layout
    -- we're using.  We need one per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              -- if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              -- if client.focus then client.focus:raise() end
                                          end))
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)


    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", height = "20", screen = s })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- left side widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mylayoutbox,
            music,
            separator,
            s.mypromptbox
        },
        s.mytasklist, -- center widget
        { -- right side widgets
            layout = wibox.layout.fixed.horizontal,
            separator,
            wibox.widget.systray(),
            mailicon,
            mail,
            volicon,
            volume,
            net,
            memory,
            clock,
        },
    }

end)

-- Mouse bindings       {{{1
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- These are set from the rules
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Key bindings         {{{1
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ modkey, "Shift"   }, "Left",  function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "Right", function () lain.util.tag_view_nonempty( 1) end,
              {description = "view  next nonempty", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Change gap size
    awful.key({ modkey, "Control" }, "=", function () lain.util.useless_gaps_resize( 1) end,
              {description = "increment useless gaps", group = "tag"}),
    awful.key({ modkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end,
              {description = "decrement useless gaps", group = "tag"}),

    -- Dynamic tagging
    awful.key({ modkey, "Shift"   }, "n",     function () lain.util.add_tag() end,
              {description = "add new tag", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "r",     function () lain.util.rename_tag() end,
              {description = "rename tag", group = "tag"}),
    -- awful.key({ modkey, "Shift"   }, "Left",  function () lain.util.move_tag(-1) end,
    --           {description = "move tag to the left", group = "tag"}),
    -- awful.key({ modkey, "Shift"   }, "Right", function () lain.util.move_tag( 1) end,
    --           {description = "move tag to the right", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "d",     function () lain.util.delete_tag() end,
              {description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- Dropdown application
    awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end,
              {description = "dropdown application", group = "launcher"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Brightness
    -- awful.key({ }, "XF86MonBrightnessUp",   function () awful.util.spawn("xbacklight -inc 10") end,
    --           {description = "brightness +10%", group = "hotkeys"}),
    -- awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 10") end,
    --           {description = "brightness -10%", group = "hotkeys"}),

    -- Media keys
    awful.key({ }, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end,
        {description = "music toggle", group = "media"}),
    awful.key({ }, "XF86AudioStop", function() awful.spawn("playerctl stop") end,
        {description = "music stop", group = "media"}),
    awful.key({ }, "XF86AudioNext", function() awful.spawn("playerctl next") end,
        {description = "music next", group = "media"}),
    awful.key({ }, "XF86AudioPrev", function() awful.spawn("playerctl previous") end,
        {description = "music previous", group = "media"}),

    -- Volume control
    -- TODO: consider some keys to +/-10% volume or such
    awful.key({ }, "XF86AudioMute",
        function () awful.spawn.easy_async("amixer -q set Master toggle",      volume.update) end,
        {description = "toggle mute", group = "media"}),
    awful.key({ }, "XF86AudioRaiseVolume",
        function () awful.spawn.easy_async("amixer -q set Master 1%+ unmute",  volume.update) end,
        {description = "volume up", group = "media"}),
    awful.key({ }, "XF86AudioLowerVolume",
        function () awful.spawn.easy_async("amixer -q set Master 1%- unmute",  volume.update) end,
        {description = "volume down", group = "media"}),
    awful.key({ "Control" }, "XF86AudioRaiseVolume",
        function () awful.spawn.easy_async("amixer -q set Master 100% unmute", volume.update) end,
        {description = "volume 100%", group = "media"}),
    awful.key({ "Control" }, "XF86AudioLowerVolume",
        function () awful.spawn.easy_async("amixer -q set Master 0% unmute",   volume.update) end,
        {description = "volume 0%", group = "media"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

-- These are set from the rules
clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #", group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #", group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #", group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #", group = "tag"})
    )
end

-- Set keys
root.keys(globalkeys)

-- Rules                {{{1
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
                 }
    },

    -- Floating clients.
    { rule_any = {
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer",
          "transmission-gtk",
          "Transmission-gtk",
          "mpv",
        },
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        },
        type = {
            "dialog",
        },
      }, properties = { floating = true }},
}

-- Signals              {{{1
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- No border for maximized clients
-- FIXME: it's kind of buggy since it only updates on focus
client.connect_signal("focus", function(c)
    if c.maximized then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    end
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}1

-- vim:fdm=marker:
