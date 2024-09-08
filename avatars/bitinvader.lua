local bitinvader = {}
setmetatable(bitinvader, require 'common.avatar')

bitinvader.version = 1
bitinvader.ident = 'lustrous.bitinvader'

bitinvader.frontend = {}

bitinvader.frontend.name = 'BitInvader'
bitinvader.frontend.author = 'GreffMASTER'

local invaders = {
    love.graphics.newImage('avatars/bitinvader/bit1.png'),
    love.graphics.newImage('avatars/bitinvader/bit2.png'),
}

local current = invaders[1]
local flip = false

function bitinvader:init( )
    current = invaders[1]
    flip = false
end

function bitinvader:update( dt )
end

function bitinvader:draw( )
    love.graphics.draw(current)
end

function bitinvader:beat( scale )
    if flip then
        current = invaders[2]
    else
        current = invaders[1]
    end
    flip = not flip
end

return bitinvader
