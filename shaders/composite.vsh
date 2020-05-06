#version 120

uniform int worldTime;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

varying vec2 texcoord;
varying vec3 lightDir;
varying vec3 lightTint;
varying vec3 skyTint;

bool isNight () {
	return worldTime >= 12800 && worldTime <= 23215;
}

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	if (isNight()) {
		lightDir = normalize(moonPosition);
		skyTint = vec3(0.0295, 0.0295, 0.03);
		lightTint = vec3(.1);
	} else {
		lightDir = normalize(sunPosition);
		skyTint = vec3(0.295, 0.295, 0.3);
		lightTint = vec3(1);
	}
}