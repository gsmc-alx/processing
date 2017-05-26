
VBOGrid vboGrid;
PShader shader;

void setup() {
  size(800, 600, P3D);

  vboGrid = new VBOGrid(100, 100, 400, 400, "POINTS", null, null);
}

void draw() {
  background(0);
  
  vboGrid.draw();

  
}