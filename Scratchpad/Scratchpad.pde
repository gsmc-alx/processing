// Drawing vertices in 3D requires P3D or OPENGL
// as a parameter to size()


void setup() {
  size(640, 480, P3D);
  background(0);
}

void draw() {

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
