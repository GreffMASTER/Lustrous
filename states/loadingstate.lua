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

local function draw_progress_text(text)
    logscreen = logger.log(text)
    rot1 = rot1 + 0.0075
    rot2 = rot2 - 0.01
    rot3 = rot3 + 0.0225
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
        song_names[1] = 'lustrous.canyoufeel'
        song_names[2] = 'lustrous.protocol'
        song_names[3] = 'lustrous.lifeisnotover'
        song_list[1] = _SONGS['lustrous.canyoufeel']
        song_list[2] = _SONGS['lustrous.protocol']
        song_list[3] = _SONGS['lustrous.lifeisnotover']
        for i=1,2 do
            if not song_list[i] then
                error('One or more songs for the club mode are missing!')
            end
        end
    end

    if mode == 'mixtape' then
        if not args.songlist or #args.songlist == 0 then error('No songs in the mixtape!') end
        for k,v in ipairs(args.songlist) do
            local sn = _SONGS[v]
            if not sn then
                error(string.format('Song "%s" not found!', v))
            end
            table.insert(song_list, sn)
            table.insert(song_names, v)
        end
    end

    if mode == 'ta' then
        song_names[1] = 'greffmaster.blackbeat'
        song_list[1] = _SONGS_TA['greffmaster.blackbeat']
        if not song_list[1] then
            error('One or more songs for the TA mode are missing!')
        end
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
        rot3 = rot3 + 0.0225
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