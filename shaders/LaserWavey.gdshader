shader_type canvas_item;

uniform sampler2D NOISE_PATTERN1;
uniform sampler2D NOISE_PATTERN2;
uniform sampler2D EDGE_NOISE_PATTERN;
uniform vec2 scroll1 = vec2(1.0, 0.4);
uniform vec2 scroll2 = vec2(0.2, 1.4);
uniform vec2 edge_scroll = vec2(1.4, 0.4);
uniform float speed : hint_range(0, 1) = 0.05;
uniform float xStretch = 1.0;
uniform float yStretch = 0.1;

uniform float laserSize : hint_range(0, 1) = 0.5;
uniform float wobbliness : hint_range(0, 1) = 0.1;
uniform float edge_jaggedness : hint_range(0, 1) = 0.1;

uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;
uniform float colorMixFactor : hint_range(0, 10) = 1;
uniform float glowFactor = 2.5;

uniform sampler2D TRANSPARENCY_VARIATION;
uniform float minAlpha = 0.3;

void fragment() {
	vec2 stretched_UV = UV;
	stretched_UV.x *= xStretch * sin(TIME);
	stretched_UV.y *= yStretch * sin(TIME);
	
	float intensity1 = textureLod(NOISE_PATTERN1, stretched_UV + TIME * scroll1 * speed, 0.0).r;
	float intensity2 = textureLod(NOISE_PATTERN2, stretched_UV + TIME * scroll2 * speed, 0.0).r;
	float intensity = intensity1 * intensity2;
	
    float edge_noise = textureLod(EDGE_NOISE_PATTERN, stretched_UV + TIME * edge_scroll * speed, 0.0).r;

	float centrality = (1.0 - abs(UV.y - 0.5)) * 0.5;
	
	if (wobbliness * intensity + (1.0 - wobbliness) * centrality > 1.0 - laserSize)
    //if (wobbliness * intensity + (1.0 - wobbliness) * centrality + edge_jaggedness * edge_noise > 1.0 - laserSize)
    //if (wobbliness * intensity + (1.0 - wobbliness) * centrality + edge_jaggedness * edge_noise > 1.0 - laserSize)
	{
		intensity *= centrality;
		COLOR = mix(color1, color2, clamp(intensity * colorMixFactor, 0.0, 1.0)) * glowFactor;
		
		float alpha = textureLod(TRANSPARENCY_VARIATION, stretched_UV + TIME * scroll1 * speed, 0.0).r;
		COLOR.a = minAlpha + alpha * (1.0 - minAlpha);
	}
}

uniform float waveFrequency : hint_range(0, 10) = 1.0;
uniform float waveAmplitude : hint_range(0, 1) = 0.1;
uniform float waveSpeed : hint_range(-2, 2) = 1.0;

void vertex() {
    //float wave = waveAmplitude * sin(waveFrequency * (UV.x * 2.0 * 3.141592) + waveSpeed * TIME);
    //VERTEX.y += wave;
	
	//VERTEX += vec2(cos(TIME)*10.0, sin(TIME)*10.0);
	
	VERTEX.y += cos(TIME) * 10.0;
}

/*shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float amplitude: hint_range(0, 100) = 10.0;
uniform float frequency: hint_range(0, 10) = 2.0;
uniform float speed: hint_range(0, 5) = 1.0;

void fragment() {
	vec2 uv = UV;
	float time = TIME * speed;
	float noise_value = texture(noise_texture, vec2(uv.x, uv.y + time)).r;
	float wave = sin((uv.y + time) * frequency + noise_value * 10.0) * amplitude * noise_value;
	uv.x += wave;

	vec4 albedo = texture(TEXTURE, uv);
	COLOR = albedo;
}*/