local avtest = {}

local utils = require 'common.utils'

local avpick = require 'states.avtest.picker'
local avatar = nil
local avatar_canvas = love.graphics.newCanvas(128, 128)
local avatar_boundary = love.graphics.newCanvas(128, 128)

local bgcolor = {.2, .2, .2}

local do_beats = false
local beat_delay = 1
local beat_timer = 0
local avatar_scale = 1
local do_outline = true

-- WINDOW SETUP

local avwin = avpick.newWindow( )

avwin.children.avlist.pressfunc = function(select)
    avatar = _AVATARS[select]
    if avatar then
        avatar:init()
        for k,v in pairs(avwin.children) do
            v.disabled = false
        end
    end
end

-- Avatar States

avwin.children.b_reset.func = function()
    avatar:init()
    beat_timer = 0
    if do_beats then
        avatar_scale = 2
        avatar:beat(2)
    end
end

avwin.children.b_normal.func = function()
    avatar:normal()
end

avwin.children.b_combo.func = function()
    avatar:combo()
end

avwin.children.b_danger.func = function()
    avatar:danger()
end

avwin.children.b_gameover.func = function()
    avatar:gameover()
end

-- Beats

avwin.children.b_beats.func = function()
    do_beats = not do_beats
    if do_beats then
        avatar_scale = 1.5
        beat_timer = 0
        avatar:beat(1.5)
        avwin.children.b_beats.text = 'Beats: Yes'
    else
        avwin.children.b_beats.text = 'Beats: No'
    end
end

avwin.children.b_beatup.func = function()
    beat_delay = beat_delay + 0.001
    avwin.children.beat_t_label.text = string.format('%.03f', beat_delay)
end

avwin.children.beat_t_label.text = string.format('%.03f', beat_delay)

avwin.children.b_beatup.altfunc = function()
    beat_delay = beat_delay + 0.025
    avwin.children.beat_t_label.text = string.format('%.03f', beat_delay)
end

avwin.children.b_beatdown.func = function()
    beat_delay = beat_delay - 0.001
    if beat_delay < 0 then beat_delay = 0 end
    avwin.children.beat_t_label.text = string.format('%.03f', beat_delay)
end

avwin.children.b_beatdown.altfunc = function()
    beat_delay = beat_delay - 0.025
    if beat_delay < 0 then beat_delay = 0 end
    avwin.children.beat_t_label.text = string.format('%.03f', beat_delay)
end

avwin.children.b_beat.func = function()
    avatar_scale = 1.5
    avatar:beat(1.5)
end

avwin.children.b_linehit.func = function()
    avatar_scale = 2
    avatar:beat(2)
end

-- Misc

avwin.children.bgrlabel.text = string.format('%.03f', bgcolor[1])
avwin.children.bgglabel.text = string.format('%.03f', bgcolor[2])
avwin.children.bgblabel.text = string.format('%.03f', bgcolor[3])

avwin.children.b_bgr_minus.func = function()
    bgcolor[1] = bgcolor[1] - 0.01
    if bgcolor[1] < 0 then bgcolor[1] = 0 end
    avwin.children.bgrlabel.text = string.format('%.03f', bgcolor[1])
end

avwin.children.b_bgg_minus.func = function()
    bgcolor[2] = bgcolor[2] - 0.01
    if bgcolor[2] < 0 then bgcolor[2] = 0 end
    avwin.children.bgglabel.text = string.format('%.03f', bgcolor[2])
end

avwin.children.b_bgb_minus.func = function()
    bgcolor[3] = bgcolor[3] - 0.01
    if bgcolor[3] < 0 then bgcolor[3] = 0 end
    avwin.children.bgblabel.text = string.format('%.03f', bgcolor[3])
end


avwin.children.b_bgr_plus.func = function()
    bgcolor[1] = bgcolor[1] + 0.01
    if bgcolor[1] > 1 then bgcolor[1] = 1 end
    avwin.children.bgrlabel.text = string.format('%.03f', bgcolor[1])
end

avwin.children.b_bgg_plus.func = function()
    bgcolor[2] = bgcolor[2] + 0.01
    if bgcolor[2] > 1 then bgcolor[2] = 1 end
    avwin.children.bgglabel.text = string.format('%.03f', bgcolor[2])
end

avwin.children.b_bgb_plus.func = function()
    bgcolor[3] = bgcolor[3] + 0.01
    if bgcolor[3] > 1 then bgcolor[3] = 1 end
    avwin.children.bgblabel.text = string.format('%.03f', bgcolor[3])
end

avwin.children.b_outline.func = function()
    do_outline = not do_outline
    if do_outline then
        avwin.children.b_outline.text = 'Outline: Yes'
    else
        avwin.children.b_outline.text = 'Outline: No'
    end
end


-- STATE CALLBACKS

function avtest.init(args)
    avpick.rescan(avwin)
end

function avtest.update(dt)
    if avatar then
        if do_beats then
            beat_timer = beat_timer + dt
            if beat_timer >= beat_delay then
                beat_timer = 0
                avatar_scale = 1.5
                avatar:beat(1.5)
            end
        end
        if avatar_scale > 1 then
            avatar_scale = avatar_scale - (avatar_scale-1) * 4 * dt
        end
        if avatar_scale < 1 then avatar_scale = 1 end
        avatar:update(dt)
        
        -- drawhack
        avatar_canvas:renderTo(function()
            love.graphics.clear(0,0,0,0)
            love.graphics.setColor(1,1,1,1)
            if avatar then
                avatar:draw()
            end
        end)

        avatar_boundary:renderTo(function()
            love.graphics.clear(0,0,0,0)
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle('line',0,0,128,128)
            love.graphics.rectangle('line',0,0,128,128)
            love.graphics.rectangle('line',0,0,128,128)
        end)
    end
end

function avtest.draw()
    love.graphics.clear(bgcolor)

    love.graphics.push()
        love.graphics.setColor(1,1,1)
        utils.drawcentered(avatar_canvas, 960 * .5, 540 * .5, 0, avatar_scale, avatar_scale)
        if do_outline then utils.drawcentered(avatar_boundary, 960 * .5, 540 * .5, 0, avatar_scale, avatar_scale) end
    love.graphics.pop()
    
    avwin:draw()
end

function avtest.mousemoved( x, y, dx, dy, istouch )
    avwin:mousemoved( x, y, dx, dy, istouch )
end

function avtest.mousepressed( x, y, button, istouch, presses )
    avwin:mousepressed( x, y, button, istouch, presses )
end

function avtest.mousereleased( x, y, button, istouch, presses )
    avwin:mousereleased( x, y, button, istouch, presses )
end

return avtest