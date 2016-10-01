uniform samplerCube uLightTexture;
uniform lowp vec4 uBaseColor;
uniform sampler2D uTextureBlur;
uniform sampler2D uTextureText;
uniform sampler2D uTexturePlain;
uniform lowp float uMixText;
uniform lowp float uMixPlain;
uniform lowp float uFadeRatio;

varying lowp vec3 vNormal;
varying lowp float vDistance;
varying lowp vec2 vTextCoord;

void main(void) {

    // Refraction
    lowp vec3 ref = 0.667 * refract(vec3(0.0, 0.0, -1.0), vNormal, 1.33);
    lowp vec2 textCoord = vTextCoord + ref.xy;

    // Mixture of original and blur
    gl_FragColor = mix(texture2D(uTextureBlur, textCoord), texture2D(uTexturePlain, textCoord), uMixPlain);
    gl_FragColor = mix(gl_FragColor, texture2D(uTextureText, textCoord), uMixText);
    
    // Base color mix
    //gl_FragColor = mix(uBaseColor, gl_FragColor, 0.8);
    
    //  Surface reflection
    gl_FragColor = gl_FragColor + 0.8 * textureCube(uLightTexture, vNormal);

    // Internal reflection
    lowp float r = 2.5;
    lowp float diff = 1.0 - min(1.0, vDistance/r);
    diff = 0.6 * pow(diff, 2.5);
    gl_FragColor.rgb += vec3(diff, diff, diff);
    gl_FragColor.rgb = gl_FragColor.rgb * uFadeRatio;

    // transparency
    //gl_FragColor = 0.2 * texture2D(uTextureBlur, vTextCoord) + 0.8 * gl_FragColor;
    
}