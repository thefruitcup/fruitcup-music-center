shader_type canvas_item;
render_mode unshaded;

/*
This Shader is mix of 2 shaders.
https://github.com/Zekiah-A/godot-text-gradient-shader
[put other shader link here]
*/ 


uniform float intensity;

uniform bool x;
uniform vec3 colorH :source_color;

uniform bool y;
uniform vec3 colorV :source_color;

void fragment()
{
	float texture_alpha = texture(TEXTURE, UV).a;

	if (texture_alpha > 0.0)
	{
		if (x == true)
		{
			float ratio = UV.s;
			float iratio = (intensity - ratio);
			
			COLOR = vec4(
				ratio * colorH.r + colorV.r * iratio,
				ratio * colorH.g + colorV.g * iratio,
				ratio * colorH.b + colorV.b * iratio,
				texture_alpha
			);
		}
		if (y == true)
		{
			COLOR = vec4(
				UV.y * colorV.r * intensity,
				UV.y * colorV.g * intensity,
				UV.y * colorV.b * intensity,
				texture_alpha
			);
		}
	}
	else
	{ 
		COLOR = texture(TEXTURE, UV);
	}
}