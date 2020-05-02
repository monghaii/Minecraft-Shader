#version 120

// can pass from vertex to fragment
varying vec4 texcoord;

void main() {
    gl_Position = ftransform(); // pos of current vert
    texcoord = gl_MultiTexCoord0;
}