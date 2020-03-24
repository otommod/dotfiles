local function circle(ass, x, y, r)
    -- http://spencermortensen.com/articles/bezier-circle/
    -- We transform the coordinates so that the left-most point lies on
    -- (0,0); that way the center is actually in the center with \an5
    x = x + r
    y = y + r

    local c = 0.551915024494 * r
    ass:move_to(x, y+r)
    ass:bezier_curve(x+c, y+r, x+r, y+c, x+r, y)
    ass:bezier_curve(x+r, y-c, x+c, y-r, x, y-r)
    ass:bezier_curve(x-c, y-r, x-r, y-c, x-r, y)
    ass:bezier_curve(x-r, y+c, x-c, y+r, x, y+r)
end

local function circle2(ass, x, y, r)
    local function point(arg_x, arg_y)
        return (arg_x*r + x), (arg_y*r + y)
    end

    local function bezier(x1, y1, x2, y2, x3, y3)
        x1, y1 = point(x1, y1)
        x2, y2 = point(x2, y2)
        x3, y3 = point(x3, y3)

        ass:bezier_curve(x1, y1, x2, y2, x3, y3)
    end

    local c = 0.551915024494
    ass:move_to(x, y + r)
    bezier( c,  1,  1,  c,  1,  0)
    bezier( 1, -c,  c, -1,  0, -1)
    bezier(-c, -1, -1, -c, -1,  0)
    bezier(-1,  c, -c,  1,  0,  1)
end
