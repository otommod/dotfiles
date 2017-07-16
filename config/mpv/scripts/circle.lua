function circle(ass, x, y, r)
    local function point(arg_x, arg_y)
        return (arg_x*r + x), (arg_y*r + y)
    end

    local function bezier(x1, y1, x2, y2, x3, y3)
        x1, y1 = point(x1, y1)
        x2, y2 = point(x2, y2)
        x3, y3 = point(x3, y3)

        ass:bezier_curve(x1, y1, x2, y2, x3, y3)
    end

    r = r or 10
    ass:move_to(x, y + r)

    local c = 0.551915024494

    bezier( c,  1,  1,  c,  1,  0)
    bezier( 1, -c,  c, -1,  0, -1)
    bezier(-c, -1, -1, -c, -1,  0)
    bezier(-1,  c, -c,  1,  0,  1)
end
