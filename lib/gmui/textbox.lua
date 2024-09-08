local style = require "lib.gmui.style"

local Textbox = {
    xpos = 0,
    ypos = 0,
    w = 100,
    h = 100,
    style = style:new()
}

function Textbox:draw()
    
end

function Textbox:new(params)
    params = params or {}
    setmetatable(params,self)
    self.x = self.xpos
    self.y = self.ypos
    self.__index = self
    return params
end