local mpv = require('mp')
mpv.utils = require('mp.utils')
mpv.assdraw = require('mp.assdraw')
              require('mp.options')

local tablex = require('lib.table')
local utils = require('lib.utils')


local M = { }

local function parse_subparam(str, i)
    local c, r = str:sub(i, i)
    local s, e

    if c == '"' then
        i = i + 1
        s, e = str:find('"', i)
    elseif c == '[' then
        i = i + 1
        s, e = str:find(']', i)
    else
        s, e = str:find('[:=,\"\'\\[%]%%]', i)
        if not e then e = #str+1 end
    end

    if e then
        return e, str:sub(i, e-1)
    else
        return nil
    end
end

local function parse_list_opt(str)
    local list = { }
    local i, r = 0

    while i < #str do
        i, r = parse_subparam(str, i+1)
        if not i then break end
        table.insert(list, r)
    end

    return list
end


M.get = function(name, type_, def)
    local funcs = {
        string = mpv.get_property,
        osd    = mpv.get_property_osd,
        bool   = mpv.get_property_bool,
        number = mpv.get_property_number,
        native = mpv.get_property_native
    }
    return funcs[type_ or 'native'](name, def)
end

M.set = mpv.set_property_native
M.do_ = mpv.commandv
M.run = function(...) return M.do_('run', ...) end
M.show = function(...)
    return M.do_('expand-properties', 'show_text', ...)
end

function M.parse_vars(str, replacement)
    return utils.parse_vars(str, '$(%b{})', function(s)
        local prop = s:strip('{}')
        local value = replacement(prop)

        if value == nil then  -- property not provided by user, ask mpv
            local val, err = M.get(prop, 'string')
            if err then value = val else value = nil end
        end

        return value or s
    end)
end


M.utils = { }
M.assdraw = { }
M.options = { }
tablex.merge(M, mpv)
tablex.merge(M.utils, mpv.utils)
tablex.merge(M.assdraw, mpv.assdraw)
tablex.merge(M.options, { read = read_options,
                          parse_list = parse_list_opt})

return M
