local input = {}

local profile = require 'common.profile'

local chars_l = {
    'a','b','c','d','e','f','g','h','i',
    'j','k','l','m','n','o','p','q','r',
    's','t','u','v','w','x','y','z'
}

local chars_u = {
    'A','B','C','D','E','F','G','H','I',
    'J','K','L','M','N','O','P','Q','R',
    'S','T','U','V','W','X','Y','Z'
}

local chars_s = {
    '0','1','2','3','4','5','6','7','8',
    '9','!','@','#','$','%','^','&','(',
    ')','-','_','=','+','[',']','?'
}

local chars = chars_u

local name = ''

local y_offset = 200
local substate = 1
local sel = 1
local sel_smooth = #chars_l * 1.25
local sel_smooth_target = 1.0
local movetimer = 400
local pointscal = 1
local wheel_hidden = false
local upper = true
local symbols = false
local goodbye = false
local velocity = 0
local left = false
local right = false
local kbmode = false

local holdt = 0.0
local holdstep = 0.25
local stepcount = 1

local s_type = love.audio.newSource('states/inputstate/input_type.wav', 'static')
local s_move = love.audio.newSource('states/inputstate/input_move.wav', 'static')
local s_ding = love.audio.newSource('states/inputstate/input_ding.wav', 'static')
local s_switch = love.audio.newSource('states/inputstate/input_switch.wav', 'static')
local s_click = love.audio.newSource('states/inputstate/input_click.wav', 'static')

local function goRight()
    s_click:stop()
    s_click:play()
    sel = sel + 1
    if sel > #chars_l then sel = 1; sel_smooth = 0 + velocity end
    sel_smooth_target = sel
end

local function goLeft()
    s_click:stop()
    s_click:play()
    sel = sel - 1
    if sel < 1 then sel = #chars_l; sel_smooth = #chars_l+1 + velocity end
    sel_smooth_target = sel
end

local function findChar(char)
    for k,v in ipairs(chars_l) do
        if v == char then
            chars = chars_l
            upper = false
            return k
        end
    end
    for k,v in ipairs(chars_u) do
        if v == char then
            chars = chars_u
            upper = true
            return k
        end
    end
    for k,v in ipairs(chars_s) do
        if v == char then
            chars = chars_s
            symbols = true
            return k
        end
    end
    return nil
end

function input.init(args)
    s_move:play()
end

function input.update(dt)
    if not wheel_hidden then
        if pointscal > 1 then
            pointscal = pointscal - dt * math.abs(pointscal - 1) * 16
        end
        if pointscal < 1 then pointscal = 1 end
        -- move the wheel from the top
        if movetimer > y_offset then
            movetimer = movetimer - dt * math.abs(movetimer - y_offset) * 8
        end
        if y_offset > movetimer then
            movetimer = movetimer + dt * math.abs(movetimer - y_offset) * 8
        end
    else
        -- move the wheel back
        if movetimer < 400 then
            movetimer = movetimer + dt * math.abs(movetimer - 400) * 8
        end
    end
    -- item wheel rotation
    local multi = 8
    if kbmode then multi = 16 end
    if sel_smooth < sel_smooth_target - 0.01 then
        sel_smooth = sel_smooth + dt * math.abs(sel_smooth - sel_smooth_target) * multi
    elseif sel_smooth > sel_smooth_target + 0.01 then
        sel_smooth = sel_smooth - dt * math.abs(sel_smooth - sel_smooth_target) * multi
    else
        sel_smooth = sel
    end
    velocity = sel_smooth - sel_smooth_target
    if left or right then
        holdt = holdt + dt
    end
    if left then
        if holdt > holdstep then
            holdt = 0.0
            goLeft()
            holdstep = holdstep - 0.05 * stepcount
            stepcount = stepcount + 1
            if holdstep < 0.05 then holdstep = 0.05 end
        end
    end
    if right then
        if holdt > holdstep then
            holdt = 0.0
            goRight()
            holdstep = holdstep - 0.05 * stepcount
            stepcount = stepcount + 1
            if holdstep < 0.05 then holdstep = 0.05 end
        end
    end
