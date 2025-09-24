shader_type canvas_item;

uniform float radius: hint_range(0.0, 1.0, 0.001) = 0.25;

uniform float width: hint_range(0.0, 0.1, 0.0001) = 0.04;
uniform float feather: hint_range(0.0, 1.0, 0.001) = 0.135;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 st = SCREEN_UV;
	float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 scaled_st = (st - vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0, 0.5);
	float dist_center = length(UV - vec2(0.5, 0.5));
	float mask =  (1.0 - smoothstep(radius - feather, radius, dist_center)) * smoothstep(radius - width - feather, radius - width , dist_center);
	vec2 biased_st = scaled_st;
	vec2 final_st = st * (1.0 - mask) + biased_st * mask;
	COLOR = texture(SCREEN_TEXTURE, final_st);
}