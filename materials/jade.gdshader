// https://www.shadertoy.com/view/llcXW7

shader_type canvas_item;

uniform vec3 type_color : source_color;
uniform vec2 offset;

#define TILING_FACTOR 1.0
#define MAX_ITER 8

// All components are in the range [0…1], including hue.
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float waterHighlight(vec2 p, float time, float foaminess)
{
    vec2 i = vec2(p);
	float c = 0.0;
    float foaminess_factor = mix(1.0, 6.0, foaminess);
	float inten = .005 * foaminess_factor;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)),p.y / (cos(i.y+t))));
	}
	c = 0.2 + c / (inten * float(MAX_ITER));
	c = 1.17-pow(c, 1.4);
    c = pow(abs(c), 8.0);
	return c / sqrt(foaminess_factor);
}

void fragment() 
{
	float time = TIME * 0.4+23.0;
	vec2 uv = UV * 1.0;
    float dist_center = pow(2.0*length(uv - 0.5), 2.0);
    
    float foaminess = smoothstep(0.4, 1.8, dist_center);
    float clearness = 0.1 + 0.9*smoothstep(0.1, 0.5, dist_center);
    
	vec2 p = mod((uv+offset)*TAU*TILING_FACTOR, TAU)-250.0;
    
    float c = waterHighlight(p, time, foaminess);
	
	vec3 complementary = rgb2hsv(type_color);
	complementary.r = fract(complementary.r + 0.5);
	complementary = hsv2rgb(complementary);
	vec3 col = mix(type_color, complementary, 1.0 - step(0.15, c));
    
    COLOR.rgb = mix(COLOR.rgb, col, c * clearness);
	//COLOR.rgb = complementary;
}
