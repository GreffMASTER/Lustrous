local avpick = {}

local gmui = require('lib.gmui')
 
local function ShuffleInPlace(t)
    for i = #t, 2, -1 do
        local j = love.math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

function avpick.rescan(win)
    win.children.avlist.elements = {}
    local i = 1
    for k,v in pairs( _AVATARS ) do
        win.children.avlist.elements[i] = k
        i = i + 1
    end
end

function avpick.newWindow( )
    local win = gmui.Window:new({
        xpos = 0,
        ypos = 0,
        w = 280,
        h = 308,
        title = 'Avatar Controller',
        children = {},
        minimizable = true
    })

    win.children.avlabel = gmui.Label:new({
        xpos = 0,
        ypos = 0,
        w = 270,
        h = 10,
        text = 'Avatars:'
    })

    win.children.avlist = gmui.List:new({
        xpos = 0,
        ypos = 20,
        w = 270,
        h = 100,
        elements = {
        }
    })

    win.children.statelabel = gmui.Label:new({
        xpos = 0,
        ypos = 124,
        w = 270,
        h = 10,
        text = 'Avatar states:'
    })

    win.children.b_reset = gmui.Button:new({
        xpos = 0,
        ypos = 142,
        w = 35,
        h = 20,
        text = 'Reset',
        disabled = true
    })

    win.children.b_normal = gmui.Button:new({
        xpos = 40,
        ypos = 142,
        w = 50,
        h = 20,
        text = 'Normal',
        disabled = true
    })

    win.children.b_combo = gmui.Button:new({
        xpos = 94,
        ypos = 142,
        w = 50,
        h = 20,
        text = 'Combo',
        disabled = true
    })

    win.children.b_danger = gmui.Button:new({
        xpos = 148,
        ypos = 142,
        w = 50,
        h = 20,
        text = 'Danger',
        disabled = true
    })

    win.children.b_gameover = gmui.Button:new({
        xpos = 202,
        ypos = 142,
        w = 70,
        h = 20,
        text = 'GameOver',
        disabled = true
    })

    win.children.beatslabel = gmui.Label:new({
        xpos = 0,
        ypos = 166,
        w = 270,
        h = 10,
        text = 'Audio beats:'
    })

    win.children.b_beats = gmui.Button:new({
        xpos = 0,
        ypos = 186,
        w = 70,
        h = 20,
        text = 'Beats: No',
        disabled = true
    })

    win.children.b_beatdown = gmui.Button:new({
        xpos = 74,
        ypos = 186,
        w = 20,
        h = 20,
        text = '-',
        disabled = true
    })

    win.children.beat_t_label = gmui.Label:new({
        xpos = 96,
        ypos = 186,
        w = 40,
        h = 20,
        text = '0.0',
        textal = 'center'
    })

    win.children.b_beatup = gmui.Button:new({
        xpos = 140,
        ypos = 186,
        w = 20,
        h = 20,
        text = '+',
        disabled = true
    })

    win.children.b_beat = gmui.Button:new({
        xpos = 164,
        ypos = 186,
        w = 40,
        h = 20,
        text = 'Beat',
        disabled = true
    })

    win.children.b_linehit = gmui.Button:new({
        xpos = 208,
        ypos = 186,
        w = 50,
        h = 20,
        text = 'LineHit',
        disabled = true
    })

    win.children.misclabel = gmui.Label:new({
        xpos = 0,
        ypos = 210,
        w = 270,
        h = 10,
        text = 'Misc:'
    })

    win.children.bglabel = gmui.Label:new({
        xpos = 0,
        ypos = 230,
        w = 80,
        h = 10,
        text = 'BG Color:'
    })

    -- color minus

    win.children.b_bgr_minus = gmui.Button:new({
        xpos = 74,
        ypos = 230,
        w = 20,
        h = 20,
        text = '-'
    })

    win.children.b_bgg_minus = gmui.Button:new({
        xpos = 74,
        ypos = 254,
        w = 20,
        h = 20,
        text = '-'
    })

    win.children.b_bgb_minus = gmui.Button:new({
        xpos = 74,
        ypos = 278,
        w = 20,
        h = 20,
        text = '-'
    })

    -- color plus

    win.children.b_bgr_plus = gmui.Button:new({
        xpos = 140,
        ypos = 230,
        w = 20,
        h = 20,
        text = '+'
    })

    win.children.b_bgg_plus = gmui.Button:new({
        xpos = 140,
        ypos = 254,
        w = 20,
        h = 20,
        text = '+'
    })

    win.children.b_bgb_plus = gmui.Button:new({
        xpos = 140,
        ypos = 278,
        w = 20,
        h = 20,
        text = '+'
    })

    -- color labels

    win.children.bgrlabel = gmui.Label:new({
        xpos = 94,
        ypos = 230,
        w = 46,
        h = 10,
        text = 'R:0.00',
        textal = 'center'
    })

    win.children.bgglabel = gmui.Label:new({
        xpos = 94,
        ypos = 254,
        w = 46,
        h = 10,
        text = 'G:0.00',
        textal = 'center'
    })

    win.children.bgblabel = gmui.Label:new({
        xpos = 94,
        ypos = 278,
        w = 46,
        h = 10,
        text = 'B:0.00',
        textal = 'center'
    })

    -- do outline

    win.children.b_outline = gmui.Button:new({
        xpos = 164,
        ypos = 230,
        w = 94,
        h = 20,
        text = 'Outline: Yes'
    })

    win:updateChildrenPos( )

    return win
end

return avpick
