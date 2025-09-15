shader_type canvas_item;

uniform sampler2D ramp_texture : repeat_enable;

const float TWO_PI = 6.28318530718;

void fragment()
{
	vec2 pos = vec2(0.5) - UV;
	COLOR = COLOR.a * texture(ramp_texture, vec2(((atan(pos.y, pos.x) + radians(TIME * 36.0)) / TWO_PI) + 0.5, 0.5)) * (pow(length(pos) * 2.0, 0.15));
}
