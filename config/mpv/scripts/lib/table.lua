local T = { }

function T.contains(t, e)
    for _, v in pairs(t) do
        if v == e then
            return true
        end
    end
    return false
end

function T.merge(t1, t2)
    for k, v in pairs(t2) do
        if t1[k] == nil then t1[k] = v end
    end

    return t1
end

return T
