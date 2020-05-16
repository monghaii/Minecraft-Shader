#version 120

uniform float viewWidth;
uniform float viewHeight;

varying vec2 texcoord;
varying vec2 imageSize;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    imageSize = vec2(viewWidth, viewHeight);
}