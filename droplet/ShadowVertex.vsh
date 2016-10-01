attribute vec4 aPosition; 

uniform mat4 uProjection;
uniform mat4 uModelview;
uniform vec2 uCoordMap;

varying float vDistance;
varying vec2 vTextCoord;

void main(void) {
    vDistance = sqrt(aPosition.x * aPosition.x + aPosition.y * aPosition.y);
    vec4 positionWorld = uModelview * aPosition;
    gl_Position = uProjection * positionWorld;
    vTextCoord = positionWorld.xy * uCoordMap;
    vTextCoord.y = 1.0 - vTextCoord.y;
}