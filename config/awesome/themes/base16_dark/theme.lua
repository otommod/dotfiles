---------------------------
-- Base16 Default Dark awesome theme --
---------------------------
local awful = require("awful")

theme = {}

theme.confdir       = awful.util.getdir("config")
theme.name          = "base16_dark"
theme.path          = theme.confdir .. "/themes/" .. theme.name

theme.font          = "Anonymous Pro 10"
theme.iconFont      = "Ionicons 10"

-- Base16 colors
theme.base16_base00 = "#151515"
theme.base16_base01 = "#202020"
theme.base16_base02 = "#303030"
theme.base16_base03 = "#505050"
theme.base16_base04 = "#b0b0b0"
theme.base16_base05 = "#d0d0d0"
theme.base16_base06 = "#e0e0e0"
theme.base16_base07 = "#f5f5f5"
theme.base16_base08 = "#ac4142"
theme.base16_base09 = "#d28445"
theme.base16_base0A = "#f4bf75"
theme.base16_base0B = "#90a959"
theme.base16_base0C = "#75b5aa"
theme.base16_base0D = "#6a9fb5"
theme.base16_base0E = "#aa759f"
theme.base16_base0F = "#8f5536"

theme.bg_normal     = theme.base16_base00
theme.bg_focus      = theme.base16_base00
theme.bg_urgent     = theme.base16_base08
theme.bg_minimize   = theme.base16_base03
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = theme.base16_base0B
theme.fg_focus      = theme.base16_base05
theme.fg_urgent     = theme.base16_base01
theme.fg_minimize   = theme.base16_base07

theme.border_width  = 1
theme.border_normal = theme.base16_base00
theme.border_focus  = theme.base16_base02
theme.border_marked = theme.base16_base08

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = theme.path .. "/icons/taglist/sel.png"
theme.taglist_squares_unsel = theme.path .. "/icons/taglist/unsel.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = theme.path .. "/icons/submenu.png"
theme.menu_height = 15
theme.menu_width  = 100

-- {{{ Widgets
theme.widget_bat_fg     = theme.base16_base09
theme.widget_batlow_fg  = theme.bg_urgent
theme.widget_netdown_fg = theme.bg_urgent
theme.widget_netup_fg   = theme.base16_base0D
theme.widget_wifi_fg    = theme.base16_base0D
theme.widget_vol_fg     = theme.base16_base0E
theme.widget_date_fg    = theme.fg_normal
theme.widget_chat_fg    = theme.base16_base0D

theme.widget_mem_ram_fg  = theme.base16_base0A
theme.widget_mem_swap_fg = theme.base16_base09

theme.widget_music_artist_fg = theme.base16_base03
theme.widget_music_title_fg  = theme.base16_base08
-- }}}

-- Define the image to load
theme.titlebar_close_button_normal = theme.path .. "/icons/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = theme.path .. "/icons/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = theme.path .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = theme.path .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = theme.path .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = theme.path .. "/icons/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = theme.path .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = theme.path .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = theme.path .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = theme.path .. "/icons/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = theme.path .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = theme.path .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = theme.path .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = theme.path .. "/icons/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = theme.path .. "/icons/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme.path .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = theme.path .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = theme.path .. "/icons/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
theme.wallpaper = theme.confdir .. "/themes/wallpaper.jpg"

-- You can use your own layout icons like this:
theme.layout_fairh = theme.path .. "/icons/layouts/fairh.png"
theme.layout_fairv = theme.path .. "/icons/layouts/fairv.png"
theme.layout_floating  = theme.path .. "/icons/layouts/floating.png"
theme.layout_magnifier = theme.path .. "/icons/layouts/magnifier.png"
theme.layout_max = theme.path .. "/icons/layouts/max.png"
theme.layout_fullscreen = theme.path .. "/icons/layouts/fullscreen.png"
theme.layout_tilebottom = theme.path .. "/icons/layouts/tilebottom.png"
theme.layout_tileleft   = theme.path .. "/icons/layouts/tileleft.png"
theme.layout_tile = theme.path .. "/icons/layouts/tile.png"
theme.layout_tiletop = theme.path .. "/icons/layouts/tiletop.png"
theme.layout_spiral  = theme.path .. "/icons/layouts/spiral.png"
theme.layout_dwindle = theme.path .. "/icons/layouts/dwindle.png"
theme.layout_termfair = theme.path .. "/icons/layouts/termfair.png"
theme.layout_centerfair = theme.path .. "/icons/layouts/centerfair.png"
theme.layout_cascade = theme.path .. "/icons/layouts/cascade.png"
theme.layout_cascadetile = theme.path .. "/icons/layouts/cascade.png"
theme.layout_centerwork = theme.path .. "/icons/layouts/centerwork.png"
theme.layout_uselessfair = theme.path .. "/icons/layouts/fairv.png"
theme.layout_uselessspiral = theme.path .. "/icons/layouts/spiral.png"
theme.layout_uselesstile = theme.path .. "/icons/layouts/tile.png"

theme.awesome_icon = theme.path .. "/icons/arch.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = elementary

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
