local logic = {}

local utils = require 'common.utils'

local state_g_path = 'states/gamestate/graphics/'

logic.linepos = 0

logic.field = {
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

logic.clearfield = {
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

logic.markedblocks = {}

logic.klele = {
    {1,1,1,1},
    {1,1,1,1},
    {1,1,1,1}
}

logic.clearCount = 0

logic.blockX = 448
logic.blockY = 96

logic.block = {1,1,1,1}

logic.level = 0
logic.score = 0
logic.target_time = 60
logic.timer = 0
logic.highscore = 0
logic.cleared = 0

logic.nextlvl = 22
logic.nextsong_countdown = 4

logic.nextsong_callback = nil

logic.mode = 'club'
logic.hasplaced = false


local field_canvas = love.graphics.newCanvas( 960, 540 )
local klele_canvas = love.graphics.newCanvas( 64, 224 )
local g_sparkle = love.graphics.newImage(state_g_path..'sparkle.png')
local clearblock = love.graphics.newImage(state_g_path..'clearblock.png')
clearblock:setWrap('repeat')
local qclearblock = love.graphics.newQuad(0,0,32,32,32,32)
local clearedblock = love.graphics.newImage(state_g_path..'clearedblock.png')

local clearblock_offset = 0

local clear_fx = {}
local clear_fx_cnt = 1
local marked_cnt = 1
local klele_offset_time = 0
local klele_offset_position = 0
local clearing = false
local clearpos = 0
local multi = 1
local multitext = ''
local multitextpos = 960
local sparkle_y = 96
local sparkle_h = 16
local rgb = 0
local bonus_text = ''
local bonus_text_timer = 0

local sparkles = love.graphics.newParticleSystem(g_sparkle)
sparkles:setParticleLifetime(0.75, 1.25)
sparkles:setEmissionRate(50)
sparkles:setSizes( 1, 0 )
sparkles:setSpin( 0, math.pi )
sparkles:setLinearAcceleration(-50, 0, -50, 0)
sparkles:setSpeed(-100, -50)
sparkles:setEmissionArea( 'normal', 0, 8, 0, false )
sparkles:setPosition(0, 0)
sparkles:setColors(1, 1, 1, 1, 1, 1, 1, 0)

--=========================-- LOCAL FUNCTIONS --=========================--

local function getRandomBlock( )
    local block = {0,0,0,0}
    for i=1,4 do
        block[i] = math.ceil(math.random()*2)
    end
    return block
end

local function ifOnClearField( y, x )
    if logic.clearfield[y][x] > 0 and logic.clearfield[y][x+1] > 0 and logic.clearfield[y+1][x] > 0 and logic.clearfield[y+1][x+1] > 0 then return true end
end

local function checkField( )
    local collected = false
    local count = 0
    -- add to global clear table (used for the sweep animations)
    -- weird code below, im not sure what makes it work, but it works :monkaS:
    for i=1,10 do
        for j=1,16 do
            local cur = logic.clearfield[i][j]
            if cur > 0 then
                if logic.field[i][j] ~= cur then
                    logic.clearfield[i][j] = 0
                end
                if i > 1 and i < 10 then
                    if logic.clearfield[i+1][j] ~= cur and logic.clearfield[i-1][j] ~= cur then
                        logic.clearfield[i][j] = 0
                    end
                else
                    if i == 10 then
                        if logic.clearfield[i-1][j] ~= cur then
                            logic.clearfield[i][j] = 0
                        end 
                    end
                end
                if j > 1 and j < 16 then
                    if logic.field[i][j+1] ~= cur and logic.field[i][j-1] ~= cur then
                        logic.clearfield[i][j] = 0
                    end
                else
                    if j == 1 then
                        if logic.field[i][j+1] ~= cur then logic.clearfield[i][j] = 0 end
                    elseif j == 16 then
                        if logic.field[i][j-1] ~= cur then logic.clearfield[i][j] = 0 end
                    end
                end
            end
        end
    end

    local acnt = 0 -- block fx delay

    for i=1,9 do
        for j=1,15 do
            local cur = logic.field[i][j]
            if cur > 0 then -- |1|?|
                if logic.field[i][j+1] == cur then -- |1|1|

                    if logic.field[i+1][j] == cur and logic.field[i+1][j+1] == cur then -- |?|?|
                        --count = count + 1                                             -- |1|1|
                        -- found a blocc
                        local isMarkedInThisSpot = false
                        for k, marked in pairs(logic.markedblocks) do
                            local col = marked[1]
                            local x = marked[2]
                            local y = marked[3]
                            if x == j and y == i then
                                isMarkedInThisSpot = true
                                break
                            end
                        end
                        if not isMarkedInThisSpot then
                            clear_fx[clear_fx_cnt] = {i,j,cur,0, acnt}
                            clear_fx_cnt = clear_fx_cnt + 1
                            logic.markedblocks[marked_cnt] = {cur, j, i}
                            marked_cnt = marked_cnt - 1
                            
                            if clear_fx_cnt > 64 then clear_fx_cnt = 1 end
                            if marked_cnt < 1 then marked_cnt = 64 end
                            logic.clearfield[i][j] = cur
                            logic.clearfield[i][j+1] = cur
                            logic.clearfield[i+1][j] = cur
                            logic.clearfield[i+1][j+1] = cur
                            collected = true
                            acnt = acnt + .125
                        end
                    end
                    --j=j+1 -- optimization (i think)
                end
                -- nope, its a single block
            end
            -- nope, nothing in the left corner
        end
    end
    -- check for outdated marked clears
    for k, marked in pairs(logic.markedblocks) do
        local color = marked[1]
        local x = marked[2]
        local y = marked[3]
        if logic.field[y][x] ~= color or logic.field[y+1][x] ~= color or logic.field[y][x+1] ~= color or logic.field[y+1][x+1] ~= color then
            logic.markedblocks[k] = nil
        end
    end
end

local function clearBlocks( from, to )
    -- clear marked clears and add to clear count
    local clears = 0
    for k, marked in pairs(logic.markedblocks) do
        local color = marked[1]
        local x = marked[2]
        local y = marked[3]
        if x >= from and x <= to and logic.clearedfield[y][x] > 0 then
            clears = clears + 1
            logic.markedblocks[k] = nil
        end
    end
    logic.clearCount = logic.clearCount + clears
    -- clear playfield blocks
    for k, y in pairs(logic.clearedfield) do
        for l, x in pairs(y) do
            if x > 0 then
                logic.field[k][l] = 0
                logic.clearfield[k][l] = 0
                logic.clearedfield[k][l] = 0
            end
        end
    end
end

--=========================-- LOGIC FUNCTIONS --=========================--

function logic.init( )
    clear_fx = {}
    clear_fx_cnt = 1
    math.randomseed( os.time( ) )
    logic.field = {
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
    logic.clearfield = {
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
    logic.markedblocks = {}
    clear_fx = {}
    marked_cnt = 64
    clear_fx_cnt = 1
    bonus_text = ''
    if logic.mode == 'ta' or logic.mode == 'puzzle' then
        logic.timer = logic.target_time
    else
        logic.timer = 0
    end
    sparkle_y = 96
    sparkle_h = 16
    clearblock_offset = 0
    logic.clearCount = 0
    logic.cleared = 0
    logic.clearCollected = 0
    logic.nextlvl = 22
    logic.nextsong_countdown = 4
    multitextpos = 960
    logic.blockX = 448
    logic.blockY = 96
    logic.hasplaced = false
    for i=1,3 do
        logic.klele[i] = getRandomBlock( )
    end
    logic.block = getRandomBlock( )
    rgb = 0
    sparkles:stop()
end

function logic.addScore( amount )
    logic.score = logic.score + amount
    if logic.score > 99999999999 then logic.score = 99999999999 end
    if logic.score > logic.highscore then logic.highscore = logic.score end
end

function logic.rotateBlock( block, clockwise )
    local buffer = {}
    for i=1,4 do
        buffer[i] = block[i]
    end
    if clockwise then
        block[1] = buffer[3]
        block[2] = buffer[1]
        block[3] = buffer[4]
        block[4] = buffer[2]
    else
        block[1] = buffer[2]
        block[2] = buffer[4]
        block[3] = buffer[1]
        block[4] = buffer[3]
    end
    return block
end

function logic.placeBlock( )
    local tx = math.ceil( (logic.blockX - 224) / 32) + 1
    local ty = math.ceil( (logic.blockY - 160) / 32) + 1

    if ty == 0 then
        -- this took way too long to fix
        local left = logic.field[ty+2][tx] > 0
        local right = logic.field[ty+2][tx+1] > 0
        if not left and right then
            logic.field[ty+1][tx] = logic.block[1]
            logic.field[ty+2][tx] = logic.block[3]
            logic.field[ty+1][tx+1] = logic.block[4]
        elseif left and not right then
            logic.field[ty+1][tx+1] = logic.block[1]
            logic.field[ty+1][tx] = logic.block[3]
            logic.field[ty+2][tx+1] = logic.block[4]
        else
            logic.field[ty+1][tx] = logic.block[3]
            logic.field[ty+1][tx+1] = logic.block[4]
        end
    else
        logic.field[ty][tx] = logic.block[1]
        logic.field[ty][tx+1] = logic.block[2]
        logic.field[ty+1][tx] = logic.block[3]
        logic.field[ty+1][tx+1] = logic.block[4]
    end
    logic.blockX = 448
    logic.blockY = 96
    logic.hasplaced = true
    logic.nextBlock( )
end

function logic.nextBlock( )
    logic.block = logic.klele[1]
    logic.klele[1] = logic.klele[2]
    logic.klele[2] = logic.klele[3]
    logic.klele[3] = getRandomBlock( )
    local same = true
    for i=1, 4 do
        if logic.klele[3][i] ~= logic.klele[2][i] then
            same = false
            break
        end
    end
    if same then logic.klele[3] = getRandomBlock( ) end
    klele_offset_time = 1
    klele_offset_position = 80
end

function logic.fallBlocks( )
    for y=9,1,-1 do
        for x=1,16 do
            if logic.field[y][x] ~= 0 then
                if logic.field[y+1][x] == 0 then
                    local bufferblock = logic.field[y][x]
                    logic.field[y][x] = 0
                    for i=y,10 do
                        if logic.field[i][x] ~= 0 then
                            logic.field[i-1][x] = bufferblock
                            break
                        end
                        if i == 10 then
                            logic.field[i][x] = bufferblock
                            break
                        end
                    end
                end
            end
        end
    end
    checkField( )
end

function logic.update( dt )
    if klele_offset_time > 0 then
        klele_offset_time = klele_offset_time - dt * 8
        klele_offset_position = utils.lerp( 0, 80, klele_offset_time )
        if klele_offset_time < 0 then klele_offset_time = 0 end
        if klele_offset_position < 0 then klele_offset_position = 0 end
    end
    if multitextpos < 960 then
        multitextpos = multitextpos + 700 * dt
    end
    rgb = rgb + dt * 180
    if rgb > 360 then rgb = 0 end
    sparkles:update(dt)
    sparkles:setEmissionRate(sparkle_h*2)
    sparkles:setPosition(logic.linepos,sparkle_y+136)
    sparkles:setEmissionArea('normal', 0, sparkle_h, 0, false)
    clearblock_offset = clearblock_offset + dt * 16
    if bonus_text_timer > 0 then
        bonus_text_timer = bonus_text_timer - dt
    end
end

function logic.time( dt )
    if logic.mode == 'ta' or logic.mode == 'puzzle' then
        if logic.timer > 0 then
            logic.timer = logic.timer - dt
        end
        if logic.timer < 0 then logic.timer = 0 end
    else
        logic.timer = logic.timer + dt
    end
end

function logic.gameover()
    logic.clearfield = {
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
    logic.markedblocks = {}
    sparkles:stop()
    bonus_text = ''
end

function logic.drawBlock( x, y, block, g_blocks )
    love.graphics.draw( g_blocks[block[1]], x, y )
    love.graphics.draw( g_blocks[block[2]], 32+x, y )
    love.graphics.draw( g_blocks[block[3]], x, y+32 )
    love.graphics.draw( g_blocks[block[4]], x+32, y+32 )
end

function logic.drawMultiText()
    -- draw score multiplier text
    love.graphics.setColor( 1, 1, 1, 0.25 )
    love.graphics.printf( multitext, _GMFont256, multitextpos, 100, 1500, "center" )
end

function logic.drawPlayfield( g_blocks, colors )
    qclearblock:setViewport(clearblock_offset, clearblock_offset, 32, 32)
    -- draw blocks
    field_canvas:renderTo(function()
        love.graphics.clear( 0, 0, 0, 0 )
        love.graphics.setColor(1,1,1)
        for y, vr in pairs(logic.field) do
            for x, v in pairs(vr) do
                if v > 0 then
                    love.graphics.draw( g_blocks[v], (x-1)*32 + 224, (y-1)*32 + 160 )
                end
            end
        end
        -- draw clear (v2!)
        love.graphics.setLineWidth(3)
        for k, marked in pairs(logic.markedblocks) do
            local color = marked[1]
            local x = marked[2]
            local y = marked[3]
            love.graphics.setColor( colors[color][1], colors[color][2], colors[color][3], 1 )
            love.graphics.rectangle( "fill", (x-1)*32 + 224, (y-1)*32 + 160, 64, 64 )
            love.graphics.setColor( colors[color][1]*0.5, colors[color][2]*0.5, colors[color][3]*0.5, 1 )
            love.graphics.rectangle( "line", (x-1)*32 + 224, (y-1)*32 + 160, 64, 64 )
        end
        -- draw og clear
        for y, vr in pairs(logic.clearfield) do
            for x, v in pairs(vr) do
                if v > 0 then              
                    love.graphics.setColor( colors[v] )
                    love.graphics.draw( clearblock, qclearblock, (x-1)*32 + 224, (y-1)*32 + 160 )
                end
            end
        end
    end)
    return field_canvas
end

function logic.updateBlockFX(dt)
    for k,v in pairs(clear_fx) do
        if v[5] > 0 then
            v[5] = v[5] - dt
        end
        if v[5] <= 0 then
            v[4] = v[4] + dt * 2
            if v[4] > 1 then
                clear_fx[k] = nil
            end
        end
    end
end

function logic.drawBlockFX(colors)
    local ogw = love.graphics.getLineWidth()
    love.graphics.setLineWidth(8)
    for k,v in pairs(clear_fx) do
        if v[5] <= 0 then
            local y=v[1]
            local x=v[2]
            local col = colors[v[3]]
            local scal=v[4]
            love.graphics.setColor(col[1], col[2], col[3], 1-scal)
            local offx = 224-32 + x * 32
            local offy = 160-32 + y * 32
            love.graphics.rectangle('line',
                offx-scal*128,
                offy-scal*128,
                64+scal*128*2,
                64+scal*128*2
            )
        end
    end
    love.graphics.setLineWidth(ogw)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(sparkles, 0, 0)
    if bonus_text_timer > 0 then
        love.graphics.setColor( 1, 1, 1, 1 )
        utils.printfWithShadow(bonus_text, _GMFont32, 0, 220, 960, 'center')
    end
end

function logic.drawClearedBlocks()
    for y, vr in pairs(logic.clearedfield) do
        for x, v in pairs(vr) do
            if v > 0 then
                love.graphics.setColor(utils.hsv2rgb(rgb, 1, 1))
                love.graphics.draw( clearedblock, (x-1)*32 + 224, (y-1)*32 + 160 )
                love.graphics.setColor(1,1,1,1)
            end
        end
    end
end

function logic.drawKlele( g_blocks )
    klele_canvas:renderTo( function()
        love.graphics.clear( 0, 0, 0, 0 )
        logic.drawBlock( 0, 0 + klele_offset_position, logic.klele[1], g_blocks )
        logic.drawBlock( 0, 80 + klele_offset_position, logic.klele[2], g_blocks )
        logic.drawBlock( 0, 160 + klele_offset_position, logic.klele[3], g_blocks )
    end )
    return klele_canvas
end

function logic.keypressed( key, scancode, isrepeat )
    if _DEBUG then
        if key == "c" then
            checkField( )
        end
        if key == "n" then
            logic.nextBlock( )
        end
        if key == "f" then
            logic.fallBlocks( )
        end
    end
end

function logic.buttonpressed( button )
end

function logic.buttonreleased( button )
end

function logic.mousepressed( x, y, button, istouch, presses )
    if _DEBUG then
        local tx = math.ceil( (x - 224) / 32)
        local ty = math.ceil( (y - 160) / 32)
        if tx > 0 and tx <= 16 and ty > 0 and ty <= 10 then
            if button > 0 and button < 3 then
                logic.field[ty][tx] = button
            elseif button == 3 then
                logic.field[ty][tx] = 0
            end
            checkField( )
        end
    end
end

function logic.mousereleased( x, y, button, istouch, presses )
end

function logic.checklinepos( pos )
    local wasclearing = clearing
    clearing = false
    for i=1,10 do
        -- hack to make the first collumn getting cleared
        if pos == 0 then
            if logic.clearfield[i][1] > 0 then
                clearing = true
                if not wasclearing then clearpos = 1 end
            end
        else
            if logic.clearfield[i][pos] > 0 then
                clearing = true
                if not wasclearing then clearpos = pos end
            end
        end
    end
    local test = false
    local hl = {}
    if pos < 16 then
        for i=1,10 do
            -- this hack took away my kids, and i still have to pay
            if pos == 0 then
                if logic.clearfield[i][1] > 0 then
                    test = true
                    logic.clearedfield[i][1] = 1
                    table.insert(hl, i)
                end
            end
            if logic.clearfield[i][pos+1] > 0 then
                test = true
                logic.clearedfield[i][pos+1] = 1
                table.insert(hl, i)
            end
        end
    end
    
    if test then
        local mn = math.huge
        for i = 1, #hl  do
            mn = mn < hl[i] and mn or hl[i]
        end

        local mx = 0
        for i = 1, #hl  do
            mx = mx > hl[i] and mx or hl[i]
        end
        local h = (mx * 16) - (mn*16)
        sparkle_h = h

        local avg = 0
        for i=1, #hl do
            avg = avg + hl[i]
        end
        avg = (avg / #hl) * 32
        sparkle_y = avg


        sparkles:start()
    else
        clearing = false
        sparkles:stop()
    end

    if wasclearing and not clearing then
        clearBlocks( clearpos, pos )
        logic.fallBlocks( )
    end
    return clearing
end

function logic.cashIn( )
    logic.cleared = logic.cleared + logic.clearCount
    if logic.clearCount >= 4 then
        multi = logic.clearCount
    else multi = 1 end -- reset multiplier

    logic.addScore( (logic.clearCount * 50) * multi )
    if logic.mode == 'club' or logic.mode == 'mixtape' then
        if logic.cleared >= logic.nextlvl then
            logic.level = logic.level + 1
            logic.nextlvl = logic.nextlvl + 22
            logic.nextsong_countdown = logic.nextsong_countdown - 1
            if logic.nextsong_countdown == 0 then
                logic.nextsong_countdown = 4
                logic.nextsong_callback()
            end
        end
    end
    if multi >= 4 then
        multitextpos = -1500
        multitext = 'SCORE x' .. multi
    end
    logic.clearCount = 0
    clearpos = 0

    if logic.hasplaced then
        -- check for clear bonus
        local has_blocks = false
        local has_one_color = true
        local block_type = 0
        for y, vr in pairs(logic.field) do
            for x, v in pairs(vr) do
                if v > 0 then
                    has_blocks = true
                    if block_type == 0 then
                        block_type = v
                    else
                        if block_type ~= v then
                            has_one_color = false
                        end
                    end
                end
            end
        end

        if not has_blocks then
            print('clear bonus')
            bonus_text_timer = 5
            bonus_text = 'CLEAR FIELD BONUS! 10000 SCORE'
            logic.addScore( 10000 )
        elseif has_one_color then
            print('single color bonus')
            bonus_text_timer = 5
            bonus_text = 'SINGLE COLOR BONUS! 1000 SCORE'
            logic.addScore( 1000 )
        end
    end

    logic.hasplaced = false

    return multi
end

return logic
