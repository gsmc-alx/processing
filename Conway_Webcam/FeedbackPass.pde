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
  private float channelSpread;        // Offset feedback amount for RGB channels
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
    supervisor.clearPass(pass);
    
    // Send updated shader uniforms
    shader.set("feedback", this.feedbackLevel);
    shader.set("channelspread", this.channelSpread);
    
    pass.beginDraw();
    pass.shader(shader);
    pass.image(supervisor.getCurrentPass(), 0, 0);
    pass.endDraw();
    
    // Update previous texture
    // Is there a faster way to do this??
    pass.loadPixels();
    previousTexture.loadPixels();
    arrayCopy(pass.pixels, previousTexture.pixels);
    pass.updatePixels();
    previousTexture.updatePixels();
  }
  
  ///////////////////// 
  // Mutator methods //
  /////////////////////
  
  public void setFeedback(float feedback)
  {
    this.feedbackLevel = feedback;
  }
  
  public void setChannelSpread(float spread)
  {
    this.channelSpread = spread;
  }
}