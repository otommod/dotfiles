local P = { }

function P.argquote(arg)
    return "'".. arg:gsub("'", "'\\''") .."'"
end

function P.cmdquote(cmd)
    local args = { }
    for _, a in ipairs(cmd) do
        table.insert(args, P.argquote(a))
    end
    return table.concat(args, ' ')
end

return P
