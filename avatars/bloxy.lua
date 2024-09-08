local bloxy = {}
setmetatable(bloxy, require 'common.avatar')

local utils = require 'common.utils'

bloxy.version = 1
bloxy.ident = 'lustrous.bloxy'

bloxy.frontend = {}
bloxy.frontend.name = 'Bloxy'
bloxy.frontend.author = 'GreffMASTER'

local bloxy_path = 'avatars/bloxy/'

local is_dizzy = false
local is_ded = false
local is_happy = false
local time = 0
local shaketime = 0
local bob1 = 0
local bob2 = 1
local bob3 = 0
local bob4 = 1
local spin1 = 0
local spin2 = 0
local multi = 6
local shake1 = 0
local shake2 = 0
local blink_delay = 0
local blink_time = 0

local g_tl = love.graphics.newImage(bloxy_path .. 'graphics/tl.png')
local g_tr = love.graphics.newImage(bloxy_path .. 'graphics/tr.png')
local g_bl = love.graphics.newImage(bloxy_path .. 'graphics/bl.png')
local g_br = love.graphics.newImage(bloxy_path .. 'graphics/br.png')
local g_el = love.graphics.newImage(bloxy_path .. 'graphics/el.png')
local g_er = love.graphics.newImage(bloxy_path .. 'graphics/er.png')
local g_ehl = love.graphics.newImage(bloxy_path .. 'graphics/ehl.png')
local g_ehr = love.graphics.newImage(bloxy_path .. 'graphics/ehr.png')
local g_esl = love.graphics.newImage(bloxy_path .. 'graphics/esl.png')
local g_esr = love.graphics.newImage(bloxy_path .. 'graphics/esr.png')

local g_eye_left = g_el
local g_eye_right = g_er

function bloxy:init( )
    is_dizzy = false
    is_ded = false
    is_happy = false
    time = 0
    bob1 = 0
    bob2 = 1
    bob3 = 0
    bob4 = 1
    spin1 = 0
    spin2 = 0
    multi = 6
    shake1 = 0
    shake2 = 0
    shaketime = 0
    blink_delay = 0
    blink_time = 0
end

function bloxy:update( dt )
    -- bobbing
    time = time + dt * multi
    bob1 = math.sin(time) * multi
    bob2 = math.cos(time) * multi
    bob3 = math.cos(time+3) * multi
    bob4 = math.sin(time+3) * multi
    -- shaking
    shaketime = shaketime + dt * 20
    shake1 = math.sin(shaketime) * 2
    shake2 = math.cos(shaketime) * 2
    -- spinning dizzy eyes
    spin1 = spin1 + dt * 2
    spin2 = spin2 - dt * 2
    blink_delay = blink_delay + dt
    
    if blink_delay >= 4 then
        blink_delay = 0
        blink_time = 0.25
        g_eye_left = g_ehl
        g_eye_right = g_ehr
    end
    
    if blink_time > 0 then
        blink_time = blink_time - dt
        if blink_time <= 0 then
            g_eye_left = g_el
            g_eye_right = g_er
        end
    end
end

function bloxy:draw( )
    love.graphics.push()
        love.graphics.translate(4,0) -- small fix
        -- draw bloxys blocks
        if is_dizzy or is_ded then
            -- right
            utils.drawcentered(g_br, 96-14+shake2, 94-8+bob1)
            utils.drawcentered(g_tr, 96-14+shake1, 30+8+bob2)
            -- left
            utils.drawcentered(g_bl, 32+8-shake1, 96-4+bob3)
            utils.drawcentered(g_tl, 32+8-shake2, 32+4+bob4)
        else -- normal
            -- right
            utils.drawcentered(g_br, 96-14, 94-8+bob1)
            utils.drawcentered(g_tr, 96-14, 30+8+bob2)
            -- left
            utils.drawcentered(g_bl, 32+8, 96-4+bob3)
            utils.drawcentered(g_tl, 32+8, 32+4+bob4)
        end
        
        -- draw the eyes
        if is_happy then
            utils.drawcentered(g_ehl, 38+6, 32+4+bob4)
            utils.drawcentered(g_ehr, 102-14, 30+8+bob2)
        elseif is_dizzy then
            utils.drawcentered(g_esl, 38+6, 32+4+bob4, spin1)
            utils.drawcentered(g_esr, 102-14, 30+8+bob2, spin2)  
        elseif is_ded then
            utils.drawcentered(g_ehl, 38+6, 32+4+bob4, math.pi *0.6)
            utils.drawcentered(g_ehr, 102-14, 30+8+bob2, -math.pi*0.6)
        else -- normal
            utils.drawcentered(g_eye_left, 38+6, 32+4+bob4)
            utils.drawcentered(g_eye_right, 102-14, 30+8+bob2)
        end
    love.graphics.pop()
end

function bloxy:normal( )
    is_dizzy = false
    is_happy = false
    is_ded = false
    multi = 6
end

function bloxy:combo( combo )
    is_dizzy = false
    is_happy = true
    is_ded = false
    multi = 10
end

function bloxy:danger( )
    is_dizzy = true
    is_happy = false
    is_ded = false
    multi = 6
end

function bloxy:gameover( )
    is_dizzy = false
    is_happy = false
    is_ded = true
    multi = 8
end

return bloxy
