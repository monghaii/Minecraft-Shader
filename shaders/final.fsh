#version 120

uniform sampler2D gcolor;
uniform sampler2D gaux1; // extracted bright for bloom

varying vec2 texcoord;

// put everything together

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