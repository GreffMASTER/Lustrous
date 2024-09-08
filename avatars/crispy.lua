local crispy = {}
setmetatable(crispy, require 'common.avatar')

local utils = require 'common.utils'

crispy.version = 1
crispy.ident = 'lustrous.crispy'

crispy.frontend = {}
crispy.frontend.name = 'Crispy'
crispy.frontend.author = 'GreffMASTER'

local crispy_path = 'avatars/crispy/'

local crispy_parts = {}

local is_dizzy = false
local rot = 0
local rot2 = math.pi * 2

crispy_parts.body = love.graphics.newImage(crispy_path..'body.png')
crispy_parts.hand = love.graphics.newImage(crispy_path..'hand.png')
crispy_parts.head_normal = love.graphics.newImage(crispy_path..'head_normal.png')
crispy_parts.head_joy = love.graphics.newImage(crispy_path..'head_joy.png')
crispy_parts.head_dizzy = love.graphics.newImage(crispy_path..'head_dizzy.png')
crispy_parts.head_dead = love.graphics.newImage(crispy_path..'head_dead.png')
crispy_parts.eye_spin = love.graphics.newImage(crispy_path..'eye_spin.png')

local head = crispy_parts.head_normal

function crispy:init( )
    head = crispy_parts.head_normal
    is_dizzy = false
end

function crispy:update( dt )
    rot = rot + dt * 2
    rot2 = rot2 - dt * 2
    if rot > math.pi * 2 then rot = 0 end
    if rot2 < 0 then rot2 = math.pi * 2 end
end

function crispy:draw( )
    utils.drawcentered( crispy_parts.body, 64, 88, 0, 0.12, 0.12 )
    utils.drawcentered( head, 64, 38, 0, 0.12, 0.12 )
    utils.drawcentered( crispy_parts.hand, 10, 30, 0, 0.15, 0.15 )
    utils.drawcentered( crispy_parts.hand, 118, 30, 0, 0.15, 0.15 )
    if is_dizzy then
        utils.drawcentered( crispy_parts.eye_spin, 42, 32, rot, 0.12, 0.12 )
        utils.drawcentered( crispy_parts.eye_spin, 86, 32, rot2, 0.12, 0.12 )
    end
end

function crispy:normal( )
    head = crispy_parts.head_normal
    is_dizzy = false
end

function crispy:combo( combo )
    head = crispy_parts.head_joy
    is_dizzy = false
end

function crispy:danger( )
    head = crispy_parts.head_dizzy
    is_dizzy = true
end

function crispy:gameover( )
    head = crispy_parts.head_dead
    is_dizzy = false
end

return crispy
