shader_type canvas_item;

// https://www.shadertoy.com/view/Mlcczr
// https://www.shadertoy.com/view/4d3SRr

uniform sampler2D height_map : repeat_enable;

#define S(r,v) smoothstep(9./iResolution.y,0.,abs(v-(r)))

const vec2 s = vec2(1, 1.7320508); // 1.7320508 = sqrt(3)
const vec3 baseCol = vec3(.05098, .25098, .2784);
const float borderThickness = .03;
const float isolineOffset = .4;
const float isolineOffset2 = .325;
const float normalStrength = 12.0;
const vec2 normalResolution = vec2(512., 512.);
const float distortionStrength = .42;

float calcHexDistance(vec2 p)
{
    p = abs(p);
    return max(dot(p, s * .5), p.x);
}

float random(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 calcHexInfo(vec2 uv)
{
    vec4 hexCenter = round(vec4(uv, uv - vec2(.5, 1.)) / s.xyxy);
    vec4 offset = vec4(uv - hexCenter.xy * s, uv - (hexCenter.zw + .5) * s);
    return dot(offset.xy, offset.xy) < dot(offset.zw, offset.zw) ? vec4(offset.xy, hexCenter.xy) : vec4(offset.zw, hexCenter.zw);
}

vec4 heightToNormal(vec2 uv)
{
    vec2 sr = 1.0/normalResolution.xy;

    float p = texture(height_map, uv).x;
    float h1 = texture(height_map, uv + sr * vec2(1,0)).x;
    float v1 = texture(height_map, uv + sr * vec2(0,1)).x;

    vec2 xy = (p - vec2(h1, v1)) * normalStrength;

    return vec4(xy + .5, 1., 1.);
}

void fragment()
{
    vec2 iResolution = vec2(1.0) / SCREEN_PIXEL_SIZE;
	float time = TIME * 0.1;

    vec2 uv = 2.5 * (2. * FRAGCOORD.xy - iResolution.xy) / iResolution.y;
    uv.x -= time;
    uv.y -= time * 0.5;

	float a = 1.7;
    float cAngle = cos(a);
    float sAngle = sin(a);
    uv = mat2(vec2(cAngle, -sAngle), vec2(sAngle, cAngle)) * uv;
	//uv += random(uv) * 0.2;

	vec4 normal = heightToNormal(UV + time * 0.3);
    vec2 displacement = clamp((normal.xy - .5) * distortionStrength, -1., 1.);
	uv += displacement * .3;

    vec4 hexInfo = calcHexInfo(uv);
    float totalDist = calcHexDistance(hexInfo.xy) + borderThickness;
    float rand = random(hexInfo.zw);

    float angle = atan(hexInfo.y, hexInfo.x) + rand * 5. + time;
    vec3 isoline = S(isolineOffset, totalDist) * baseCol * step(.5 + rand * .5, mod(angle, 6.28))
        + S(isolineOffset2, totalDist)
                    * baseCol * step(.1 + rand * 1.5, mod(angle + rand * 2., 6.28));

    float sinOffset = sin(time + rand * 8.);
    float aa = 2. / iResolution.y;

    COLOR.rgb = (smoothstep(.51, .51 - aa, totalDist) + pow(1. - max(0., .5 - totalDist), 20.) * .5)
        * (baseCol + rand * vec3(0., .03, .02)) + isoline * .0 + baseCol * smoothstep(.02 + sinOffset, .02 + sinOffset - aa, totalDist) * .3;
}
