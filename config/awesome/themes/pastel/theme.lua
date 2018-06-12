--
-- Pastel theme
--

local gears = require("gears")
local gfs   = gears.filesystem


local theme                                     = {}
theme.name                                      = "pastel"
theme.confdir                                   = gfs.get_dir("config") .. "themes/" .. theme.name
theme.icondir                                   = theme.confdir .. "/icons/"

theme.font                                      = "xos4 Terminus 8"
theme.bg_normal                                 = "#000000"
theme.bg_focus                                  = "#000000"
theme.bg_urgent                                 = "#af1d18"
theme.fg_normal                                 = "#aaaaaa"
theme.fg_focus                                  = "#ff8c00"
theme.fg_urgent                                 = "#aaaaaa"
theme.fg_minimize                               = "#ffffff"

theme.border_width                              = 1
theme.border_normal                             = "#1c2022"
theme.border_focus                              = "#606060"
theme.border_marked                             = "#3ca4d8"

theme.menu_border_width                         = 0
theme.menu_width                                = 130
theme.menu_submenu_icon                         = theme.icondir .. "submenu.png"
theme.menu_fg_normal                            = "#aaaaaa"
theme.menu_fg_focus                             = "#ff8c00"
theme.menu_bg_normal                            = "#050505dd"
theme.menu_bg_focus                             = "#050505dd"
-- theme.menu_bg_normal                            = "#000000"
-- theme.menu_bg_focus                             = "#000000"

theme.taglist_squares_sel                       = theme.icondir .. "square_a.png"
theme.taglist_squares_unsel                     = theme.icondir .. "square_b.png"

-- Layouts              {{{1
-- theme.tasklist_plain_task_name                  = true
-- theme.tasklist_disable_icon                     = true
theme.useless_gap                               = 0
theme.layout_tile                               = theme.icondir .. "layouts/tile.png"
theme.layout_tilegaps                           = theme.icondir .. "layouts/tilegaps.png"
theme.layout_tileleft                           = theme.icondir .. "layouts/tileleft.png"
theme.layout_tilebottom                         = theme.icondir .. "layouts/tilebottom.png"
theme.layout_tiletop                            = theme.icondir .. "layouts/tiletop.png"
theme.layout_fairv                              = theme.icondir .. "layouts/fairv.png"
theme.layout_fairh                              = theme.icondir .. "layouts/fairh.png"
theme.layout_spiral                             = theme.icondir .. "layouts/spiral.png"
theme.layout_dwindle                            = theme.icondir .. "layouts/dwindle.png"
theme.layout_max                                = theme.icondir .. "layouts/max.png"
theme.layout_fullscreen                         = theme.icondir .. "layouts/fullscreen.png"
theme.layout_magnifier                          = theme.icondir .. "layouts/magnifier.png"
theme.layout_floating                           = theme.icondir .. "layouts/floating.png"

-- Titlebar             {{{1
theme.titlebar_close_button_normal              = theme.icondir .. "titlebar/close_normal.png"
theme.titlebar_close_button_focus               = theme.icondir .. "titlebar/close_focus.png"
theme.titlebar_minimize_button_normal           = theme.icondir .. "titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus            = theme.icondir .. "titlebar/minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive     = theme.icondir .. "titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = theme.icondir .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = theme.icondir .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = theme.icondir .. "titlebar/ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive    = theme.icondir .. "titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = theme.icondir .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = theme.icondir .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = theme.icondir .. "titlebar/sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive  = theme.icondir .. "titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = theme.icondir .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = theme.icondir .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = theme.icondir .. "titlebar/floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = theme.icondir .. "titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme.icondir .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = theme.icondir .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = theme.icondir .. "titlebar/maximized_focus_active.png"

-- Widgets              {{{1
theme.widget_clock                              = theme.icondir .. "widgets/clock.png"

theme.widget_mail                               = theme.icondir .. "widgets/mail.png"
theme.widget_mail_fg                            = "#cccccc"

theme.widget_bat                                = theme.icondir .. "widgets/bat.png"
theme.widget_bat_fg                             = theme.fg_normal

theme.widget_vol                                = theme.icondir .. "widgets/spkr.png"
theme.widget_vol_fg                             = "#7493d2"

theme.widget_net_up                             = theme.icondir .. "widgets/net_up.png"
theme.widget_net_down                           = theme.icondir .. "widgets/net_down.png"
theme.widget_net_up_fg                          = "#e54c62"
theme.widget_net_down_fg                        = "#87af5f"

theme.widget_mem                                = theme.icondir .. "widgets/mem.png"
theme.widget_mem_ram_fg                         = "#e0da37"
theme.widget_mem_swap_fg                        = "#d28445"

theme.widget_mus_off                            = theme.icondir .. "widgets/note.png"
theme.widget_mus                                = theme.icondir .. "widgets/note_on.png"
theme.widget_mus_artist_fg                      = theme.fg_normal
theme.widget_mus_title_fg                       = "#e53c62"

theme.widget_wifi                               = theme.icondir .. "widgets/dish.png"
-- }}}1

return theme
-- vim:fdm=marker:
