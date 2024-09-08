-- Project Greenbox (Lustrous) 2022-2024
-- Started around 06/21/2022 9:00 PM
-- Currently      04/09/2024

_LVERSION = 'Lustrous v. Alpha 1.2.3_02 (2024-Apr-10) (Fool\'s Demo)'
_WEBBUILD = false
_GMState = require 'stateman'
_PROFILE = nil
_AVATARS = {}
_SONGS = {}
_SONGS_TA = {}
_DEBUG = false

local loader = require 'common.loader'
local logger = require 'common.logger'

local g_loading = love.graphics.newImage('common/graphics/loading.png')
local rot1 = 0
local rot2 = 0
local rot3 = 0
local logscreen = nil

local function quick_draw()
    love.graphics.clear(0,0,0)
    love.graphics.setColor(1,1,1,.3)
    love.graphics.draw(g_loading, 960-70, 540-70, rot1, 1, 1, 256, 256)
    love.graphics.setColor(1,1,1,.6)
    love.graphics.draw(g_loading, 960-70, 540-70, rot2, .75, .75, 256, 256)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(g_loading, 960-70, 540-70, rot3, .5, .5, 256, 256)
    if logscreen and _DEBUG then love.graphics.draw(logscreen) end

    love.graphics.present( )
end

function draw_progress_text(text)
    logscreen = logger.log(text)
    rot1 = rot1 + 0.0075
    rot2 = rot2 - 0.01
    rot3 = rot3 + 0.0125
    quick_draw()
end

function love.load(args)
    draw_progress_text(_VERSION)
    love.graphics.setDefaultFilter( 'nearest', 'nearest', 1 )
    draw_progress_text(_LVERSION)
    -- Create fonts
    draw_progress_text('Creating fonts...')
    _GMFont14 = love.graphics.newFont( 14 )
    _GMFont20 = love.graphics.newFont( 20 )
    _GMFont24 = love.graphics.newFont( 24 )
    _GMFont32 = love.graphics.newFont( 32 )
    _GMFont48 = love.graphics.newFont( 48 )
    _GMFont64 = love.graphics.newFont( 64 )
    _GMFont128 = love.graphics.newFont( 128 )
    _GMFont256 = love.graphics.newFont( 256 )
    -- Initiate stateman
    draw_progress_text('Starting StateMan...')
    _GMState.load( )
    -- Load states to the state list
    draw_progress_text('Loading game states...')
    
    draw_progress_text('Loading "states.bootstate" as "boot"')
    _GMState.addState(require 'states.bootstate', 'boot')
    draw_progress_text('Loading "states.avatartest" as "avtest"')
    _GMState.addState(require 'states.avatartest', 'avtest')
    draw_progress_text('Loading "states.inputstate" as "input"')
    _GMState.addState(require 'states.inputstate', 'input')
    draw_progress_text('Loading "states.introstate" as "intro"')
    _GMState.addState(require 'states.introstate', 'intro')
    draw_progress_text('Loading "states.menustate" as "menu"')
    _GMState.addState(require 'states.menustate', 'menu')
    draw_progress_text('Loading "states.loadingstate" as "loading"')
    _GMState.addState(require 'states.loadingstate', 'loading')
    draw_progress_text('Loading "states.gamestate" as "game"')
    _GMState.addState(require 'states.gamestate', 'game')
    draw_progress_text('Loading "states.quitstate" as "quit"')
    _GMState.addState(require 'states.quitstate', 'quit')

    draw_progress_text('Loading "states.demo_start" as "demo_start"')
    _GMState.addState(require 'states.demo_start', 'demo_start')
    draw_progress_text('Loading "states.demo_end" as "demo_end"')
    _GMState.addState(require 'states.demo_end', 'demo_end')
    -- load avatars
    draw_progress_text('Loading avatars...')
    loader.loadAvatars()
    -- load songs
    draw_progress_text('Loading songs...')
    loader.loadSongs()
    draw_progress_text('Done!')
    
    print('Avatars loaded:')
    for k,v in pairs(_AVATARS) do
        print(k, v)
    end
    print('Songs loaded:')
    for k,v in pairs(_SONGS) do
        print(k, v)
    end
    
    -- Set to the boot state
    _GMState.change('boot',nil,
        {ttype='fadeout',color={0,0,0},time=1}
    )
end

-- Callbacks
love.update             =   _GMState.update
love.draw               =   _GMState.draw
love.keypressed         =   _GMState.keypressed
love.keyreleased        =   _GMState.keyreleased
love.mousemoved         =   _GMState.mousemoved
love.mousepressed       =   _GMState.mousepressed
love.mousereleased      =   _GMState.mousereleased
love.joystickhat        =   _GMState.joystickhat
love.joystickaxis       =   _GMState.joystickaxis
love.joystickpressed    =   _GMState.joystickpressed
love.joystickreleased   =   _GMState.joystickreleased
love.joystickadded      =   _GMState.joystickadded
love.joystickremoved    =   _GMState.joystickremoved
love.textinput          =   _GMState.textinput
love.focus              =   _GMState.focus
love.quit               =   _GMState.quit
love.resize             =   _GMState.resize
