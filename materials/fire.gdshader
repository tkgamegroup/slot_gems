shader_type canvas_item;

uniform sampler2D noiseTexture : repeat_enable;
uniform sampler2D maskTexture;
uniform float amount: hint_range (0.0,1.0);

void fragment() {
	vec2 noise_uv = vec2(UV.x, UV.y+TIME*1.5);
	vec4 col = texture(noiseTexture, noise_uv);
	float mask = texture(maskTexture, UV).a;
	col *= mask;
	col = mix(vec4(0.0, 0.0, 0.0, 0.0), col * 2.0, UV.y * amount);
	COLOR *= col;
}
