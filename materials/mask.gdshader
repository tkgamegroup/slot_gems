shader_type canvas_item;

uniform float radius : hint_range(0.0, 4.0);

// https://www.shadertoy.com/view/7tSXzt
const float an = 3.141593/6.;
const vec2  acs = vec2(cos(an),sin(an));
float sdHexagon(in vec2 p, in float r)
{
    // reduce to first sector
    float bn = mod(atan(p.x,p.y)+1.5707965,2.0*an) - an;
    p = length(p)*vec2(cos(bn),abs(sin(bn)));

    // line sdf
    p -= r*acs;
    p.y += clamp( -p.y, 0.0, r*acs.y);
    return length(p)*sign(p.x);
}

void fragment() {
    vec2 uv = SCREEN_UV;
	uv = uv * 2.0 - 1.0;
	uv.x *= TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;

    float d = sdHexagon(uv, radius);

    if (d < 0.)
        COLOR = vec4(0.0);
    else
        COLOR = texture(TEXTURE, SCREEN_UV);
}