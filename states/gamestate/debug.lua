local gamedebugstuff = {}

local gmui = require("lib.gmui")

function gamedebugstuff.newDebugWindow( )
    local debug_win = gmui.Window:new({
        xpos = 0,
        ypos = 20,
        x = 0,
        y = 20,
        w = 200,
        h = 154,
        minimized = true,
        title = "Debug Window",
        children = {}
    })
    
    debug_win.children[1] = gmui.Label:new({
        xpos = 2,
        ypos = -2,
        w = 200,
        h = 20,
        text = "Song:"
    })
    
    debug_win.children[2] = gmui.Label:new({
        xpos = 2,
        ypos = 12,
        w = 200,
        h = 20,
        text = "Line:"
    })
    
    debug_win.children[3] = gmui.Label:new({
        xpos = 2,
        ypos = 26,
        w = 200,
        h = 20,
        text = "Loop part:"
    })
    
    debug_win.children[4] = gmui.Label:new({
        xpos = 2,
        ypos = 40,
        w = 200,
        h = 20,
        text = "Beat:"
    })

    debug_win.children[5] = gmui.Button:new({
        xpos = 152,
        ypos = 72,
        w = 40,
        h = 20,
        text = "Skip",
        disabled = true
    })

    debug_win.children[6] = gmui.Button:new({
        xpos = 44,
        ypos = 72,
        w = 20,
        h = 20,
        text = "-"
    })

    debug_win.children[7] = gmui.Button:new({
        xpos = 84,
        ypos = 72,
        w = 20,
        h = 20,
        text = "+"
    })

    debug_win.children[8] = gmui.Button:new({
        xpos = 108,
        ypos = 72,
        w = 40,
        h = 20,
        text = "Jump"
    })

    debug_win.children[9] = gmui.Label:new({
        xpos = 70,
        ypos = 75,
        w = 20,
        h = 20,
        text = "0"
    })

    debug_win.children[10] = gmui.Label:new({
        xpos = 2,
        ypos = 54,
        w = 200,
        h = 20,
        text = "X: 0 / Y: 0"
    })

    debug_win.children[11] = gmui.Button:new({
        xpos = 1,
        ypos = 72,
        w = 40,
        h = 20,
        text = "Reset"
    })

    debug_win.children[12] = gmui.Button:new({
        xpos = 1,
        ypos = 98,
        w = 70,
        h = 20,
        text = "Next Song"
    })

    debug_win.children[13] = gmui.Button:new({
        xpos = 1,
        ypos = 124,
        w = 50,
        h = 20,
        text = "A.Dizzy"
    })

    debug_win.children[14] = gmui.Button:new({
        xpos = 56,
        ypos = 124,
        w = 60,
        h = 20,
        text = "A.Happy"
    })

    debug_win:updateChildrenPos( )

    return debug_win
end

return gamedebugstuff
