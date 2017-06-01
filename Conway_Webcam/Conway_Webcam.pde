/*
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////

  A-Life

  Alex Drinkwater 2017

  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
*/

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// LIBRARIES /////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// GLOBAL VARIABLES //////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

Capture cam;
PGraphics camFrame;

// Custom shader pass classes (requires PostFX)
PostFX fx;
FeedbackPass feedbackPass;
ConwayPass conwayPass;

// GUI library and options
ControlP5 cp5;
color guiColor          = color(154, 154, 154);
/* https://forum.processing.org/one/topic/how-to-change-slider-colors-in-controlp5.html
color guiFGColor        = color(154, 154, 154);
color guiBGColor        = color(97, 97, 97);
color guiActiveColor    = color(255, 255, 255);*/
color guiLabelColor     = color(200,200,200);
int controlsTop         = 20;
int controlsLeft        = 20;

// Feedback shader setting variables
float feedbackLevel;
float feedbackSpread;
int feedbackColour;

// Conway shader setting variables
boolean runFX;

void captureEvent(Capture video) {
    video.read();
}

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// SETUP /////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

void setup() {
    size(640, 480, OPENGL);

    //////////////////
    // Init Capture //
    //////////////////

    String[] cameras = Capture.list();
    camFrame = createGraphics(width, height);

    /*if (cameras.length == 0) {
    size(1280, 720, P2D);

    //////////////////
    // Init Capture //
    //////////////////

    String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
    } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    // The camera can be initialized directly using an
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();
    }*/

    cam = new Capture(this, 640, 480);
    cam.start();

    ///////////////////////
    // PostFX pass stuff //
    ///////////////////////

    // Init class instances of PostFX + custom PostFX pass classes
    fx            = new PostFX(this);
    feedbackPass  = new FeedbackPass();
    conwayPass    = new ConwayPass();

    //////////////////
    // Add controls //
    //////////////////

    cp5 = new ControlP5(this);
    /*cp5.addSlider("brushSize")
        .setPosition(40, 40)
        .setSize(100, 20)
        .setRange(0.01, 0.05)
        .setValue(0.025)
        .setColorCaptionLabel(guiColor);*/

    cp5.addSlider("feedbackLevel")
        .setPosition(40, 70)
        .setSize(100, 20)
        .setRange(0.0, 1.0)
        .setValue(0.80)
        .setColorCaptionLabel(guiColor);

    cp5.addSlider("feedbackSpread")
        .setPosition(40, 100)
        .setSize(100, 20)
        .setRange(0.0, 1.0)
        .setValue(0.0)
        .setColorCaptionLabel(guiColor);

    cp5.addSlider("feedbackColour")
        .setPosition(40, 130)
        .setSize(100, 20)
        .setRange(0, 5)
        .setValue(0.0)
        .setColorCaptionLabel(guiColor);

    cp5.addToggle("runFX")
        .setPosition(40, 160)
        .setSize(20, 20)
        .setColorCaptionLabel(guiColor)
        .setValue(false);
}

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// DRAW //////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

void draw() {

    // Update shader uniforms
    updateUniforms();

    // Draw capture to canvas
    if (cam.available() == true) {
        cam.read();
    }

    camFrame.beginDraw();
    image(cam, 0, 0);
    camFrame.endDraw();

    image(camFrame, 0, 0);

    // Apply passes
    blendMode(BLEND);
    fx.render()
        .custom(conwayPass)
        .custom(feedbackPass)
        //.bloom(0.5, 20, 40)
        .compose();

    fill(guiLabelColor);
    text("fps: " + frameRate, controlsLeft, 460);
}

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// FUNCTIONS /////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

void updateUniforms() {

    // Set uniforms for shader Conway pass
    conwayPass.setStartFX(runFX);

    // Set uniforms for feedback shader pass
    feedbackPass.setFeedback(feedbackLevel);
    feedbackPass.setFeedbackSpread(feedbackSpread);
    feedbackPass.setFeedbackColour(feedbackColour);
}
