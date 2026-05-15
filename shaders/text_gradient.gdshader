shader_type canvas_item;

uniform vec4 color1 :source_color = vec4(1, 0, 0,1); // RED
uniform vec4 color2 :source_color= vec4(0, 0, 1,0.2); // BLUE

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	
	float ratio = SCREEN_UV.x;
	float iratio = (0.6 - SCREEN_UV.x);
	
	float new_r = color2.r * ratio + color1.r * iratio;
	float new_g = color2.g * ratio + color1.g * iratio;
	float new_b = color2.b * ratio + color1.b * iratio;
	
	COLOR = vec4(new_r, new_g, new_b, current_color.a);
}