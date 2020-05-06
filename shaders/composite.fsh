#version 120

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D gdepth;

varying vec2 texcoord;

const int RGBA16 = 1;
const int gcolorFormat = RGBA16;

void vignette(inout vec3 color){
	float dist = distance(texcoord.st, vec2(0.5)) * 2.0;
	dist /= 1.5142f;

	dist = pow(dist, 1.1f);

	color.rgb  *= (1.0 - dist) / 0.80;
}


void main() {
	// 	vec3 finalComposite = texture2D(gcolor, texcoord).rgb;
	// 	vec3 finalCompositeNormal = texture2D(gnormal, texcoord).rgb;
	// 	vec3 finalCompositeDepth = texture2D(gdepth, texcoord).rgb;

	// /* DRAWBUFFERS:012 */
	// 	gl_FragData[0] = vec4(finalComposite, 1.0); //gcolor
	// 	gl_FragData[0] = vec4(finalCompositeNormal, 1.0); //gnormal
	// 	gl_FragData[0] = vec4(finalCompositeDepth, 1.0); //gdepth

	vec3 color = texture2D(gcolor, texcoord).rgb;
	vignette(color);


/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}