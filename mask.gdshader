shader_type canvas_item;

uniform vec2 resolution = vec2(320.0, 180.0);
uniform float radius : hint_range(0.0, 2.0);
uniform vec2 center = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = SCREEN_UV;
	uv = uv * 2.0 - 1.0;
	uv.x *= resolution.x / resolution.y;
    float dist = distance(uv, center);

    if (dist < radius)
        COLOR = vec4(0.0);
    else
        COLOR = texture(TEXTURE, SCREEN_UV);
}