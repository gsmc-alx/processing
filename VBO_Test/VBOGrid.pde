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

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2ES2;

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
        vertsX              = vX;
        vertsY              = vY;

        pxWidth             = pW;
        pxHeight            = pH;

        // Possible values: POINTS, LINES, GRID, WIREFRAME, SOLID
        drawMode            = mode;

        vertexShader        = (vertS == null) ? "vertDefault.glsl" : vertS;
        fragmentShader      = (fragS == null) ? "fragDefault.glsl" : fragS;

        shader              = loadShader(fragmentShader, vertexShader);

        vBufferLength       = vertsX * vertsY * 4;
        iBufferLength       = (vertsX - 1) * (vertsY - 1) * 6;
        tBufferLength       = vertsX * vertsY * 2;

        positions           = new float[vBufferLength];
        colors              = new float[vBufferLength];
        texCoords           = new float[tBufferLength];
        indices             = new int[iBufferLength];

        posBuffer           = allocateDirectFloatBuffer(positions.length);
        colorBuffer         = allocateDirectFloatBuffer(colors.length);
        texCoordBuffer      = allocateDirectFloatBuffer(texCoords.length);
        indexBuffer         = allocateDirectIntBuffer(indices.length);

        pgl                 = (PJOGL) beginPGL();
        gl                  = pgl.gl.getGL2ES2();

        // Get GL ids for all the buffers
        IntBuffer intBuffer = IntBuffer.allocate(4);
        gl.glGenBuffers(4, intBuffer);
        posVboId            = intBuffer.get(0);
        colorVboId          = intBuffer.get(1);
        texCoordVboId       = intBuffer.get(2);
        indexVboId          = intBuffer.get(3);

        // Get the location of the attribute variables.
        shader.bind();
        posLoc              = gl.glGetAttribLocation(shader.glProgram, "position");
        colorLoc            = gl.glGetAttribLocation(shader.glProgram, "color");
        texCoordLoc         = gl.glGetAttribLocation(shader.glProgram, "texCoord");
        shader.unbind();

        endPGL();
    }

    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // DRAW //////////////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////

    void draw() {

        // Geometry transformations from Processing are automatically passed to the shader
        // as long as the uniforms in the shader have the right names.
        translate(width/2, height/2);

        updateGeometry();

        pgl = (PJOGL) beginPGL();
        gl = pgl.gl.getGL2ES2();

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

    void updateGeometry() {

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
                positions[i    ] = ((pxWidth / vertsX) * x) - (0.5 * pxWidth);
                positions[i + 1] = ((pxHeight / vertsY) * y) - (0.5 * pxHeight);
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

    FloatBuffer allocateDirectFloatBuffer(int n)
    {
      return ByteBuffer.allocateDirect(n * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
    }

    IntBuffer allocateDirectIntBuffer(int n)
    {
      return ByteBuffer.allocateDirect(n * Integer.BYTES).order(ByteOrder.nativeOrder()).asIntBuffer();
    }


    /////////////////////////
    // Set Shader Uniforms //
    /////////////////////////

    void setShaderUniformInt(String name, int val) {
        shader.set(name, val);
    }

    void setShaderUniformFloat(String name, float val) {
        shader.set(name, val);
    }

    void setShaderUniformBoolean(String name, Boolean val) {
        shader.set(name, val);
    }


    void setShaderUniformTexture(String name, PGraphics tex) {
        shader.set(name, tex);
    }

    ///////////////////
    // Grid Settings //
    ///////////////////

    void setVBODrawMode(String mode)
    {
        drawMode = mode;
    }
}
