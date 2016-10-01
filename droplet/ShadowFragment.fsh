uniform lowp vec4 uBaseColor;
uniform sampler2D uTextureBlur;
uniform sampler2D uTextureText;
uniform lowp float uMixOrg;
uniform lowp float uMixShadow;
uniform lowp float uFadeRatio;

varying lowp float vDistance;
varying lowp vec2 vTextCoord;

void main(void) {
    gl_FragColor = mix(texture2D(uTextureBlur, vTextCoord), texture2D(uTextureText, vTextCoord), uMixOrg);
    lowp float ratio = uMixShadow * (1.0 - pow(vDistance, 30.0));
    gl_FragColor = mix(gl_FragColor, uBaseColor, ratio) * uFadeRatio;
}