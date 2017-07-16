local S = { }

local function _char_set(chars, exclude, plain)
    if plain then
        local subs

        chars:gsub('%^', '%%^')
        chars, subs = chars:gsub('%%', '')
        if subs > 0 then chars = chars..'%%' end
    end

    exclude = (exclude and '^') or ''
    chars = chars:gsub(']', '%%]')
    return '['..exclude.. chars ..']'
end

local function _contains(str, sub, start, end_, condition)
    start = start or 1
    end_ = end_ or #str

    if type(sub) == "string" then sub = { sub } end
    for _, p in ipairs(sub) do
        if condition(p, start, end_) then
            return true
        end
    end
    return false
end

local function _strip(str, chars, left, right)
    chars = _char_set(chars or '%s') .. '*'

    if left  then str = str:gsub('^'..chars, '') end
    if right then str = str:gsub(chars..'$', '') end

    return str
end


function S.startswith(str, prefix, start, end_)
    return _contains(str, prefix, start, end_,
        function(p, start, end_)
            local s, e = str:find(p, start, true)
            return s == start and e <= end_
        end)
end

function S.endswith(str, suffix, start, end_)
    return _contains(str, suffix, start, end_,
        function(p, start, end_)
            local s, e = str:find(p, end_ - #p + 1, true)
            return e == end_ and s >= start
        end)
end


function S.rfind(str, sub)
    local i = str:reverse():find(sub, 1, true)
    if not i then return nil end
    return (#str - i + 1)
end


function S.lstrip(str, chars)
    return _strip(str, chars,  true, false)
end

function S.rstrip(str, chars)
    return _strip(str, chars, false,  true)
end

function S.strip(str, chars)
    return _strip(str, chars,  true,  true)
end


function S.split(str, sep, splits)
        local fields = { }
        sep = '('.. _char_set(sep or '%s', true) ..'+)'
        str:gsub(sep, function(c) fields[#fields+1] = c end, splits)
        return fields
end


function S.rjust(str, width, char)
    char = char or ' '
    str = char:rep(width) .. str

    return str:sub(-width)
end

function S.ljust(str, width, char)
    char = char or ' '
    str = str .. char:rep(width)

    return str:sub(1, width)
end


function S.eatstart(str, start, plain)
    local f = table.pack(str:find(start, 1, plain))
    local s, e, m = table.remove(f, 1), table.remove(f, 1), f

    if s == 1 then
        return true, str:sub(e+1), table.unpack(m)
    else
        return false, str
    end
end


local Ss = { }
local old_format = string.format
function Ss.format(str, ...)
    local utils = require('lib.utils')

    local args = { ... }
    local outargs, num = { }, 1
    local has_numbered, has_unnumbered = false, false

    fmt = utils.parse_vars(str, '%%(.-)([AaEefGgcdiouXxsq])', function(f, c)
        local _, params, initial_percents = S.eatstart(f, '%%*()')

        initial_percents = initial_percents or 1
        if initial_percents % 2 == 0 then
            return '%' .. f .. c
        end
        local prefix = ('%'):rep(initial_percents)

        params = utils.parse_vars(params, {'*', '%*(%d+)%$'}, function(s)
            local a

            if not s then
                -- we caught a lone *
                a = args[num]
                num = num + 1
                has_unnumbered = true
            else
                a = args[tonumber(s)]
                has_numbered = true
            end

            if type(a) ~= 'number' then
                error('Cannot use non-numbers as fields')
            end

            return a
        end)

        local b, params, a = S.eatstart(params, '(%d+)%$')
        if a then has_numbered = true else has_unnumbered = true end
        table.insert(outargs, args[tonumber(a or num)])

        if has_numbered and has_unnumbered then
            error("Cannot mix numbered and unnumbered")
        end

        num = num + 1
        return prefix .. params .. c
    end)

    return old_format(fmt, table.unpack(outargs))
end

return S
