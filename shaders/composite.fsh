#version 120

uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;
uniform vec3 skyColor;

const int gcolorFormat = 1;
const int gdepthFormat = 0;
const int gnormalFormat = 1;

varying vec2 texcoord;
varying vec3 lightDir;
varying vec3 lightTint;
varying vec3 skyTint;

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;
	vec3 normal = texture2D(gnormal, texcoord).rgb * 2.0 - 1.0;
	vec4 depth = texture2D(gdepth, texcoord);

	vec3 directionalLight = lightTint * max(dot(normal, lightDir), 0);
	vec3 torchLight =  depth.x * vec3(1.0, .9, .8);
	vec3 skyLight = depth.y * skyTint;
	float emission = depth.w;
	float ambient = 0.1;
	vec3 phong = color * (directionalLight + torchLight + skyLight) + vec3(ambient); 
	vec3 finalColor;
	if (emission == 1) {
		finalColor = color; // don't use phong model on emissive material
	} else {
		finalColor = phong; // do use phong
	}

/* DRAWBUFFERS:012 */
	gl_FragData[0] = vec4(finalColor, 1.0); //gcolor
	gl_FragData[1] = vec4(vec3(depth), 1.0);
	gl_FragData[2] = vec4(normal, 1.0);
}