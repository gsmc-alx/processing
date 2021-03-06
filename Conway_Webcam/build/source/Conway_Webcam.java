import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import ch.bildspur.postfx.builder.*; 
import ch.bildspur.postfx.pass.*; 
import ch.bildspur.postfx.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Conway_Webcam extends PApplet {

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


// PostFX shader-chaining library
// https://github.com/cansik/processing-postfx




// ControlP5 GUI library
// https://github.com/sojamo/controlp5


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
int guiColor          = color(154, 154, 154);
/* https://forum.processing.org/one/topic/how-to-change-slider-colors-in-controlp5.html
color guiFGColor        = color(154, 154, 154);
color guiBGColor        = color(97, 97, 97);
color guiActiveColor    = color(255, 255, 255);*/
int guiLabelColor     = color(200,200,200);
int controlsTop         = 20;
int controlsLeft        = 20;

// Feedback shader setting variables
float feedbackLevel;
float feedbackSpread;
int feedbackColour;

// Conway shader setting variables
boolean runFX;

public void captureEvent(Capture video) {
    video.read();
}

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// SETUP /////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

public void setup() {
    

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
        .setRange(0.0f, 1.0f)
        .setValue(0.80f)
        .setColorCaptionLabel(guiColor);

    cp5.addSlider("feedbackSpread")
        .setPosition(40, 100)
        .setSize(100, 20)
        .setRange(0.0f, 1.0f)
        .setValue(0.0f)
        .setColorCaptionLabel(guiColor);

    cp5.addSlider("feedbackColour")
        .setPosition(40, 130)
        .setSize(100, 20)
        .setRange(0, 5)
        .setValue(0.0f)
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

public void draw() {

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

public void updateUniforms() {

    // Set uniforms for shader Conway pass
    conwayPass.setStartFX(runFX);

    // Set uniforms for feedback shader pass
    feedbackPass.setFeedback(feedbackLevel);
    feedbackPass.setFeedbackSpread(feedbackSpread);
    feedbackPass.setFeedbackColour(feedbackColour);
}
/*
  ////////////////////////////////////////
  PostFX custom pass class definition

  Dependencies:
  PostFX library
  ////////////////////////////////////////
*/

class ConwayPass implements Pass
{
    PShader shader;

    // Shader uniforms
    PGraphics previousTexture;                 // Previous texture for feedback
    float brushSize;                           // Brush size
    float a0, a1, a2, a3, a4, a5, a6, a7, a8;  // Rules alive
    float d0, d1, d2, d3, d4, d5, d6, d7, d8;  // Rules dead
    boolean runRX;
    float mousex, mousey;

    /////////////////
    // Constructor //
    /////////////////

    public ConwayPass()
    {
        shader = loadShader("conwayPass.glsl");
        previousTexture = createGraphics(width, height, P2D);
    }

    @Override
    public void prepare(Supervisor supervisor)
    {
            shader.set("previoustexture", this.previousTexture);
            shader.set("run", runFX);
    }

    @Override
    public void apply(Supervisor supervisor)
    {
        PGraphics pass = supervisor.getNextPass();
        supervisor.clearPass(pass);

        // Update shader uniforms
        shader.set("run", runFX);

        pass.beginDraw();
        pass.shader(shader);
        pass.image(supervisor.getCurrentPass(), 0, 0);
        pass.endDraw();

        // Update previous texture
        previousTexture.beginDraw();
        previousTexture.image(pass, 0, 0);
        previousTexture.endDraw();
    }

    /////////////////////
    // Mutator methods //
    /////////////////////

    //
    public void setStartFX(boolean run)
    {
        runFX = run;
    }

    // Set rule uniforms
    public void setRules(
        float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8,
        float d0, float d1, float d2, float d3, float d4, float d5, float d6, float d7, float d8
    )
    {
        // Alive rules
        this.a0 = a0; this.a1 = a1; this.a2 = a2; this.a3 = a3; this.a4 = a4;
        this.a5 = a5; this.a6 = a6; this.a7 = a7; this.a8 = a8;

        // Dead rules
        this.d0 = d0; this.d1 = d1; this.d2 = d2; this.d3 = d3; this.d4 = d4;
        this.d5 = d5; this.d6 = d6; this.d7 = d7; this.d8 = d8;
    }
}
/*
  ////////////////////////////////////////
  PostFX custom pass class definition

  Dependencies:
  PostFX library
  ////////////////////////////////////////
*/

class FeedbackPass implements Pass
{
    PShader shader;

    // Shader uniforms
    float feedbackLevel;                    // Global feedback mix level
    float[] feedbackMixVals = {0,0,0,0};    // RGBA feedback mix levels (array must be initialised)
    float channelSpread;                    // Offset feedback amount for RGB channels
    int channelSpreadShuffle;               // Shuffle channels feedback mix level

    PGraphics previousTexture;              // Previous frame texture

    /////////////////
    // Constructor //
    /////////////////

    public FeedbackPass()
    {
        shader = loadShader("feedbackPass.glsl");
        this.previousTexture = createGraphics(width, height, P3D);
    }

    @Override
    public void prepare(Supervisor supervisor)
    {
        shader.set("previoustexture", this.previousTexture);
    }

    @Override
    public void apply(Supervisor supervisor)
    {
        PGraphics pass = supervisor.getNextPass();
        supervisor.clearPass(pass);

        // Update shader uniforms
        this.updateUniforms();

        // Begin drawing
        pass.beginDraw();
        pass.shader(shader);
        pass.image(supervisor.getCurrentPass(), 0, 0);
        pass.endDraw();

        // Update previous texture
        previousTexture.beginDraw();
        previousTexture.image(pass, 0, 0);
        previousTexture.endDraw();
    }

    ////////////////////////////
    // Update shader uniforms //
    ////////////////////////////

    public void updateUniforms()
    {
        shader.set(
            "feedback",
            this.feedbackMixVals[0],
            this.feedbackMixVals[1],
            this.feedbackMixVals[2],
            this.feedbackMixVals[3]
        );
    }

    /////////////////////
    // Mutator methods //
    /////////////////////

    public void setFeedback(float val)
    {
        // Input in 0 > 1 range
        // Scaled to 0 > 0.9, with 'pow(val, 0.2)' curve for more resolution at upper end of range
        this.feedbackLevel = 0.9f * pow(max(min(val,1.0f), 0.0f), 0.2f);

        // Add feedback level offsets to RGB channels
        // Array containing 6 possible permutations of +/- offsets
        float cs0 = this.feedbackLevel + this.channelSpread;
        float cs1 = this.feedbackLevel;
        float cs2 = this.feedbackLevel - this.channelSpread;
        float[][] valCombinations = {
            {cs0, cs1, cs2, cs1},
            {cs0, cs2, cs1, cs1},
            {cs1, cs0, cs2, cs1},
            {cs1, cs2, cs0, cs1},
            {cs2, cs0, cs1, cs1},
            {cs2, cs1, cs0, cs1}
        };
        // Update RGBA mix levels array
        this.feedbackMixVals[0] = valCombinations[this.channelSpreadShuffle][0];
        this.feedbackMixVals[1] = valCombinations[this.channelSpreadShuffle][1];
        this.feedbackMixVals[2] = valCombinations[this.channelSpreadShuffle][2];
        this.feedbackMixVals[3] = valCombinations[this.channelSpreadShuffle][3];
    }

    public void setFeedbackSpread(float val)
    {
        // Input in 0 > 1 range
        this.channelSpread = 0.07f * max(min(val,1.0f), 0.0f);
    }

    public void setFeedbackColour(int index)
    {
        // Range 0 > 5
        this.channelSpreadShuffle = max(min(index, 5), 0);
    }
}
  public void settings() {  size(640, 480, OPENGL); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Conway_Webcam" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
