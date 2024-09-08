local discoball = {}
setmetatable(discoball, require 'common.avatar')

local utils = require 'common.utils'

discoball.version = 1
discoball.ident = 'lustrous.discoball'

discoball.frontend = {}

discoball.frontend.name = 'DiscoBoy'
discoball.frontend.author = 'GreffMASTER'

local frames = {
    love.graphics.newImage('avatars/discoball/graphics/1.png'),
    love.graphics.newImage('avatars/discoball/graphics/2.png'),
    love.graphics.newImage('avatars/discoball/graphics/3.png'),
    love.graphics.newImage('avatars/discoball/graphics/4.png')
}
local glasses = love.graphics.newImage('avatars/discoball/graphics/glasses.png')
local glasses_b = love.graphics.newImage('avatars/discoball/graphics/glasses_b.png')
local glasses_err = love.graphics.newImage('avatars/discoball/graphics/glasses_err.png')
local glasses_ded = love.graphics.newImage('avatars/discoball/graphics/glasses_ded.png')
local glasses_dosh = love.graphics.newImage('avatars/discoball/graphics/glasses_dosh.png')
local beams = love.graphics.newImage('avatars/discoball/graphics/beams.png')

local current = frames[1]
local frame = 1
local timer = 0
local flash_t = 0
local flash = false
local time = 0
local bob1 = 0
local bob2 = 0
local beamup = 0.0
local danger = false
local ded = false
local is_combo = false
local rot = 0
local rot_mul = 1
local mul = 0

function discoball:init( )
    frame = 1
    current = frames[frame]
    timer = 0
    bob1 = 0
    bob2 = 0
    time = 0
    flash_t = 0
    beamup = 0.0
    rot = 0
    rot_mul = 1
    mul = 0

    flash = false
    danger = false
    is_combo = false
    ded = false
end

function discoball:update( dt )
    timer = timer + dt
    time = time + dt * 6
    flash_t = flash_t + dt
    rot = rot + dt * rot_mul
    if beamup > 0 then
        beamup = beamup - dt
    end
    if is_combo then
        bob1 = math.sin(time*4) * 4
    else
        bob1 = math.sin(time) * 2
    end
    bob2 = math.cos(time*4) * mul
    if timer >= 0.1 then
        frame = frame + 1
        if frame > #frames then frame = 1 end
        timer = 0
    end
    if flash_t > 0.5 then
        flash_t = 0
        flash = not flash
    end
end

function discoball:draw( )
    love.graphics.setColor(1,1,1,beamup)
    utils.drawcentered(beams, 64, 64, rot)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(glasses_b, bob2, bob1)
    love.graphics.draw(frames[frame])
    -- draw glasses
    love.graphics.draw(glasses, bob2, bob1)
    if ded then
        love.graphics.draw(glasses_ded, bob2, bob1)
    else
        if danger and flash then
            love.graphics.draw(glasses_err, bob2, bob1)
        end
        if is_combo then
            love.graphics.draw(glasses_dosh, bob2, bob1)
        end
    end
end

function discoball:beat( scale )
    rot_mul = love.math.random(-1, 1)
    beamup = 1.0
end

function discoball:normal( )
    danger = false
    ded = false
    is_combo = false
    mul = 0
end

function discoball:combo( combo )
    danger = false
    is_combo = true
    ded = false

    flash = true
    flash_t = 0
    mul = 0
end

function discoball:danger( )
    danger = true
    ded = false
    is_combo = false

    flash = true
    flash_t = 0
    mul = 4
end

function discoball:gameover( )
    danger = false
    is_combo = false
    ded = true
    mul = 0
end

return discoball
