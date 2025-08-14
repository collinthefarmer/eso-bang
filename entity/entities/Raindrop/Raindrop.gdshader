shader_type spatial;

uniform vec3 color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	EMISSION = color;
}

void light() {
}
