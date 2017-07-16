local osx = require('lib.os')
local mpv = require('lib.mpv')
local tablex = require('lib.table')


local P = { }

function P.exists(name)
    local file = io.open(name, "r")

    if file == nil then
        return false
    else
        file:close()
        return true
    end
end

function P.join(p1, p2)
    return mpv.utils.join_path(p1, p2)
end

function P.splitext(path)
    sep_i = path:rfind(P.sep) or 0
    if P.altsep then
        altsep_i = path:rfind(P.altsep)
        sep_i = math.max(sep_i, altsep_i)
    end

    dot_i = path:rfind(P.extsep) or 0
    if dot_i > sep_i then
        -- skip all leading dots
        file_i = sep_i + 1
        while file_i < dot_i do
            if path:sub(file_i, file_i) ~= extsep then
                return path:sub(1, dot_i-1), path:sub(dot_i)
            end
            file_i = file_i + 1
        end
    end

    return path, ''
end

function P.ensuredir(dir)
    if not P.exists(dir) then
        osx.mkdir(dir)
    end
    if not P.exists(dir) then
        -- Directory still doesn't exists.
        -- We probably couldn't create it due to permissions.
        return false
    end
    return true
end

function P.validname(filename)
    -- This is wrong.  On Windows there is a ton of reserved characters,
    -- filenames and other restrictions.
    -- TODO: fix this
    return filename:find(P.sep) == nil
end

if osx.name == 'posix' then
    tablex.merge(P, require('lib.path.posix'))
elseif osx.name == 'windows' then
    tablex.merge(P, require('lib.path.windows'))
end

return P
