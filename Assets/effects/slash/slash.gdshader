shader_type spatial;
render_mode blend_mix, unshaded;

uniform vec4 base_color : source_color;
uniform vec4 highlight_color : source_color;
uniform sampler2D texture_albedo : source_color, repeat_disable, filter_linear;
uniform sampler2D erosion_texture : source_color, repeat_disable;

uniform float highlight_scale : hint_range(1.0, 2.0, 0.001);
uniform float erosion : hint_range(0.0, 1.0, 0.001);

uniform vec3 uv_scale;
uniform vec3 uv_offset;

void vertex() {
	UV = UV * uv_scale.xy + uv_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec2 center = vec2(0.1, 0.5);
    vec2 scaled_uv = (base_uv - center) * highlight_scale + center;
	
	vec4 hi_tex = texture(texture_albedo, scaled_uv);
	vec4 base_tex = texture(texture_albedo, base_uv) - hi_tex;
	
	vec4 erosion_tex = texture(erosion_texture, vec2(base_uv.y, base_uv.x));
	float erosion_val = step(erosion, erosion_tex.r); 
	
    ALBEDO = hi_tex.rgb * highlight_color.rgb + base_tex.rgb * base_color.rgb;
	ALPHA = hi_tex.r * highlight_color.a + base_tex.r * base_color.a;
	ALPHA *= erosion_val;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
