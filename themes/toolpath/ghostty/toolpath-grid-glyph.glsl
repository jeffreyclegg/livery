// ============================================================
// TOOLPATH · SHOP FLOOR — blueprint grid + gradient glyph shader
// Personal design system, Rev H. JDC.
//
//   custom-shader = shaders/toolpath-grid-glyph.glsl
//   custom-shader-animation = true
//
// Static by design — iTime is never sampled. Animation=true only forces
// redraws so the cursor repaints promptly as it moves.
//
// NOTE: every px value below is a PHYSICAL device pixel. On a Retina
// display that is half the apparent size, so spacings look twice as
// fine as the numbers suggest. Scale GRID_SPACING up if the grid reads
// too dense on your screen.
//
// The grid is drawn only where the terminal is showing background.
// Text, cursor and selection mask it out entirely, so legibility is
// untouched no matter how dense the grid gets.
//
// Adds a vertical temper gradient INSIDE a glyph — something terminal
// text can never do on its own, since a cell renders one glyph in one
// color. Starship paints the chevron in a sentinel color; this shader
// swaps that color for a top-to-bottom run of the temper spectrum.
//
// starship.toml:
//   [character]
//   success_symbol = "[❱](fg:#FF00FF)"
//   error_symbol   = "[❱](fg:#CE7A46)"
//
// Magenta is used as the key because nothing in Toolpath is near it, so
// no real text is ever caught. If the shader is off you will see a
// magenta chevron — that is the only visible cost, and it doubles as a
// load indicator.
//
// ghostty config for the cursor effect:
//   cursor-color = #00FF00
//   adjust-cursor-thickness = 100%
// ============================================================

// ---- TUNABLES ----
const float GRID_SPACING   = 32.0;   // px between minor lines (matches hero backdrop)
const float GRID_MAJOR     = 5.0;    // heavier line every N cells
const float LINE_WIDTH     = 1.0;    // px
const float GRID_ALPHA     = 0.055;  // minor line strength (CSS uses 0.06)
const float MAJOR_ALPHA    = 0.10;   // major line strength

const float HATCH_SPACING  = 14.0;   // px period of the 45° section hatch
const float HATCH_ALPHA    = 0.16;
const float HATCH_REACH    = 0.42;   // corner hatch reach, as a FRACTION of window
                                     // height — stays correct on any display density

const float TEMPER_HEIGHT  = 2.0;    // px, top-edge signature strip. 0.0 = off
const float TEMPER_ALPHA   = 0.85;

// ---- GRADIENT GLYPH ----
// Keyed on channel RELATIONSHIPS, not an exact color: red high, blue
// high, green low. Exact matching fails because Ghostty renders into a
// Display P3 colorspace on macOS, so sRGB #FF00FF does not sample as
// (1,0,1) in the shader. Nothing in Toolpath is magenta-dominant, so
// this catches the sentinel and nothing else.
const float KEY_RB_LO   = 0.32;   // red/blue must exceed this
const float KEY_RB_HI   = 0.58;
const float KEY_G_LO    = 0.18;   // green must fall below this
const float KEY_G_HI    = 0.42;

// Outward growth in PHYSICAL px, as (horizontal, vertical). Separate
// axes because uniform dilation makes a chevron fat rather than tall —
// keep x small and push y for weight without width.
// (0,0) leaves the glyph at its drawn size.
const vec2  GLYPH_GROW  = vec2(0.1, 4.0);

// Edge softness for the grown shape. Coverage below LO is outside, above
// HI is solid, between is antialiased. LOWER lo = more expansion and a
// softer edge. Raising both toward 0.5 gives a crisper but harder edge.
const float GROW_LO     = 0.10;
const float GROW_HI     = 0.42;
const int   GROW_TAPS   = 32;     // disc samples; more = smoother, slower

// Extent probing for the self-normalizing gradient: how far to scan for
// the glyph's top/bottom edge, in physical px (STEPS * STEP each way).
const float EXT_STEP    = 2.0;
const int   EXT_STEPS   = 44;
// Columns to agree across (+/- this many px). Per-column extents trace
// the glyph OUTLINE and make the front and back grade differently; a
// neighborhood makes every column converge on the shared bounding box.
const float EXT_COL     = 9.0;
// Consecutive misses (in steps) before an edge is declared. Bridges the
// notch inside the chevron so it reads as one span, not two strokes.
const int   EXT_GAP     = 6;

// ---- CURSOR ----
// cursor-color is pure green (#00FF00) purely as a key — the shader
// repaints every green pixel, so green is never actually seen. Distinct
// from the magenta glyph key so the two never collide.
//
// A bar cursor is a few px wide; a block spans the whole cell. The shader
// measures the keyed run's horizontal coverage: narrow -> solid bearing
// bronze, wide -> the vertical temper gradient. So the resting bar is
// bronze, and the block that appears while a command is running grades
// top to bottom like the chevron.
const vec3  BRONZE      = vec3(0.8078, 0.4784, 0.2745);  // #CE7A46
const float CUR_G_LO    = 0.35;   // green must exceed this
const float CUR_G_HI    = 0.60;
const float CUR_RB_LO   = 0.20;   // red AND blue must stay below this
const float CUR_RB_HI   = 0.40;
const float CUR_PROBE   = 3.0;    // px between width probes
const float CUR_WIDE_LO = 0.35;   // coverage above this reads as a block
const float CUR_WIDE_HI = 0.65;
const float CELL_H      = 58.0;   // used by GLYPH_DEBUG 1 overlay only
const float CELL_OFF    = 0.0;

