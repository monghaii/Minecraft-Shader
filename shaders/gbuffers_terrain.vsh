#version 120

#define ENTITY_SMALLGRASS   31.0
#define ENTITY_LOWERGRASS   175.0 
#define ENTITY_UPPERGRASS	176.0 

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform int worldTime;
uniform float frameTimeCounter;
const float PI = 3.1415927;
const float PI48 = 150.796447372;
float pi2wt = (PI48*frameTimeCounter) * 0.5;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
    vec3 ret;
    float magnitude,d0,d1,d2,d3;
    magnitude = sin(pi2wt*fm + pos.x*0.5 + pos.z*0.5 + pos.y*0.5) * mm + ma;
    d0 = sin(pi2wt*f0);
    d1 = sin(pi2wt*f1);
    d2 = sin(pi2wt*f2);
    ret.x = sin(pi2wt*f3 + d0 + d1 - pos.x + pos.z + pos.y) * magnitude;
    ret.z = sin(pi2wt*f4 + d1 + d2 + pos.x - pos.z + pos.y) * magnitude;
	ret.y = sin(pi2wt*f5 + d2 + d0 + pos.z + pos.y - pos.y) * magnitude;
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}

void main() {
	// Initialization
	// gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
	vec3 worldpos = position.xyz + cameraPosition;
	bool istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t;

	if (mc_Entity.x == ENTITY_LOWERGRASS || mc_Entity.x == ENTITY_UPPERGRASS)
			position.xyz += calcMove(worldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));

	
	if ( mc_Entity.x == ENTITY_SMALLGRASS)
		position.xyz += calcMove(worldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0063,
			0.0000,
			vec3(3.0,1.6,3.0),
			vec3(0.0,0.0,0.0));

	// Small grass
  	// if (mc_Entity.x == 31.0) {
  	//   float t = float(mod(worldTime, 300))/300.0;
  	//   vec2 pos = position.xz/16.0;
  	//   if (floor(16.0*gl_MultiTexCoord0.t) <= floor(16.0*gl_MultiTexCoord0.t)) {
  	//     position.x -= (sin(2 * 3.14159*(2.0*pos.x + pos.y - 3.0*t)) + 0.6)/12.0;
  	//   }
  	// }
	
	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
}