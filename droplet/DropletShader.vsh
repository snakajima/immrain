attribute vec4 aPosition;
//attribute vec3 aNormal;

uniform mat4 uProjection;
uniform mat4 uModelview;
uniform mat3 uNormalizeModelview;
uniform vec3 uRefLightPosition;
uniform vec2 uCoordMap;

varying vec3 vNormal;
varying float vDistance;
varying vec2 vTextCoord;

void main(void) {
    vec4 positionWorld;
    vec3 aNormal = aPosition.xyz; // Because it's a sphere
    positionWorld = uModelview * aPosition;
    vNormal = normalize(uNormalizeModelview * aNormal);
    //vDistance = distance(uRefLightPosition, mat3(uModelview)* aNormal);
    vDistance = distance(uRefLightPosition, aNormal);
    gl_Position = uProjection * positionWorld;
    vTextCoord = positionWorld.xy * uCoordMap;
    vTextCoord.y = 1.0 - vTextCoord.y;
}