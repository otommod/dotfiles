function map(func, array)  -- {{{2
    local new_array = {}
    for i, v in ipairs(array) do
        new_array[i] = func(v)
    end
    return new_array
end


function starmap(func, array)
    return map(function(a) return func(table.unpack(a)) end, array)
end


function keybind(key_, action, debug)
    local MODSMAP = {
        S = "Shift",
        C = "Control",
        A = "Alt",
        M = modkey,

        M1 = "Mod1",
        M2 = "Mod2",
        M3 = "Mod3",
        M4 = "Mod4",
        M5 = "Mod5",
    }

    local mod_, key = tostring(key_):match("^(.-)-(.?)$")

    if key:len() == 1 then key = key:lower() end

    -- Non-valid keybinding
    if not (mod_ and key) or mod_:len() < 1 or key:len() < 1 then
        if debug then naughty.notify({
            text = "Invalid keybind: '" .. key_ .. "'" })
        end
        return
    end

    local mod = {}
    for m in (mod_ or ""):gmatch("[^%s-]") do
        mod[#mod+1] = MODSMAP[m]
    end

    return awful.key(mod, key, action)
end


function keymaps(groups)
    return awful.util.table.join(starmap(keybind, groups))
end
