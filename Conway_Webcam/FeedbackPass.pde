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
    private float feedbackLevel;                    // Global feedback mix level
    private float[] feedbackMixVals = {0,0,0,0};    // RGBA feedback mix levels (array must be initialised)
    private float channelSpread;                    // Offset feedback amount for RGB channels
    private int channelSpreadShuffle;               // Shuffle channels feedback mix level

    private PGraphics previousTexture;              // Previous frame texture

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
        // Is there a faster way to do this??
        pass.loadPixels();
        previousTexture.loadPixels();
        arrayCopy(pass.pixels, previousTexture.pixels);
        //pass.updatePixels();
        previousTexture.updatePixels();
    }

    ////////////////////////////
    // Update shader uniforms //
    ////////////////////////////

    private void updateUniforms()
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
        this.feedbackLevel = 0.9 * pow(max(min(val,1.0), 0.0), 0.2);

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
        this.channelSpread = 0.07 * max(min(val,1.0), 0.0);
    }

    public void setFeedbackColour(int index)
    {
        // Range 0 > 5
        this.channelSpreadShuffle = min(index, 5);
    }
}
