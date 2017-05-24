// Conway's game of life

#ifdef GL_ES
precision highp float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform bool run;
uniform sampler2D texture;			// Live input texture
uniform sampler2D previoustexture;	// Previous frame texture
uniform float brushsize;
uniform float feedback;

float cellstates = 100.0;
uniform float a0, a1, a2, a3, a4, a5, a6, a7, a8;
uniform float d0, d1, d2, d3, d4, d5, d6, d7, d8;

vec4 live = vec4(1.0, 1.0, 1.0, 1.0);
vec4 dead = vec4(0.0, 0.0, 0.0, 1.0);

float singlestate = 1. / (cellstates - 1);

vec2 pixel = 1.0 / resolution;

float rand(vec2 pos) {
	return mod(fract(sin(dot(pos + time * 0.001, vec2(14.9898,78.233))) * 43758.5453), 1.0);
}

float val(vec2 pos, vec2 offset) {
	return (texture2D(previoustexture, fract(pos + (pixel * offset))).r > 0.0) ? 1.0 : 0.0;
}

void main( void ) {

	// Normalised texture coordinates
	vec2 position = (gl_FragCoord.xy / resolution.xy);

	if(!run) {
	// Pass through texture input
		gl_FragColor = texture2D(texture, position);
	} else {
	// Run Game of Life

		vec2 rules[9];
		rules[0] = vec2(a0, d0);
		rules[1] = vec2(a1, d1);
		rules[2] = vec2(1., d2);
		rules[3] = vec2(a3, 1.);
		rules[4] = vec2(a4, d4);
		rules[5] = vec2(a5, d5);
		rules[6] = vec2(a6, d6);
		rules[7] = vec2(a7, d7);
		rules[8] = vec2(a8, d8);

		// Paintbrush
		if (length(position-mouse) < brushsize) {
			gl_FragColor = mix(live, dead, step(rand(position), 0.5));
		} else {

			// Neighbouring cells
			float sum = 0.0;
			sum += val(position, vec2(-1., -1.));
			sum += val(position, vec2(-1.,  0.));
			sum += val(position, vec2(-1.,  1.));
			sum += val(position, vec2( 1., -1.));
			sum += val(position, vec2( 1.,  0.));
			sum += val(position, vec2( 1.,  1.));
			sum += val(position, vec2( 0., -1.));
			sum += val(position, vec2( 0.,  1.));

			// Current pixel
			float me = texture2D(previoustexture, position).r;

			// Lookup into rules array
			vec2 r = rules[int(sum)].rg;

			float state = me * r.x + r.y;

			gl_FragColor = vec4(state, state, state, 1.0);
		}
	}
}
