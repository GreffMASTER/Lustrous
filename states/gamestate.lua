-- The main gamestate
-- Gaze upon my 'glorious' code!
-- ...help...

local gamestate = {}

local logic = require 'states.gamestate.gamelogic'
local debugstuff = require 'states.gamestate.debug'
local perfstuff = require 'states.gamestate.performance'
local utils = require 'common.utils'
local state_g_path = 'states/gamestate/graphics/'

local song_list = {}
local all_songs = {}

local song
local previous_song
local avatar

-- canvases
local previous_blocks = {
    love.graphics.newCanvas(32, 32),
    love.graphics.newCanvas(32, 32)
}
local song_canvas = love.graphics.newCanvas(960, 540)
local previous_song_canvas = love.graphics.newCanvas(960, 540)
local field_canvas = love.graphics.newCanvas(960, 540)
local g_block1 = love.graphics.newCanvas(32, 32)
local g_block2 = love.graphics.newCanvas(32, 32)
local cslider = love.graphics.newCanvas(512, 32)
local avatar_canvas = love.graphics.newCanvas(128, 128)
local klele_canvas

-- graphics
local gloop = love.graphics.newImage(state_g_path..'loop.png')
local gnext = love.graphics.newImage(state_g_path..'next.png')
local gbeats = love.graphics.newImage(state_g_path..'beats.png')
local glinegrad = love.graphics.newImage(state_g_path..'line_grad.png')
local gblocknext = love.graphics.newImage(state_g_path..'block_next.png')
local gslider = love.graphics.newImage(state_g_path..'slider.png')
local gslidermask = love.graphics.newImage(state_g_path..'slider_mask.png')

gslider:setWrap('repeat')
gslidermask:setWrap('repeat')

-- shaders
local shd_mask = require 'common.shader.alpha_mask'

-- windows
local debug_win = debugstuff.newDebugWindow()
local perf_win = perfstuff.newPerformanceWindow(800, 0)

-- constants
local SPRINT_DELAY = 0.25
-- variables
local mode = 'club'
local tdone = false
local buttons_held = {false,false,false,false,false,false,false}
local button_timer = 0
local repeat_direction_timer = 0
local repeat_down_timer = 0
local sprint = false
local linepos = 224
local lineblockpos = 1
local linetimer = 0
local inloop = false
local lp = 1
local jp = 1
local beats_timer = 0
local beatem = 0.25
local ending = false
local endtimer = 3
local ogspeed, ogbeat
local endalpha = 0
local part_jump = 1
local fallhold = 3
local falldelay = 0
local tatime = 60
local avatar_scale = 1
local hack1 = true -- a hack to prevent updating before everything loads (fixes song sync issue at the beginning)
local cursongid = 0
local happy_timer = 0
local is_happy = false
local sliderx = 0
local countdown = 3.0
local menu_state = 'menu'

local qbeats = love.graphics.newQuad(0, 0, linepos-224, 32, 512, 32)
local qslider = love.graphics.newQuad(sliderx, 0, 512, 32, 512, 32)

--=========================-- LOCAL FUNCTIONS --=========================--

local function resetVars()
    tdone = false
    buttons_held = {false,false,false,false,false,false,false}
    button_timer = 0
    repeat_direction_timer = 0
    repeat_down_timer = 0
    sprint = false
    linepos = 224
    linetimer = 0
    lineblockpos = 1
    inloop = false
    lp = 1
    beats_timer = 0
    beatem = 0.25
    ending = false
    endtimer = 3
    endalpha = 0
    part_jump = 1
    avatar_scale = 1
    logic.level = 0
    logic.score = 0
    logic.timer = 0
    logic.highscore = 0
    fallhold = 3
    happy_timer = 0
    is_happy = false
    
    song_canvas:renderTo(function()
        love.graphics.clear(0,0,0,0)
    end)
    previous_song_canvas:renderTo(function()
        love.graphics.clear(0,0,0,0)
    end)
    previous_blocks[1]:renderTo(function()
        love.graphics.clear(0,0,0,0)
    end)
    previous_blocks[2]:renderTo(function()
        love.graphics.clear(0,0,0,0)
    end)
    previous_song = nil
    logic.highscore = _PROFILE:getScore(mode, tatime)
    if logic.highscore > 99999999999 then logic.highscore = 99999999999 end
