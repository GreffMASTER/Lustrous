local utils = require 'common.utils'

local gsideui = love.graphics.newImage('common/graphics/sideui.png')

local song_ta_meta = {
    __index = {
        version = 0,
        ident = '',
        frontend = {
            title = '',
            artist = '',
            skin_author = ''
        },
        colors = {
            {1,1,1},
            {1,0,1}
        },
        load = function(self)
        end,
        init = function(self)
        end,
        update = function(self, dt)
        end,
        draw = function(self)
        end,
        drawUi = function(self, level, time, score, highscore, cleared)
            love.graphics.draw(gsideui,752,96)
            utils.printfWithShadow( level, _GMFont24, 752, 136, 182, "right" )              -- level
            utils.printfWithShadow( utils.getTimeString( time ), _GMFont24, 752, 216, 182, "right" )   -- time
            utils.printfWithShadow( score, _GMFont24, 752, 296-6, 182, "right" )            -- score
            utils.printfWithShadow( highscore, _GMFont24, 752, 376-10, 182, "right" )       -- highscore
            utils.printfWithShadow( cleared, _GMFont24, 752, 456-10, 182, "right" )         -- clear count
        end,
        drawBlock = function(self, type)
            if type == 1 then
                love.graphics.setColor(self.colors[1])
            elseif type == 2 then
                love.graphics.setColor(self.colors[2])
            end
            love.graphics.rectangle('fill',0,0,32,32)
        end,
        linehit = function(self, mus_time, in_loop)
        end,
        beat = function(self, scale)
        end,
        combo = function(self, combo)
        end,
        buttonpressed = function(self, button)
        end,
        buttonreleased = function(self, button)
        end,
        blockMoved = function(self, tx, ty)
        end,
        gameover = function(self)
        end,
        play = function(self)
        end,
        timer = function(self, time, tatime)
        end,
        pause = function(self)
        end,
        resume = function(self)
        end,
        jump = function(self, mus_time)
        end,
    }
}

return song_ta_meta