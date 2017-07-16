function trunc(s, w)
    local floor, ceil = math.floor(w/2), math.ceil(w/2)
    if #s <= w then return s end
    return s:sub(1, ceil) .. '…' .. s:sub(-floor + 1)
end

function torrent_info()
    local cmd = io.popen('transmission-remote -tall -i')
    local line = cmd:read()
    local torrents = { }

    while line ~= nil do
        if line == 'NAME' then torrents[#torrents+1] = { } end

        key, value = line:match("  ([^:]*):%s*(.*)")
        if key then
            key = key:lower():gsub(" ", "_")
            torrents[#torrents][key] = value
        end

        line = cmd:read()
    end

    for i, t in ipairs(torrents) do
        t.eta = t.eta:match("(.*) %(%d* seconds%)")
        t.ratio = tonumber(t.ratio)
        t.percent_done = tonumber(t.percent_done:sub(1, #t.percent_done-1))
    end

    return torrents
end

-- register = {}
-- function conky_draw()
--     require('cairo')

--     if conky_window == nil then return end

--     local cs = cairo_xlib_surface_create(
--         conky_window.display, conky_window.drawable, conky_window.visual,
--         conky_window.width, conky_window.height)
--     local cr = cairo_create(cs)
--     local updates = tonumber(conky_parse('${updates}'))

--     if updates > 5 then
--         for _, func in ipairs(register) do
--             func(cr)
--         end
--     end

--     cairo_destroy(cr)
--     cairo_surface_destroy(cs)
-- end

-- function register_hook(func)
--     register[#register+1] = func
-- end

function conky_tonumber(x)
    return tonumber(x)
end

function conky_torrents()
    torrents = { }

    for _, t in ipairs(torrent_info()) do
        ret = ''
        ret = ret .. trunc(t.name, 28) .. '  '
        ret = ret .. '${font Fira Sans:light:weight=ultra:size=12}'
        ret = ret .. '↓' .. t.download_speed.. ' '
        ret = ret .. '↑' .. t.upload_speed   .. ' '
        ret = ret .. '${goto 850}${color 386}'
        ret = ret .. '${lua_bar 10,0 tonumber ' .. t.percent_done .. '}'
        ret = ret .. '${goto 935}${color #000}'
        ret = ret .. '${lua_bar 10,42 tonumber 100}'
        ret = ret .. '${offset -39}${color}${voffset -2}'
        ret = ret .. tostring(t.percent_done) .. '%'
        ret = ret .. '${voffset 2}${color}${font}'

        table.insert(torrents, ret)
    end

    return table.concat(torrents, '\n')
end