end

local function lerp(a, b, t)
    return (1-t)*a + t*b
end

local function beatIt(scale)
    if ending then return end
    beatem = 1
    beats_timer = 0
    avatar_scale = scale
    
    avatar:beat(scale)
    song:beat(scale)
end

local function skipLoop()
    if inloop then
        inloop = false
        debug_win.children[5]:disable()
        lp = lp + 1
        if lp > #song.timestamps.loops then lp = 0 end
    end
end

local function partLoopUp()
    part_jump = part_jump + 1
    if part_jump > #song.timestamps.loops then part_jump = 1 end
    debug_win.children[9].text = part_jump
end

local function partLoopDown()
    part_jump = part_jump - 1
    if part_jump < 1 then part_jump = #song.timestamps.loops end
    debug_win.children[9].text = part_jump
end

local function jumpToLoop()
    lp = part_jump
    linetimer = 0
    linepos = 224
    inloop = true
    debug_win.children[5]:enable()
    beatIt(2)
    song.music:seek(song.timestamps.loops[ part_jump ].starts, 'seconds')
    song:linehit(song.music:tell('seconds'), inloop)
    logic.clearedfield = {
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    }
end

local function resetSong()
    song.music:stop()
    lp = 1
    jp = 1
    linepos = 224
    inloop = false
    beats_timer = 0
    linetimer = 0
    debug_win.children[5]:disable()
    song:init()
    song.music:setPitch(1)
    song.music:setVolume(0)
    song.music:setLooping(true)
    song.music:play()
    song:play()
    if song.timestamps.offset then
        song.music:seek(song.timestamps.offset, 'seconds')
    end
    beatIt(2)
end

local function processLine(dt)
    -- move the line (tm)
    linetimer = linetimer + dt
    linepos = linepos + dt * song.speed
    -- check for cleared blocks
    if not ending then
        if (linepos-224)/32 > lineblockpos then
            if logic.checklinepos(lineblockpos) then skipLoop() end
            lineblockpos = lineblockpos + 1
        end
    end

    if beatem > 0.25 then beatem = beatem - (beatem-0.25) * 2 * dt end

    if linepos > 736 then -- line reached the end
        is_happy = false
        happy_timer = 0
        local multi = logic.cashIn()
        -- update avatar status
        if not ending then
            local bloccount = 0
            for _, y in pairs(logic.field) do
                for _, x in pairs(y) do
                    if x > 0 then bloccount = bloccount + 1 end
                end
            end
            if bloccount > 99 then
                avatar:danger()
            else
                avatar:normal()
            end
            if multi > 1 then
                avatar:combo(multi)
                is_happy = true
                happy_timer = 4
            end
        end

        if mode == 'ta' or mode == 'puzzle' then
            if logic.timer / tatime <= 0.125 then
                avatar:danger()
            end
        end

        linetimer = 0
        beatIt(2)
        linepos = 224
        lineblockpos = 0 -- originally was 1, but the very first collumn wasnt cleared, this is a dirty hack
        
        song:linehit(song.music:tell('seconds'), inloop)
        -- audio loops
        if lp > 0 then
            if song.music:tell('seconds') >= math.floor(song.timestamps.loops[lp].starts)-1 then
                inloop = true
                song.music:seek(song.timestamps.loops[lp].starts, 'seconds')
                song:jump(song.music:tell('seconds'))
                debug_win.children[5]:enable()
            end
            if song.music:tell('seconds') >= math.floor(song.timestamps.loops[lp].ends)-1 then
                song.music:seek(song.timestamps.loops[lp].starts, 'seconds')
                song:jump(song.music:tell('seconds'))
            end
        end
        if song.music:tell('seconds') >= math.floor(song.timestamps.ends)-1 then -- song reached its end
            song.music:seek(song.timestamps.starts, 'seconds') -- loop to the beginning of the song
            lp = 1 -- reset loop part
            jp = 1
            -- check if the returned part is in loop
            if song.music:tell('seconds') >= math.floor(song.timestamps.loops[lp].starts)-1 then
                inloop = true
                song.music:seek(song.timestamps.loops[lp].starts, 'seconds')
                debug_win.children[5]:enable()
            end
            if song.music:tell('seconds') >= math.floor(song.timestamps.loops[lp].ends)-1 then
                song.music:seek(song.timestamps.loops[lp].starts, 'seconds')
            end
            song:jump(song.music:tell('seconds'))
        end
        if song.timestamps.jumps then -- new feature, not every song has it
            if jp > 0 then
                if song.music:tell('seconds') >= math.floor(song.timestamps.jumps[jp].starts)-1 then
                    song.music:seek(song.timestamps.jumps[jp].ends, 'seconds')
                    jp = jp + 1
                    if jp > #song.timestamps.jumps then jp = 0 end
                    song:jump(song.music:tell('seconds'))
                end
            end
        end
    end
    -- update logic linepos
    logic.linepos = linepos
