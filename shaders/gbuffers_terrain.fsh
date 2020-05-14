#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;
varying float brightness;

/* const gdepthFormat = RGBA16F */ 

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	// color *= texture2D(lightmap, lmcoord);

	float isEmissive = ceil(lmcoord.s / 16.0);

/* DRAWBUFFERS:012 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord.st, brightness, 0.0);
	gl_FragData[2] = vec4(normal * 0.5 + vec3(0.5), 1); // convert normal from range -1 : 1 to 0 : 1
}