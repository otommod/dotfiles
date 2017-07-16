require('lib.utils').inject('string')

local sep = '/'
local altsep = nil
local extsep = '.'

local P = {
    sep = sep,
    altsep = altsep,
    extsep = extsep,
}

function P.isabs(path)
    return path:startswith(sep)
end


function P.splitdrive(path)
    return '', path
end


function P.basename(path)
    local i = path:rfind(sep) or 1
    return path:sub(i+1)
end

function P.dirname(path)
    local i = path:rfind(sep) or 1
    local head = path:sub(1, i)
    if head ~= '' and head ~= sep:rep(#head) then
        head = head:rstrip(sep)
    end
    return head
end


function P.expanduser(path)
    if not path:startswith('~') then
        return path
    end

    local i, userhome = path:find(sep, 2) or #path
    if i == 2 then
        userhome = os.getenv('HOME')
    else  -- ~user  we can't handle that in lua
        -- local name = path:sub(2, i-1)
        return path
    end

    return (userhome:rstrip('/') .. path:sub(i)) or '/'
end

function P.normpath(path)
    if path == '' then
        return '.'
    end

    local initial_slashes = path:startswith(sep) and 1
    -- POSIX allows one or two initial slashes, but treats three or more
    -- as a single slash.
    if (initial_slashes
            and path:startswith(sep..sep)
            and not path:startswith(sep..sep..sep)) then
        initial_slashes = 2
    end

    local comps, new_comps = path:split(sep), { }
    for _, comp in ipairs(comps) do
        if comp ~= '' and comp ~= '.' then
            if (comp ~= '..'
                    or (not initial_slashes and #new_comps == 0)
                    or (#new_comps > 0 and new_comps[-1] == '..')) then
                table.insert(new_comps, comp)
            elseif #new_comps > 0 then
                table.remove(new_comps)
            end
        end
    end

    comps = new_comps
    path = table.concat(comps, sep)
    if initial_slashes then
        path = sep:rep(initial_slashes) .. path
    end

    if #path > 0 then return path else return '.' end
end

return P
