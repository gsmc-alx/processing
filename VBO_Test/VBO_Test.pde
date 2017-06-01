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

// GUI object instance
ControlP5 cp5;

// PostFX and custom passes
PostFX fx;
ConwayPass conwayPass;
FeedbackPass feedbackPass;

// Feedback shader setting variables
float feedbackLevel;
float feedbackSpread;
int feedbackColour;

PGraphics world;

boolean runFX;

float extrude;

void setup() {
    size(800, 600, P3D);

    cam = new Capture(this, 640, 480);
    cam.start();
    camFrame = createGraphics(640, 480, P3D);

    world = createGraphics(width, height, P3D);

    vboGrid = new VBOGrid(200, 200, 800, 600, "POINTS", "customFrag.glsl", "customVert.glsl");
    vboGrid.setShaderUniformBoolean("flipY", true);
    vboGrid.setShaderUniformTexture("fragtex", camFrame);
    vboGrid.setShaderUniformTexture("verttex", camFrame);

    cp5 = new ControlP5(this);
    setupGUI();

    fx = new PostFX(this);

    conwayPass = new ConwayPass();
    feedbackPass = new FeedbackPass();
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

    // Update pass settings
    updatePassSettings();

    // Draw geometry
    world.beginDraw();
    vboGrid.draw();
    world.endDraw();
    image(world, 0, 0);

    // Apply passes
    blendMode(BLEND);
    fx.render()
        .custom(conwayPass)
        .custom(feedbackPass)
        .bloom(0.5, 20, 40)
        .compose();

    //fill(guiLabelColor);
    text("fps: " + frameRate, 20, height - 30);
}

void setupGUI() {
    cp5.addSlider("extrude")
        .setPosition(20, 40)
        .setSize(100, 20)
        .setRange(0.0, 800.0)
        .setValue(300.0)
        .setLabel("Z-Extrude Amount");

    cp5.addSlider("feedbackLevel")
        .setPosition(20, 70)
        .setSize(100, 20)
        .setRange(0.0, 1.0)
        .setValue(0.80);

    cp5.addSlider("feedbackSpread")
        .setPosition(20, 100)
        .setSize(100, 20)
        .setRange(0.0, 1.0)
        .setValue(0.0);

    cp5.addSlider("feedbackColour")
        .setPosition(20, 130)
        .setSize(100, 20)
        .setRange(0, 5)
        .setValue(0.0);

    cp5.addToggle("runFX")
        .setPosition(20, 160)
        .setSize(20, 20)
        .setValue(false);
}

void updatePassSettings()
{
    // VBO Grid uniforms
    vboGrid.setShaderUniformFloat("extrude", extrude);

    // Conway shader uniforms
    conwayPass.setStartFX(runFX);

    // Set uniforms for feedback shader pass
    feedbackPass.setFeedback(feedbackLevel);
    feedbackPass.setFeedbackSpread(feedbackSpread);
    feedbackPass.setFeedbackColour(feedbackColour);
}
