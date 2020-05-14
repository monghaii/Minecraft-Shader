#version 120

uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;
uniform sampler2D gaux2;

uniform sampler2D gdepthtex;
uniform sampler2D shadow;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform float screenBrightness;

varying vec2 texcoord;
varying vec3 lightDir;
varying vec3 lightColor;
varying float skyIntensity;
varying vec3 skyColor;

const float ambientOcclusionLevel = 0.0f;


/*  const gdepthFormat = RGBA32F
	const gcolorFormat = RGBA32F */ 

vec3 linearToGamma (vec3 color) {
	return pow(color, vec3(1 / 2.2));
}

vec3 gammaToLinear (vec3 color) {
	return pow(color, vec3(2.2));
}

float getDepth(in vec2 coord) {
	return texture2D(gdepthtex, coord).r;
}

vec4 getCameraSpacePosition(in vec2 coord) {
	float depth = getDepth(coord);
	vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
	vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;
	return positionCameraSpace / positionCameraSpace.w;
}

vec4 getWorldSpacePosition(in vec2 coord) {
	vec4 positionCameraSpace = getCameraSpacePosition(coord);
	vec4 positionWorldSpace = gbufferModelViewInverse * positionCameraSpace;
	positionWorldSpace.xyz += cameraPosition.xyz;

	return positionWorldSpace;
}

vec3 getShadowSpacePosition(in vec2 coord) {
	vec4 positionWorldSpace = getWorldSpacePosition(coord);

	positionWorldSpace.xyz -= cameraPosition;
	vec4 positionShadowSpace = shadowModelView * positionWorldSpace;
	positionShadowSpace = shadowProjection * positionShadowSpace;
	positionShadowSpace /= positionShadowSpace.w;

	return positionShadowSpace.xyz * 0.5 + 0.5;
}

float getSunVisibility(in vec2 coord) {
	vec3 shadowCoord = getShadowSpacePosition(coord);
	float shadowMapSample = texture2D(shadow, shadowCoord.st).r;
	return step(shadowCoord.z - shadowMapSample, 0.01);
}

vec3 calculateLitSurface(in vec3 color) {
	float sunlightVisibility = getSunVisibility(texcoord.st);
	float ambientLighting = 0.3 * texture2D(gaux2, texcoord.st).r;

	return color * (sunlightVisibility + ambientLighting);
}

vec3 toHDR (in vec3 color) {
	vec3 overExposed = color * 1.2;
	vec3 underExposed = color * 0.3;
	return mix(underExposed, overExposed, color);
}

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;
	vec3 normal = texture2D(gnormal, texcoord).rgb;
	vec4 depth = texture2D(gdepth, texcoord);
	
	float occlusion = texture2D(gaux2, texcoord).r;

	normal = normal * 2.0 - 1.0; // Readjust normals so they aren't broken
	
	float adjustedBrightness = 1.0;
	vec3 albedo = gammaToLinear(color);
	
	float emitterLightStrength = depth.x;
	float skyLightStrength = depth.y;
	float blockBrightness = depth.z;
	bool applyPhongShading = depth.w == 0;

	vec3 directionalLight = skyLightStrength * skyColor * max(dot(normal, lightDir), 0);
	vec3 emitterColor = blockBrightness == 7.0 ? vec3(1.0, 0.3, 0.3) : vec3(1.0, 0.9, 0.8);
	vec3 emitterLight =  emitterLightStrength * emitterColor; // For things like torches, glowstone
	vec3 skyBrightness = skyLightStrength * skyColor * 0.3;

	vec3 ambient = albedo * (skyBrightness + emitterLight);
	ambient *= occlusion;
	vec3 diffuse = albedo * directionalLight;
	vec3 phong = calculateLitSurface(diffuse) + ambient; 

	vec3 finalColor;
	if (!applyPhongShading) {
		finalColor = albedo; // don't use phong model 
	} else if (blockBrightness > 0) {
		finalColor = albedo * (blockBrightness / 3.0);
	} else {
		finalColor = phong; // do use phong
	}
	finalColor = toHDR(finalColor);

	float brightness = dot(finalColor, vec3(0.2126, 0.7152, 0.0722)); 
	
	vec3 extractedBright = (brightness > 4.0) ? finalColor : vec3(0, 0, 0);

	// finalColor = linearToGamma(adjustedBrightness * finalColor);

	// finalColor = calculateLitSurface(finalColor);

/* DRAWBUFFERS:04 */
	gl_FragData[0] = vec4(finalColor, 1.0); //gcolor
	gl_FragData[1] = vec4(extractedBright, 1.0); // for processing bloom
}