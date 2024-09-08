local utils = {}

function utils.lerp( a, b, t )
    return (1-t)*a + t*b
end

function utils.drawcentered(drawable, x, y, r, sx, sy)
    x = x or 0
    y = y or 0
    r = r or 0
    sx = sx or 1
    sy = sy or 1
    love.graphics.draw( drawable, x, y, r, sx, sy, drawable:getWidth( ) / 2, drawable:getHeight( ) / 2 )
end

function utils.hsv2rgb(h, s, v)
	local k1 = v*(1-s)
	local k2 = v - k1
	local r = math.min (math.max (3*math.abs (((h	    )/180)%2-1)-1, 0), 1)
	local g = math.min (math.max (3*math.abs (((h	-120)/180)%2-1)-1, 0), 1)
	local b = math.min (math.max (3*math.abs (((h	+120)/180)%2-1)-1, 0), 1)
	return k1 + k2 * r, k1 + k2 * g, k1 + k2 * b
end

function utils.printfWithShadow( str, font, x, y, w, align, offset_x, offset_y )
    offset_x = offset_x or 0
    offset_y = offset_y or 2
    local r,g,b,a = love.graphics.getColor( )
    love.graphics.setColor( 0, 0, 0 )
    love.graphics.printf( str, font, x+offset_x, y+offset_y, w, align )
    love.graphics.setColor( r, g, b, a )
    love.graphics.printf( str, font, x, y, w, align )
end

function utils.getTimeString( seconds )
    local time = ""
    time = time .. math.floor(seconds/60) .. ":"
    if math.floor(seconds - math.floor(seconds/60) * 60) < 10 then time = time .. "0" end
    time = time .. math.floor(seconds - math.floor(seconds/60) * 60)
    return time
end

function utils.newCachedVideoStream(path)
    local ogvfile = love.filesystem.newFile(path)
    ogvfile:open('r')
    local ogvdata = ogvfile:read()
    ogvfile:close()
    local md5 = love.data.encode('string', 'hex', love.data.hash('md5', ogvdata))
    local temp_path = 'cache/'..md5..'.ogv'
    local tempfile
    love.filesystem.createDirectory('cache')
    local info = love.filesystem.getInfo(temp_path)
    tempfile = love.filesystem.newFile(temp_path)
    if not info then
        tempfile:open('w')
        tempfile:write(ogvdata)
        tempfile:close()
    end
    return love.video.newVideoStream(tempfile)
end

return utils