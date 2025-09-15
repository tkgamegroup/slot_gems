shader_type canvas_item;

const float pi = 3.14159265358979323846;

mat2 rotate_mat(float ang)
{
	ang = ang * pi / 180.0;
	float cos_a = cos(ang);
	float sin_a = sin(ang);
	return mat2(vec2(cos_a, -sin_a), vec2(sin_a, cos_a));
}

float triangleSDF(in vec2 p, in vec2 a, in vec2 b, in vec2 c, float scl, float ang)
{
	mat2 m = rotate_mat(ang);
	a = (m * a * scl );
	b = (m * b * scl );
	c = (m * c * scl );

    vec2 ab = b - a;
    vec2 bc = c - b;
    vec2 ca = a - c;
    vec2 pa = p - a;
    vec2 pb = p - b;
    vec2 pc = p - c;

    vec2 v1 = pa - ab * clamp( dot(pa, ab) / dot(ab, ab), 0.0, 1.0 );
    vec2 v2 = pb - bc * clamp( dot(pb, bc) / dot(bc, bc), 0.0, 1.0 );
    vec2 v3 = pc - ca * clamp( dot(pc, ca) / dot(ca, ca), 0.0, 1.0 );

    float d = sign(pa.x * ab.y - pa.y * ab.x) +
              sign(pb.x * bc.y - pb.y * bc.x) +
              sign(pc.x * ca.y - pc.y * ca.x);

    if (d < 2.0) {
        return sqrt(min(dot(v1, v1), min(dot(v2, v2), dot(v3, v3))));
    } else {
        return -sqrt(min(dot(v1, v1), min(dot(v2, v2), dot(v3, v3))));
    }
}

void fragment()
{
	vec2 uv = UV - 0.5;

	vec2 p1a = vec2(0.0, 0.7);
    vec2 p1b = vec2(0.6, -0.4);
    vec2 p1c = vec2(-0.6, -0.4);

    vec2 p2a = vec2(0.0, -0.7);
    vec2 p2b = vec2(-0.6, 0.4);
    vec2 p2c = vec2(0.6, 0.4);

	float ang = TIME * 360.0 / 10.0;
    float d1 = triangleSDF(uv, p1a, p1b, p1c, 0.7, ang);
    float d2 = triangleSDF(uv, p2a, p2b, p2c, 0.7, ang);

	float glowPower = 40.0;
    float glow1 = exp(-glowPower * abs(d1));
    float glow2 = exp(-glowPower * abs(d2));

    COLOR = vec4(vec3(1.0, 1.0, 1.0), max(glow1, glow2));
}
