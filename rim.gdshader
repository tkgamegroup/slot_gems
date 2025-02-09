shader_type canvas_item;

void fragment() {
	vec2 iResolution = 1.0 / TEXTURE_PIXEL_SIZE;
	
	vec2 uv_g = vec2(ivec2(UV * iResolution)) / iResolution;
	vec2 uv_c = uv_g - vec2(0.5, 0.5);
	float L = texture(TEXTURE, UV + vec2(-0.5, 0.0) / iResolution).a;
	float R = texture(TEXTURE, UV + vec2(+0.5, 0.0) / iResolution).a;
	float T = texture(TEXTURE, UV + vec2(0.0, -0.5) / iResolution).a;
	float B = texture(TEXTURE, UV + vec2(0.0, +0.5) / iResolution).a;
	float ang = (atan(uv_c.y, uv_c.x) / PI + 1.0) / 2.0;
	float edge = min(1.0, abs(L - R) + abs(T - B));
	COLOR = mix(texture(TEXTURE, UV), mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(1.0, 1.0, 1.0, 1.0), step(fract(ang * 10.0 + TIME), 0.5)), edge);
	//COLOR = texture(TEXTURE, UV);
}

