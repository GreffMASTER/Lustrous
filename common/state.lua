local state_meta = {
    __index = {
        init = function(prev, args) end,
        update = function(dt) end,
        draw = function() end,
        transitionfinished = function() end,
        keypressed = function(key, scancode, isrepeat) end,
        keyreleased = function(key, scancode) end,
        mousemoved = function(x, y, dx, dy, istouch) end,
        mousepressed = function(x, y, button, istouch, presses) end,
        mousereleased = function(x, y, button, istouch, presses) end,
        joystickhat = function(joystick, hat, direction) end,
        joystickaxis = function(joystick, axis, value) end,
        joystickpressed = function(joystick, button) end,
        joystickreleased = function(joystick, button) end,
        joystickadded = function(joystick) end,
        joystickremoved = function(joystick) end,
        textinput = function(t) end,
        focus = function(focus) end,
        quit = function() end,
        buttonpressed = function(buttonindex) end,
        buttonreleased = function(buttonindex) end,
        pause = function() end,
        resume = function() end,
        resize = function(w,h) end,
    }
}

return state_meta
