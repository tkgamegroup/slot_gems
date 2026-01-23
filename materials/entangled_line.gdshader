shader_type canvas_item;
//render_mode blend_add;

uniform float alpha : hint_range(0.0, 1.0) = 0.0;

#define S smoothstep

float Line(vec2 uv, float speed, float height) 
{
    uv.y += S(1., 0., abs(uv.x)) * sin(TIME * speed + uv.x * height) * .2;
    return (S(.06 * S(.2, .9, abs(uv.x)), 0., abs(uv.y) - .01)) * S(1., .3, abs(uv.x));
}

void fragment() {
    vec2 uv = UV - 0.5;
	uv.x *= 2.0;
    vec4 O = vec4(0.);
    for (float i = 1.; i <= 1.; i += 1.) 
	{
        float t = i / 2.;
		float val = Line(uv, 1. + t, 1. + t);
		O.rgb += val * vec3(.2 + t * .7, .2 + t * .4, 0.3);
        O.a = max(min(val, 1.0), O.a);
    }
	O.a *= alpha;
	COLOR = O;
}