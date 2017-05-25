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
    private float feedbackLevel;          // Feedback amount
    private float channelSpread;          // Offset feedback amount for RGB channels
    private int channelSpreadShuffle;     // Shuffle channels feedback mix level

    private PGraphics previousTexture;    // Previous frame texture

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

        updateUniforms();

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

    private void updateUniforms()
    {
        // Send updated shader uniforms
        float cs0 = this.feedbackLevel + this.channelSpread;
        float cs1 = this.feedbackLevel;
        float cs2 = this.feedbackLevel - this.channelSpread;
        float[][] feedbackMixVals = {
            {cs0, cs1, cs2, cs1},
            {cs0, cs2, cs1, cs1},
            {cs1, cs0, cs2, cs1},
            {cs1, cs2, cs0, cs1},
            {cs2, cs0, cs1, cs1},
            {cs2, cs1, cs0, cs1}
        };
        shader.set(
            "feedback",
            feedbackMixVals[this.channelSpreadShuffle][0],
            feedbackMixVals[this.channelSpreadShuffle][1],
            feedbackMixVals[this.channelSpreadShuffle][2],
            feedbackMixVals[this.channelSpreadShuffle][3]
        );
    }

    /////////////////////
    // Mutator methods //
    /////////////////////

    public void setFeedback(float feedback)
    {
        // Input in 0 > 1 range
        this.feedbackLevel = 0.9 * pow(max(min(feedback,1.0), 0.0), 0.2);
    }

    public void setChannelSpread(float spread)
    {
        // Input in 0 > 1 range
        this.channelSpread = 0.07 * max(min(feedback,1.0), 0.0);
    }

    public void setChannelSpreadShuffle(int index)
    {
        // Range 0 > 5
        this.channelSpreadShuffle = min(index, 5);
    }
}
