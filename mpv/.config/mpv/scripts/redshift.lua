function redshift()
    mp.commandv('run', 'pkill', '-USR1', 'redshift')
end

redshift()
mp.register_event('shutdown', redshift)
