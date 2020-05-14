#version 120

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;
varying float brightness;

attribute vec4 mc_Entity;

const float LAVA = 10010.0;
const float FIRE = 10051.0;
const float REDSTONE_TORCH = 10076.0;
const float GLOWSTONE = 10089.0;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	float blockId = mc_Entity.x;
	
	if ( blockId == LAVA ||blockId == FIRE || blockId == REDSTONE_TORCH || blockId == GLOWSTONE ) {
		brightness = blockId == REDSTONE_TORCH ? 7.0 : 15.0;
	} else {
		brightness = 0;
	}

	normal = normalize(gl_NormalMatrix * gl_Normal);
}