#version 120

// final colors are sent here

varying vec4 texcoord;
uniform sampler2D gcolor;

void main() {
    vec3 color = texture2D(gcolor, texcoord.st).rgb;
    color.g = color.g * 2.0;
    
    gl_FragColor = vec4(color.rgb, 1.0f);
}