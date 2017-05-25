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

PGraphics canvas;

// GUI library
ControlP5 cp5;
color guiColor = color(200,200,200);

float feedback;
float channelSpread;
int channelSpreadShuffle;
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

    size(640, 480, P3D);

    //////////////////
    // Init Capture //
    //////////////////

    String[] cameras = Capture.list();

    /*if (cameras.length == 0) {
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
    camFrame = createGraphics(640, 480, P3D);

    ///////////////////////
    // PostFX pass stuff //
    ///////////////////////

    fx            = new PostFX(this);
    feedbackPass  = new FeedbackPass();
    conwayPass    = new ConwayPass();

    //////////////////
    // Add controls //
    //////////////////

    cp5 = new ControlP5(this);
    cp5.addSlider("feedback")
        .setPosition(40, 70)
        .setSize(100, 20)
        .setRange(0.0, 1.0)
        .setValue(0.0)
        .setColorCaptionLabel(guiColor);

    cp5.addSlider("channelSpread")
        .setPosition(40, 100)
        .setSize(100, 20)
        .setRange(0.0, 1.0)
        .setValue(0.0)
        .setColorCaptionLabel(guiColor);

    cp5.addSlider("channelSpreadShuffle")
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

    updateUniforms();

    if (cam.available() == true) {
        cam.read();
    }

    // Copy capture pixels to PGraphics instance
    cam.loadPixels();
    camFrame.loadPixels();
    arrayCopy(cam.pixels, camFrame.pixels);
    cam.updatePixels();
    camFrame.updatePixels();

    image(camFrame, 0, 0);

    // Apply passes
    blendMode(BLEND);
    fx.render()
        .custom(conwayPass)
        .custom(feedbackPass)
        //.bloom(0.5, 20, 40)
        .compose();
}

void updateUniforms() {
    // Set uniforms for Conway pass shader
    conwayPass.setStartFX(runFX);

    // Set uniforms for feedback pass shader
    feedbackPass.setFeedback(feedback);
    feedbackPass.setChannelSpread(channelSpread);
    feedbackPass.setChannelSpreadShuffle(channelSpreadShuffle);
}
