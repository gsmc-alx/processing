import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import ch.bildspur.postfx.builder.*; 
import ch.bildspur.postfx.pass.*; 
import ch.bildspur.postfx.*; 
import controlP5.*; 
import java.util.*; 
import java.nio.ByteBuffer; 
import java.nio.ByteOrder; 
import java.nio.FloatBuffer; 
import java.nio.IntBuffer; 
import com.jogamp.opengl.GL; 
import com.jogamp.opengl.GL2ES2; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class VBO_Test extends PApplet {

// Video library


// PostFX shader-chaining library
// https://github.com/cansik/processing-postfx




// ControlP5 GUI library
// https://github.com/sojamo/controlp5



Capture cam;
PGraphics camFrame;

VBOGrid vboGrid;

// GUI object instance
ControlP5 cp5;

// PostFX and custom passes
PostFX fx;
ConwayPass conwayPass;
FeedbackPass feedbackPass;

// Feedback shader setting variables
float feedbackLevel;
float feedbackSpread;
int feedbackColour;

PGraphics world;

boolean runFX;

// VBO Settings
float extrude;
String VBODrawMode;

public void setup() {
    

    cam = new Capture(this, 640, 480);
    cam.start();
    camFrame = createGraphics(640, 480, P3D);

    world = createGraphics(width, height, P3D);

    vboGrid = new VBOGrid(200, 200, 800, 600, "LINES", "customFrag.glsl", "customVert.glsl");
    vboGrid.setShaderUniformBoolean("flipY", true);
    vboGrid.setShaderUniformTexture("fragtex", camFrame);
    vboGrid.setShaderUniformTexture("verttex", camFrame);

    cp5 = new ControlP5(this);
    setupGUI();

    fx = new PostFX(this);

    conwayPass = new ConwayPass();
    feedbackPass = new FeedbackPass();
}

public void draw() {
    background(0);

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

    // Update pass settings
    updatePassSettings();

    // Draw geometry
    world.beginDraw();
    vboGrid.draw();
    world.endDraw();
    image(world, 0, 0);

    // Apply passes
    blendMode(BLEND);
    fx.render()
        .custom(conwayPass)
        .custom(feedbackPass)
        .bloom(0.5f, 20, 40)
        .compose();

    //fill(guiLabelColor);
    text("fps: " + frameRate, 20, height - 30);
}

public void setupGUI() {
    cp5.addSlider("extrude")
        .setPosition(20, 20)
        .setSize(100, 20)
        .setRange(0.0f, 800.0f)
        .setValue(300.0f)
        .setLabel("Z-Extrude Amount");

    cp5.addSlider("feedbackLevel")
        .setPosition(20, 50)
        .setSize(100, 20)
        .setRange(0.0f, 1.0f)
        .setValue(0.80f);

    cp5.addSlider("feedbackSpread")
        .setPosition(20, 80)
        .setSize(100, 20)
        .setRange(0.0f, 1.0f)
        .setValue(0.0f);

    cp5.addSlider("feedbackColour")
        .setPosition(20, 110)
        .setSize(100, 20)
        .setRange(0, 5)
        .setValue(0.0f);

    cp5.addToggle("runFX")
        .setPosition(100, 140)
        .setSize(20, 20)
        .setValue(false);

    List l = Arrays.asList("POINTS", "LINES", "SOLID");
    cp5.addScrollableList("dropdown")
        .setPosition(20, 140)
        .setSize(70, 100)
        .setBarHeight(20)
        .setItemHeight(20)
        .addItems(l)
        .setType(ScrollableList.DROPDOWN);
}

public void dropdown(int n) {
    vboGrid.setVBODrawMode((String)cp5.get(ScrollableList.class, "dropdown").getItem(n).get("name"));
}

public void updatePassSettings()
{
    // VBO Grid uniforms
    vboGrid.setShaderUniformFloat("extrude", extrude);

    // Conway shader uniforms
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
/*
    //////////////////////////////////////////////////

    OpenGL VBO Grid-creator

    Based on
    https://github.com/processing/processing/wiki/Advanced-OpenGL
    (with warnings that it may break in future Processing versions,
    may make your computer/head explode etc.)

    //////////////////////////////////////////////////
*/

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// LIBRARIES /////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////









//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
// CLASS DEFINITION //////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

class VBOGrid
{
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // FIELDS ////////////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////

    float[] positions;
    float[] colors;
    float[] texCoords;
    int[] indices;

    FloatBuffer posBuffer;
    FloatBuffer colorBuffer;
    FloatBuffer texCoordBuffer;
    IntBuffer indexBuffer;

    int posVboId;
    int colorVboId;
    int texCoordVboId;
    int indexVboId;

    int posLoc;
    int colorLoc;
    int texCoordLoc;

    int vertsX;
    int vertsY;
    int vBufferLength;
    int tBufferLength;
    int iBufferLength;
    int pxWidth;
    int pxHeight;
    String drawMode;
    String vertexShader;
    String fragmentShader;

    PShader shader;

    PJOGL pgl;
    GL2ES2 gl;

    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // CONSTRUCTOR ///////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////

    // Arguments:
    // Vertices X | Vertices Y | Pixels Wide | Pixels High | Draw Mode (some not yet implemented) | Fragment Shader (optional) | Vertex Shader (optional)
    public VBOGrid(int vX, int vY, int pW, int pH, String mode, String fragS, String vertS)
    {
        vertsX = vX;
        vertsY = vY;

        pxWidth = pW;
        pxHeight = pH;

        // Possible values: POINTS, LINES, GRID, WIREFRAME, SOLID
        drawMode = mode;

        vertexShader = (vertS == null) ? "vertDefault.glsl" : vertS;
        fragmentShader = (fragS == null) ? "fragDefault.glsl" : fragS;

        shader = loadShader(fragmentShader, vertexShader);

        vBufferLength = vertsX * vertsY * 4;
        iBufferLength = (vertsX - 1) * (vertsY - 1) * 6;
        tBufferLength = vertsX * vertsY * 2;

        positions    = new float[vBufferLength];
        colors       = new float[vBufferLength];
        texCoords    = new float[tBufferLength];
        indices      = new int[iBufferLength];

        posBuffer = allocateDirectFloatBuffer(positions.length);
        colorBuffer = allocateDirectFloatBuffer(colors.length);
        texCoordBuffer = allocateDirectFloatBuffer(texCoords.length);
        indexBuffer = allocateDirectIntBuffer(indices.length);

        pgl = (PJOGL) beginPGL();
        gl = pgl.gl.getGL2ES2();

        // Get GL ids for all the buffers
        IntBuffer intBuffer = IntBuffer.allocate(4);
        gl.glGenBuffers(4, intBuffer);
        posVboId = intBuffer.get(0);
        colorVboId = intBuffer.get(1);
        texCoordVboId = intBuffer.get(2);
        indexVboId = intBuffer.get(3);

        // Get the location of the attribute variables.
        shader.bind();
        posLoc = gl.glGetAttribLocation(shader.glProgram, "position");
        colorLoc = gl.glGetAttribLocation(shader.glProgram, "color");
        texCoordLoc = gl.glGetAttribLocation(shader.glProgram, "texCoord");
        shader.unbind();

        endPGL();
    }

    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // DRAW //////////////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////

    public void draw() {

        // Geometry transformations from Processing are automatically passed to the shader
        // as long as the uniforms in the shader have the right names.
        translate(width/2, height/2);

        pgl = (PJOGL) beginPGL();
        gl = pgl.gl.getGL2ES2();

        updateGeometry();

        shader.bind();
        gl.glEnableVertexAttribArray(posLoc);
        gl.glEnableVertexAttribArray(colorLoc);

        // Copy vertex data to VBOs
        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, posVboId);
        gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * positions.length, posBuffer, GL.GL_DYNAMIC_DRAW);
        gl.glVertexAttribPointer(posLoc, 4, GL.GL_FLOAT, false, 4 * Float.BYTES, 0);

        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, colorVboId);
        gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * colors.length, colorBuffer, GL.GL_DYNAMIC_DRAW);
        gl.glVertexAttribPointer(colorLoc, 4, GL.GL_FLOAT, false, 4 * Float.BYTES, 0);

        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, texCoordVboId);
        gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * texCoords.length, texCoordBuffer, GL.GL_DYNAMIC_DRAW);
        gl.glVertexAttribPointer(texCoordLoc, 2, GL.GL_FLOAT, false, 2 * Float.BYTES, 0);

        gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);

        gl.glBindBuffer(PGL.ELEMENT_ARRAY_BUFFER, indexVboId);
        pgl.bufferData(PGL.ELEMENT_ARRAY_BUFFER, Integer.BYTES * indices.length, indexBuffer, GL.GL_DYNAMIC_DRAW);

        background(0);

        ///////////////////
        // Draw Elements //
        ///////////////////

        blendMode(ADD);

        switch (drawMode) {
            case "POINTS" :
                gl.glDrawElements(PGL.POINTS, indices.length, GL.GL_UNSIGNED_INT, 0);
                break;
            case "LINES" :
                gl.glDrawElements(PGL.LINES, indices.length, GL.GL_UNSIGNED_INT, 0);
                break;
            /*case "WIREFRAME" :
                //gl.glCullFace(GL.GL_FRONT_AND_BACK);
                //gl.glDrawElements(PGL.LINES, indices.length, GL.GL_UNSIGNED_INT, 0);
                break;
            case "GRID" :
                gl.glDrawElements(PGL.LINES, indices.length, GL.GL_UNSIGNED_INT, 0);
                break;*/
            case "SOLID" :
                gl.glDrawElements(PGL.TRIANGLES, indices.length, GL.GL_UNSIGNED_INT, 0);
                break;
            default :
                 gl.glDrawElements(PGL.POINTS, indices.length, GL.GL_UNSIGNED_INT, 0);
        }

        gl.glBindBuffer(PGL.ELEMENT_ARRAY_BUFFER, 0);

        gl.glDisableVertexAttribArray(posLoc);
        gl.glDisableVertexAttribArray(colorLoc);
        gl.glDisableVertexAttribArray(texCoordLoc);
        shader.unbind();

        endPGL();

        /////////////////////////
        // Reset Draw-Position //
        /////////////////////////

        translate(-width/2, -height/2);
    }

    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // METHODS ///////////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////

    public void updateGeometry() {

        // Loop-counters
        int i = 0;
        int x = 0;
        int y = 0;

        //////////////////////
        // Vertex Positions //
        //////////////////////

        for(y = 0; y < vertsY; y++)
        {
            for(x = 0; x < vertsX; x++)
            {
                 // Vertex positions
                positions[i    ] = ((pxWidth / vertsX) * x) - (0.5f * pxWidth);
                positions[i + 1] = ((pxHeight / vertsY) * y) - (0.5f * pxHeight);
                positions[i + 2] = 0;
                positions[i + 3] = 1;

                // Vertex colours
                colors[i    ] = (1.0f / vertsX) * x;
                colors[i + 1] = (1.0f / vertsY) * y;
                colors[i + 2] = 0;
                colors[i + 3] = 1;

                i += 4;
            }
        }

        /////////////////////////
        // Texture Coordinates //
        /////////////////////////

        i = 0;
        for(y = 0; y < vertsY; y++)
        {
            for(x = 0; x < vertsX; x++) {
                texCoords[i    ] = (1.0f / vertsX) * x;
                texCoords[i + 1] = (1.0f / vertsY) * y;
                i += 2;
            }
        }

        /////////////
        // Indices //
        /////////////

        /*
        Indices generation routines taken from vade's Rutt Etra plugin for Quartz Composer
        https://github.com/v002/v002-Rutt-Etra
        Specifically, this document:
        https://github.com/v002/v002-Rutt-Etra/blob/master/v002RuttEtraPlugIn.m
        */

        String mode = drawMode;

        if (mode == "LINES")
        {
        // Just for LINES mode
            i = 0;
            for(y = 0; y < vertsY - 1 ; y++)
            {
                for(x = 0; x < vertsX - 1 && vertsY > 2; x++)
                {
                    // vade's comment: This little aparatus makes sure we do not draw a line segment between different rows of scanline.
                    // My comment on vade's comment: The downside is you lose one column of verts on the right, and one row at the bottom
                    if (i % (vertsX - 2) <= (vertsX - 1))
                    {
                        indices[i + 0] = x + y * vertsX;
                        indices[i + 1] = x + y * vertsX + 1;
                    }
                    i += 2;
                }
            }
        } else {
        // Triangles
            i = 0;
            for(y = 0; y < vertsY - 1; y++)
            {
                for(x = 0; x < vertsX - 1 ; x++)
                {
                    indices[i + 0] = x + y * vertsX;
                    indices[i + 1] = x + y * vertsX + vertsX;
                    indices[i + 2] = x + y * vertsX + 1;
                    indices[i + 3] = x + y * vertsX + 1;
                    indices[i + 4] = x + y * vertsX + vertsX;
                    indices[i + 5] = x + y * vertsX + vertsX + 1;
                    i += 6;
                }
            }
        }

        ///////////////////
        // Update Arrays //
        ///////////////////

        posBuffer.rewind();
        posBuffer.put(positions);
        posBuffer.rewind();

        colorBuffer.rewind();
        colorBuffer.put(colors);
        colorBuffer.rewind();

        texCoordBuffer.rewind();
        texCoordBuffer.put(texCoords);
        texCoordBuffer.rewind();

        indexBuffer.rewind();
        indexBuffer.put(indices);
        indexBuffer.rewind();
    }

    //////////////////////
    // Allocate Buffers //
    //////////////////////

    public FloatBuffer allocateDirectFloatBuffer(int n)
    {
      return ByteBuffer.allocateDirect(n * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
    }

    public IntBuffer allocateDirectIntBuffer(int n)
    {
      return ByteBuffer.allocateDirect(n * Integer.BYTES).order(ByteOrder.nativeOrder()).asIntBuffer();
    }


    /////////////////////////
    // Set Shader Uniforms //
    /////////////////////////

    public void setShaderUniformInt(String name, int val) {
        shader.set(name, val);
    }

    public void setShaderUniformFloat(String name, float val) {
        shader.set(name, val);
    }

    public void setShaderUniformBoolean(String name, Boolean val) {
        shader.set(name, val);
    }


    public void setShaderUniformTexture(String name, PGraphics tex) {
        shader.set(name, tex);
    }

    ///////////////////
    // Grid Settings //
    ///////////////////

    public void setVBODrawMode(String mode)
    {
        drawMode = mode;
    }
}
  public void settings() {  size(800, 600, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "VBO_Test" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
