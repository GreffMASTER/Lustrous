local gameperfstuff = {}

local gmui = require("lib.gmui")

local function getPerfStats(perf_win,dt)
    
    local stats = love.graphics.getStats()
    
    perf_win.children[1].text = string.format( "VRAM: %.2f MB", math.abs( stats.texturememory / 1024 / 1024 ) )
    perf_win.children[2].text = string.format( "Images: %d", stats.images )
    perf_win.children[3].text = string.format( "Canvases: %d", stats.canvases )
    perf_win.children[4].text = string.format( "Fonts: %d", stats.fonts )
    perf_win.children[5].text = string.format( "RAM: %.2f MB", collectgarbage( "count" ) / 1024 )
    perf_win.children[6].text = string.format( "FPS: %d", love.timer.getFPS() )
    stats = nil
    collectgarbage()
end

function gameperfstuff.newPerformanceWindow( x, y )
    local perf_win = gmui.Window:new({
        xpos = x,
        ypos = y,
        w = 160,
        h = 80,
        title = "Performance Window",
        updatefunc = getPerfStats,
        minimizable = true,
        children = {}
    })
    
    perf_win.children[1] = gmui.Label:new({
        xpos = 2,
        ypos = -2,
        w = 160,
        h = 20,
        text = "VRAM:"
    })

    perf_win.children[2] = gmui.Label:new({
        xpos = 2,
        ypos = 10,
        w = 160,
        h = 20,
        text = "Images:"
    })

    perf_win.children[3] = gmui.Label:new({
        xpos = 2,
        ypos = 22,
        w = 160,
        h = 20,
        text = "Canvases:"
    })

    perf_win.children[4] = gmui.Label:new({
        xpos = 2,
        ypos = 34,
        w = 160,
        h = 20,
        text = "Fonts:"
    })

    perf_win.children[5] = gmui.Label:new({
        xpos = 2,
        ypos = 46,
        w = 160,
        h = 20,
        text = "Memory:"
    })

    perf_win.children[6] = gmui.Label:new({
        xpos = 2,
        ypos = 58,
        w = 160,
        h = 20,
        text = "FPS:"
    })

    perf_win:updateChildrenPos( )
    perf_win.minimized = true
    perf_win.hidebutt.clicked = true

    return perf_win
end

return gameperfstuff
