#version 120

uniform sampler2D gcolor;
uniform sampler2D gaux1; // extracted bright for bloom

varying vec2 texcoord;
varying vec2 imageSize;

uniform float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

// Bloom second pass

void main() {
	vec4 color = texture2D(gcolor, texcoord);

    vec2 texOffset = vec2(1.0) / imageSize;
    
    vec3 result = vec3(0);

    // Vertical second
    for (int i = 0; i < 5; i++) {
        result += texture2D(gaux1, texcoord + vec2(0, texOffset.y * i)).rgb * weight[i];
        result += texture2D(gaux1, texcoord - vec2(0, texOffset.y * i)).rgb * weight[i];
    }
    
    /* DRAWBUFFERS:04 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(result, 1.0);
}