end

local function gameover(timeup)
    ogspeed = song.speed
    ending = true
    for i=1,7 do
        gamestate.buttonreleased(i)
    end
    buttons_held = {false,false,false,false,false,false,false}
    logic.gameover()
    song:gameover(timeup)
    avatar:gameover()
    if logic.highscore >= logic.score then
        _PROFILE:setNewScore(logic.score, mode, tatime)
        _PROFILE:save()
    end
end

local function drawGrid()
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1,1,1,0.1)
    for i=1,9 do
        local y = (i*32)+160
        love.graphics.line(224,y,672+64,y)
    end
    for j=1,15 do
        local x = (j*32)+224
        love.graphics.line(x,160,x,_GMState.getHeight()-64)
    end
end

local function drawUI()
    -- draw song title and artist
    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle('fill', 0, 510, 960, 540-510)
    love.graphics.setColor(1, 1, 1)
    local songtext = '\"'..song.frontend.title..'\" / '..song.frontend.artist
    utils.printfWithShadow(songtext, _FONTMAN.getFont(24), 0, 510, 950, 'right')
    if ending or hack1 then return end
    -- song status (looping/not looping)
    if inloop then
        love.graphics.draw(gloop, 448, 16)
    else
        love.graphics.draw(gnext, 448, 16)
    end
end

local function moveBlock(direction)
    local tx = math.ceil((logic.blockX - 224) / 32) + 1
    local ty = math.ceil((logic.blockY - 160) / 32) + 1
    if direction == 'up' then
        if logic.blockY > 96 then
            logic.blockY = logic.blockY - 32
        end
        return
    end
    if direction == 'down' then
        if ty == -1 then
            if logic.field[1][tx] ~= 0 or logic.field[1][tx+1] ~= 0 then
                gameover()
                return
            end
        end
        if ty == 0 then
            if logic.field[2][tx] ~= 0 or logic.field[2][tx+1] ~= 0 then
                logic.placeBlock()
                if song.sfx_place then
                    song.sfx_place:stop()
                    song.sfx_place:play()
                end
                -- force to release the buttons
                gamestate.buttonreleased(4) -- down
                logic.fallBlocks()
                fallhold = 3 - logic.level / 25
                return
            end
        end
        if logic.blockY >= 416 then
            logic.placeBlock()
            if song.sfx_place then
                song.sfx_place:stop()
                song.sfx_place:play()
            end
            -- force to release the buttons
            gamestate.buttonreleased(4) -- down
            logic.fallBlocks()
            fallhold = 3 - logic.level / 25
            return
        end
        if ty > 0 then
            if logic.field[ty+2][tx] ~= 0 or logic.field[ty+2][tx+1] ~= 0 then
                logic.placeBlock()
                if song.sfx_place then
                    song.sfx_place:stop()
                    song.sfx_place:play()
                end
                -- force to release the buttons
                gamestate.buttonreleased(4) -- down
                logic.fallBlocks()
                fallhold = 3 - logic.level / 25
                return
            end
        end
        logic.blockY = logic.blockY + 32
        return
    end
    
    if direction == 'left' then
        if logic.blockX > 224 then
            if ty > -1 then
                if logic.field[ty+1][tx-1] == 0 then
                    logic.blockX = logic.blockX - 32
                end
            else
                logic.blockX = logic.blockX - 32
            end
            if not sprint then
                if song.sfx_move then song.sfx_move:stop(); song.sfx_move:play() end
            end
        end
        return
    end
    
    if direction == 'right' then
        if logic.blockX < 672 then
            if ty > -1 then
                if logic.field[ty+1][tx+2] == 0 then
                    logic.blockX = logic.blockX + 32
                end
            else
                logic.blockX = logic.blockX + 32
            end
            if not sprint then
                if song.sfx_move then song.sfx_move:stop(); song.sfx_move:play() end
            end
        end
        return
    end
