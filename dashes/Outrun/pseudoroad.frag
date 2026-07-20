// pseudoroad.frag
// GLSL ES 2.0 (Qt Quick 5.12 ShaderEffect default vertex shader is used --
// no vertexShader override needed here).
//
// Replaces: sky Rectangle, grassStrips Repeater, roadShapeOn, roadShapeOff,
// laneDividerShape, edgeLineShape.
//
// Design note: instead of looping over segments (which needs dynamic loop
// bounds / array indexing -- not reliably supported on ES2 fragment shaders,
// especially on weaker embedded GPU drivers), we invert the perspective
// projection analytically per-pixel. This is O(1) per pixel, needs no
// loops/arrays at all, and is strictly smoother than the original's
// per-segment trapezoids (exact projection per scanline instead of linear
// interpolation between two segment boundaries).

uniform lowp float qt_Opacity;
varying highp vec2 qt_TexCoord0;

uniform highp float uWidth;
uniform highp float uHeight;
uniform highp float uPosition;
uniform highp float uZNear;
uniform highp float uSegmentLength;
uniform highp float uHorizonY;
uniform highp float uRoadWidthNear;
uniform highp float uLaneMarkingWidthNear;
uniform highp float uEdgeMarkingWidthNear;
uniform highp float uShowLaneDividers; // 0.0 or 1.0
uniform highp float uShowEdgeLines;    // 0.0 or 1.0

uniform lowp vec4 uSkyColorTop;
uniform lowp vec4 uSkyColorBottom;
uniform lowp vec4 uRoadColorOn;
uniform lowp vec4 uRoadColorOff;
uniform lowp vec4 uTerrainColorOn;
uniform lowp vec4 uTerrainColorOff;
uniform lowp vec4 uLaneMarkingColor;
uniform lowp vec4 uEdgeMarkingColor;

void main() {
    highp float px = qt_TexCoord0.x * uWidth;
    highp float py = qt_TexCoord0.y * uHeight;

    lowp vec4 outColor;

    if (py <= uHorizonY) {
        // Sky gradient -- matches the original Rectangle's Gradient stops
        // (0.0 at top of the full item, 0.33 of full item height).
        highp float t = clamp(py / (uHeight * 0.33), 0.0, 1.0);
        outColor = mix(uSkyColorTop, uSkyColorBottom, t);
    } else {
        // Invert project(z): scale = zNear/z, screenY = horizonY + (h-horizonY)*scale
        highp float scale = (py - uHorizonY) / (uHeight - uHorizonY);
        scale = max(scale, 0.0001); // avoid div-by-zero right at the horizon line
        highp float z = uZNear / scale;

        // Same math as JS's (baseIndex + i), collapsed to one closed form --
        // see the derivation note in the accompanying QML file.
        highp float worldIndexF = (z - uZNear + uPosition) / uSegmentLength;
        highp float segIndex = floor(worldIndexF);
        bool stripeOn = mod(segIndex, 2.0) < 1.0;

        highp float dx = px - uWidth * 0.5;
        highp float adx = abs(dx);

        highp float roadHalfW = max(uRoadWidthNear * scale * 0.5, 0.5);

        lowp vec4 terrainColor = stripeOn ? uTerrainColorOn : uTerrainColorOff;
        lowp vec4 roadColor = stripeOn ? uRoadColorOn : uRoadColorOff;

        outColor = terrainColor;

        if (adx < roadHalfW) {
            outColor = roadColor;

            // Dashed lane dividers: centered at +/- roadWidth/6 (matches the
            // original's nearRoadW/6 offset), only drawn on "on" segments,
            // which is what produces the dash gaps for free.
            if (uShowLaneDividers > 0.5 && stripeOn) {
                highp float dHalfW = max(uLaneMarkingWidthNear * scale * 0.5, 0.25);
                highp float dCenterDist = (roadHalfW * 2.0) / 6.0;
                if (abs(adx - dCenterDist) < dHalfW) {
                    outColor = uLaneMarkingColor;
                }
            }

            // Edge lines: drawn every segment (never gapped), just inside
            // the road boundary. Position (not visibility) alternates:
            // "off" sits flush against the true edge, "on" is pushed
            // inward by one full line-width -- the alternating in/out
            // "curb" look. This has to live in the road branch (adx <
            // roadHalfW), not the terrain branch below -- both
            // flushCenterDist and pushedCenterDist are always < roadHalfW.
            if (uShowEdgeLines > 0.5) {
                highp float eHalfW = max(uEdgeMarkingWidthNear * scale * 0.5, 0.25);
                highp float eFullW = eHalfW * 2.0;
                highp float flushCenterDist = roadHalfW - eHalfW;
                highp float pushedCenterDist = flushCenterDist - eFullW;
                highp float centerDist = stripeOn ? pushedCenterDist : flushCenterDist;
                if (abs(adx - centerDist) < eHalfW) {
                    outColor = uEdgeMarkingColor;
                }
            }
        }
    }

    // Premultiplied alpha output, as QML's scene graph expects.
    gl_FragColor = vec4(outColor.rgb * outColor.a * qt_Opacity, outColor.a * qt_Opacity);
}
