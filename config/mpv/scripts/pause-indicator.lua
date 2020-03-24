local options = require("mp.options")
local assdraw = require("mp.assdraw")

local settings = {
    -- Acts as a multiplier to increase the size of every UI element. Useful for
    -- high-DPI displays that cause the UI to be rendered too small (happens at
    -- least on macOS).
    ["display-scale-factor"] = 1,

    -- Controls how long the UI animations take. A value of 0 disables all
    -- animations (which breaks the pause indicator).
    ["animation-duration"] = 0.2,
}
options.read_options(settings)

local state = {
    timer = nil,
    anistart = nil,
    paused = false,
    framestep = false,
}

local function scale_value(x0, x1, y0, y1, val)
    local m = (y1 - y0) / (x1 - x0)
    local b = y0 - (m * x0)
    return (m * val) + b
end

local function ass_circle_cw(ass, x, y, r)
    -- http://spencermortensen.com/articles/bezier-circle/
    -- We transform the coordinates so that the left-most point lies on
    -- (0,0); that way the center is actually in the center with \an5
    x = x + r
    y = y + r

    local c = 0.551915024494 * r
    ass:move_to(x, y+r)
    ass:bezier_curve(x+c, y+r, x+r, y+c, x+r, y)
    ass:bezier_curve(x+r, y-c, x+c, y-r, x, y-r)
    ass:bezier_curve(x-c, y-r, x-r, y-c, x-r, y)
    ass:bezier_curve(x-r, y+c, x-c, y+r, x, y+r)
end

local function tick()
    local now = mp.get_time()
    local aniend = state.anistart + settings["animation-duration"]

    if now > aniend then
        state.timer:kill()
        mp.set_osd_ass(0, 0, "")
        return
    end

    local screenW, screenH = mp.get_osd_size()
    local osdScale = settings["display-scale-factor"]
    local w = math.floor(screenW / osdScale) / 2
    local h = math.floor(screenH / osdScale) / 2

    local alpha = scale_value(state.anistart, aniend, 0, 192, now)
    local scale = scale_value(state.anistart, aniend, 64, 128, now)

    local ass = assdraw.ass_new()

    ass:pos(w, h)
    ass:an(5)
    ass:append("{\\blur0\\bord0\\1c&H000000&}")
    ass:append(("{\\fscx%g\\fscy%g}"):format(scale, scale))
    ass:append(("{\\alpha&H%02X}"):format(alpha+63))
    ass:draw_start()
    ass_circle_cw(ass, 0, 0, 40)
    ass:draw_stop()

    ass:new_event()
    ass:pos(w, h)
    ass:an(5)
    ass:append("{\\blur0\\bord0\\1c&HFFFFFF&\\fs42\\fnmpv-osd-symbols}")
    ass:append(("{\\fscx%g\\fscy%g}"):format(scale, scale))
    ass:append(("{\\alpha&H%02X}"):format(alpha))
    if state.paused then
        ass:append("\238\128\130")
    else
        ass:append("\238\132\129")
    end

    mp.set_osd_ass(screenW, screenH, ass.text)
end

mp.observe_property("pause", "bool", function(event, paused)
    state.paused = paused
    if state.framestep then
        state.framestep = not paused
        return
    end

    state.anistart = mp.get_time()
    if state.timer then
        state.timer:resume()
    else
        state.timer = mp.add_periodic_timer(0.03, tick)
    end
end)

mp.add_key_binding(".", "step-forward", function()
    state.framestep = true
    return mp.commandv("frame-step")
end, {
    repeatable = true
})

mp.add_key_binding(",", "step-backward", function()
    state.framestep = true
    return mp.commandv("frame-back-step")
end, {
    repeatable = true
})

-- mp.register_event('playback-restart', function()
--     state.framestep = false
-- end)