// 1 = overlay alternating bands (legacy row-alignment debug).
// 2 = paint every KEYED pixel solid green. If the chevron turns green,
//     the key works. If it stays magenta, the key is not matching.
#define GLYPH_DEBUG 0

// If the temper strip and hatch land on the BOTTOM edge instead of the
// top, your backend reports Y inverted — set this to 1.
#define FLIP_Y 0

// ---- TOOLPATH TOKENS ----
const vec3 GROUND = vec3(0.0784, 0.0863, 0.1059); // #14161B
const vec3 DYKEM  = vec3(0.3569, 0.5608, 0.7490); // #5B8FBF

const vec3 T_STRAW  = vec3(0.9137, 0.7843, 0.4157); // #E9C86A
const vec3 T_AMBER  = vec3(0.8784, 0.6275, 0.2118); // #E0A036
const vec3 T_BRONZE = vec3(0.7529, 0.4157, 0.2431); // #C06A3E
const vec3 T_VIOLET = vec3(0.6039, 0.3569, 0.5608); // #9A5B8F
const vec3 T_BLUE   = vec3(0.3059, 0.5255, 0.7216); // #4E86B8

// The temper spectrum, stops at 0 / .28 / .52 / .74 / 1
vec3 temper(float t) {
    t = clamp(t, 0.0, 1.0);
    if (t < 0.28) return mix(T_STRAW,  T_AMBER,  t / 0.28);
    if (t < 0.52) return mix(T_AMBER,  T_BRONZE, (t - 0.28) / 0.24);
    if (t < 0.74) return mix(T_BRONZE, T_VIOLET, (t - 0.52) / 0.22);
    return                mix(T_VIOLET, T_BLUE,  (t - 0.74) / 0.26);
}

// Distance to the nearest line of a grid with the given spacing, in px.
float gridMask(vec2 p, float spacing, float width) {
    vec2 g = abs(fract(p / spacing - 0.5) - 0.5) * spacing;
    float d = min(g.x, g.y);
    return 1.0 - smoothstep(0.0, width, d);
}

// Is the pixel at this coordinate the sentinel color? Sampled by
// position so the glyph can be dilated.
float keyAt(vec2 p) {
    vec3 c = texture(iChannel0, p / iResolution.xy).rgb;
    return smoothstep(KEY_RB_LO, KEY_RB_HI, c.r)
         * smoothstep(KEY_RB_LO, KEY_RB_HI, c.b)
         * (1.0 - smoothstep(KEY_G_LO, KEY_G_HI, c.g));
}

// Is the pixel at this coordinate the cursor sentinel (pure green)?
float cursorAt(vec2 p) {
    vec3 c = texture(iChannel0, p / iResolution.xy).rgb;
    return smoothstep(CUR_G_LO, CUR_G_HI, c.g)
         * (1.0 - smoothstep(CUR_RB_LO, CUR_RB_HI, max(c.r, c.b)));
}

