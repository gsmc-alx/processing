// Video library
import processing.video.*;

//Peasycam
import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

// ControlP5 GUI library
// https://github.com/sojamo/controlp5
import controlP5.*;

Capture cam;
PGraphics camFrame;

VBOGrid vboGrid;

ControlP5 cp5;

PeasyCam pcam;

PGraphics canvas;

float extrude;

void setup() {
    size(800, 600, P3D);

    cam = new Capture(this, 640, 480);
    cam.start();
    camFrame = createGraphics(640, 480, P3D);

    canvas = createGraphics(width, height, P3D);

    vboGrid = new VBOGrid(400, 300, 800, 600, "POINTS", "customFrag.glsl", "customVert.glsl");
    vboGrid.setShaderUniformBoolean("flipY", true);
    vboGrid.setShaderUniformTexture("fragtex", camFrame);
    vboGrid.setShaderUniformTexture("verttex", camFrame);

    cp5 = new ControlP5(this);
    cp5.addSlider("extrude")
        .setPosition(20, 20)
        .setSize(100, 20)
        .setRange(0.0, 800.0)
        .setValue(300.0)
        .setLabel("Z-Extrude Amount");

    /*pcam = new PeasyCam(this, 500);
    pcam.setMinimumDistance(50);
    pcam.setMaximumDistance(500);*/
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

    vboGrid.setShaderUniformFloat("extrude", extrude);

    vboGrid.draw();
}
