#version 120

uniform sampler2D gaux2;
uniform float viewWidth;
uniform float viewHeight;

varying vec2 texcoord;

void main() {
    vec2 offset = vec2(1.0 / viewWidth, 1.0 / viewHeight);
    float occlusion = 0.0;
    for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
            occlusion += texture2D(gaux2, texcoord + offset * vec2(i, j)).r;
        }
    }
    occlusion /= (5.0 * 5.0);

    /* DRAWBUFFERS: 5 */
    gl_FragData[0] = vec4(occlusion, occlusion, occlusion, 1.0);
}