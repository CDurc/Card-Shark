shader_type particles;

void process(inout Particle particle) {
	vec3 dir = normalize(particle.position);
	dir.y = 0.0;
	dir = normalize(dir);

	float angle = atan(dir.x, dir.z);

	particle.rotation = vec3(0.0, angle, 0.0);
	particle.velocity = dir * 5.0 + vec3(0.0, 2.0, 0.0);
}
