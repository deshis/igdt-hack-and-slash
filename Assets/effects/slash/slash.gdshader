shader_type spatial;
render_mode blend_add, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, repeat_disable;
uniform sampler2D erosion_texture : source_color;

uniform float erosion : hint_range(0.0, 1.0, 0.001);

uniform vec3 uv_scale;
uniform vec3 uv_offset;

void vertex() {
	UV = UV * uv_scale.xy + uv_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	
	vec4 erosion_tex = texture(erosion_texture, vec2(base_uv.y, base_uv.x));
	float erosion_val = step(erosion, erosion_tex.r); 
	
	ALBEDO = albedo_tex.rgb * albedo.rgb;
	ALPHA = step(0.2,albedo_tex.r) * erosion_val;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
