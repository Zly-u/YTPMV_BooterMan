shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform float amplitude_horizontal = 0.075;
uniform float frequency_horizontal = 10.0;
uniform float speed_horizontal = 2.0;
uniform float amplitude_vertical = 0.0;
uniform float frequency_vertical = 0.0;
uniform float speed_vertical = 0.0;
uniform vec2 scroll_direction = vec2(0.0, 0.0);
uniform float scrolling_speed = 0.08;
uniform vec2 scrolling_shift = vec2(0.0);

uniform float phase_offset = 45.0;
uniform float hue_blend = 1.0;
uniform float hue = 0.0;
uniform float hue_offset = 0.0;
uniform float hue_time_offset_speed = 1.0;
uniform int amount = 5;
uniform float iteration_scaling = 0.0;
uniform bool keep_original_on_top = false;
uniform bool make_gradual = false;
uniform bool use_screen_texture = true;
uniform float scale_up = 0.0;

uniform float RGB_Blend = 0.0;
uniform float RGB_Strength = 0.0;

vec3 rgb2hsb(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(
		vec4(c.bg, K.wz),
		vec4(c.gb, K.xy),
		step(c.b, c.g)
	);
	vec4 q = mix(
		vec4(p.xyw, c.r),
		vec4(c.r, p.yzx),
		step(p.x, c.r)
	);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(
		abs(q.z + (q.w - q.y) / (6.0 * d + e)),
		d / (q.x + e),
		q.x
	);
}

vec3 hsb2rgb(vec3 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 rgb_offset(sampler2D image, vec2 _UV, float angle, float strength){
    vec2 offset = vec2(cos(radians(angle)), sin(radians(angle))) * (strength/1000.0);

    float r  = texture(image, _UV + offset).r;
    float g  = texture(image, _UV).g;
    float b  = texture(image, _UV - offset).b;
    vec4 pixel = vec4(r+g, g+b, r+b, 1.0);

    return pixel;
}

void fragment()
{
	COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	
	vec2 _UV = use_screen_texture ? SCREEN_UV : UV;
	vec2 scroll = fract(TIME * scroll_direction * scrolling_speed + scrolling_shift/2.0) * -2.0;
	
	for(float i = 0.0; i < float(amount); i++){
		float diff_x = sin((frequency_horizontal * fract(_UV.y)) + (speed_horizontal * TIME) + radians(phase_offset * i)) * amplitude_horizontal;
		float diff_y = sin((frequency_vertical   * fract(_UV.y)) + (speed_vertical   * TIME) + radians(phase_offset * i)) * amplitude_vertical;
		
		vec2 uv_off = fract(_UV);
		
		// To simulate some kind of 3D effect
		if(make_gradual){
			uv_off += vec2(diff_x, diff_y) * (i / float(amount));
		}else{
			uv_off += vec2(diff_x, diff_y);
		}
		
		uv_off = uv_off * (1.0 + iteration_scaling * i) - vec2(iteration_scaling * i / 2.0);
		
		// Scaling
//		uv_off *= 1.0 + scale_up;
		
		if (uv_off.y <= 0.0 || uv_off.y > 1.0){
			uv_off.y = fract(-uv_off.y);
		}
		if (uv_off.x <= 0.0 || uv_off.x > 1.0){
			uv_off.x = fract(-uv_off.x);
		}
		uv_off = fract(uv_off);
		
		vec4 result;
		vec2 scrolled_uv = uv_off+scroll;
		
		if (scrolled_uv.y < 0.0 && scrolled_uv.y > -1.0){
			scrolled_uv.y *= -1.0;
		}
		if (scrolled_uv.y > 1.0 && scrolled_uv.y < 2.0){
			scrolled_uv.y *= -1.0;
		}

		if (scrolled_uv.x < 0.0 && scrolled_uv.x > -1.0){
			scrolled_uv.x *= -1.0;
		}
		if (scrolled_uv.x > 1.0 && scrolled_uv.x < 2.0){
			scrolled_uv.x *= -1.0;
		}
		
		if (use_screen_texture){
			result = texture(SCREEN_TEXTURE, fract(scrolled_uv));
		} else {
			result = texture(TEXTURE, fract(scrolled_uv));
		}
		
		// Hue shift
		vec3 shifted = rgb2hsb(result.rgb);
		shifted.r += (hue / 360.0) + TIME * (hue_time_offset_speed / 360.0) + (hue_offset / 360.0) * i;
		
		// Result
		COLOR += (mix(result, vec4(hsb2rgb(shifted), 1.0), hue_blend) + rgb_offset(SCREEN_TEXTURE, fract(scrolled_uv), 45.0, RGB_Strength)*RGB_Blend)/ float(amount);
	}
	
	
	if (keep_original_on_top){
		vec4 text_clr;	
		if (use_screen_texture){
			text_clr = texture(SCREEN_TEXTURE, _UV);
		}else{
			text_clr = texture(TEXTURE, _UV);
		}
	
		if (sign(text_clr.r) == 1.0){
			COLOR = text_clr;
		}
	}
}