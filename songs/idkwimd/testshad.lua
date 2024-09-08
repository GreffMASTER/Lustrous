local code = [[
    #pragma language glsl1

    uniform float u_scale;
    uniform Image u_noise;

    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 nscolor = Texel( u_noise, fract(texture_coords) );
        vec4 texcolor = Texel(tex, texture_coords + vec2(nscolor.x * u_scale * 0.5, 0));
        vec4 tcolor = texcolor * color;
        return tcolor;
    }
]]

local shader = love.graphics.newShader(code)

return shader