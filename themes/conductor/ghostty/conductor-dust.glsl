// ============================================================
// CONDUCTOR · MOFFAT — dust board shader for Ghostty
// The build machine's terminal, Rev G. JDC.
//
//   custom-shader = shaders/conductor-dust.glsl
//   custom-shader-animation = true
//
// A very quiet departure board seen through dust, behind the text: square
// cells, mostly empty, a few lit at a whisper in line strong and hudson,
// and the odd sodium spark that swells and fades over a few seconds.
// Dust gathers toward the bottom-right and thins to nothing toward the
// top-left, so the prompt and most output sit on bare ground.
//
// Drawn only where the terminal shows bare ground (#130B0B). Text, cursor
// and selection mask it out entirely, so ink is never dimmed. The cursor
// is left exactly as Ghostty draws it.
//
// For a still board, set STILL to 1 and custom-shader-animation = false.
// ============================================================

// ---- TUNABLES ----
// Cell pitch as a FRACTION of window height, not px: shader px are
// physical device pixels, so a fixed count halves on Retina. 0.0135 of a
// ~1800 device-px window is ~24 px, i.e. ~12 css px, the web board's pitch.
const float CELL_FRAC   = 0.0135;
const float DOT         = 0.72;   // lit square as a fraction of the pitch
const float DUST_ALPHA  = 0.12;   // brightest dim cell
const float SPARK_ALPHA = 0.35;   // sodium spark peak
const float FILL        = 0.40;   // share of cells lit at the densest corner
const float SPARK_RATE  = 0.004;  // chance a cell sparks per slot, densest corner
const float SLOT        = 4.0;    // seconds per cell clock (each cell offset)

const float SUNSET_HEIGHT = 2.0;  // px, top-edge strip. 0.0 = off
const float SUNSET_ALPHA  = 0.85;

// 1 = freeze the board (no iTime), for custom-shader-animation = false.
#define STILL 0

// If the sunset strip lands on the BOTTOM edge and the dust gathers
// top-right, your backend reports Y inverted — set this to 1.
#define FLIP_Y 0

// ---- CONDUCTOR · MOFFAT TOKENS ----
const vec3 GROUND      = vec3(0.0745, 0.0431, 0.0431); // #130B0B
const vec3 LINE_STRONG = vec3(0.3020, 0.2078, 0.1961); // #4D3532
const vec3 HUDSON      = vec3(0.6627, 0.7020, 0.7569); // #A9B3C1
const vec3 SODIUM      = vec3(0.9490, 0.6392, 0.2353); // #F2A33C

const vec3 S_DUSK  = vec3(0.1686, 0.1843, 0.2431); // #2B2F3E
const vec3 S_EMBER = vec3(0.3686, 0.1843, 0.1725); // #5E2F2C
const vec3 S_GLOW  = vec3(0.6902, 0.4157, 0.2824); // #B06A48

vec3 sunset(float t) {
    t = clamp(t, 0.0, 1.0);
    if (t < 0.33) return mix(S_DUSK,  S_EMBER, t / 0.33);
    if (t < 0.66) return mix(S_EMBER, S_GLOW,  (t - 0.33) / 0.33);
    return                mix(S_GLOW,  SODIUM,  (t - 0.66) / 0.34);
}

float hash(vec3 p) {
    p = fract(p * vec3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.x + p.y) * p.z);
}

// One cell's state for one time slot: rgb = color, a = alpha.
vec4 pick(vec2 cell, float slot, float dens) {
    float x = hash(vec3(cell, slot));
    if (x < SPARK_RATE * dens) return vec4(SODIUM, SPARK_ALPHA);
    if (x > 1.0 - FILL * dens) {
        float lv = pow(hash(vec3(cell, slot + 71.0)), 1.8) * DUST_ALPHA * dens;
        vec3  c  = hash(vec3(cell, 13.0)) < 0.7 ? LINE_STRONG : HUDSON;
        return vec4(c, lv);
    }
    return vec4(GROUND, 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv   = fragCoord / iResolution.xy;
    vec3 term = texture(iChannel0, uv).rgb;
    float clear = 1.0 - smoothstep(0.015, 0.06, distance(term, GROUND));

    // Pixel coords with a top-left origin.
    vec2 px = fragCoord;
#if FLIP_Y
    px.y = iResolution.y - px.y;
#endif
    vec2 tl = px / iResolution.xy;   // 0,0 top-left; 1,1 bottom-right

    vec3 col = term;

    // ---- DUST BOARD ----
    float pitch = max(4.0, CELL_FRAC * iResolution.y);
    vec2  cell  = floor(px / pitch);
    vec2  f     = fract(px / pitch);
    float dot_  = step(abs(f.x - 0.5), DOT * 0.5) * step(abs(f.y - 0.5), DOT * 0.5);

    // Density from the cell centre so a square never splits across the ramp.
    vec2  cc   = (cell + 0.5) * pitch / iResolution.xy;
    float dens = smoothstep(0.55, 1.75, cc.x + cc.y);
    dens *= dens;

    if (dot_ > 0.0 && dens > 0.0 && clear > 0.0) {
#if STILL
        float t = 0.0;
#else
        float t = iTime / SLOT + hash(vec3(cell, 5.0)) * 8.0;
#endif
        float s = floor(t);
        vec4  a = pick(cell, s, dens);
        vec4  b = pick(cell, s + 1.0, dens);
        vec4  d = mix(a, b, smoothstep(0.0, 1.0, fract(t)));
        // Fade a spark through the dust colour, not through a grey midpoint.
        vec3  c = a.a > b.a ? a.rgb : b.rgb;
        col = mix(col, c, d.a * clear);
    }

    // ---- SUNSET STRIP, top edge ----
    if (SUNSET_HEIGHT > 0.0 && px.y < SUNSET_HEIGHT) {
        col = mix(col, sunset(uv.x), SUNSET_ALPHA);
    }

    fragColor = vec4(col, 1.0);
}
