#version 120

uniform sampler2D gcolor;
uniform sampler2D gaux1; // extracted bright for bloom
uniform sampler2D gdepthtex;
uniform sampler2D gaux2;

uniform vec3 fogColor;
uniform float near;
uniform float far;

varying vec2 texcoord;

// put everything together

float LinearizeDepth(vec2 uv)
{
  float n = near; // camera z near
  float f = far; // camera z far
  float z = texture2D(gdepthtex, uv).x;
  return (2.0 * n) / (f + n - z * (f - n));	
}

// GLSL 1.2 doesn't have this, implementing from documentation
float mySmoothstep (float edge0, float edge1, float x) {
	float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

vec3 linearToGamma (vec3 color) {
	return pow(color, vec3(1 / 2.2));
}

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;
    vec3 bloom = texture2D(gaux1, texcoord).rgb;

    color += bloom;

    color = color / (color + vec3(1.0)); // Tonemap

    color = linearToGamma(color);
    
    gl_FragColor = vec4(color, 1);
}