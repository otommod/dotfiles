local path = require('lib.path')

require('lib.utils').inject('string')


local sep = '\\'
local altsep = '/'
local extsep = '.'

local special_prefixes = { '\\\\.\\', '\\\\?\\' }

local W = {
    sep = sep,
    altsep = altsep,
    extsep = extsep,
}

-- Return whether a path is absolute.
-- Trivial in Posix, harder on Windows.
-- For Windows it is absolute if it starts with a slash or backslash (current
-- volume), or if a pathname after the volume-letter-and-colon or UNC-resource
-- starts with a slash or backslash.
function W.isabs(path)
    _, path = W.splitdrive(path)
    return #path > 0 and path:startswith({sep, altsep})
end

-- TODO: make it correct
function W.validname(filename)
    return filename:find('[/\\:*?"<>|]') == nil
end

---
-- Split a pathname into drive/UNC sharepoint and relative path specifiers.
-- Returns a 2-tuple (drive_or_unc, path); either part may be empty.
--
-- If you assign
--     result = splitdrive(p)
-- It is always true that:
--     result[0] + result[1] == p
--
-- If the path contained a drive letter, drive_or_unc will contain
-- everything up to and including the colon.
--     e.g. splitdrive("c:/dir") returns ("c:", "/dir")
--
-- If the path contained a UNC path, the drive_or_unc will contain the host
-- name and share up to but not including the fourth directory separator
-- character.
--     e.g. splitdrive("//host/computer/dir") returns ("//host/computer", "/dir")
--
-- Paths cannot contain both a drive letter and a UNC path.
function W.splitdrive(path)
    if #path > 1 then
        local normp = path:gsub(altsep, sep)
        if (normp:startswith(sep..sep)) and (normp:sub(3, 3) ~= sep) then
            -- is a UNC path:
            -- vvvvvvvvvvvvvvvvvvvv drive letter or UNC path
            -- \\machine\mountpoint\directory\etc\...
            --           directory ^^^^^^^^^^^^^^^
            local index = normp:find(sep, 3)
            if index == nil then
                return '', path
            end

            local index2 = normp:find(sep, index + 1, true) or #path
            -- a UNC path can't have two slashes in a row
            -- (after the initial two)
            if index2 == index + 1 then
                return '', path
            end
            return path:sub(1, index2-1), path:sub(index2)
        end

        if normp:sub(2, 2) == ':' then
            return path:sub(1, 2), path:sub(3)
        end
    end
    return '', path
end


function W.split(path)
    local d, p = W.splitdrive(path)

    local i = #p+1
    while i > 1 and (p:sub(i-1, i-1) ~= sep and p:sub(i-1, i-1) ~= altsep) do
        i = i - 1
    end

    local head, tail = p:sub(1, i-1), p:sub(i)
    local head2 = head
    while #head2 > 1 and (head2:sub(-1, -1) == sep or head2:sub(-1, -1) == altsep) do
        head2 = head2:sub(1, -2)
    end

    if #head2 > 0 then head = head2 end
    return d .. head, tail
end

function W.dirname(path)
    local dir, _ = W.split(path)
    return dir
end

function W.basename(path)
    local _, file = W.split(path)
    return file
end

-- Expand paths beginning with '~' or '~user'.
-- '~' means $HOME; '~user' means that user's home directory.
-- If the path doesn't begin with '~', or if the user or $HOME is unknown,
-- the path is returned unchanged (leaving error reporting to whatever
-- function is called with the expanded path as argument).
-- See also module 'glob' for expansion of *, ? and [...] in pathnames.
-- (A function should also be defined to do full *sh-style environment
-- variable expansion.)
function W.expanduser(path)
    path = path or '~'

    if not path:startswith('~') then
        return path
    end

    local i = math.min(path:find('/',  1, true) or #path,
                       path:find('\\', 1, true) or #path)

    local userhome = os.getenv('HOME') or os.getenv('USERPROFILE')
    if not userhome then
        if not os.getenv('HOMEPATH') then
            return path
        else
            userhome = path.join(os.getenv('HOMEDRIVE') or '',
                                     os.getenv('HOMEPATH'))
        end
    end

    if i > 2 then  -- ~user
        userhome = path.join(W.dirname(userhome), path:sub(2, i-1))
    end

    return userhome .. path:sub(i)
end

-- Normalize a path, e.g. A//B, A/./B and A/foo/../B all become A\B.
-- Previously, this function also truncated pathnames to 8+3 format,
-- but as this module is called "ntpath", that's obviously wrong!
function W.normpath(path)
    if path:startswith(special_prefixes) then
        -- in the case of paths with these prefixes:
        -- \\.\ -> device names
        -- \\?\ -> literal paths
        -- do not do any normalization, but return the path unchanged
        return path
    end

    local prefix, path = W.splitdrive(path:gsub(altsep, sep))
    -- collapse initial backslashes
    if path:startswith(sep) then
        prefix = prefix .. sep
        path = path:lstrip(sep)
    end

    local comps, i = path:split(sep), 1
    while i <= #comps do
        if comps[i] == '' or comps[i] == '.' then
            table.remove(comps, i)
        elseif comps[i] == '..' then
            if i > 1 and comps[i-1] ~= '..' then
                table.remove(comps, i-1)
                table.remove(comps, i)
                i = i-1
            elseif i == 1 and prefix:endswith(sep) then
                table.remove(comps, i)
            else
                i = i+1
            end
        else
            i = i+1
        end
    end

    -- If the path is now empty, substitute '.'
    if #prefix == 0 and #comps == 0 then
        table.insert(comps, '.')
    end

    return prefix .. table.concat(comps, sep)
end

return W
