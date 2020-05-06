#version 120

uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;

uniform float screenBrightness;

// const int gcolorFormat = 1;
// const int gdepthFormat = 0;
// const int gnormalFormat = 1;

varying vec2 texcoord;
varying vec3 lightDir;
varying vec3 lightColor;
varying vec3 skyColor;

vec3 linearToGamma (vec3 color) {
	return pow(color, vec3(1 / 2.2));
}

vec3 gammaToLinear (vec3 color) {
	return pow(color, vec3(2.2));
}

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;
	vec3 normal = texture2D(gnormal, texcoord).rgb;
	vec4 depth = texture2D(gdepth, texcoord);

	normal = normal * 2.0 - 1.0; // Readjust normals so they aren't broken
	
	float adjustedBrightness = 0.6 + 0.4 * screenBrightness;
	vec3 albedo = gammaToLinear(color);
	// vec3 albedo = color;
	
	float emitterLightStrength = depth.x;
	float skyLightStrength = depth.y;
	bool applyPhongShading = depth.w == 0;

	vec3 directionalLight = skyLightStrength * lightColor * max(dot(normal, lightDir), 0);
	vec3 emitterLight =  emitterLightStrength * vec3(1.0, .9, .8); // For things like torches, glowstone
	vec3 skyBrightness = skyLightStrength * skyColor;

	vec3 ambient = albedo * skyBrightness;
	vec3 diffuse = albedo * (directionalLight + emitterLight);
	vec3 phong = diffuse + ambient; 

	vec3 finalColor;
	if (!applyPhongShading) {
		finalColor = albedo; // don't use phong model 
	} else {
		finalColor = phong; // do use phong
	}
	finalColor = linearToGamma(adjustedBrightness * finalColor);

/* DRAWBUFFERS:012 */
	gl_FragData[0] = vec4(finalColor, 1.0); //gcolor
	gl_FragData[1] = vec4(vec3(depth), 1.0);
	gl_FragData[2] = vec4(normal, 1.0);
}