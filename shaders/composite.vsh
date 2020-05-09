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
		lightColor = vec3(.1);
		skyColor = vec3(0.0, 0.15, 0.25);
	} else {
		lightDir = normalize(sunPosition);
		lightColor = vec3(1);
		skyColor = vec3(1.0, 1.0, 0.9);
	}
}