local loading = {}

local logger = require 'common.logger'

local g_loading = love.graphics.newImage('common/graphics/loading.png')
local rot1 = 0
local rot2 = 0
local rot3 = 0
local logscreen = nil
local loading_screen = love.graphics.newCanvas(960, 540)

local song_list = {}
local song_names = {}
local cur = 1
local passargs = {}

local webfix = 0

local function quick_draw()
    loading_screen:renderTo(function()
        love.graphics.clear(0,0,0)
        love.graphics.setColor(1,1,1,.3)
        love.graphics.draw(g_loading, 960-70, 540-70, rot1, 1, 1, 256, 256)
        love.graphics.setColor(1,1,1,.6)
        love.graphics.draw(g_loading, 960-70, 540-70, rot2, .75, .75, 256, 256)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(g_loading, 960-70, 540-70, rot3, .5, .5, 256, 256)
        if logscreen and _DEBUG then love.graphics.draw(logscreen) end
    end)
    
    _GMState.draw_transform(loading_screen)
    love.graphics.present( )
end

function draw_progress_text(text)
    logscreen = logger.log(text)
    rot1 = rot1 + 0.0075
    rot2 = rot2 - 0.01
    rot3 = rot3 + 0.0125
end

function loading.init(last_state, args)
    collectgarbage('collect')
    song_list = {}
    song_names = {}
    passargs = args
    cur = 1
    webfix = 0

    local mode = 'club'
    if not args then
        mode = 'club'
    end
    if args.mode ~= 'club' and args.mode ~= 'mixtape' and args.mode ~= 'ta' then
        mode = 'club'
    else
        mode = args.mode
    end

    if mode == 'club' then
        song_names[1] = 'greffmaster.idkwimd'
        song_list[1] = _SONGS['greffmaster.idkwimd']
        for i=1,1 do
            if not song_list[i] then
                error('One or more songs for the club mode are missing!')
            end
        end
    end

    if mode == 'mixtape' then
        error('Mixtape mode not implemented in this build. Please wait for the next demo. :)')
    end

    if mode == 'ta' then
        error('Time attack mode not implemented in this build. Please wait for the next demo. :)')
    end

    if not _WEBBUILD then
        for k,v in pairs(song_list) do
            draw_progress_text(string.format('Loading assets for song "%s"...', song_names[k]))
            quick_draw()
            v:load()
            if not v.music then
                error('Song failed to load \"music\" variable. Cannot proceed!')
            end
        end
        draw_progress_text('Done! Switching to gamestate...')
        _GMState.change('game', passargs)
    end
end

-- Code below, web build only

-- Q: Why is it split between init, update and draw? Why don't you do it all in init instead?
-- A: love.js

function loading.update(dt)
    if cur > #song_list then
        -- add a few second delay for webfix
        -- thanks love.js
        webfix = webfix + dt
        rot1 = rot1 + 0.0075
        rot2 = rot2 - 0.01
        rot3 = rot3 + 0.0125
        if webfix >= 2 then
            draw_progress_text('Done! Switching to gamestate...')
            _GMState.change('game', passargs)
        end
    else
        local v = song_list[cur]

        draw_progress_text(string.format('Loading assets for song "%s"...', song_names[cur]))
        v:load()
        if not v.music then
            error('Song failed to load \"music\" variable. Cannot proceed!')
        end

        cur = cur + 1
    end
end

function loading.draw()
    loading_screen:renderTo(function()
        love.graphics.clear(0,0,0)
        love.graphics.setColor(1,1,1,.3)
        love.graphics.draw(g_loading, 960-70, 540-70, rot1, 1, 1, 256, 256)
        love.graphics.setColor(1,1,1,.6)
        love.graphics.draw(g_loading, 960-70, 540-70, rot2, .75, .75, 256, 256)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(g_loading, 960-70, 540-70, rot3, .5, .5, 256, 256)
        if logscreen and _DEBUG then love.graphics.draw(logscreen) end
    end)
    love.graphics.draw(loading_screen)
end

return loading