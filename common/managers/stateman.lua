local stateman = {}

-- StateMan v2 created by GreffMASTER 2022

local state_meta = require 'common.state'
local cbs1_str = require 'common.shader.cbs1'
local cbs2_str = require 'common.shader.cbs2'
local cbs3_str = require 'common.shader.cbs3'

-- stuff
local scale = 1 --Mobile scale
local res = {960,540} --Ingame resolution (units)
local sxo = 0 --Safe area X offset (avoids drawing on the notch)
local realx = 0 --Real screen width (in pixels)
local realy = 0 --Real screen height (in pixels)
local movex = 0 --move screen X pixels to the right
local movey = 0 --move screen Y pixels down
local isGfxPushed = false --Is scaling active or not

local current = {}
setmetatable(current, state_meta)
local currentname
local timer = 0
local fadeintime = 0
local fadeouttime = 0
local fedecolor
local fadeintarget
local fadeouttarget
local tx_fps = love.graphics.newText(love.graphics.newFont(14), '')
local pausedaudio
local paused = false
local drawfps
local targetargs = {}

-- KB Button graphics
local gKBKeyZ = love.graphics.newImage( "common/graphics/keyboard/key_z.png" )
local gKBKeyX = love.graphics.newImage( "common/graphics/keyboard/key_x.png" )
local gKBKeyUp = love.graphics.newImage( "common/graphics/keyboard/key_up.png" )
local gKBKeyDown = love.graphics.newImage( "common/graphics/keyboard/key_down.png" )
local gKBKeyLeft = love.graphics.newImage( "common/graphics/keyboard/key_left.png" )
local gKBKeyRight = love.graphics.newImage( "common/graphics/keyboard/key_right.png" )
local gKBKeyReturn = love.graphics.newImage( "common/graphics/keyboard/key_return.png" )
-- PS Button graphics
local gPSButtonCross = love.graphics.newImage( "common/graphics/ds4/cross.png" )
local gPSButtonCircle = love.graphics.newImage( "common/graphics/ds4/circle.png" )
local gPSButtonUp = love.graphics.newImage( "common/graphics/ds4/dpad_up.png" )
local gPSButtonDown = love.graphics.newImage( "common/graphics/ds4/dpad_down.png" )
local gPSButtonLeft = love.graphics.newImage( "common/graphics/ds4/dpad_left.png" )
local gPSButtonRight = love.graphics.newImage( "common/graphics/ds4/dpad_right.png" )
local gPSButtonOptions = love.graphics.newImage( "common/graphics/ds4/options.png" )

local cbs = nil -- current
local cbs1 = love.graphics.newShader( cbs1_str )
local cbs2 = love.graphics.newShader( cbs2_str )
local cbs3 = love.graphics.newShader( cbs3_str )
local cbm_strings = {
    [0] = 'No Effect',
    [1] = 'Deuteranopia',
    [2] = 'Protanopia',
    [3] = 'Tritanopia'
}
local cbm = 0

local game_canvas = love.graphics.newCanvas(960, 540)
game_canvas:setFilter('nearest')

local function setKBButtons()
    print( "Setting buttons for keboard" )
    _GMGButton1     = gKBKeyZ
    _GMGButton2     = gKBKeyX
    _GMGButtonUp    = gKBKeyUp
    _GMGButtonDown  = gKBKeyDown
    _GMGButtonLeft  = gKBKeyLeft
    _GMGButtonRight = gKBKeyRight
    _GMGButtonStart = gKBKeyReturn
end

local function setPSButtons()
    print( "Setting buttons for DualShock 4" )
    _GMGButton1     = gPSButtonCross
    _GMGButton2     = gPSButtonCircle
    _GMGButtonUp    = gPSButtonUp
    _GMGButtonDown  = gPSButtonDown
    _GMGButtonLeft  = gPSButtonLeft
    _GMGButtonRight = gPSButtonRight
    _GMGButtonStart = gPSButtonOptions
end

local function mapRange( a1, a2, b1, b2, s )
    return b1 + ( s-a1 )*( b2-b1 )/( a2-a1 )
end

local function changeState( statename, args )
    args = args or nil
    if stateman.list[statename] then
        love.audio.stop( )
        love.audio.setVolume(1.0) -- TODO add global volume control
        if current and current.stop then
            current.stop( statename )
        end
        local last = current
        currentname = statename
        current = stateman.list[statename]
        if current.init then
            local newx,newy
            if type( args ) == "table" then
                newx, newy = current.init( last, args )
            else
                newx, newy = current.init( last )
            end
            if newx and newy then
                love.window.updateMode( newx, newy )
            end
        end
    else
        error("No such state as '"..statename.."'!")
    end
