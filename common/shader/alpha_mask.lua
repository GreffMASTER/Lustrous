local code = [[
    #pragma language glsl1

    uniform Image u_mask;

    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        vec4 tcolor = texcolor * color;

        vec4 maskcolor = Texel(u_mask, texture_coords);
        tcolor.a = tcolor.a * maskcolor.r;

        return tcolor;
    }
]]

local shader = love.graphics.newShader(code)

return shader