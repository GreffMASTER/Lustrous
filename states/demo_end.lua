local state = {}

local utils = require('common.utils')

local done = false
local g_bg = love.graphics.newImage('states/demo_end/screen_end.png')

function state.init()
    done = false
end

function state.transitionfinished()
    done = true
end

function state.draw()
    love.graphics.draw(g_bg)
    utils.drawcentered(_GMGButtonStart, 650, 512)
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