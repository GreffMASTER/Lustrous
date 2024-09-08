local bootstate = {}

local profile = require('common.profile')

local done = false
local countdown = 5.0
local g_warn = love.graphics.newImage('states/bootstate/graphics/warning.png')
local lctrl = false

local function nextState(state)
    _GMState.change(state ,nil, {
        ttype='fadeinout',
        color={0,0,0},
        fintime=1,
        fouttime=1
    })
    done = false
end

function bootstate.init(prev,args)
    done = false
    countdown = 10.0
    lctrl = false
    if not _PROFILE then
        local s, r = pcall(profile.load)
        if not s or not r then
            _PROFILE = profile.new()
            _PROFILE.name = 'April Fools!!!'
            _PROFILE:save()
        else
            _PROFILE = r
        end
    end
    _PROFILE:save()
end

function bootstate.draw()
    love.graphics.setColor(1,1,1,0.1)
    love.graphics.draw(g_warn, _GMState.getWidth() - 400, 32, 0, 0.9, 0.9)
    love.graphics.setColor(1,1,1)
    love.graphics.printf('SEIZURE WARNING!', _GMFont32, 0, 150, _GMState.getWidth(), 'center')
    love.graphics.printf(
        [[
            This game may contain flashing lights and images
            that may cause epileptic seizures.
            If the User or anyone in your household has epileptic condition,
            please consult your doctor before playing the game.
            If anyone experiences dizziness, altered vision,
            eye or muscle twitches, loss of awareness, disorientation,
            any involuntary movement, or convulsions while playing
            the game, immediately stop playing and consult your doctor.
        ]],
        _GMFont20, 0, 200, _GMState.getWidth() - 64, 'center'
    )
end

function bootstate.update(dt)
    if done then
        countdown = countdown - dt
        if countdown <= 0 then
            nextState('demo_start')
        end
    end
end

function bootstate.transitionfinished()
    done = true
end

function bootstate.buttonpressed(button)
    if done then
        nextState('demo_start')
    end    
end

function bootstate.keypressed( key, scancode, isrepeat )
    if key == 'lctrl' then
        lctrl = true
    end
    if key == 'a' and lctrl and done then
        nextState('avtest')
        _DEBUG = true
    end
    if key == 'd' and lctrl and done then
        nextState('intro')
        _DEBUG = true
    end
end

function bootstate.keyreleased( key, scancode )
    if key == 'lctrl' then
        lctrl = false
    end
end

return bootstate