attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;

varying vec2 vTextCoord;

void main(void) { 
    vTextCoord = aTextCoord;
    gl_Position = uProjection * aPosition;
}