end

local function nextSong()
    local song_max_vol = song.volume or 1
    if #song_list > 1 and not ending and song.music:getVolume() >= song_max_vol then
        cursongid = cursongid + 1
        if cursongid > #song_list then cursongid = 1 end
        if previous_song then previous_song.music:stop() end
        previous_song = song
        previous_blocks[1]:renderTo(function()
            love.graphics.clear(0,0,0,0)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(g_block1)
        end)
        previous_blocks[2]:renderTo(function()
            love.graphics.clear(0,0,0,0)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(g_block2)
        end)
        song = song_list[cursongid]
        resetSong()
        part_jump = lp
    end
end

--=========================-- GAMESTATE FUNCTIONS --=========================--

function gamestate.init(last_state, args)
    if _SONGS == 0 then
        error('No songs at all!!!')
    end
    if not args then
        mode = 'club'
    end
    if args.mode ~= 'club' and args.mode ~= 'mixtape' and args.mode ~= 'ta' then
        mode = 'club'
    else
        mode = args.mode
    end
    logic.mode = mode
    logic.nextsong_callback = nextSong
    logic.gamestate = gamestate
    resetVars()
    song_list = {}
    if mode == 'club' then
        -- set songs for club mode
        song_list[1] = _SONGS['lustrous.canyoufeel']
        song_list[2] = _SONGS['lustrous.protocol']
        song_list[3] = _SONGS['lustrous.lifeisnotover']
        for i=1,2 do
            if not song_list[i] then
                error('One or more songs for the club mode are missing!')
            end
        end
    elseif mode == 'mixtape' then
        if not args.songlist then
            local i = 1
            for k,v in pairs(_SONGS) do
                song_list[i] = v
                i = i + 1
            end
        else
            if #args.songlist == 0 then error('No songs in the mixtape!') end
            for k,v in ipairs(args.songlist) do
                local sn = _SONGS[v]
                song_list[k] = sn
            end
        end
    elseif mode == 'ta' then
        song_list[1] = _SONGS_TA['greffmaster.blackbeat']
        if not song_list[1] then
            error('One or more songs for the TA mode are missing!')
        end
        if not args.tatime then
            error('TA mode missing \"tatime\" argument!')
        end
        
        tatime = args.tatime
        logic.target_time = args.tatime
    end

    -- set the first song on the list to current song
    for k,v in pairs(song_list) do
        song = v
        cursongid = 1
        break
    end
    if not _AVATARS[_PROFILE.avatar] then
        error('Avatar \"'.._PROFILE.avatar..'\" is missing!')
    end
    avatar = _AVATARS[_PROFILE.avatar]
    avatar:init()
    song:init()
    logic.init()
    love.graphics.setBackgroundColor(0, 0, 0)
    debug_win.children[5].func = skipLoop
    debug_win.children[6].func = partLoopDown
    debug_win.children[7].func = partLoopUp
    debug_win.children[8].func = jumpToLoop
    debug_win.children[9].text = part_jump
    debug_win.children[11].func = resetSong
    debug_win.children[12].func = nextSong
    debug_win.children[13].func = avatar.danger
    debug_win.children[14].func = avatar.combo
    part_jump = lp
    countdown = 3.0
    sliderx = 0
    hack1 = true
    menu_state = args.menu_state or 'menu'
end

