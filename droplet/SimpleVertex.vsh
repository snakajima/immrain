attribute vec4 aPosition;
attribute vec2 aTextCoord;

uniform mat4 uProjection;
uniform mat4 uModelView;
uniform float uFactor;

varying vec4 vColor;

#define M_PI 3.1415926535897932384626433832795

void main(void) {
  vec4 position = aPosition;
  position.z = uFactor * cos(M_PI/2.0 * position.x) * cos(M_PI/2.0 * position.y);
    gl_Position = uProjection * uModelView * position;
   vColor = vec4(aTextCoord.x, aTextCoord.y, 1.0, 1.0);
}