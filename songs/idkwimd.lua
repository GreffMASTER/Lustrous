local song = {}

setmetatable(song, require 'common.song')

song.version = 1
song.ident = 'greffmaster.idkwimd'

song.frontend = {}

song.frontend.artist = 'GreffMASTER'
song.frontend.title = 'I don\'t know what I\'m doing'
song.frontend.skin_author = 'GreffMASTER'

song.colors ={
    {0.9,0.9,0.9},
    {0.2,0.2,0.2}
}

local songdata
local samplecount
local samples = {}
local grad
local block
local qgrid = love.graphics.newQuad(0,0,960,540,64,64)
local grid
local noise
local shad_test = require('songs.idkwimd.testshad')
local grid_offset = 0
local colBeatScaleInv = 0
local beatc = 0

function song:load()
    songdata = love.sound.newSoundData( "songs/idkwimd/idkwimd_game.ogg" )
    song.music = love.audio.newSource(songdata,"stream")
    song.sfx_move   = love.audio.newSource( "songs/idkwimd/hat.wav", "static" )
    song.sfx_rotate = song.sfx_move
    song.sfx_sprint = love.audio.newSource( "songs/idkwimd/siren.wav", "static" )
    song.sfx_place  = love.audio.newSource( "songs/idkwimd/clap.wav", "static" )
    samplecount = songdata:getSampleCount()
    samples = {}
    grad = love.graphics.newImage( "songs/idkwimd/grad.png" )
    grid = love.graphics.newImage( "songs/idkwimd/grid.png" )
    grid:setWrap('repeat')
    block = love.graphics.newImage( "songs/idkwimd/block.png" )
    noise = love.graphics.newImage( "songs/idkwimd/noise.png" )
end

function song:init()
    song.speed      = 74.75
    song.beattime  = 0.425
    samples = {}
    grid_offset = 0
    beatc = 0
end

local ts = {}

ts.starts = 0
ts.ends   = 164

ts.loops  = {}

ts.loops[1]        = {}
ts.loops[1].starts = 6.8731065759637
ts.loops[1].ends   = 13.746213151927

ts.loops[2]        = {}
ts.loops[2].starts = 13.746213151927
ts.loops[2].ends   = 20.596099773243

ts.loops[3]        = {}
ts.loops[3].starts = 34.319092970522
ts.loops[3].ends   = 41.168979591837

ts.loops[4]        = {}
ts.loops[4].starts = 48.018866213152
ts.loops[4].ends   = 54.891972789116

ts.loops[5]        = {}
ts.loops[5].starts = 61.741859410431
ts.loops[5].ends   = 68.591746031746

ts.loops[6]        = {}
ts.loops[6].starts = 68.591746031746
ts.loops[6].ends   = 75.441632653061

ts.loops[7]        = {}
ts.loops[7].starts = 82.291519274376
ts.loops[7].ends   = 89.141405895692

ts.loops[8]        = {}
ts.loops[8].starts = 102.84117913832
ts.loops[8].ends   = 109.66784580499

ts.loops[9]        = {}
ts.loops[9].starts = 116.56417233560
ts.loops[9].ends   = 123.41405895692

ts.loops[10]        = {}
ts.loops[10].starts = 123.41405895692
ts.loops[10].ends   = 130.26394557823

ts.loops[11]        = {}
ts.loops[11].starts = 137.06739229025
ts.loops[11].ends   = 143.94049886621

ts.loops[12]        = {}
ts.loops[12].starts = 150.79038548753
ts.loops[12].ends   = 157.66349206349

ts.loops[13]        = {}
ts.loops[13].starts = 157.66349206349
ts.loops[13].ends   = 164.571


song.timestamps = ts

function song:update( dt )
    for i=1,960 do
        local temp = song.music:tell( "samples" ) + (i-1)
        if temp < samplecount and temp > 0 then
            samples[i] = songdata:getSample( temp )
            
        else
            samples[i] = 0
        end
    end

    if colBeatScaleInv > 0 then
        colBeatScaleInv = colBeatScaleInv - dt * 2
    end

    grid_offset = grid_offset + dt * song.speed * 0.5
    if grid_offset >= 512 then grid_offset = 0 end
end

function song:draw( )
    love.graphics.clear( 0.5, 0.5, 0.5 )
     -- grid
    shad_test:send('u_scale', colBeatScaleInv)
    shad_test:send('u_noise', noise)
    love.graphics.setShader(shad_test)
    love.graphics.setColor(0.3,0.3,0.3,0.3)
    qgrid:setViewport(0, grid_offset, 960, 540)
    love.graphics.draw(grid, qgrid)
    love.graphics.setShader()
    -- audio
    love.graphics.setColor(0.3,0.3,0.3,1)
    for i=960,1,-1 do
        if samples[i] then
            love.graphics.line(i,540/2, i,(-math.abs(samples[i]) * 200) + 540/2)
        end
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(grad, 0, 540/2)
end

function song:drawBlock(type)
    love.graphics.setColor(song.colors[type])
    love.graphics.draw(block)
end

function song:linehit(mus_time, in_loop)
    colBeatScaleInv = 3
    beatc = 0
end

function song:beat( scale )
    
    beatc = beatc + 1
    if beatc >= 2 then
        colBeatScaleInv = 1
        beatc = 0
    end
end

return song