function gamestate.update(dt)
    if not hack1 then -- dont update until loaded all
        sliderx = sliderx + dt * (endtimer / 3) * song.speed * 0.5
        if sliderx > 512 then sliderx = 0 end
        -- song sync stuff
        processLine(dt)
        beats_timer = beats_timer + dt
        if beats_timer > song.beattime then
            beatIt(1.5)
        end

        -- gameover sequence
        if ending then
            if endtimer > 0 then
                song.music:setPitch(lerp(0.0001,1,endtimer/3))
                song.speed = lerp(0,ogspeed,endtimer/3)
                song.beattime = 999999999
                endalpha = lerp(0.8,0,endtimer/3)
                endtimer = endtimer - dt
            end
            if endtimer <= 0 then
                song.music:stop()
                if previous_song then previous_song.music:stop() end
                _GMState.change(menu_state,nil,{['ttype']='fadeout',['color']={0,0,0},['time']=1})
            end
        end

        -- fade in new song
        local song_max_vol = song.volume or 1
        if song.music:getVolume() < song_max_vol then
            local vol = song.music:getVolume() + dt / 6
            if vol > song_max_vol then vol = song_max_vol end
            song.music:setVolume(vol)
        end

        song:update(dt * (endtimer / 3))
        
        -- fade out previous song
        if previous_song then
            local vol = previous_song.music:getVolume()
            vol = vol - dt / 6
            if vol < 0 then
                previous_song.music:stop()
            else previous_song.music:setVolume(vol) end
        end

        logic.update(dt * (endtimer/3))
        logic.updateBlockFX(dt)
        if not ending then
            logic.time(dt)
            if song.time then song:time(logic.timer, tatime) end
        end
        -- time attack
        if mode == 'ta' or mode == 'puzzle' then
            if logic.timer <= 0 and not ending then
                gameover(true)
            end
        end
        -- avatar stuff
        if avatar_scale > 1 then
            avatar_scale = avatar_scale - (avatar_scale-1) * 4 * dt
        end
        if avatar_scale < 1 then avatar_scale = 1 end

        avatar:update(dt * (endtimer/3))
        if is_happy and not ending then
            happy_timer = happy_timer - dt
            if happy_timer <= 0 then
                is_happy = false
                if mode == 'ta' or mode == 'puzzle' then
                    if logic.timer / tatime <= 0.125 then
                        avatar:danger()
                    else
                        avatar:normal()
                    end
                else
                    local bloccount = 0
                    for _, y in pairs(logic.field) do
                        for _, x in pairs(y) do
                            if x > 0 then bloccount = bloccount + 1 end
                        end
                    end
                    if bloccount > 99 then
                        avatar:danger()
                    else
                        avatar:normal()
                    end
                end
            end
        end
        -- controls stuff
        if button_timer > 0 then
            button_timer = button_timer - dt * (endtimer/3)
        end
        -- Controls logic
        if not ending then
            if fallhold > 0 then
                fallhold = fallhold - dt
            else
                if falldelay > 0 then
                    falldelay = falldelay - dt
                else
                    moveBlock('down')
                    falldelay = 0.5 - logic.level / 100
                end
            end
            if buttons_held[4] then
                repeat_down_timer = repeat_down_timer + dt
                if repeat_down_timer >= 0.01 then
                    moveBlock('down')
                    logic.addScore(1)
                    repeat_down_timer = 0
                end
            end
            if buttons_held[5] and not buttons_held[6] and button_timer <= 0 then
                repeat_direction_timer = repeat_direction_timer + dt
                if repeat_direction_timer >= 0.0165 then
                    moveBlock('left')
                    repeat_direction_timer = 0
                end
                if not sprint then
                    if song.sfx_sprint then
                        song.sfx_sprint:stop()
                        song.sfx_sprint:play()
                    end
                end
                sprint = true
            end
            if buttons_held[6] and not buttons_held[5] and button_timer <= 0 then
                repeat_direction_timer = repeat_direction_timer + dt
                if repeat_direction_timer >= 0.0165 then
                    moveBlock('right')
                    repeat_direction_timer = 0
                end
                if not sprint then
                    if song.sfx_sprint then
                        song.sfx_sprint:stop()
                        song.sfx_sprint:play()
                    end
                end
                sprint = true
            end
        end
        -- debug stuff
        if _DEBUG then 
            perf_win:update(dt)
            debug_win.children[1].text = 'Song: '..song.music:tell('seconds')
            debug_win.children[2].text = 'Line: '..linetimer
            debug_win.children[3].text = 'Loop part: '..lp..' / '..#song.timestamps.loops
            debug_win.children[4].text = 'Beat: '..beats_timer
            debug_win.children[10].text = 'X: '..logic.blockX..' / Y: '..logic.blockY
            debug_win:update(dt)
        end
    else -- start delay
        countdown = countdown - dt
        if countdown <= 0 then
            hack1 = false
            resetSong()
        end
    end