end

local function fadeIn( transition )
    if type( transition.color ) == "table" then
        if type( transition.time ) == "number" then
            fadeintime = transition.time
            fedecolor = transition.color
            return transition.time
        else
            error( "FadeIn time must be number!" )
        end
    else
        error( "Color must be table!" )
    end
end

local function fadeOut( transition )
    if type( transition.color ) == "table" then
        if type( transition.time ) == "number" then
            fadeouttime = transition.time
            fedecolor = transition.color
            return transition.time
        else
            error( "FadeOut time must be number!" )
        end
    else
        error( "Color must be table!" )
    end
end

local function fadeInOut( transition )
    if type( transition.color ) == "table" then
        if type( transition.fintime ) == "number" and type( transition.fouttime ) == "number" then
            fadeintime = transition.fintime
            fadeouttime = transition.fouttime
            fedecolor = transition.color
            return transition.fintime, transition.fouttime
        else
            error( "FadeIn/Out time must be number!" )
        end
    else
        error( "Color must be table!" )
    end
end

local function manupdate( dt )
    timer = timer + dt
    if fadeintarget then
        if fadeintime > 0 then
            fadeintime = fadeintime - dt
            local value = mapRange( 0, fadeintarget, 1, 0, fadeintime )
            fedecolor[4] = value
        else
            changeState( targetargs[1], targetargs[2] )
            if not fadeouttarget then
                if current.transitionfinished then
                    current.transitionfinished( )
                end
            end
            fadeintarget = nil
        end
    end
    
    if fadeouttarget then
        if not fadeintarget then
            if fadeouttime > 0 then
                fadeouttime = fadeouttime - dt
                local value = mapRange( 0, fadeouttarget, 0, 1, fadeouttime )
                fedecolor[4] = value
            else
                if current.transitionfinished then
                    current.transitionfinished() 
                end
                fadeouttarget = nil
            end
        end
    end
end

local function mandraw( )
    if fadeintarget then
        love.graphics.setColor( fedecolor )
        love.graphics.rectangle( "fill", 0, 0, 960, 540 )
    end
    if fadeouttarget then
        love.graphics.setColor( fedecolor )
        love.graphics.rectangle( "fill", 0, 0, 960, 540 )
    end
    if paused then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle('fill',0,0,960,540)
        love.graphics.setColor(1,1,1)
        love.graphics.printf( "Game Paused", _GMFont24,0 , 540 / 2 - 100, 960, "center" )
        love.graphics.printf( "Press      to resume the game.", _GMFont24,0 , 540 / 2 - 50, 960, "center" )
        love.graphics.draw(_GMGButtonStart,370,540 / 2 - 50)
    end
end

stateman.list = {}

function stateman.load( )
    setKBButtons()
    realx = res[1]
    realy = res[2]
end

-- Callbacks

function stateman.update( dt )
    manupdate( dt )
    if not paused then
        current.update( dt )
    end
end

function stateman.draw( )
    
    -- draw things
    scale = math.min(realx/res[1],realy/res[2])
    movex = math.floor((realx/2)-((res[1]/2)*scale))+sxo
    movey = math.floor((realy/2)-((res[2]/2)*scale))

    game_canvas:renderTo(function()
        love.graphics.clear(0, 0, 0)
        love.graphics.setColor( 1, 1, 1, 1 )
        current.draw( )
    end)

    love.graphics.setShader(cbs)
    love.graphics.push()
    love.graphics.translate(movex,movey)
    love.graphics.scale(scale)
    love.graphics.setColor( 1, 1, 1, 1 )
    love.graphics.draw(game_canvas)
    mandraw( )
    if drawfps then
        tx_fps:set(love.timer.getFPS( ))
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle('fill',0,0,tx_fps:getWidth(),tx_fps:getHeight())
        love.graphics.setColor(0,1,0)
        love.graphics.draw(tx_fps)
    end
    love.graphics.pop()
    love.graphics.setShader()
end

function stateman.draw_transform( drawable )
    love.graphics.setShader(cbs)
    scale = math.min(realx/res[1],realy/res[2])
    movex = math.floor((realx/2)-((res[1]/2)*scale))+sxo
    movey = math.floor((realy/2)-((res[2]/2)*scale))
    love.graphics.push()
        love.graphics.translate(movex,movey)
        love.graphics.scale(scale)
        love.graphics.setColor( 1, 1, 1, 1 )
        love.graphics.draw(drawable)
    love.graphics.pop()
    love.graphics.setShader()
