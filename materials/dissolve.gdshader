shader_type canvas_item;

uniform sampler2D dissolve_texture : source_color;
uniform float dissolve : hint_range(0,1);
uniform float burn_size: hint_range(0.0, 1.0, 0.001);
uniform vec4 burn_color: source_color;

void fragment()
{
    vec4 noise_texture = texture(dissolve_texture, UV);
	float burn_size_step = burn_size * step(0.001, dissolve) * step(dissolve, 0.999);
	float threshold = smoothstep(noise_texture.x-burn_size_step, noise_texture.x, dissolve);
	float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, dissolve);
	vec4 img = texture(TEXTURE, UV);
	COLOR *= vec4(mix(burn_color.rgb, img.rgb, border), img.a * threshold);
}
