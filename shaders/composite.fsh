#version 120

uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;
uniform vec3 skyColor;

uniform sampler2D gdepthtex;
uniform sampler2D shadow;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

const int gcolorFormat = 1;
const int gdepthFormat = 0;
const int gnormalFormat = 1;

varying vec2 texcoord;
varying vec3 lightDir;
varying vec3 lightTint;
varying vec3 skyTint;

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
	float ambientLighting = 0.3;

	return color * (sunlightVisibility + ambientLighting);
}

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;
	vec3 normal = texture2D(gnormal, texcoord).rgb * 2.0 - 1.0;
	vec4 depth = texture2D(gdepth, texcoord);

	vec3 directionalLight = lightTint * max(dot(normal, lightDir), 0);
	vec3 torchLight =  depth.x * vec3(1.0, .9, .8);
	vec3 skyLight = depth.y * skyTint;
	float emission = depth.w;
	float ambient = 0.1;
	vec3 phong = color * (directionalLight + torchLight + skyLight) + vec3(ambient); 
	vec3 finalColor;
	if (emission == 1) {
		finalColor = color; // don't use phong model on emissive material
	} else {
		finalColor = phong; // do use phong
	}

	finalColor = calculateLitSurface(finalColor);

/* DRAWBUFFERS:012 */
	gl_FragData[0] = vec4(finalColor, 1.0); //gcolor
	gl_FragData[1] = vec4(vec3(depth), 1.0);
	gl_FragData[2] = vec4(normal, 1.0);
}