end

function gamestate.draw()
    -- prepare block canvases
    g_block1:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        -- draw fade in
        love.graphics.setColor(1, 1, 1, song.music:getVolume())
        song:drawBlock(1)
        if previous_song and previous_song.music:getVolume() > 0 then
            love.graphics.setColor(1, 1, 1, previous_song.music:getVolume())
            love.graphics.draw(previous_blocks[1])
        end
    end)
    g_block2:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        -- draw fade in
        love.graphics.setColor(1, 1, song.music:getVolume())
        song:drawBlock(2)
        if previous_song and previous_song.music:getVolume() > 0 then
            love.graphics.setColor(1, 1, 1, previous_song.music:getVolume())
            love.graphics.draw(previous_blocks[2])
        end
    end)
    -- song background
    song_canvas:renderTo(function()
        love.graphics.setColor(1, 1, 1)
        love.graphics.clear(0, 0, 0, 0)
        song:draw()
        love.graphics.setColor(1, 1, 1)
        song:drawUi(logic.level, logic.timer, logic.score, logic.highscore, logic.cleared)
    end)
    -- previous song
    if previous_song then
        previous_song_canvas:renderTo(function()
            love.graphics.setColor(1, 1, 1)
            love.graphics.clear(0, 0, 0, 0)
            previous_song:draw()
            love.graphics.setColor(1, 1, 1)
            previous_song:drawUi(logic.level, logic.timer, logic.score, logic.highscore, logic.cleared)
        end)
    end
    -- avatar
    avatar_canvas:renderTo(function()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.clear(0, 0, 0, 0)
        avatar:draw()
    end)
    -- klele
    klele_canvas = logic.drawKlele({g_block1, g_block2})
    -- playfield
    field_canvas = logic.drawPlayfield({g_block1, g_block2}, song.colors)
    -- slider pass 1
    cslider:renderTo(function()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.clear(0,0,0,0)
        qslider:setViewport(sliderx, 0, 512, 32)
        love.graphics.draw(gslider, qslider)
    end)

    -- DRAW TO MAIN

    love.graphics.setColor(1, 1, 1)
    -- draw background
    love.graphics.draw(song_canvas)
    if previous_song then
        love.graphics.setColor(1, 1, 1, previous_song.music:getVolume())
        love.graphics.draw(previous_song_canvas)
    end
    -- draw score multiplier text
    if not ending then logic.drawMultiText() end
    love.graphics.setColor(1, 1, 1)
    drawGrid()
    -- helper beam
    if not ending and not hack1 then
        love.graphics.setColor(1, 1, 1, 0.25)
        love.graphics.rectangle('fill', logic.blockX, logic.blockY, 64, 384-logic.blockY+96)
    end
    love.graphics.setColor(1, 1, 1, 1)
    -- slider
    shd_mask:send('u_mask', gslidermask)
    love.graphics.setShader(shd_mask)
    love.graphics.draw(cslider, 224, 96)
    love.graphics.setShader()
    -- beats
    love.graphics.setColor(1, 1, 1, 1)
    qbeats:setViewport(0, 0, linepos-224, 32)
    love.graphics.draw(gbeats, qbeats, 224, 128)
    -- draw playfield bloccs
    love.graphics.setColor(1,1,1)
    love.graphics.draw(field_canvas)
    logic.drawClearedBlocks()
    -- moving blocc
    if not ending and not hack1 then
        logic.drawBlock(logic.blockX, logic.blockY, logic.block, {g_block1, g_block2})
    end
    -- playfield bounds
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.line(224, 160, 224, _GMState.getHeight()-64)
    love.graphics.line(736, 160, 736, _GMState.getHeight()-64)
    love.graphics.line(224, _GMState.getHeight()-62, 736, _GMState.getHeight()-62)

    if not hack1 then
        -- next overlay
        if logic.blockY < 96 + 64 and not ending then
            -- draw helper ui
            love.graphics.draw(gblocknext, logic.blockX - 18, 60)
        end
        -- clear line
        love.graphics.setColor(1,1,1,beatem)
        love.graphics.draw(glinegrad, linepos-64, 128+32)
        love.graphics.setLineWidth(5)
        love.graphics.line(linepos, 128, linepos, _GMState.getHeight()-64)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', linepos-64, 128, 64, 32)
        local verts = {}
        love.graphics.polygon('fill', (linepos+2), 128, (linepos+2), 160, (linepos+16), 144)
        love.graphics.printf(logic.clearCount, _GMFont24, linepos-64, 128, 64, 'center')
        logic.drawBlockFX(song.colors)
    end
    -- side bloccs
    love.graphics.setColor(1, 1, 1)
    if klele_canvas then love.graphics.draw(klele_canvas, 96, 96) end
    -- ui
    drawUI()
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(avatar_canvas, 128, 416, 0, avatar_scale, avatar_scale, 64, 64)
    -- end
    if ending then
        love.graphics.setColor(0, 0, 0, endalpha)
        love.graphics.rectangle('fill', 0, 0, _GMState.getWidth(), _GMState.getHeight())
    end

    if hack1 then
        love.graphics.setColor(0, 0, 0, countdown / 3)
        love.graphics.rectangle('fill', 0, 0, _GMState.getWidth(), _GMState.getHeight())
    end
    -- debug
    if _DEBUG then
        perf_win:draw()
        debug_win:draw()
    end
