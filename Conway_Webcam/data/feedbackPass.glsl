// Mix between input texture and previous frame pixels

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D previoustexture;
uniform float feedback;
uniform float channelspread;
uniform int spreadshuffle;

varying vec4 vertTexCoord;

void main( void ) {
    vec2 position = vertTexCoord.st;
    vec4 mixlevels = vec4(feedback, feedback + channelspread, feedback - channelspread, feedback);

    //vec3 shufflechannels[6] = ;

    gl_FragColor = mix(
        texture2D(texture, position),
        texture2D(previoustexture, position),
        mixlevels
    );
}