end

function input.draw()
    love.graphics.setColor(0,0,0)
    love.graphics.clear(1,1,1,1)
    if not wheel_hidden then
        love.graphics.printf('Name?', _GMFont32, 16, 16, _GMState.getWidth())
    else
        love.graphics.printf('Is that correct?', _GMFont32, 16, 16, _GMState.getWidth())
    end
    -- draw name
    love.graphics.printf(name, _GMFont48, 0, 190, _GMState.getWidth(), 'center')
    love.graphics.setLineWidth(4)
    love.graphics.line((_GMState.getWidth() / 2) - 300, 250, (_GMState.getWidth() / 2) + 300, 250)
    -- draw wheel
    for k, v in ipairs(chars_l) do
        local diff = math.pi * 2 / #chars
        local sino = (math.sin(sel_smooth * diff + (math.pi) - (diff*k))*(#chars)*12) + _GMState.getWidth() / 2
        local coso = ((math.cos(sel_smooth * diff + (math.pi) - (diff*k))*(#chars)*12) + _GMState.getHeight() + movetimer)
        if k == sel then coso = coso - pointscal end
        love.graphics.setColor(0,0,0)
        love.graphics.setLineWidth(4)
        love.graphics.line(sino, coso, _GMState.getWidth() / 2, _GMState.getHeight() + movetimer)
        love.graphics.circle('fill', sino, coso, 32)
        love.graphics.setColor(1,1,1)
        --local angle = (math.pi * 2 / #chars_l) + sel_smooth   TODO
        local angle = 0
        love.graphics.printf( chars[k], _GMFont24, sino, coso, 32, 'center', angle, 1, 1, 16, 16)
    end
    -- draw info
    if not wheel_hidden then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(_GMGButtonStart, _GMState.getWidth() - 32, _GMState.getHeight() - 32, 0, 1, 1, 16, 16)
        if not kbmode then
            if not symbols then love.graphics.draw(_GMGButtonUp, _GMState.getWidth() - 32, _GMState.getHeight() - 130, 0, 1, 1, 16, 16) end
            love.graphics.draw(_GMGButton2, 32, _GMState.getHeight() - 80, 0, 1, 1, 16, 16)
            love.graphics.draw(_GMGButton1, 32, _GMState.getHeight() - 32, 0, 1, 1, 16, 16)
            love.graphics.draw(_GMGButtonDown, _GMState.getWidth() - 32, _GMState.getHeight() - 80, 0, 1, 1, 16, 16)
            love.graphics.draw(_GMGButtonLeft, (_GMState.getWidth() / 2) - 50, _GMState.getHeight() - 164, 0, 1, 1, 16, 16)
            love.graphics.draw(_GMGButtonRight, (_GMState.getWidth() / 2) + 50, _GMState.getHeight() - 164, 0, 1, 1, 16, 16)
        end

        love.graphics.setColor(0,0,0)
        if not kbmode then
            love.graphics.printf('Erase', _GMFont20, 50, _GMState.getHeight() - 92, 200, 'left')
            love.graphics.printf('Type',  _GMFont20, 50, _GMState.getHeight() - 44, 200, 'left')
            local uplow = 'Lower'
            if upper then uplow = 'Lower' else uplow = 'Upper' end
            if not symbols then love.graphics.printf(uplow, _GMFont20, _GMState.getWidth() - 56 - 200, _GMState.getHeight() - 142, 200, 'right') end
            local letsym = 'Symbols'
            if symbols then letsym = 'Letters' else letsym = 'Symbols' end
            love.graphics.printf(letsym,   _GMFont20, _GMState.getWidth() - 56 - 200, _GMState.getHeight() - 92, 200, 'right')
        end
        love.graphics.printf('Accept', _GMFont20, _GMState.getWidth() - 56 - 200, _GMState.getHeight() - 44, 200, 'right')
    else
        local px1 = (_GMState.getWidth() / 2) - 200
        local px2 = (_GMState.getWidth() / 2) + 200
        local py = 0
        love.graphics.setColor(1,1,1)
        love.graphics.draw(_GMGButton1, px1, 300, 0, 1, 1, 16, 16)
        love.graphics.draw(_GMGButtonStart, px1 - 32 - 8, 300, 0, 1, 1, 16, 16)
        love.graphics.draw(_GMGButton2, px2, 300, 0, 1, 1, 16, 16)
        love.graphics.setColor(0,0,0)
        love.graphics.printf('Yes', _GMFont32, px1 + 24, 280, 100, 'left')
        love.graphics.printf('No', _GMFont32, px2 - 24 - 100, 280, 100, 'right')
    end
end

function input.buttonpressed(button)
    if not goodbye then
        if not wheel_hidden then
            if not kbmode then
                if button == 1 and not left and not right then -- z
                    if string.len(name) < 16 then
                        s_type:stop()
                        s_type:play()
                        pointscal = 200
                        name = name .. chars[sel]
                        if string.len(name) >= 16 then
                            s_ding:play()
                        end
                    end
                end
                if button == 2 and not left and not right then -- x
                    if string.len(name) > 0 then
                        s_type:stop()
                        s_type:play()
                        pointscal = 200
                        name = string.sub(name, 0, string.len(name) - 1)
                    end
                end
                if button == 3 and not symbols then -- up
                    upper = not upper
                    s_switch:stop()
                    s_switch:play()
                    movetimer = y_offset - 50
                    if upper then
                        chars = chars_u
                    else
                        chars = chars_l
                    end
                end
                if button == 4 then -- down
                    symbols = not symbols
                    s_switch:stop()
                    s_switch:play()
                    movetimer = y_offset + 50
                    if symbols then
                        chars = chars_s
                    else
                        if upper then
                            chars = chars_u
                        else
                            chars = chars_l
                        end
                    end
                end
                if button == 5 then -- left
                    left = true
                    pointscal = 1
                    goLeft()
                end
                if button == 6 then -- right
                    right = true
                    pointscal = 1
                    goRight() 
                end
            end
            if button == 7 then -- return
                if string.len(name) > 0 then
                    s_move:stop()
                    s_move:play()
                    pointscal = 1
                    wheel_hidden = true
                    left = false
                    right = false
                    kbmode = false
                end
            end
        else
            if button == 2 then
                s_move:stop()
                s_move:play()
                wheel_hidden = false
            end
            if button == 7 or button == 1 then
                s_ding:play()
                _PROFILE = profile.new()
                _PROFILE.name = name
                _PROFILE:save()
                _GMState.change('menu',nil,{["ttype"]="fadeinout",["color"]={1,1,1},["fintime"]=1,["fouttime"]=1})
                goodbye = true
            end
        end
    end
end

function input.buttonreleased(button)
    if button == 5 then
        left = false
        holdt = 0.0
        holdstep = 0.25
        stepcount = 1
    end
    if button == 6 then
        right = false
        holdt = 0.0
        holdstep = 0.25
        stepcount = 1
    end
end

function input.keypressed(key)
    if not wheel_hidden then
        if key == 'space' then
            s_switch:stop()
            s_switch:play()
            kbmode = not kbmode
        end
        if kbmode then
            if key == 'backspace' then
                if string.len(name) > 0 then
                    s_type:stop()
                    s_type:play()
                    pointscal = 200
                    name = string.sub(name, 0, string.len(name) - 1)
                end
            end
        end
    end
end

function input.textinput(t)
    if kbmode and not wheel_hidden then
        local i = findChar(t)
        if i then
            if sel ~= i then
                sel = i
                sel_smooth_target = i
                s_click:stop()
                s_click:play()
            end
            if string.len(name) < 16 then
                s_type:stop()
                s_type:play()
                pointscal = 200
                name = name .. chars[sel]
                if string.len(name) >= 16 then
                    s_ding:play()
                end
            end
        end
    end
end

return input