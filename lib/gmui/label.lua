local style = require "lib.gmui.style"

local Label = {
    xpos = 0,
    ypos = 0,
    w = 100,
    h = 50,
    style = style:new(),
    text = "",
    textal = "left"
}

function Label:draw()
    local tr,tg,tb,ta = love.graphics.getColor()    -- get current color to later reset it
    love.graphics.setColor(self.style.txt_color)
    love.graphics.printf(self.text,self.x,self.y,self.w,self.textal)
    love.graphics.setColor(tr,tg,tb,ta)             -- reset color back to normal
end

function Label:new(params)
    params = params or {}
    if params.xpos and params.ypos then
        params.x = params.xpos
        params.y = params.ypos
    end
    setmetatable(params,self)
    self.__index = self
    return params
end

return Label