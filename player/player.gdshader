shader_type canvas_item;

uniform sampler2D palette;

uniform vec4 old_color_1: hint_color;
uniform vec4 old_color_2: hint_color;
uniform vec4 old_color_3: hint_color;

uniform vec4 new_color_1: hint_color;
uniform vec4 new_color_2: hint_color;
uniform vec4 new_color_3: hint_color;

const float precision = 0.09;

vec4 swap_color(vec4 color){
	vec4 original_colors[3] = vec4[3] (old_color_1, old_color_2, old_color_3);
	vec4 replace_colors[3] = vec4[3] (new_color_1, new_color_2, new_color_3);
	for (int i = 0; i < 3; i ++) {
		if (distance(color, original_colors[i]) <= precision){
			vec4 new_color = replace_colors[i];
			new_color.a = color.a;
			return new_color;
		}
	}
	return color;
}


void fragment() {
	COLOR = swap_color(texture(TEXTURE, UV));
}