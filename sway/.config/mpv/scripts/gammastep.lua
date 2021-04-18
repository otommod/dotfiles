-- turn gammastep off on startup
mp.commandv("run", "pkill", "-USR2", "-f", "signal-usr-toggle gammastep")

-- and back on on shutdown
mp.register_event("shutdown", function(ev)
    mp.commandv("run", "pkill", "-USR1", "-f", "signal-usr-toggle gammastep")
end)
