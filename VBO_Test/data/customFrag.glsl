// frag.glsl

uniform sampler2D fragtex;
uniform mat4 transform;

in vec4 vertColor;
in vec4 vertTexCoord;

out vec4 fragColor;

void main() {
    fragColor = texture(fragtex, vertTexCoord.st);
}
