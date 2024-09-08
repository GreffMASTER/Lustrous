local introstate = {}

local debugstuff = require "states.introstate.debug"
local profile = require 'common.profile'

local done = false
local buttonpressed = {false,false,false,false,false,false,false}
local glogo = love.graphics.newImage("states/introstate/graphics/lustrous.png")
local lovelogo = love.graphics.newImage("states/introstate/graphics/love-logo.png")
local ctrl = false

local debug_win

local function btn(value)
  return value and 1 or 0
end

function introstate.init()
    done = false
    
    love.graphics.setBackgroundColor( 1, 1, 1 )
    if not _PROFILE then
        local s, r = pcall(profile.load)
        if not s or not r then
            _GMState.change('input')
            return
        end
        _PROFILE = r
    end
    _PROFILE:save()
    debug_win = debugstuff.newDebugWindow( )

    debug_win.children[2].pressfunc = function(sel)
        if done then
            _GMState.change('loading',
                {mode='mixtape', songlist={sel}, menu_state='intro'},
                {ttype="fadein",color={0,0,0},time=1}
            )
            done = false
        end
    end
    debug_win.children[5].func = function() -- all mixtape
        if done then
            -- fill the song list with the mixtape
            local lst = {}
            for k, v in ipairs(debug_win.children[2].elements) do
                table.insert(lst, v)
            end
            _GMState.change('loading',
                {mode='mixtape', songlist=lst},
                {ttype="fadein",color={0,0,0},time=1}
            )
            done = false
        end
    end
    debug_win.children[7].func = function() -- ta 60
        if done then
            _GMState.change('loading',
                {mode='ta', tatime=60},
                {ttype="fadein",color={0,0,0},time=1}
            )
            done = false
        end
    end
    debug_win.children[8].func = function() -- ta 300
        if done then
            _GMState.change('loading',
                {mode='ta', tatime=300},
                {ttype="fadein",color={0,0,0},time=1}
            )
            done = false
        end
    end
    debug_win.children[9].func = function() -- ta 600
        if done then
            _GMState.change('loading',
                {mode='ta', tatime=600},
                {ttype="fadein",color={0,0,0},time=1}
            )
            done = false
        end
    end
end

function introstate.draw()
    love.graphics.clear(1,1,1,1)
    love.graphics.setColor(1,1,0,1)
    if buttonpressed[1] then love.graphics.rectangle("fill",400+150,200+200,32,32) end
    if buttonpressed[2] then love.graphics.rectangle("fill",448+150,200+200,32,32) end
    if buttonpressed[3] then love.graphics.rectangle("fill",200+150,140+200,32,32) end
    if buttonpressed[4] then love.graphics.rectangle("fill",200+150,200+200,32,32) end
    if buttonpressed[5] then love.graphics.rectangle("fill",168+150,170+200,32,32) end
    if buttonpressed[6] then love.graphics.rectangle("fill",232+150,170+200,32,32) end
    if buttonpressed[7] then love.graphics.rectangle("fill",320+150,170+200,32,32) end
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(_GMGButton1,400+150,200+200)
    love.graphics.draw(_GMGButton2,448+150,200+200)
    love.graphics.draw(_GMGButtonUp,200+150,140+200)
    love.graphics.draw(_GMGButtonDown,200+150,200+200)
    love.graphics.draw(_GMGButtonLeft,168+150,170+200)
    love.graphics.draw(_GMGButtonRight,232+150,170+200)
    love.graphics.draw(_GMGButtonStart,320+150,170+200)
    love.graphics.draw(glogo,_GMState.getWidth()/2 - glogo:getWidth()/2 ,0)
    love.graphics.printf( {{0,0,0},"Press      to start the game."}, _GMFont24,0 , _GMState.getHeight() / 2 , _GMState.getWidth( ), "center" )
    love.graphics.draw(_GMGButtonStart,386,_GMState.getHeight() / 2)
    --[[
    love.graphics.printf( {{0,0,0},"Input Test"}, _GMFont24, 0, _GMState.getHeight() / 2 + 164 , love.graphics.getWidth( ), "center" )
    local inputstring = ""
    for k,v in ipairs(buttonpressed) do
        inputstring = inputstring .. btn(v) .. " "
    end
    love.graphics.printf( {{0,0,0},"{ "..inputstring.."}"}, _GMFont24, 0, _GMState.getHeight() / 2 + 186 , love.graphics.getWidth( ), "center" )]]
    love.graphics.setColor(0,0,0,1)
    love.graphics.print(_LVERSION)
    love.graphics.printf('Made with', 800, 450, 128, 'left')
    love.graphics.setColor(1,1,1)
    love.graphics.draw(lovelogo, 800, 420, 0, 0.4, 0.4)

    if _DEBUG then
        debug_win:draw()
    end
end

function introstate.transitionfinished()
    done = true
end

function introstate.keypressed( key )
    if key == "lctrl" then ctrl = true end
    if ctrl == true and key == "d" then _DEBUG = not _DEBUG end
end

function introstate.keyreleased( key )
    if key == "lctrl" then ctrl = false end
end

function introstate.buttonpressed( button )
    buttonpressed[button] = true
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

function introstate.buttonreleased( button )
    buttonpressed[button] = false
end

function introstate.mousemoved( x, y, dx, dy, istouch )
    if _DEBUG then debug_win:mousemoved( x, y, dx, dy, istouch ) end
end

function introstate.mousepressed( x, y, button, istouch, presses )
    if _DEBUG then debug_win:mousepressed( x, y, button, istouch, presses ) end
end

function introstate.mousereleased( x, y, button, istouch, presses )
    if _DEBUG then debug_win:mousereleased( x, y, button, istouch, presses ) end
end

return introstate
