shader_type canvas_item;
render_mode unshaded;

/*
This Shader is a heavily modified version of 2 shaders.
https://github.com/Zekiah-A/godot-text-gradient-shader
*/ 


uniform float intensity;

uniform vec3 colorH :source_color;
uniform vec3 colorV :source_color;
uniform vec4 modulate :source_color= vec4(1,1,1,1);

void fragment()
{
	float texture_alpha = texture(TEXTURE, UV).a;

	if (texture_alpha > 0.0)
	{
		float ratio = UV.s;
		float iratio = (intensity - ratio);
		
		COLOR = vec4(
			ratio * colorH.r + colorV.r * iratio,
			ratio * colorH.g + colorV.g * iratio,
			ratio * colorH.b + colorV.b * iratio,
			texture_alpha
		) * modulate;
	}
}