// 45° hatching — drafting shorthand for a cut surface.
float hatchMask(vec2 p, float spacing, float width) {
    float v = abs(fract((p.x + p.y) / spacing) - 0.5) * spacing;
    return 1.0 - smoothstep(0.0, width, v);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv   = fragCoord / iResolution.xy;
    vec3 term = texture(iChannel0, uv).rgb;

    // How far this pixel is from bare background. Anything with ink on it
    // — glyphs, cursor, selection — pushes this up and kills the grid.
    float ink   = smoothstep(0.015, 0.09, distance(term, GROUND));
    float clear = 1.0 - ink;

    // Pixel coords with a consistent top-left origin.
    vec2 px = fragCoord;
#if FLIP_Y
    px.y = iResolution.y - px.y;
#endif

    // ---- BLUEPRINT GRID ----
    float minor = gridMask(px, GRID_SPACING, LINE_WIDTH) * GRID_ALPHA;
    float major = gridMask(px, GRID_SPACING * GRID_MAJOR, LINE_WIDTH) * MAJOR_ALPHA;
    float grid  = max(minor, major);

    // ---- SECTION HATCH, top-right corner only ----
    vec2  corner = vec2(iResolution.x - px.x, px.y);
    float reach  = 1.0 - smoothstep(0.0, HATCH_REACH * iResolution.y, length(corner));
    float hatch  = hatchMask(px, HATCH_SPACING, LINE_WIDTH) * HATCH_ALPHA * reach;

    vec3 col = term;
    col = mix(col, DYKEM, (grid + hatch) * clear);

    // ---- GRADIENT GLYPH ----
    {
        float onGlyph = keyAt(fragCoord);

        // Grow the shape smoothly. Taking max() over a ring of samples
        // unions discrete directions and leaves a faceted, pixelated
        // edge. Instead, average the key over a disc to get a coverage
        // field, then threshold it — that expands the shape while
        // keeping the boundary continuous and antialiased.
        if (GLYPH_GROW.x > 0.0 || GLYPH_GROW.y > 0.0) {
            float acc = 0.0;
            for (int i = 0; i < GROW_TAPS; i++) {
                float fi = float(i) + 0.5;
                float r  = sqrt(fi / float(GROW_TAPS));   // even over the disc
                float a  = fi * 2.39996;                  // golden angle
                acc += keyAt(fragCoord + vec2(cos(a), sin(a)) * r * GLYPH_GROW);
            }
            acc /= float(GROW_TAPS);
            onGlyph = max(onGlyph, smoothstep(GROW_LO, GROW_HI, acc));
        }

        // Self-normalizing gradient over the glyph's BOUNDING BOX: scan
        // three nearby columns, bridge short gaps (the chevron's notch),
        // and take the farthest edges found. Every pixel then shares one
        // top and one bottom, so the gradient is a single flat vertical
        // ramp — immune to font size, row position, and display density.
        if (onGlyph > 0.001) {
            float dUp = EXT_STEP, dDn = EXT_STEP;
            for (int c = -1; c <= 1; c++) {
                vec2 cb = fragCoord + vec2(float(c) * EXT_COL, 0.0);
                float hit = 0.0; int miss = 0;
                for (int i = 1; i <= EXT_STEPS; i++) {
                    if (keyAt(cb - vec2(0.0, float(i) * EXT_STEP)) >= 0.35) {
                        hit = float(i) * EXT_STEP; miss = 0;
                    } else { miss++; if (miss >= EXT_GAP) break; }
                }
                dUp = max(dUp, hit + EXT_STEP);
                hit = 0.0; miss = 0;
                for (int i = 1; i <= EXT_STEPS; i++) {
                    if (keyAt(cb + vec2(0.0, float(i) * EXT_STEP)) >= 0.35) {
                        hit = float(i) * EXT_STEP; miss = 0;
                    } else { miss++; if (miss >= EXT_GAP) break; }
                }
                dDn = max(dDn, hit + EXT_STEP);
            }
#if FLIP_Y
            float t = dDn / max(dUp + dDn, 1.0);
#else
            float t = dUp / max(dUp + dDn, 1.0);
#endif
            col = mix(col, temper(t), onGlyph);
        }
    }

    // ---- CURSOR ----
    // Narrow keyed run = bar at rest -> solid bronze.
    // Wide keyed run = block while a command runs -> vertical temper.
    {
        float onCur = cursorAt(fragCoord);
        if (onCur > 0.001) {
            float wide = 0.0;
            for (int i = 1; i <= 6; i++) {
                float dd = float(i) * CUR_PROBE;
                wide += cursorAt(fragCoord + vec2(dd, 0.0));
                wide += cursorAt(fragCoord - vec2(dd, 0.0));
            }
            wide /= 12.0;
            float isBlock = smoothstep(CUR_WIDE_LO, CUR_WIDE_HI, wide);

            float dUp = 0.0, dDn = 0.0;
            for (int i = 1; i <= EXT_STEPS; i++) {
                float dd = float(i) * EXT_STEP;
                if (dUp == 0.0 && cursorAt(fragCoord - vec2(0.0, dd)) < 0.35) dUp = dd;
                if (dDn == 0.0 && cursorAt(fragCoord + vec2(0.0, dd)) < 0.35) dDn = dd;
            }
            float lim = float(EXT_STEPS) * EXT_STEP;
            if (dUp == 0.0) dUp = lim;
            if (dDn == 0.0) dDn = lim;
#if FLIP_Y
            float ct = dDn / max(dUp + dDn, 1.0);
#else
            float ct = dUp / max(dUp + dDn, 1.0);
#endif
            col = mix(col, mix(BRONZE, temper(ct), isBlock), onCur);
        }
    }

#if GLYPH_DEBUG == 1
    col = mix(col, vec3(0.0, 1.0, 0.0),
              0.18 * step(0.5, fract((px.y - CELL_OFF) / CELL_H)));
#elif GLYPH_DEBUG == 2
    col = mix(col, vec3(0.0, 1.0, 0.0),
              smoothstep(KEY_RB_LO, KEY_RB_HI, term.r)
            * smoothstep(KEY_RB_LO, KEY_RB_HI, term.b)
            * (1.0 - smoothstep(KEY_G_LO, KEY_G_HI, term.g)));
#endif

    // ---- TEMPER STRIP, top edge ----
    if (TEMPER_HEIGHT > 0.0 && px.y < TEMPER_HEIGHT) {
        float edge = 1.0 - smoothstep(TEMPER_HEIGHT - 1.0, TEMPER_HEIGHT, px.y);
        col = mix(col, temper(uv.x), TEMPER_ALPHA * edge);
    }

    fragColor = vec4(col, 1.0);
}