end

function stateman.keypressed( key, scancode, isrepeat )
    _INPUTMAN.keypressed(key, scancode, isrepeat)
    if not paused then
        local buttonindex
        if key == "z" then buttonindex = 1 end
        if key == "x" then buttonindex = 2 end
        if key == "up" then buttonindex = 3 end
        if key == "down" then buttonindex = 4 end
        if key == "left" then buttonindex = 5 end
        if key == "right" then buttonindex = 6 end
        if key == "return" then buttonindex = 7 end

        if buttonindex then
            current.buttonpressed( buttonindex )
        end
        current.keypressed( key, scancode, isrepeat )
    else
        if key == "return" then
            stateman.resumegame()
        end
    end
    if key == "f1" then
        drawfps = not drawfps
    end
    if key == 'f11' and not _WEBBUILD then
        local full = love.window.getFullscreen()
        if not full then
            res[1], res[2] = love.graphics.getDimensions()
            sxo = love.window.getSafeArea()
            realx, realy = love.window.getDesktopDimensions()
            realx = realx - sxo*2
            love.window.updateMode(realx,realy,{fullscreen=true,resizable=false})
            stateman.resize()
        else
            res[1] = 960
            res[2] = 540
            realx = res[1]
            realy = res[2]
            love.window.updateMode(realx,realy,{fullscreen=false,resizable=false})
            stateman.resize()
        end
    end
    if key == 'f12' then
        cbm = cbm + 1
        if cbm > 3 then
            cbm = 0
        end
        if cbm == 0 then cbs = nil end
        if cbm == 1 then cbs = cbs1 end
        if cbm == 2 then cbs = cbs2 end
        if cbm == 3 then cbs = cbs3 end
        print('CB Mode', cbm_strings[cbm])
    end
end

function stateman.keyreleased( key, scancode )
    _INPUTMAN.keyreleased(key, scancode)
    if not paused then
        local buttonindex
        if key == "z" then buttonindex = 1 end
        if key == "x" then buttonindex = 2 end
        if key == "up" then buttonindex = 3 end
        if key == "down" then buttonindex = 4 end
        if key == "left" then buttonindex = 5 end
        if key == "right" then buttonindex = 6 end
        if key == "return" then buttonindex = 7 end

        if buttonindex then
            current.buttonreleased( buttonindex )
        end
        current.keyreleased( key, scancode )
    end
end

function stateman.mousemoved( x, y, dx, dy, istouch )
    x = x / scale
    y = y / scale
    current.mousemoved( x, y, dx, dy, istouch )
end

function stateman.mousepressed( x, y, button, istouch, presses )
    x = x / scale
    y = y / scale
    current.mousepressed( x, y, button, istouch, presses )
end

function stateman.mousereleased( x, y, button, istouch, presses )
    x = x / scale
    y = y / scale
    current.mousereleased( x, y, button, istouch, presses )
end

function stateman.joystickhat( joystick, hat, direction )
    if not paused then
        local buttons = {false,false,false,false}

        if direction == "c" then buttons = {false,false,false,false} end
        if direction == "u" then buttons = {true,false,false,false} end
        if direction == "d" then buttons = {false,true,false,false} end
        if direction == "l" then buttons = {false,false,true,false} end
        if direction == "r" then buttons = {false,false,false,true} end

        if direction == "lu" then buttons = {true,false,true,false} end
        if direction == "ru" then buttons = {true,false,false,true} end
        if direction == "ld" then buttons = {false,true,true,false} end
        if direction == "rd" then buttons = {false,true,false,true} end

        for k,v in pairs(buttons) do
            if v then
                if current and current.buttonpressed then
                    current.buttonpressed( k+2 )
                end
            else
                if current and current.buttonreleased then
                    current.buttonreleased( k+2 )
                end
            end
        end
        current.joystickhat( joystick, hat, direction )
    end
end


function stateman.joystickaxis( joystick, axis, value )
    local buttons = {false, false, false, false}
	--print(axis) -- 8 = up/down, 7 = left/right (dpad)
    --print(value) -- 1/0/-1
    --    -1
    -- -1     1
    --     1
    if axis == 7 then
        if value == 1 then
            buttons[4] = true
        end
        if value == -1 then
            buttons[3] = true
        end
    end
    if axis == 8 then
        if value == 1 then
            buttons[2] = true
        end
        if value == -1 then
            buttons[1] = true
        end
    end

    if axis > 6 and axis < 9 then
        for k,v in pairs(buttons) do
            if v then
                current.buttonpressed( k+2 )
            else
                current.buttonreleased( k+2 )
            end
        end
    end
