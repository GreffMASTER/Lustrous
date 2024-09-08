local shader = [[
    #pragma language glsl1
    // Deuteranope - greens are greatly reduced (1% men)
    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        vec4 tcolor = texcolor * color;
        float L = (17.8824 * tcolor.r) + (43.5161 * tcolor.g) + (4.11935 * tcolor.b);
	    float M = (3.45565 * tcolor.r) + (27.1554 * tcolor.g) + (3.86714 * tcolor.b);
	    float S = (0.0299566 * tcolor.r) + (0.184309 * tcolor.g) + (1.46709 * tcolor.b);

        float l = 1.0 * L + 0.0 * M + 0.0 * S;
		float m = 0.494207 * L + 0.0 * M + 1.24827 * S;
		float s = 0.0 * L + 0.0 * M + 1.0 * S;

        vec4 error;
	    error.r = (0.0809444479 * l) + (-0.130504409 * m) + (0.116721066 * s);
	    error.g = (-0.0102485335 * l) + (0.0540193266 * m) + (-0.113614708 * s);
	    error.b = (-0.000365296938 * l) + (-0.00412161469 * m) + (0.693511405 * s);
	    error.a = tcolor.a;
        return error;
    }
]]

return shader