shader_type canvas_item;
uniform sampler2D NOISE_PATTERN;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float DISPLACEMENT = .01;

void vertex() {
	vec4 noiseValue = texture(NOISE_PATTERN, UV);
	vec2 val = vec2(0,0);
	val.x = noiseValue.r * DISPLACEMENT;
	val.y = noiseValue.r * DISPLACEMENT;
	VERTEX = VERTEX + val;
}

void fragment() {
	
	
	
	vec4 noiseValue = texture(NOISE_PATTERN, UV);
	
	vec2 updated_uv = UV;
	updated_uv += noiseValue.r * DISPLACEMENT;
	vec4 screenValue = texture(SCREEN_TEXTURE, updated_uv);

	COLOR = screenValue;

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