end

local function isDS4( joystick )
    if string.find(joystick:getName( ), "Sony Computer Entertainment Wireless Controller") then return true end
    if string.find(joystick:getName( ), "PS4 Controller") then return true end
    return false
end

function stateman.joystickpressed( joystick, button )
    local buttonindex
    if string.find(joystick:getName( ), "PS4 Controller") then
        if button == 1 then buttonindex = 1 end
        if button == 2 then buttonindex = 2 end
        if button == 12 then buttonindex = 3 end
        if button == 13 then buttonindex = 4 end
        if button == 14 then buttonindex = 5 end
        if button == 15 then buttonindex = 6 end
        if button == 7 then buttonindex = 7 end
    end
    if string.find(joystick:getName( ), "Sony Computer Entertainment Wireless Controller") then
        if button == 1 then buttonindex = 1 end
        if button == 2 then buttonindex = 2 end
        if button == 10 then buttonindex = 7 end
    end
    
    if not paused then
        if buttonindex then
            current.buttonpressed( buttonindex )
        end
        current.joystickpressed( joystick, button )
    else
        if buttonindex == 7 then    -- start button
            stateman.resumegame()
        end
    end
end

function stateman.joystickreleased( joystick, button )
    local buttonindex
    if string.find(joystick:getName( ), "PS4 Controller") then
        if button == 1 then buttonindex = 1 end
        if button == 2 then buttonindex = 2 end
        if button == 12 then buttonindex = 3 end
        if button == 13 then buttonindex = 4 end
        if button == 14 then buttonindex = 5 end
        if button == 15 then buttonindex = 6 end
        if button == 7 then buttonindex = 7 end
    end
    if string.find(joystick:getName( ), "Sony Computer Entertainment Wireless Controller") then
        if button == 1 then buttonindex = 1 end
        if button == 2 then buttonindex = 2 end
        if button == 10 then buttonindex = 7 end
    end
    
    if not paused then
        if buttonindex then
            current.buttonreleased( buttonindex )
        end
        current.joystickreleased( joystick, button )
    end
end

function stateman.joystickadded( joystick )
    print( "Joystick added:", joystick:getName( ) )
    if isDS4( joystick ) then
        setPSButtons( )
    else
        print("Unsupported joystick")
    end
    current.joystickadded( joystick )
end

function stateman.joystickremoved( joystick )
    setKBButtons()
    current.joystickremoved( joystick )
end

function stateman.textinput( t )
    current.textinput( t )
end

function stateman.focus( focus )
    if not paused then
        current.focus( focus )
    end
end

function stateman.quit( )
    print('Shutting down...')
    local q = current.quit( )
    print('Goodbye! :)')
    return q
end

function stateman.resize( w, h )
    current.resize( w, h )
end

-- other

function stateman.change( statename, args, transition )
    args = args or nil
    transition = transition or nil

    if type( transition ) == "table" then
        if type( transition.ttype ) == "string" then
            if transition.ttype == "fadeinout" then
                fadeintarget, fadeouttarget = fadeInOut( transition )
                targetargs = { statename, args }
            elseif transition.ttype == "fadein" then
                fadeintarget = fadeIn( transition )
                targetargs = { statename, args }
            elseif transition.ttype == "fadeout" then
                fadeouttarget = fadeOut( transition )
                changeState( statename, args )
            else
                error("Unknown transition '"..transition.ttype.."'!")
            end
        else
            error("Transition type must be string!")
        end
    else
        changeState( statename, args )
    end
end

function stateman.pausegame( )
    current.pause()
    paused = true
    pausedaudio = love.audio.pause( )
    -- love.js fix (bruh)
    for k, v in pairs(pausedaudio) do
        v:pause()
    end
end

function stateman.resumegame( )
    -- love.js fix (bruh)
    for k, v in pairs(pausedaudio) do
        v:play()
    end
    pausedaudio = nil
    paused = false
    current.resume()
end

function stateman.addState(state_tab, name)
    if not name or type(name) ~= 'string' then
        error('Missing or incorrect state name')
    end
    if stateman.list[name] then
        error('State \"'..name..'\" already exists!')
    end
    setmetatable(state_tab, state_meta)
    stateman.list[name] = state_tab
end

function stateman.getWidth()
    return 960
end

function stateman.getHeight()
    return 540
end

function stateman.actionPressed(action, isrepeat)
    print(action, 'pressed')
end

function stateman.actionReleased(action)
    print(action, 'released')
end

return stateman
