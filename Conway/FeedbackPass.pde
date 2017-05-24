/*
  ////////////////////////////////////////
  PostFX custom pass class definition
  
  Dependencies:
  PostFX library
  ////////////////////////////////////////
*/

class FeedbackPass implements Pass
{
  private PShader shader;
  
  // Shader uniforms
  private float feedbackLevel;        // Feedback amount
  private PGraphics previousTexture;  // Previous frame texture
  
  /////////////////
  // Constructor //
  /////////////////
  
  public FeedbackPass()
  {
    shader = loadShader("feedbackPass.glsl");
    this.previousTexture = createGraphics(width, height, P3D);
  }

  @Override
    public void prepare(Supervisor supervisor) {
       shader.set("previoustexture", this.previousTexture);
  }

  @Override
    public void apply(Supervisor supervisor) {
    PGraphics pass = supervisor.getNextPass();
    //supervisor.clearPass(pass);
    
    shader.set("feedback", this.feedbackLevel);
    pass.beginDraw();
    pass.shader(shader);
    pass.image(supervisor.getCurrentPass(), 0, 0);
    pass.endDraw();
    
    // Update previous texture
    this.previousTexture = pass;  
  }
  
  ///////////////////// 
  // Mutator methods //
  /////////////////////
  
  public void setfeedback(float feedback)
  {
    this.feedbackLevel = feedback;
  }
}