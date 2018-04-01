require "transmission"
require "strict"

-- The logic is mostly taken from tr_formatter_speed_KBps, what transmission
-- uses to display its speeds.
function humanize_Bps(speed)
    local K = 1000
    local M = 1000*K
    local speed = speed / K

    if speed <= 999.95 then -- 0.0 kB to 999.9 kB
        return string.format("%d kB/s", math.floor(speed))
    elseif speed <= 99995 then -- 0.98 MB to 99.99 MB
        return string.format("%.2f MB/s", speed / K)
    elseif speed <= 999950 then -- 100.0 MB to 999.9 MB
        return string.format("%.1f MB/s", speed / K)
    else
        return string.format("%.1f GB/s", speed / M)
    end
end

function trunc(s, w)
    local floor, ceil = math.floor(w/2), math.ceil(w/2)
    if #s <= w then return s end
    return s:sub(1, ceil) .. "…" .. s:sub(-floor + 1)
end


-- ${lua_bar} takes a function that should return a number.  Even if we have a
-- number already, it still needs a function.  This is that function, just a
-- tonumber (since we must return a number).
function conky_tonumber(x)
    return tonumber(x)
end

function conky_torrents()
    local torrents = transmission:get({"id", "name", "status", "percentDone",
                                       "rateDownload", "rateUpload"})

    -- from FontAwesome
    local icons = {
        ["check"] = "",
        ["check-wait"] = "",
        -- ["download"] = "",
        -- ["download-wait"] = "",
        ["download"] = "",
        ["download-wait"] = "",
        -- ["seed"] = "",
        -- ["seed-wait"] = "",
        ["seed"] = "",
        ["seed-wait"] = "",
        -- ["stopped"] = "",
        -- ["stopped"] = "",
        ["stopped"] = "",
    }

    local out = { }
    for _, t in ipairs(torrents) do
        if t.status == "download" or t.status == "download-wait" then
            local percent = math.floor(100 * t.percentDone)

            table.insert(out, (""
                .. "${goto 25}${font FontAwesome-8}" .. icons[t.status] .. "${font}"
                .. "${goto 40}${color5}" .. trunc(t.name, 28)
                .. "${color2}"
                .. "${goto 230}↓" .. humanize_Bps(t.rateDownload)
                .. "${goto 300}↑" .. humanize_Bps(t.rateUpload)
                -- .. "${goto 250}${color5}${lua_bar 10,0 tonumber " .. percent .. "}"
                -- .. "${offset -40}${color2}" .. percent .. "%"
            ))
        end
    end

    return table.concat(out, "\n")
end


-- We create one (global) Transmission client
transmission = Transmission.new("http://localhost:9091/transmission/rpc")
