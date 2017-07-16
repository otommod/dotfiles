local W = { }

-- Also see:
--   http://blogs.msdn.com/b/twistylittlepassagesallalike/archive/2011/04/23/
--          everyone-quotes-arguments-the-wrong-way.aspx

function W.argquote(arg, force)
--[[
Routine Description:
    This routine appends the given argument to a command line such
    that CommandLineToArgvW will return the argument string unchanged.
    Arguments in a command line should be separated by spaces; this
    function does not add these spaces.

Arguments:
    @argument - Supplies the argument to encode.
    @force - Supplies an indication of whether we should quote
            the argument even if it does not contain any characters that would
            ordinarily require quoting.

Return Value:
    None.
]]
    if (not force and #arg > 0 and arg:find('[ \t\n\v"]') == nil) then
        -- Don't quote unless we have to or are forced to.  Hopefully avoids
        -- problems if programs can't parse quotes property.
        return arg
    end

    local i = 1
    local cmdline = '"'
    while i < #arg + 1 do
        local backslashes = 0

        while arg:sub(i, i) == '\\' do
            i = i + 1
            backslashes = backslashes + 1
        end

        char = arg:sub(i, i)
        if i == #arg + 1 then
            -- Escape all backslashes, but let the terminating double quote
            -- we add below be interpreted as a metacharacter.
            cmdline = cmdline .. ('\\'):rep(backslashes * 2)
        elseif char == '"' then
            -- Escape all backslashes and the double quote that follows.
            cmdline = cmdline .. ('\\'):rep(backslashes * 2 + 1)
            cmdline = cmdline .. char
        else
            -- Backslashes aren't special here.
            cmdline = cmdline .. ('\\'):rep(backslashes)
            cmdline = cmdline .. char
        end
        i = i + 1
    end

    return cmdline .. '"'
end

function W.cmdquote(cmd)
    local args = { }
    for _, a in ipairs(cmd) do
        table.insert(args, W.argquote(a))
    end
    return '"'.. table.concat(args, ' ') ..'"'
end

return W
