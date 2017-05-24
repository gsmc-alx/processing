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

// Custom shader pass class (requires PostFX)
PostFX fx;
FeedbackPass feedbackPass;

PShader conway;
PGraphics canvas;

// GUI library
ControlP5 cp5;
color guiColor = color(200,200,200);

float brushSize;
float feedback;

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// SETUP /////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

void setup() {

  size(640, 480, P2D);

  // Add controls
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
    .setRange(0., 0.95)
    .setValue(0.80)
    .setColorCaptionLabel(guiColor);

  // Init shader stuff
  canvas = createGraphics(width, height, P3D);
  canvas.noSmooth();

  conway = loadShader("conway.glsl");
  conway.set("resolution", float(canvas.width), float(canvas.height));

  // PostFX pass stuff
  fx = new PostFX(this);
  feedbackPass = new FeedbackPass();
}

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// DRAW //////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

void draw() {

  // Shader uniforms
  conway.set("time", millis()/1000.0);
  float x = map(mouseX, 0, width, 0, 1);
  float y = map(mouseY, 0, height, 1, 0);
  conway.set("brushsize", brushSize);
  conway.set("mouse", x, y);

  // Draw shader
  canvas.beginDraw();
  canvas.background(0);
  canvas.shader(conway);
  canvas.rect(0, 0, canvas.width, canvas.height);
  canvas.endDraw();
  image(canvas, 0, 0);

  // Set feedback level for feedback pass shader
  feedbackPass.setfeedback(feedback);

  // Apply passes
  blendMode(BLEND);
  fx.render()
    .custom(feedbackPass)
    .compose();

}