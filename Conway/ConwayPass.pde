/*
  ////////////////////////////////////////
  PostFX custom pass class definition
  
  Dependencies:
  PostFX library
  ////////////////////////////////////////
*/

class ConwayPass implements Pass
{
  private PShader shader;
  
  // Shader uniforms
  private PGraphics previousTexture;                 // Previous texture for feedback
  private float brushSize;                           // Brush size
  private float a0, a1, a2, a3, a4, a5, a6, a7, a8;  // Rules alive
  private float d0, d1, d2, d3, d4, d5, d6, d7, d8;  // Rules dead
  
  /////////////////
  // Constructor //
  /////////////////
  
  public ConwayPass()
  {
    shader = loadShader("conwayPass.glsl");
    previousTexture = createGraphics(width, height, P3D);
  }

  @Override
    public void prepare(Supervisor supervisor) {
       shader.set("previousTexture", previousTexture);
       shader.set("brushsize", this.brushSize);
  }

  @Override
    public void apply(Supervisor supervisor) {
    PGraphics pass = supervisor.getNextPass();
    //supervisor.clearPass(pass);

    pass.beginDraw();
    pass.shader(shader);
    pass.image(supervisor.getCurrentPass(), 0, 0);
    pass.endDraw();
    
    // Update previous texture
    previousTexture = pass;  
  }
  
  ///////////////////// 
  // Mutator methods //
  /////////////////////
  
  // Set brush size
  public void setBrushSize(float size)
  {
    this.brushSize = size;
  }
  
  // Set rule uniforms
  public void setRules(float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float d0, float d1, float d2, float d3, float d4, float d5, float d6, float d7, float d8)
  {
    // Alive rules
    this.a0 = a0;
    this.a1 = a1;
    this.a2 = a2;
    this.a3 = a3;
    this.a4 = a4;
    this.a5 = a5;
    this.a6 = a6;
    this.a7 = a7;
    this.a8 = a8;
    
    // Dead rules
    this.d0 = d0;
    this.d1 = d1;
    this.d2 = d2;
    this.d3 = d3;
    this.d4 = d4;
    this.d5 = d5;
    this.d6 = d6;
    this.d7 = d7;
    this.d8 = d8;
  }
}