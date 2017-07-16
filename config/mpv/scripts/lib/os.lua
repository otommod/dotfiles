local mpv = require('lib.mpv')
local path -- will be set by mkdir if needed
local tablex = require('lib.table')

require('lib.utils').inject('string')


local O = { }

if package.config:startswith('\\') then
    O.name = 'windows'
else
    O.name = 'posix'
end

function O.sleep(n)  -- seconds
    -- warning: clock can eventually wrap around for sufficiently large n
    -- (whose value is platform dependent).  Even for n == 1, clock() - t0
    -- might become negative on the second that clock wraps.
  local t0 = os.clock()
  while os.clock() - t0 <= n do end
end

function O.getcwd()
    return mpv.utils.getcwd()
end

function O.mkdir(p)
    path = path or require('lib.path')

    local args = { 'mkdir', path.join('.', p) }
    if O.name == 'posix' then table.insert(args, 2, '-p') end

    -- TODO: fix this whole stuff
    O.execv(args)
end

function O.execv(cmd, blocking)
    local blocking = blocking or true
    local f = io.popen(O.cmdquote(cmd))
    if blocking then f:read('*all') end
    return f:close()
end


if O.name == 'posix' then
    tablex.merge(O, require('lib.os.posix'))
elseif O.name == 'windows' then
    tablex.merge(O, require('lib.os.windows'))
end

return O
