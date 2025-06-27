shader_type canvas_item;
uniform float cookVal: hint_range(0.0,100.0) = 0.0;
uniform bool isBurnt = false;

void vertex() {
	// Called for every vertex the material is visible on.
}
void fragment() {
	// Called for every pixel the material is visible on.
	vec4 cookedColor = vec4(0,0,0,1);
    vec4 base_color = texture(TEXTURE, UV);

//TODO This needs an overhaul
	if (isBurnt){
		cookedColor.r = base_color.r + (cookVal * .0005);
		cookedColor.g = base_color.g + (cookVal * .005);
		cookedColor.b = base_color.b + (cookVal * .005);
		cookedColor.a = base_color.a;
	} else {
		cookedColor.r = base_color.r;
		cookedColor.g = base_color.g + (cookVal * .005);
		cookedColor.b = base_color.b - (cookVal * .005);
		cookedColor.a = base_color.a;
	}
	
	COLOR = cookedColor;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
