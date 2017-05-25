import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Vertex_Shader_PCloud extends PApplet {

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


Capture cam;
PGraphics camFrame;
PShader pCloud;

// Vertex grid w/h
int gw;
int gh;

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// SETUP /////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

public void setup() {

    
    

    cam = new Capture(this, 640, 480);
    cam.start();
    camFrame = createGraphics(640, 480, P3D);

    pCloud = loadShader("pcloudVert.glsl", "pcloudFrag.glsl");

    gw = 20;
    gh = 20;

}

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// DRAW //////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

public void draw() {

    background(0, 0, 0);

    //image(camFrame, 0, 0);

    //fill(color(200, 200, 200));
    //text("fps: " + frameRate, 20, 460);

    stroke(255);
    noFill();

    translate(20, 20, 0);

    for(int y = 0; y < gh; y++) {
        for(int x = 0; x < gw; x++) {
            translate(
                x * (640 / gw),
                y * (480 / gh),
                0
            );
            point(0, 0);
        }
    }
}

public void getCapture() {
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
}
  public void settings() {  size(640, 480, P3D);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Vertex_Shader_PCloud" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
