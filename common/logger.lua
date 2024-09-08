local logger = {}

local lg = love.graphics
local w = lg.getWidth()
local h = lg.getHeight()

local logcanv = love.graphics.newCanvas(w, h)
local logbuff = love.graphics.newCanvas(w, h)

local scroll = false
local text_y = 0

function logger.log(text)
    print(text)
    logcanv:renderTo(function()
        love.graphics.setColor(1,1,1)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.print(text, 0, text_y)

        logbuff:renderTo(function()
            love.graphics.clear(0,0,0,0)
            love.graphics.draw(logcanv, 0, -14)
        end)

        if scroll then
            love.graphics.clear(0,0,0,0)
            love.graphics.draw(logbuff)
        end

        love.graphics.setBlendMode("alpha", "alphamultiply")
    end)
    
    if text_y > h-30 then
        scroll = true
    else
        text_y = text_y + 14
    end

    return logcanv
end

return logger