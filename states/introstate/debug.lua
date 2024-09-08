local introdebugstuff = {}

local gmui = require("lib.gmui")
 
local function ShuffleInPlace(t)
    for i = #t, 2, -1 do
        local j = love.math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end


function introdebugstuff.rescan(debug_win)
    local i = 1
    for k,v in pairs( _SONGS ) do
        debug_win.children[2].elements[i] = k
        i = i + 1
    end

    local i = 1
    for k,v in pairs( _AVATARS ) do
        debug_win.children[4].elements[i] = k
        i = i + 1
    end
end

function introdebugstuff.newDebugWindow( )
    local debug_win = gmui.Window:new({
        xpos = 0,
        ypos = 40,
        w = 210,
        h = 380,
        title = "Debug Window",
        children = {}
    })
    
    debug_win.children[1] = gmui.Label:new({
        xpos = 0,
        ypos = 0,
        w = 200,
        h = 10,
        text = "Songs:"
    })

    debug_win.children[2] = gmui.List:new({
        xpos = 0,
        ypos = 20,
        w = 200,
        h = 170
    })

    debug_win.children[3] = gmui.Label:new({
        xpos = 0,
        ypos = 240,
        w = 200,
        h = 10,
        text = "Avatars:"
    })

    debug_win.children[4] = gmui.List:new({
        xpos = 0,
        ypos = 260,
        w = 200,
        h = 110,
        elements = {
        }
    })

    debug_win.children[5] = gmui.Button:new({
        xpos = 0,
        ypos = 196,
        w = 80,
        h = 16,
        text = 'All Mixtape'
    })

    debug_win.children[6] = gmui.Button:new({
        xpos = 84,
        ypos = 196,
        w = 60,
        h = 16,
        text = 'Shuffle',
    })

    debug_win.children[7] = gmui.Button:new({
        xpos = 148,
        ypos = 196,
        w = 50,
        h = 16,
        text = 'TA 60',
    })

    debug_win.children[8] = gmui.Button:new({
        xpos = 148,
        ypos = 216,
        w = 50,
        h = 16,
        text = 'TA 300',
    })

    debug_win.children[9] = gmui.Button:new({
        xpos = 148,
        ypos = 236,
        w = 50,
        h = 16,
        text = 'TA 600',
    })

    introdebugstuff.rescan(debug_win)

    debug_win.children[4].pressfunc = function(sel)
        _PROFILE.avatar = sel
    end

    debug_win.children[6].func = function()
        ShuffleInPlace(debug_win.children[2].elements)
    end

    for k,v in pairs( debug_win.children[4].elements ) do
        if v == _PROFILE.avatar then
            debug_win.children[4].selected = debug_win.children[4].elements[k]
        end
    end

    debug_win.children[2].selected = debug_win.children[2].elements[1]

    debug_win:updateChildrenPos( )

    return debug_win
end

return introdebugstuff
