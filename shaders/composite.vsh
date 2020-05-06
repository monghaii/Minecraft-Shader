#version 120

uniform int worldTime;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

varying vec2 texcoord;
varying vec3 lightDir;
varying vec3 lightColor;
varying vec3 skyColor;

bool isNight () {
	return worldTime >= 12800 && worldTime <= 23215;
}

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	if (isNight()) {
		lightDir = normalize(moonPosition);
		skyColor = vec3(0.01, 0.01, 0.015);
		lightColor = vec3(.05);
	} else {
		lightDir = normalize(sunPosition);
		skyColor = vec3(0.3, 0.3, 0.35);
		lightColor = vec3(1);
	}
}