// Video library
import processing.video.*;

// ControlP5 GUI library
// https://github.com/sojamo/controlp5
import controlP5.*;

Capture cam;
PGraphics camFrame;

VBOGrid vboGrid;

ControlP5 cp5;

float extrude;

void setup() {
    size(800, 600, P3D);

    cam = new Capture(this, 640, 480);
    cam.start();
    camFrame = createGraphics(640, 480, P3D);

    vboGrid = new VBOGrid(100, 100, 640, 480, "POINTS", "customFrag.glsl", "customVert.glsl");
    vboGrid.setShaderUniformBoolean("flipY", true);
    vboGrid.setShaderUniformTexture("fragtex", camFrame);
    vboGrid.setShaderUniformTexture("verttex", camFrame);

    cp5 = new ControlP5(this);
    cp5.addSlider("extrude")
        .setPosition(550, 0)
        .setSize(100, 20)
        .setRange(0.0, 400.0)
        .setValue(200.0)
        .setLabel("Z-Extrude Amount");
}

void draw() {
    background(0);

    // Draw capture to canvas
    if (cam.available() == true) {
        cam.read();
    }

    // Copy capture pixels to PGraphics instance
    cam.loadPixels();
    camFrame.loadPixels();
    arrayCopy(cam.pixels, camFrame.pixels);
    cam.updatePixels();
    camFrame.updatePixels();

    //image(cam, 0, 0);

    vboGrid.setShaderUniformFloat("extrude", extrude);

    vboGrid.draw();
}
