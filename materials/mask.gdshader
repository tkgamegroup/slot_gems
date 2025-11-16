shader_type canvas_item;

uniform float offset : hint_range(0.0, 2.0);

void fragment() {
    vec2 uv = SCREEN_UV;
	uv.x *= TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
	uv.y += offset;

    if (uv.y > 1.0 && uv.y < 2.0)
        COLOR = vec4(0.0);
    else
        COLOR = texture(TEXTURE, SCREEN_UV);
}