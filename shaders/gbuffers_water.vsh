#version 120

const float waves_amplitude  = 0.65;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

varying vec3 worldpos;

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

void main() {

	// Initialization
	// gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec3 normal = normalize(gl_NormalMatrix * gl_Normal).xyz;
	vec3 position = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;
	worldpos = position.xyz + cameraPosition;

	// Waving 
	float fy = fract(worldpos.y + 0.001);
	float wave = 0.05 * sin(2 * 3.14159 * (frameTimeCounter*0.8 + worldpos.x /  2.5 + worldpos.z / 5.0))
			   + 0.05 * sin(2 * 3.14159 * (frameTimeCounter*0.6 + worldpos.x / 6.0 + worldpos.z /  12.0));
	position.y += clamp(wave, -fy, 1.0-fy)*waves_amplitude;

	gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);
}