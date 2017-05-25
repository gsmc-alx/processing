import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Scratchpad extends PApplet {

// Drawing vertices in 3D requires P3D or OPENGL
// as a parameter to size()


public void setup() {
  
  background(0);
}

public void draw() {

  background(0);
  lights();

  //translate (width/2, 322, 2);
  //rotateY(angle);

  background(0);
   stroke(255);
   strokeWeight (2);
   noFill();

   for (int i=1; i<9; ++i) {
     for (int j=1; j<9 ; ++j) {
       beginShape();
       // A
       vertex(j*60, i*60);
       // B
       vertex((j+1)*60, i*60);
       // C
       vertex((j+1)*60, (i+1)*60);
       // D
       vertex(j*60, (i+1)*60);
       // A
       vertex(j*60, i*60);
       endShape();
     }
   }

}
  public void settings() {  size(640, 480, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Scratchpad" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
