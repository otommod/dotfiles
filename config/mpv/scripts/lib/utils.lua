local tablex = require('lib.table')


local function find_first(str, patterns, start)
    local cs, ce, cm = #str + 1, 0, { }

    for _, pat in ipairs(patterns) do
        local t = table.pack(str:find(pat, start))
        -- there may be more than on matches
        local s, e, m = table.remove(t, 1), table.remove(t, 1), t

        if s and s <= cs then
            cs, ce, cm = s, e, m
        end
    end

    if cs == #str + 1 then
        return nil
    else
        return cs, ce, cm
    end
end


local U = { }

function U.inject(pkgs)
    if not pkgs then return end
    if type(pkgs) == "string" then pkgs = { pkgs } end

    for _, pkg in ipairs(pkgs) do
        tablex.merge(_G[pkg], require('lib.'..pkg))
    end
end


function U.parse_vars(str, pattern, replacement)
    if type(replacement) == 'string' then
        replacement = function() return replacement end
    end
    if type(pattern) == 'string' then
        pattern = { pattern }
    end

    local function find(start)
        if type(pattern) == 'function' then
            return pattern(str, start)
        end

        return find_first(str, pattern, start)
    end

    local end_, start, match = find(0)
    local ret = str:sub(1, (end_ or #str+1) - 1)

    local last_end = #str + 1
    while end_ do
        last_end = end_
        start, end_, match = find(end_)

        if end_ then
            end_ = end_ + 1
            ret = ret .. str:sub(last_end, start-1)
            ret = ret .. replacement(table.unpack(match))
        end
    end

    return ret .. str:sub(last_end, #str)
end


function U.format_time(time, force_mins, force_hours)
    local seconds, milliseconds = math.modf(math.abs(time))
    local minutes, seconds = seconds / 60, seconds % 60
    local hours, minutes = minutes / 60, minutes % 60
    local formated = ''

    if hours >= 1 or force_hours then
        formated = formated .. string.format('%02d:%02d:', hours, minutes)
    elseif minutes >= 1 or force_mins then
        formated = formated .. string.format('%02d:', minutes)
    end
    formated = formated .. string.format('%02d', seconds)
    formated = formated .. string.format('%.3f', milliseconds):sub(2)

    return formated
end

return U
