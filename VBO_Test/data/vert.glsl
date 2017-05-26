// vert.glsl
#version 150

uniform mat4 transform;
uniform mat4 texMatrix;

in vec4 position;
in vec4 color;
in vec2 texCoord;

out vec4 vertColor;
out vec4 vertTexCoord;

void main() {
  gl_Position = transform * position;
  vertTexCoord = vec4(texCoord, 0.0, 1.0);//texMatrix * vec4(texCoord, 1.0, 1.0);
  vertColor = color;
}
