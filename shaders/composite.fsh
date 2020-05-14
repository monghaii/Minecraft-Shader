#version 120

// Followed and got some code from this article: https://learnopengl.com/Advanced-Lighting/SSAO

uniform sampler2D gdepthtex;
uniform sampler2D shadow;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float viewHeight;
uniform float viewWidth;

const int gcolorFormat = 1;
const int shadowMapResolution = 4096;
const int noiseTextureResolution = 64;
const float sunPathRotation = 25.0;
const int gdepthFormat = 0;
const int gnormalFormat = 1;
uniform sampler2D gnormal;
uniform sampler2D noisetex;

uniform float frameTimeCounter;
uniform float viewWdith;
uniform float viewHeight;
uniform float near;
uniform float far;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

varying vec2 texcoord;

const int noiseTextureResolution = 64;
const int kernelSamplesInt = 32;
const float kernelSamples = 32.0;
const float radius = 3.0;

int inc = 0;

// GLSL 1.2 doesn't have this, implementing from documentation
float mySmoothstep (float edge0, float edge1, float x) {
	float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

float rand () {
	vec4 noise = texture2D(noisetex, texcoord);
	vec2 co = vec2(inc + cos(noise.r * 25.0 + noise.g + frameTimeCounter * clamp(0.0, 256.0, length(gl_FragCoord))));
	inc++;
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

mat2 getRotationMatrix(in vec2 coord) {
	float rotationAmount = texture2D(
		noisetex,
		coord * vec2(
			viewWidth / noiseTextureResolution,
			viewHeight / noiseTextureResolution
		)
	).r;

	return mat2(
		cos(rotationAmount), -sin(rotationAmount),
		sin(rotationAmount), cos(rotationAmount)
	);
}

vec3 getSunVisibility(in vec2 coord) {
	vec3 shadowCoord = getShadowSpacePosition(coord);

	mat2 rotationMatrix = getRotationMatrix(coord);

	// shadow map averaging
	vec3 shadowColor = vec3(0);
	for(int y = -1; y < 2; y++) {
		for(int x = -1; x < 2; x++) {
			vec2 offset = vec2(x, y) / shadowMapResolution;
			offset = rotationMatrix * offset;
			float shadowMapSample = texture2D(shadow, shadowCoord.st + offset).r;
			float visibility = step(shadowCoord.z - shadowMapSample, 0.01);

			vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb;
			shadowColor += mix(colorSample, vec3(1.0), visibility);
		}
	}

	return shadowColor * 0.111;
}

vec3 calculateLitSurface(in vec3 color) {
	vec3 sunlightVisibility = getSunVisibility(texcoord.st);
	vec3 ambientLighting = vec3(0.3);
float lerp(float a, float b, float f) {
    return a + f * (b - a);
}  

mat3 getTBN (in vec3 n) {
	// get a random rotation vector
	// vec3 randvec = vec3(
	// 	rand() * 2.0 - 1.0,
	// 	rand() * 2.0 - 1.0,
	// 	0
	// );
	// randvec = normalize(randvec);
	// b is gram schmidt result of n and randvec
	// vec3 b = normalize(randvec - (n * dot(randvec, n)));
	vec3 shortestcomp = vec3(0);
	int index = 0;
	for (int i = 1; i < 3; i++) {
		index = n[i] < n[index] ? i : index;
	}
	shortestcomp[index] = 1;
	vec3 b = cross(n, shortestcomp);
	// t is the cross between n and b
	vec3 t = cross(n, b);
	return mat3(t, b, n);
}

vec4 getFragPos () {
	vec4 screenCoords;
	// Initially in NDC
	screenCoords.xy = texcoord;
	screenCoords.z = texture2D(gdepthtex, texcoord).r;
	screenCoords.w = 1.0;
	// To Clip Space
	screenCoords.xyz = screenCoords.xyz * 2.0 - 1.0;
	// To View Space
	vec4 res = gbufferProjectionInverse * screenCoords;
	res.xyz /= res.w;
	return res;
}

float linearize (float d) {
	return (2.0 * near) / (far + near - d * (far - near));
}

// SSAO - Find out how occluded each fragment is
void main() {
	vec3 fragNormal = texture2D(gnormal, texcoord).rgb * 2.0 - 1.0;
	mat3 TBN = getTBN(fragNormal);

	vec3 fragSample = texture2D(gdepthtex, texcoord).rgb;
	float fragDepth = fragSample.z;
	vec3 fragPos = getFragPos().xyz;

	float occluded = 0.0;
	// For a given fragment, sample points in a hemisphere around it. If a given sample is obstructed by geometry, the geometry will have less depth than the sample. 
	// Total occlusion = sum of occluded samples / total samples
	float len;
	bool fuck;
	for (int i = 0; i < kernelSamplesInt; i++) {
		vec3 samplePos = vec3(
			rand() * 2.0 - 1.0, // from -1.0 to 1.0
			rand() * 2.0 - 1.0, // from -1.0 to 1.0
			rand() // from 0.0 to 1.0
		);
		fuck = samplePos.z < 0;
		// Put sample closer to origin
		float scale = 1.0 / kernelSamples;
		scale = lerp(0.1, 1.0, scale * scale);
		samplePos *= scale;
		// Transform samples to eye space
		samplePos = TBN * samplePos;
		samplePos = fragPos + samplePos * radius;
		// Now to ndc
		vec4 offset = vec4(samplePos, 1.0);
		offset = gbufferProjection * offset;
		offset.xyz /= offset.w;
		offset.xyz = offset.xyz * 0.5 + 0.5;
		// Get depth of texture at sample location
		float sampleDepth = texture2D(gdepthtex, offset.xy).z;
		len =  samplePos.z / sampleDepth;
		float rangeCheck = mySmoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
		occluded += (sampleDepth <= fragDepth ? 1 : 0) * rangeCheck;
	}

	float occlusion = 1.0 - (occluded / kernelSamples);

	vec3 color = vec3(occlusion);

/* DRAWBUFFERS:5 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
	// gl_FragData[0] = vec4(occlusion, occlusion, occlusion, 1.0); //gcolor
}