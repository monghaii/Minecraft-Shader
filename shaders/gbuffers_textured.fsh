#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:012 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord.st, 0.0, 0.0);
	gl_FragData[2] = vec4(normal, 1.0);
}