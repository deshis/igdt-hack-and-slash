shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.0;

vec3 interpolate_vec3(vec3 start, vec3 end, float delta){
	return start + (end - start) * delta;
}

void fragment(){
	vec4 tex = texture(TEXTURE, UV);
	COLOR.rgb = interpolate_vec3(tex.rgb, vec3(1,1,1), strength);
}