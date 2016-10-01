uniform sampler2D uTextureBlur;
uniform sampler2D uTextureText;
uniform sampler2D uTexturePlain;
uniform mediump float uMixText;
uniform mediump float uMixPlain;
uniform mediump float uFadeRatio;

varying lowp vec2 vTextCoord;

void main(void) {
    gl_FragColor = mix(texture2D(uTextureBlur, vTextCoord), texture2D(uTexturePlain, vTextCoord), uMixPlain);
    gl_FragColor = mix(gl_FragColor, texture2D(uTextureText, vTextCoord), uMixText) * uFadeRatio;
}