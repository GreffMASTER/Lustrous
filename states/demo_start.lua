local state = {}

local utils = require('common.utils')

local done = false
local g_bg = love.graphics.newImage('states/demo_start/screen_start.png')

function state.init()
    done = false
end

function state.transitionfinished()
    done = true
end

function state.draw()
    love.graphics.draw(g_bg)
    utils.drawcentered(_GMGButtonLeft, 107, 400-64)
    utils.drawcentered(_GMGButtonDown, 107+32+2, 400-64)
    utils.drawcentered(_GMGButtonRight, 107+64+4, 400-64)
    utils.drawcentered(_GMGButton1, 290, 400-64)
    utils.drawcentered(_GMGButton2, 290+32+2, 400-64)
    utils.drawcentered(_GMGButtonStart, 652, 510)
end

function state.buttonpressed(button)
    if button == 7 then
        if done then
            --_SONG = string.sub(debug_win.children[2].selected,0,-5)
            --_AVATAR = string.sub(debug_win.children[4].selected,0,-5)
            _GMState.change(
                'loading',
                {mode='club',},
                {ttype="fadein",color={0,0,0},time=1}
            )
            done = false
        end
    end
end

return state