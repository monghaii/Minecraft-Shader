#version 120

uniform sampler2D gaux2;
uniform float viewWidth;
uniform float viewHeight;

varying vec2 texcoord;

void main() {
    int ntexels = 7; 
    float ntexelsf = float(ntexels);
    vec2 offset = vec2(1.0 / viewWidth, 1.0 / viewHeight);
    float occlusion = 0.0;
    for (int i = 0; i < ntexels; i++) {
        for (int j = 0; j < ntexels; j++) {
            int ioffset = i - (ntexels / 2);
            int joffset = j - (ntexels / 2);
            occlusion += texture2D(gaux2, texcoord + offset * vec2(ioffset, joffset)).r;
        }
    }
    occlusion /= (ntexelsf * ntexelsf);

    /* DRAWBUFFERS:5 */
    gl_FragData[0] = vec4(occlusion, occlusion, occlusion, 1.0);
}