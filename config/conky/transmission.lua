local json = require("json")
local http = require("socket.http")
local ltn12 = require("ltn12")


-- local Transmission = {}
Transmission = {}
Transmission.__index = Transmission

function Transmission.new(...)
    local self = setmetatable({}, Transmission)
    self:init(...)
    return self
end

function Transmission.init(self, url, ...)
    -- TODO: authentication
    self.url = url
    self.session_id = nil
end

function Transmission.call(self, method, ...)
    local jsonRequest = json.encode {
        ["method"] = method,
        ["arguments"] = ...,
    }

    local headers = {
        ["content-type"] = "application/json",
        ["content-length"] = string.len(jsonRequest),
        ["x-transmission-session-id"] = self.session_id,
    }

    local resultChunks = {}
    local _, code, respHeaders, status = http.request {
        ["url"] = self.url,
        ["method"] = "POST",
        ["headers"] = headers,
        ["source"] = ltn12.source.string(jsonRequest)
        ["sink"] = ltn12.sink.table(resultChunks),
    }
    local response = table.concat(resultChunks)

    if code == 409 then
        -- We had not set X-Transmission-Session-Id or it expired; retry with the new one
        self.session_id = respHeaders["x-transmission-session-id"]
        return self:call(method, ...)
    elseif code ~= 200 then
        -- HTTP error
        return nil, status
    end

    local result = json.decode(response)
    if result.result ~= "success" then
        return nil, result.result
    end

    return result.arguments
end

function Transmission.get(self, fields)
    local resp, err = self:call("torrent-get", { fields = fields })
    if err ~= nil then
        return nil, err
    end
    local torrents = resp.torrents

    -- Transmission uses an enum to represent a torrent's status and
    -- (unfortunately) that is also what it sents to us.
    -- Source: libtransmission/transmission.h
    local status_translate = {
        [0] = "stopped",        -- Torrent is stopped
        [1] = "check-wait",     -- Queued to check files
        [2] = "check",          -- Checking files
        [3] = "download-wait",  -- Queued to download
        [4] = "download",       -- Downloading
        [5] = "seed-wait",      -- Queued to seed
        [6] = "seed",           -- Seeding
    }

    for _, f in ipairs(fields) do
        if f == "status" then
            for _, t in ipairs(torrents) do
                t.status = status_translate[t.status]
            end
        end
    end
    return torrents
end
