// Video library
import processing.video.*;

// PostFX shader-chaining library
// https://github.com/cansik/processing-postfx
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

// ControlP5 GUI library
// https://github.com/sojamo/controlp5
import controlP5.*;

Capture cam;
PGraphics camFrame;

VBOGrid vboGrid;

ControlP5 cp5;

PostFX fx;

PGraphics world;

float extrude;

void setup() {
    size(800, 600, P3D);

    cam = new Capture(this, 640, 480);
    cam.start();
    camFrame = createGraphics(640, 480, P3D);

    world = createGraphics(width, height, P3D);

    vboGrid = new VBOGrid(200, 200, 800, 600, "LINES", "customFrag.glsl", "customVert.glsl");
    vboGrid.setShaderUniformBoolean("flipY", true);
    vboGrid.setShaderUniformTexture("fragtex", camFrame);
    vboGrid.setShaderUniformTexture("verttex", camFrame);
    
    cp5 = new ControlP5(this);
    setupGUI();
    
    fx = new PostFX(this);
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
    
    world.beginDraw();
    
    vboGrid.draw();
    
    world.endDraw();
    
    image(world, 0, 0);
    
    // Apply passes
    blendMode(BLEND);
    fx.render()
      .bloom(0.5, 20, 40)
      .compose();
}

void setupGUI() {
    cp5.addSlider("extrude")
        .setPosition(20, 20)
        .setSize(100, 20)
        .setRange(0.0, 800.0)
        .setValue(300.0)
        .setLabel("Z-Extrude Amount");
}