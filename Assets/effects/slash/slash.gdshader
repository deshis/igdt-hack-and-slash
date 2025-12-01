shader_type spatial;
render_mode blend_mix, unshaded;

uniform vec4 base_color : source_color;
uniform vec4 highlight_color : source_color;

uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap, repeat_disable;
uniform sampler2D erosion_texture : source_color, repeat_disable;
uniform sampler2D gradient_texture : source_color, repeat_disable;

uniform float highlight_scale : hint_range(1.0, 2.0, 0.001);
uniform float erosion : hint_range(0.0, 1.0, 0.001);
uniform float fade : hint_range(0.001, 1.0, 0.01);

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset;

void fragment() {
	vec2 base_uv = UV * uv_scale + uv_offset;

	vec2 center = vec2(0.1, 0.5);
	vec2 uv_hi = clamp((base_uv - center) * highlight_scale + center, vec2(0.0), vec2(1.0));

	vec4 tex_hi = texture(texture_albedo, uv_hi);
	vec4 tex_main = texture(texture_albedo, base_uv);

	vec4 base_tex = tex_main - tex_hi;

	float erosion_val = step(erosion, texture(erosion_texture, base_uv).r);

	float minimum = step(0, uv_offset.x*uv_scale.x)*(uv_offset.x);
	float maximum = (1.0*uv_scale.x + step(uv_offset.x, 0.0)*(uv_offset.x))*uv_scale.x;
	float fade_val = smoothstep(minimum, minimum+fade, base_uv.x) * smoothstep(maximum, maximum - fade, base_uv.x);

    // Final Composition
	ALBEDO = tex_hi.rgb * highlight_color.rgb + base_tex.rgb * base_color.rgb;
	ALPHA = (tex_hi.r * highlight_color.a + base_tex.r * base_color.a) * fade_val * erosion_val;
}