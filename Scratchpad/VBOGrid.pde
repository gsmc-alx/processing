/*
  ////////////////////////////////////////
  
  OpenGL VBO Grid-creator

  Based on
  https://github.com/processing/processing/wiki/Advanced-OpenGL
  (with warnings that it may break in future Processing versions,
  may make your computer/head explode etc.)
  
  ////////////////////////////////////////
*/

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2ES2;

class VBOGrid
{
  PShader shader;
  
  float[] positions;
  float[] colors;
  int[] indices;
  
  FloatBuffer posBuffer;
  FloatBuffer colorBuffer;
  IntBuffer indexBuffer;
  
  int posVboId;
  int colorVboId;
  int indexVboId;
  
  int posLoc;
  int colorLoc;
  
  int vertsX;
  int vertsY;
  int vBufferLength;
  int indicesBufferLength;
  int pxWidth;
  int pxHeight;
  
  PJOGL pgl;
  GL2ES2 gl;
  
  /////////////////
  // Constructor //
  /////////////////
  
  public VBOGrid(int vX, int vY, int pW, int pH)
  {
    println("Init toneburst VBO Grid Creator" + positions.length);
    
    vertsX = vX;
    vertsY = vY;
    vBufferLength = vertsX * vertsY * 4;
    indicesBufferLength = (vertsX - 1) * (vertsY - 1) * 6;
    pxWidth = pW;
    pxHeight = pH;
    
    shader = loadShader("frag.glsl", "vert.glsl");

    positions    = new float[vBufferLength];
    colors       = new float[vBufferLength];
    indices      = new int[indicesBufferLength];
    
    posBuffer = allocateDirectFloatBuffer(positions.length);
    colorBuffer = allocateDirectFloatBuffer(colors.length);
    indexBuffer = allocateDirectIntBuffer(indices.length);
    
    pgl = (PJOGL) beginPGL();
    gl = pgl.gl.getGL2ES2();
    
    // Get GL ids for all the buffers
    IntBuffer intBuffer = IntBuffer.allocate(3);
    gl.glGenBuffers(3, intBuffer);
    posVboId = intBuffer.get(0);
    colorVboId = intBuffer.get(1);
    indexVboId = intBuffer.get(2);
    
    // Get the location of the attribute variables.
    shader.bind();
    posLoc = gl.glGetAttribLocation(shader.glProgram, "position");
    colorLoc = gl.glGetAttribLocation(shader.glProgram, "color");
    shader.unbind();
    
    endPGL();
  }
  
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
    
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);
    
    // Draw the triangle elements
    gl.glBindBuffer(PGL.ELEMENT_ARRAY_BUFFER, indexVboId);
    pgl.bufferData(PGL.ELEMENT_ARRAY_BUFFER, Integer.BYTES * indices.length, indexBuffer, GL.GL_DYNAMIC_DRAW);
    gl.glDrawElements(PGL.TRIANGLES, indices.length, GL.GL_UNSIGNED_INT, 0);
    gl.glBindBuffer(PGL.ELEMENT_ARRAY_BUFFER, 0);
    
    gl.glDisableVertexAttribArray(posLoc);
    gl.glDisableVertexAttribArray(colorLoc);
    shader.unbind();
    
    endPGL();
    
  }
  
  /////////////
  // Methods //
  /////////////
  
  void updateGeometry() {
    // Loop-counter
    int i = 0;
    int x = 0;
    int y = 0;

    // Vertex positions 
    for(y = 0; y < vertsY; y++)
    {
       for(x = 0; x < vertsX; x++) {
         
         // Vertex positions
         positions[i    ] = -(0.5 * pxWidth) + ((pxWidth / vertsX) * x);
         positions[i + 1] = -(0.5 * pxHeight) + ((pxHeight / vertsY) * y);
         positions[i + 2] = 0;
         positions[i + 3] = 1;
         
         // Vertex colours
         colors[i    ] = (1.0f / gridW) * x;
         colors[i + 1] = (1.0f / gridW) * y;
         colors[i + 2] = 0;
         colors[i + 3] = 1;
         
         i += 4;
       }
    }
    
    // Indices (thanks, vade :)
    i = 0;
    for(y = 0; y < gridH - 1; y++)
    {
      for(x = 0; x < gridW - 1 ; x++)
      {
        indices[i + 0] = x + y * gridW;
        indices[i + 1] = x + y * gridW + gridW;
        indices[i + 2] = x + y * gridW + 1;
        indices[i + 3] = x + y * gridW + 1;
        indices[i + 4] = x + y * gridW + gridW;
        indices[i + 5] = x + y * gridW + gridW + 1;
        i += 6;
      }
    }
  
    posBuffer.rewind();
    posBuffer.put(positions);
    posBuffer.rewind();
  
    colorBuffer.rewind();
    colorBuffer.put(colors);
    colorBuffer.rewind();
  
    indexBuffer.rewind();
    indexBuffer.put(indices);
    indexBuffer.rewind();
  }
  
  FloatBuffer allocateDirectFloatBuffer(int n)
  {
    return ByteBuffer.allocateDirect(n * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
  }
  
  IntBuffer allocateDirectIntBuffer(int n)
  {
    return ByteBuffer.allocateDirect(n * Integer.BYTES).order(ByteOrder.nativeOrder()).asIntBuffer();
  }
   
}