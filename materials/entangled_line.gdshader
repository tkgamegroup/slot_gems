// https://www.shadertoy.com/view/DtXfDr

shader_type canvas_item;
//render_mode blend_add;

uniform float alpha : hint_range(0.0, 1.0) = 0.0;
uniform float offset = 0.0;
uniform float sig = 0.0;

#define S smoothstep

float Line(vec2 uv, float speed, float height) 
{
    uv.y += S(1., 0., abs(uv.x)) * sin(TIME * speed + uv.x * height + offset) * 0.2;
    return (S(0.06 * S(0.2, 0.9, abs(uv.x)), 0.0, abs(uv.y) - (0.02 + sig * 0.09))) * S(1.0, 0.3, abs(uv.x));
}

void fragment() 
{
    vec2 uv = UV - 0.5;
	uv.x *= 2.0;
    vec4 O = vec4(0.0);
    for (float i = 1.0; i <= 1.0; i += 1.0) 
	{
        float t = i / 2.0;
		float val = Line(uv, 1.0 + t, 1.0 + t);
		O.rgb += val * (vec3(0.5, 0.4, 0.7) + vec3(0.5) * sig);
        O.a = max(min(val, 1.0), O.a) * max(sig, sin(offset + TIME * 1.0));
    }
	O.a *= max(alpha, sig);
	COLOR = O;
}