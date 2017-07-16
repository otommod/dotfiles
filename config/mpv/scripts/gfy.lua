-- Imports              {{{1
local osx = require('lib.os')
local mpv = require('lib.mpv')
local utils = require('lib.utils')
local tablex = require('lib.table')


-- Helper functions     {{{1
local function cur_pos()
    return mpv.get('playback-time/full') or 0
end


-- Classes              {{{1
local RecordingWidget = {}   -- {{{2
RecordingWidget.__index = RecordingWidget

function RecordingWidget.new(...)
    local self = setmetatable({}, RecordingWidget)

    tablex.merge(self, self:init(...))

    return self
end

function RecordingWidget.init(self, x, y)
    return {
        x = x,
        y = y,
        start = cur_pos(),
        timer = nil,
    }
end

function RecordingWidget.move(self, new_x, new_y)
    self.x = new_x
    self.y = new_y
end

function RecordingWidget.recording_time(self)
    return utils.format_time(cur_pos() - self.start)
end

function RecordingWidget.submit(ass)
    local width, height = 1280, 720
    mpv.set_osd_ass(width, height, ass.text)
end

function RecordingWidget.draw(self)
    local sign
    local x, y = self.x, self.y
    local text, circle = mpv.assdraw.ass_new(),
                         mpv.assdraw.ass_new()
    local start, rec_time = utils.format_time(self.start),
                            self:recording_time()

    if self.start <= cur_pos() then
        sign = '+'
    else
        sign = '-'
    end

    text:an(3)                         -- left-justified text
    text:pos(x, y)

    text:append('{\\r\\fs20}')         -- font size 20
    text:append(("%s\\N"):format(start))
    text:append(("%s %s"):format(sign,
        rec_time:rjust(math.max(#rec_time, #start))))  -- #str + a space

    circle:an(3)                       -- left-justified text
    circle:pos(x - (#start*10 + 5), y - 10)

    circle:append('{\\bord0}')         -- no border
    circle:append('{\\c&H0000FF&}')    -- red; in <BBGGRR>
    circle:append("●")

    circle:new_event()
    circle:merge(text)
    self.submit(circle)
end

function RecordingWidget.show(self)
    self:destroy()
    self.timer = mpv.add_periodic_timer(0.005, function() self:draw() end)
end

function RecordingWidget.destroy(self)
    if self.timer then self.timer:kill() end
    self.submit({ text = "" })
end


local GFYRecorder = { }      -- {{{2
GFYRecorder.__index = GFYRecorder

function GFYRecorder.new(...)
    local self = setmetatable({}, GFYRecorder)

    tablex.merge(self, self:init(...))

    return self
end

function GFYRecorder.init(self)
    return {
        st = nil,  -- start time
        et = nil,  -- end time
        recording = false,
        widget = RecordingWidget.new(1190, 110),
    }
end

function GFYRecorder.write(self, file)
    osx.execv({"mpv", "--start="..self.st, "--end="..self.et,
               "--profile=anime-gfy",
               mpv.get("path"),        -- currect playing file
               "-o="..file},           -- output file
              true)
end

function GFYRecorder.start(self, time)
    self:cancel()

    self.recording = true
    self.st = tonumber(time) or cur_pos()

    self.widget.start = self.st
    self.widget:show()
end

function GFYRecorder.finish(self, time)
    self.recording = false
    self.et = tonumber(time) or cur_pos()

    self.widget:destroy()
end

function GFYRecorder.cancel(self)
    self.st = nil
    self.et = nil
    self.recording = false
    self.widget:destroy()
end


-- Exports              {{{1
return {
    RecordingWidget = RecordingWidget,
    GFYRecorder = GFYRecorder
}
