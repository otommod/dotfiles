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

local lain = require("lain")
lain.helpers = require("lain.helpers")

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
local config_dir = gears.filesystem.get_dir("config")

-- Themes define colours, icons, font and wallpapers.
beautiful.init(config_dir .. "themes/base16_dark/theme.lua")
beautiful.wallpaper = "/home/otto/Pictures/Gare_de_Lyon_TGV_Sud-Est.jpg"

-- This is used later as the default terminal and editor to run.
terminal = "st"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- You can use another modifier like Mod1, but it may mess with other programs.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- Helper functions     {{{1
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

-- Wibar                {{{1
-- Separators                {{{2
spacer    = wibox.widget.textbox("  ")
separator = wibox.widget.textbox(" | ")

-- Power menu                {{{2
powermenu = awful.menu({ items = {
    { "lock", "slock" },
    { "suspend", "systemctl suspend" },
    { "reboot", "reboot" },
    { "shutdown", "poweroff" }
  }
})

-- powerwidget = wibox.widget.textbox()
-- powerwidget:set_markup(lain.util.markup.fontfg(beautiful.iconFont, beautiful.fg_focus, ""))
-- powerwidget:buttons(awful.util.table.join(
--     awful.button({ }, 1, function (c) powermenu:toggle() end)
-- ))

-- Memory usage              {{{2
memory = lain.widget.mem {
    settings = function()
        local text = lain.util.markup.font(beautiful.iconFont, "")
        local mempercent = (mem_now.used / mem_now.total) * 100
        if mempercent < 10 then
            text = text .. (" %dMiB"):format(mem_now.used)
        else
            text = text .. (" %.0f%%"):format(mempercent)
        end
        text = lain.util.markup(beautiful.widget_mem_ram_fg, text)

        if mem_now.swap ~= 0 then
            text = text .. " " .. lain.util.markup(
                beautiful.widget_mem_swap_fg,
                ("%.0f%%"):format(100 * mem_now.swapused / mem_now.swap))
        end

        widget:set_markup(text)
    end
}

local memnotification
memory.widget:connect_signal("mouse::enter", function()
    memnotification = naughty.notify({
        text = ("RAM: %s MB (%s / %s MB)\nSwap: %s MB (%s / %s MB)"):format(
            mem_now.free, mem_now.used, mem_now.total,
            mem_now.swapf, mem_now.swapused, mem_now.swap),
        position = "top_right",
        timeout = 0
    })
end)
memory.widget:connect_signal("mouse::leave", function()
    if (memnotification ~= nil) then
        naughty.destroy(memnotification)
        memnotification = nil
    end
end)

-- Volume                    {{{2
volume = lain.widget.alsa {
    timeout = 2,
    settings = function()
        local icons = {
            [100] = "", [50] = "", [0] = ""
        }

        local seen = true, icon
        local volnum = tonumber(volume_now.level) or 0
        if volnum == 0 or volume_now.status == 'off' then
            icon = lain.util.markup.font(beautiful.iconFont, icons[0])
        elseif volnum == 100 then
            -- if volume is 100% no need to show it
            seen = false
        elseif volnum > 50 then
            icon = lain.util.markup.font(beautiful.iconFont, icons[100])
        elseif volnum > 0 then
            icon = lain.util.markup.font(beautiful.iconFont, icons[50])
        end

        if seen then
            widget:set_markup(lain.util.markup(
                beautiful.widget_vol_fg, icon .. " " .. volume_now.level .. "%  "))
        else
            widget:set_markup("")
        end
    end
}

volume.widget:buttons(awful.util.table.join(
    awful.button({ }, 3, function() awful.spawn("amixer -q set Master toggle"); volume:update() end),
    awful.button({ }, 4, function() awful.spawn("amixer -q set Master 5%+ unmute"); volume:update() end),
    awful.button({ }, 5, function() awful.spawn("amixer -q set Master 5%- unmute"); volume:update() end)
))

-- Music                     {{{2
-- musicwidget = lain.widget.abase({
--     timeout = 2,
--     cmd = "cat /tmp/music-info",
--     settings = function()
--         local icons = {
--             playing = "", paused = "", stopped = "",
--         }
--         icons = map(function(i)
--             return ('<span font="%s" color="%s">%s</span>'):format(
--                 beautiful.iconFont, beautiful.widget_music_title_fg, i)
--         end, icons)

--         local state = output:match("(%w*) ")
--         if not state then
--             return
--         end

--         local artist, title = output:match("([^-]*) %- (.*)$", state:len() + 2)

--         if not title then
--             title = output:sub(state:len() + 2)
--         end
--         title = lain.util.markup.fg.color(beautiful.widget_music_title_fg,
--                                           awful.util.escape(title))

--         if artist then
--             artist = lain.util.markup.fg.color(beautiful.widget_music_artist_fg,
--                                                awful.util.escape(artist)) .. " "
--         end

--         state = (icons[state] or "") .. " "
--         widget:set_markup(state .. (artist or "") .. title)
--     end
-- })

-- Wireless                  {{{2
wifi = lain.widget.net {
    iface = { "wlp4s6" },
    settings = function()
        -- TODO: perhaps also try to detect if we have an IP too rather than
        -- just be connected to the network

        if net_now.carrier:match("0") then
            widget:set_markup(lain.util.markup.fontfg(
                beautiful.iconFont, beautiful.widget_wifi_fg, "") .. "  ")
        elseif net_now.carrier:match("1") then
            widget:set_markup("")
        end
    end
}

-- Date and time             {{{2
dateicon = wibox.widget.textbox(("<span font='%s'></span> "):format(beautiful.iconFont))
datewidget = wibox.widget.textclock("%a %d %b  %R ")
lain.widget.calendar {
    attach_to = { datewidget }
}
-- lain.widget.calendar:attach(datewidget, { icons = '', font = beautiful.font, font_size = 10 })

-- }}}2

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

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

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
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
            spacer,
            s.mylayoutbox,
            s.mypromptbox
        },
        s.mytasklist, -- center widget
        { -- right side widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            -- spacer,
            -- musicwidget,
            spacer,
            volume,
            -- spacer,
            wifi,
            -- spacer,
            memory,
            spacer,
            dateicon,
            datewidget,
            -- spacer,
            -- powerwidget,
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

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

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
              {description = "show the menubar", group = "launcher"}),

    -- Media keys
    awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end, {description = ""}),
    awful.key({}, "XF86AudioStop", function() awful.spawn("playerctl stop") end, {description = ""}),
    awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next") end, {description = ""}),
    awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous") end, {description = ""})
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
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
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
                  {description = "move focused client to tag #"..i, group = "tag"}),
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
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
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
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
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

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}1

-- vim:fdm=marker:
