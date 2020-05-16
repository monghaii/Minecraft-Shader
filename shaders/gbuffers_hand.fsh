#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;
uniform mat4 gbufferProjection;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;

/* const int gaux3Format = RGBA32F; */

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	// color *= texture2D(lightmap, lmcoord);

	int itemBrightness = heldBlockLightValue > heldBlockLightValue2 ? heldBlockLightValue : heldBlockLightValue2;

/* DRAWBUFFERS:026 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(normal * 0.5 + vec3(0.5), 1);
	gl_FragData[2] = vec4(lmcoord.st, itemBrightness * 15.0, 1);
}