// vert.glsl
#version 150

uniform mat4 transform;
uniform mat4 texMatrix;

uniform bool flipY;

uniform sampler2D verttex;
uniform float extrude;

in vec4 position;
in vec4 color;
in vec2 texCoord;

out vec4 vertColor;
out vec4 vertTexCoord;

void main() {

    vertTexCoord = (flipY == true) ? vec4(texCoord.s, 1.0 - texCoord.t, 0.0, 1.0) : vec4(texCoord.st, 0.0, 1.0);

    vec4 color = texture(verttex, texCoord.st);

    vec4 vertColor = color;
    vec4 newvpos = vec4(position.xy, color.r * extrude, 1.0);

    gl_Position = transform * newvpos;
}
