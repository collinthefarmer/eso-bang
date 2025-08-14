shader_type spatial;

uniform float ff;
uniform float fdf;
uniform float a;
uniform float b;

uniform vec3 color : source_color;

void vertex() {
}

void fragment() {
    float ve = VERTEX.z;
    
    float f = fract(ve * ff);
    float df = fwidth(ve * fdf);
    float g = smoothstep(df * a, df * b, f);

    EMISSION = color * g;
    ALBEDO = vec3(g,g,g);
    METALLIC = .2;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