end

function gamestate.buttonpressed(button)
    if not ending and not hack1 then
        buttons_held[button] = true
        if button == 1 then
            if song.sfx_rotate then
                song.sfx_rotate:stop()
                song.sfx_rotate:play()
            end
            logic.block = logic.rotateBlock(logic.block, not _PROFILE.settings.flip_z_x)
        end
        if button == 2 then
            if song.sfx_rotate then
                song.sfx_rotate:stop()
                song.sfx_rotate:play()
            end
            logic.block = logic.rotateBlock(logic.block, _PROFILE.settings.flip_z_x)
        end
        if button == 3 and _DEBUG then moveBlock('up') end
        if button == 4 then moveBlock('down') end
        if button == 5 and logic.blockX > 224 then
            moveBlock('left')
            button_timer = SPRINT_DELAY
        end
        if button == 6 and logic.blockX < 672 then
            moveBlock('right')
            button_timer = SPRINT_DELAY
        end
        song:buttonpressed(button)
        avatar:buttonpressed(button)
        -- pause the game
        if button == 7 and tdone then song:pause(); _GMState.pausegame() end
    end
end

function gamestate.buttonreleased(button)
    if not ending and not hack1 then
        if buttons_held[button] then
            buttons_held[button] = false
        end
        if button == 5 or button == 6 then sprint = false end 
        song:buttonreleased(button)
        avatar:buttonreleased(button)
    end
end

function gamestate.keypressed(key, scancode, isrepeat)
    if not ending and not hack1 then
        if key == 'end' then
            gameover()
            return
        end
        logic.keypressed(key, scancode, isrepeat)
    end
end

function gamestate.mousemoved(x, y, dx, dy, istouch)
    if _DEBUG then
        perf_win:mousemoved(x, y, dx, dy, istouch)
        debug_win:mousemoved(x, y, dx, dy, istouch)
    end
end

function gamestate.mousepressed(x, y, button, istouch, presses)
    if _DEBUG then
        perf_win:mousepressed(x, y, button, istouch, presses)
        if debug_win:mousepressed(x, y, button, istouch, presses) then return end
    end
    logic.mousepressed(x, y, button, istouch, presses)
end

function gamestate.mousereleased(x, y, button, istouch, presses)
    if _DEBUG then
        perf_win:mousereleased(x, y, button, istouch, presses)
        if debug_win:mousereleased(x, y, button, istouch, presses) then return end
    end
    logic.mousereleased(x, y, button, istouch, presses)
end

function gamestate.focus(focus)
    if not focus and not ending then
        _GMState.pausegame()
        song:pause()
    end
end

function gamestate.resume()
    for k,v in pairs(buttons_held) do
        buttons_held[k] = false
    end
    song:resume()
    sprint = false
end

function gamestate.transitionfinished()
    tdone = true
end

return gamestate
