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

// Custom shader pass class (requires PostFX)
PostFX fx;
FeedbackPass feedbackPass;
ConwayPass conwayPass;

PGraphics canvas;

// GUI library
ControlP5 cp5;
color guiColor = color(200,200,200);

float brushSize;
float feedback;
float channelSpread;
boolean runFX;

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// SETUP /////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

void setup() {

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
  }
  
  camFrame = createGraphics(width, height, P2D);
  
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
  cp5.addSlider("brushSize")
    .setPosition(40, 40)
    .setSize(100, 20)
    .setRange(0.01, 0.05)
    .setValue(0.025)
    .setColorCaptionLabel(guiColor);

  cp5.addSlider("feedback")
    .setPosition(40, 70)
    .setSize(100, 20)
    .setRange(0.0, 0.90)
    .setValue(0.80)
    .setColorCaptionLabel(guiColor);
  
  cp5.addSlider("channelSpread")
    .setPosition(40, 100)
    .setSize(100, 20)
    .setRange(0.00, 0.07)
    .setValue(0.0)
    .setColorCaptionLabel(guiColor);
  
   cp5.addToggle("runFX")
     .setPosition(40, 130)
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
  
  // Set feedback level for feedback pass shader
  feedbackPass.setFeedback(feedback);
  feedbackPass.setChannelSpread(channelSpread);
  
  conwayPass.setStartFX(runFX);
  conwayPass.setMouse(map(mouseX, 0, width, 0, 1), map(mouseY, 0, height, 1, 0));
  conwayPass.setBrushSize(brushSize);
  
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