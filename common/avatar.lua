local avatar_meta = {
    __index = {
        version = 0,
        ident = '',
        frontend = {
            name = '',
            author = ''
        },
        load = function(self)
        end,
        init = function(self)
        end,
        update = function(self, dt)
        end,
        draw = function(self)
        end,
        beat = function(self, scale)
        end,
        normal = function(self)
        end,
        combo = function(self, combo)
        end,
        danger = function(self)
        end,
        gameover = function(self)
        end,
        buttonpressed = function(self, button)
        end,
        buttonreleased = function(self, button)
        end
    }
}

return avatar_meta