#version 120

uniform sampler2D gcolor;
uniform sampler2D gaux1; // extracted bright for bloom

varying vec2 texcoord;
varying vec2 imageSize;

uniform float weight[9] = float[] (0.008488, 0.038078, 0.111165, 0.211357, 0.261824, 0.211357, 0.111165, 0.038078, 0.008488);

// Bloom second pass

void main() {
    vec2 texOffset = vec2(1.0) / imageSize;
    
    vec3 result = vec3(0);

    // Vertical second
    for (int i = 0; i < 9; i++) {
        result += texture2D(gaux1, texcoord + vec2(0, texOffset.y * i)).rgb * weight[i];
        result += texture2D(gaux1, texcoord - vec2(0, texOffset.y * i)).rgb * weight[i];
    }
    
    /* DRAWBUFFERS:4 */
    gl_FragData[0] = vec4(result, 1.0);
}