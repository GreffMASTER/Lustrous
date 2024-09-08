local utils = require 'common.utils'
local profile = require 'common.profile'
local shd_alpha_mask = require 'common.shader.alpha_mask'

local menu = {}

local avatar = nil
local avatar_canvas = love.graphics.newCanvas(128, 128)
local text_canvas = love.graphics.newCanvas(960, 540)
local fade_mask = love.graphics.newImage('states/menustate/graphics/fade_mask.png')

local music = love.audio.newSource('states/menustate/music/NetworkAtoms.mp3', 'stream')

local wheel_offset = {
    x = 0,
    y = 540 * 0.49
}

local icons = {
    'CLUB',
    'MIXTAPE',
    'TIME ATTACK',
    'PUZZLE',
    'PROFILE',
    'SETTINGS',
    'CREDITS',
    'QUIT',
}

-- variables
local x_start = -400
local selection = 1
local selection_smooth = #icons * 1.25
local selection_smooth_target = 1.0
local movetimer = x_start
local wheel_hidden = false
local global_scale = 3
local item_scale = 0.9
local beat_scale = 1.0
local beat_delay = 0.5975
local beat_timer = 0.0
local locked = false
local velocity = 0
local last_selection = 1

-- misc functions
-- callbacks

local function init_wheel()
    wheel_hidden = false
    movetimer = x_start
    selection = last_selection
    selection_smooth = #icons + last_selection * 1.25
    selection_smooth_target = last_selection
    locked = false
end

function menu.init( args )
    if not _PROFILE then
        local s, r = pcall(profile.load)
        if not s or not r then
            _GMState.change('input')
            return
        end
        _PROFILE = r
    end
    _PROFILE:save()

    beat_timer = 0.0

    avatar = _AVATARS[_PROFILE.avatar]
    avatar:init()
    init_wheel()
    music:setLooping(true)
    music:play()
    shd_alpha_mask:send('u_mask', fade_mask)
end

function menu.update( dt )
    -- item wheel intro
    if not wheel_hidden then
        -- move the wheel from the left
        if movetimer < wheel_offset.x then
            movetimer = movetimer + dt * math.abs(movetimer - wheel_offset.x) * 4
        end
    else
        -- move the wheel from the right
        if movetimer > x_start then
            movetimer = movetimer - dt * math.abs(movetimer + math.abs(x_start)) * 4
        end
    end
    -- item wheel rotation
    if selection_smooth < selection_smooth_target - 0.01 then
        selection_smooth = selection_smooth + dt * math.abs(selection_smooth - selection_smooth_target) * 6
    elseif selection_smooth > selection_smooth_target + 0.01 then
        selection_smooth = selection_smooth - dt * math.abs(selection_smooth - selection_smooth_target) * 6
    else
        selection_smooth = selection
    end
    velocity = selection_smooth - selection_smooth_target
    beat_timer = beat_timer + dt
    if beat_timer >= beat_delay then
        beat_timer = 0
        if movetimer > wheel_offset.x - 4 then
            beat_scale = 1.5
            avatar:beat(1.5)
        end
    end
    if beat_scale > 1.0 then
        beat_scale = beat_scale - (beat_scale-1) * 4 * dt
    end
    avatar:update(dt)
end

function menu.draw()
    love.graphics.clear(0, 0, 0)
    love.graphics.clear(0.1, 0.1, 0.1)
    text_canvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(1,1,1)
        for k, v in ipairs(icons) do
            local diff = math.pi * 2 / #icons
            if (math.sin(selection_smooth*diff + (math.pi * 0.5) - (diff*k))*64 * global_scale) + movetimer > 1 and not wheel_hidden then
                utils.printfWithShadow(icons[k], _FONTMAN.getFont(64, 'electric'),
                    (math.sin(selection_smooth*diff + (math.pi * 0.5) - (diff*k))*64 * global_scale) + movetimer - 16 + 48 * global_scale * item_scale,
                    (math.cos(selection_smooth*diff + (math.pi * 0.5) - (diff*k))*64 * global_scale) + wheel_offset.y - 32,
                    1000, 'left', 6, 6)
            end
        end
    end)
    love.graphics.push()
        love.graphics.shear(-0.25,0)
        love.graphics.translate(50,0)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.circle('fill', movetimer * 3, wheel_offset.y, 200 * global_scale * 0.7 + (math.abs(1-beat_scale) * 150.0))
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.circle('fill', movetimer * 2, wheel_offset.y, 200 * global_scale * 0.6 + (math.abs(1-beat_scale) * 75.0))
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.circle('fill', movetimer, wheel_offset.y, 200 * global_scale * 0.5 + (math.abs(1-beat_scale) * 25.0))
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.circle('fill', movetimer, wheel_offset.y, 16 * global_scale)
        -- draw icons
        love.graphics.setColor(1, 1, 1)
        for k, v in ipairs(icons) do
            local diff = math.pi * 2 / #icons
            love.graphics.circle('fill',
                (math.sin(selection_smooth*diff + (math.pi * 0.5) - (diff*k))*64 * global_scale) + movetimer,
                (math.cos(selection_smooth*diff + (math.pi * 0.5) - (diff*k))*64 * global_scale) + wheel_offset.y,
                200 * global_scale * item_scale / #icons)
        end

        love.graphics.setShader(shd_alpha_mask)
        love.graphics.draw(text_canvas)
        love.graphics.setShader()
    love.graphics.pop()
    avatar_canvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        avatar:draw()
    end)
    love.graphics.setColor(1,1,1)
    utils.drawcentered(avatar_canvas, 960 - 64 - 20, 540 - 64 - 20, 0, -1 * beat_scale, beat_scale)
end

function menu.buttonpressed(button)
    if not wheel_hidden then
        if movetimer > wheel_offset.x - 4 then -- wait until wheel move in animation finishes
            if button == 1 then
                wheel_hidden = true
                selection_smooth_target = #icons + selection * 1.25
                if selection == 1 then
                    locked = true
                    _GMState.change(
                        'loading',
                        {mode='club',},
                        {ttype="fadein",color={0,0,0},time=1}
                    )
                end
                if selection == #icons then
                    locked = true
                    _GMState.change(
                        'quit',
                        nil,
                        {ttype="fadein",color={0,0,0},time=1}
                    )
                end
            end
            if button == 3 then
                selection = selection - 1
                if selection < 1 then selection = #icons; selection_smooth = #icons+1 + velocity end
                selection_smooth_target = selection
                last_selection = selection
            end
            if button == 4 then
                selection = selection + 1
                if selection > #icons then selection = 1; selection_smooth = 0 + velocity end
                selection_smooth_target = selection
                last_selection = selection
            end
        end
    else
        if movetimer < x_start + 4 and not locked then -- wait until wheel move in animation finishes
            if button == 1 then
                wheel_hidden = false
                init_wheel()
                -- selection_smooth_target = #icons + selection * 1.25
            end
        end
    end
end

function menu.buttonreleased(button)
    
end

return menu