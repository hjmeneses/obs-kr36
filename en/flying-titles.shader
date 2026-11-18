// Flying titles: blue chrome letters that streak toward the camera as blocks of light.
// In the style of late-70s superhero movie credits, for OBS Studio (obs-shaderfilter plugin,
// "User-defined shader" mode).
//
// How to use: put your text (text source or PNG with transparency) in its own scene, for
// example "Credits". Add that scene inside your main scene and apply the filter to the nested
// scene, not to the text source: that way the effect gets the whole canvas for the streaks and
// the stars.
//
// Three effects ("Effect" select), Progress 0 → 100:
//
// Opening credits
//   3–30   The letters arrive clean from the vanishing point.
//   30–50  Reading pause.
//   50–80  The streak shoots toward the camera and passes it (by default slightly above, as if
//          the letters flew over us).
//   80–97  The letters follow their streak and leave.
//
// Closing credits
//   3–30   The letters arrive from behind the camera with the streak ahead of them; the streak
//          cuts off abruptly when they arrive.
//   30–50  Reading pause.
//   50–97  They recede clean; three quarters of the way they blur from blue to orange and back
//          to blue, and go out before reaching the vanishing point.
//
// Emblem
//   3–97   Born at the center with streaks toward the viewer from the first frame, it advances
//          until it fills the frame before fading out.
//
// Kodalith style (default): recreates the R/Greenberg technique. The blue light outline is
// generated from solid text, and the streak is the light the outline accumulates with the
// shutter open.

uniform bool auto_play<
    string label = "Loop playback (ignores Progress)";
> = true;

uniform float duration<
    string label = "Sequence duration (s)";
    string widget_type = "slider";
    float minimum = 2.0; float maximum = 30.0; float step = 0.5;
> = 8.0;

uniform float progress<
    string label = "Progress (%)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 100.0; float step = 0.1;
> = 50.0;

uniform float vp_x<
    string label = "Vanishing point X (%)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 100.0; float step = 0.1;
> = 50.0;

uniform float vp_y<
    string label = "Vanishing point Y (%)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 100.0; float step = 0.1;
> = 50.0;

// How far away the horizon is. 40 = there the text is 1/40 of its size.
uniform float z_far<
    string label = "Horizon distance";
    string widget_type = "slider";
    float minimum = 3.0; float maximum = 100.0; float step = 1.0;
> = 40.0;

uniform int mode<
    string label = "Effect";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Opening credits: arrive clean, leave streaking toward the camera";
    int    option_1_value = 1;
    string option_1_label = "Closing credits: arrive streaking, leave clean with a color shift";
    int    option_2_value = 2;
    string option_2_label = "Emblem: streaks from the center until it fills the frame";
> = 0;

// When arriving from the vanishing point, at what distance it starts to show (horizon fraction).
uniform float fade_start<
    string label = "Appear from horizon (fraction)";
    string widget_type = "slider";
    float minimum = 0.05; float maximum = 0.95; float step = 0.01;
> = 0.3;

// Closing credits: how far it recedes before going out. Three quarters of the way the blur
// starts, with the blue → orange → blue shift.
uniform float fade_dist<
    string label = "Closing: fade-out distance";
    string widget_type = "slider";
    float minimum = 1.5; float maximum = 40.0; float step = 0.1;
> = 12.0;

uniform float horizon_blur<
    string label = "Closing: blur when fading (px)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 40.0; float step = 0.5;
> = 14.0;

uniform float4 color_warm = {1.0, 0.55, 0.12, 1.0};
uniform float4 color_cool = {0.15, 0.35, 1.0, 1.0};

// How much the letter face darkens behind its extrusion. More visible with hollow letters;
// keep it low for solid letters.
uniform float face_shadow<
    string label = "Letter face shadow";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 0.35;

// Each letter is a 3D block reaching from the letter toward the camera, in units of the
// distance at which the text shows at normal size. 1 or more = the block passes the camera.
uniform float extrude<
    string label = "Extrusion length toward camera";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 1.2;

uniform int follow_delay<
    string label = "Time before letters follow the extrusion";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Half a second";
    int    option_1_value = 1;
    string option_1_label = "1 second";
    int    option_2_value = 2;
    string option_2_label = "2 seconds";
> = 1;

// 0 = the extrusion goes straight at the camera; negative = passes above; positive = below.
uniform float pass_dir<
    string label = "Pass above (-) / below (+)";
    string widget_type = "slider";
    float minimum = -1.0; float maximum = 1.0; float step = 0.01;
> = -0.25;

// Text roll while extruding. Proportional to "Pass above/below", so going straight at the
// camera it does not roll.
uniform float roll<
    string label = "Roll when passing above/below (degrees)";
    string widget_type = "slider";
    float minimum = -20.0; float maximum = 20.0; float step = 0.1;
> = 6.0;

uniform float volume_strength<
    string label = "Volume brightness";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.8;

// Bright lines on the extrusion edges (where a letter edge lines up with the direction of the
// extrusion).
uniform float line_strength<
    string label = "Edge brightness";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 4.0; float step = 0.01;
> = 1.6;

uniform float line_width<
    string label = "Edge width (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 6.0; float step = 0.1;
> = 1.5;

// Kodalith: as in the film. A negative and a positive of the letter stacked with a blue gel in
// between only let light through at the outline, and with the shutter open the light builds up
// on the film: edges running along the motion become bright lines and crossing edges faint
// sheets. Chrome: solid letter with a bevel and a translucent volume.
uniform int style<
    string label = "Style";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Kodalith (light outline, like the film)";
    int    option_1_value = 1;
    string option_1_label = "Solid chrome";
> = 0;

uniform float kodalith_width<
    string label = "Kodalith: outline width (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 8.0; float step = 0.1;
> = 2.0;

// How much light the streak accumulates. Lines saturate to near white; sheets stay faint.
uniform float exposure<
    string label = "Kodalith: streak exposure";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 20.0; float step = 0.1;
> = 6.0;

// How much the streak covers. From 0 to 1 it covers the letter (at 1 it hides it completely
// while streaking, so it only reads during the pause, as in the film). From 1 to 2 the streak
// gets more solid: brighter, and the stars no longer show through.
uniform float streak_opacity<
    string label = "Streak opacity";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.9;

// How many samples the streak uses. If OBS says the encoder is overloaded or frames get skipped
// while streaming or recording, lower it: the streak gets a little grainier.
uniform int quality<
    string label = "Quality (lower it if OBS gets overloaded)";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Low (8 samples, lightest)";
    int    option_1_value = 1;
    string option_1_label = "Medium (16 samples)";
    int    option_2_value = 2;
    string option_2_label = "High (32 samples, heaviest)";
> = 1;

uniform bool letterbox<
    string label = "CinemaScope 2.35:1 (black bars)";
> = false;

// 1 = blue chrome; 0 = keeps the original text colors.
uniform float chrome_amount<
    string label = "Chrome (0 = original colors)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 1.0;

uniform float4 color_deep = {0.02, 0.10, 0.45, 1.0};
uniform float4 color_light = {0.25, 0.50, 1.0, 1.0};

uniform float bevel<
    string label = "Chrome bevel (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 12.0; float step = 0.5;
> = 3.0;

uniform float sheen<
    string label = "Sheen across the text";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 0.45;

uniform float glow_strength<
    string label = "Glow";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.6;

uniform float glow_size<
    string label = "Glow width (px)";
    string widget_type = "slider";
    float minimum = 1.0; float maximum = 40.0; float step = 0.5;
> = 10.0;

uniform float white_core<
    string label = "White core of the light (0 = pure blue)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 0.15;

uniform bool flare<
    string label = "Anamorphic flare (horizontal line)";
> = false;

uniform float flare_strength<
    string label = "Flare: strength";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.8;

uniform float flare_y<
    string label = "Flare: height (%)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 100.0; float step = 0.1;
> = 50.0;

uniform float flare_length<
    string label = "Flare: length (% of width)";
    string widget_type = "slider";
    float minimum = 5.0; float maximum = 100.0; float step = 1.0;
> = 45.0;

uniform float flare_thickness<
    string label = "Flare: thickness (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 10.0; float step = 0.1;
> = 1.5;

uniform float4 flare_color = {0.30, 0.55, 1.0, 1.0};

uniform bool stars<
    string label = "Starfield background (otherwise transparent)";
> = true;

uniform float star_density<
    string label = "Star density";
    string widget_type = "slider";
    float minimum = 5.0; float maximum = 60.0; float step = 1.0;
> = 25.0;

uniform float star_speed<
    string label = "Star speed";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 3.0; float step = 0.01;
> = 0.4;

uniform float4 space_color = {0.0, 0.01, 0.05, 1.0};

float hash12(float2 p)
{
    float3 p3 = frac(float3(p.x, p.y, p.x) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

float seg(float p, float a, float b)
{
    return saturate((p - a) / (b - a));
}

float ease(float t)
{
    return t * t * (3.0 - 2.0 * t);
}

// 0 near, 1 at the horizon: fade-in when arriving from the vanishing point
float horizonAt(float z)
{
    return smoothstep(z_far * fade_start, z_far * 0.97, z);
}

// State at instant p. Returns:
//   x = z distance of the letter (1 = normal size; on-screen scale is 1/z)
//   y = z distance of the other end of the streak (equal to x = no streak). Smaller than x =
//       the streak runs from the letter toward the camera; larger = toward the background.
//   z = visibility (0..1)
//   w = phase of the closing-credits blur and color shift (0..1)
//
// The streaks mimic the open shutter of the animation camera: one end stays where the letter
// was when the shutter opened and the other is where it is now.

float follow_seconds()
{
    return (follow_delay == 0) ? 0.5 : ((follow_delay == 2) ? 2.0 : 1.0);
}

// Opening credits: arrives clean from the vanishing point, reading pause, then the streak shoots
// toward the camera (passing it); finally the letter follows it.
float4 stateOpening(float p)
{
    // Letters always leave at 0.80; the extrusion starts "Time before letters follow the
    // extrusion" seconds earlier (never before the arrival ends). The ending stays the same; the
    // reading pause is what gets longer or shorter.
    float p_follow = 0.80;
    float p_ext = max(0.30, p_follow - follow_seconds() / max(duration, 0.5));
    float zf = max(1.0 - extrude, 0.02);

    if (p < 0.30) {
        float u = seg(p, 0.03, 0.30);
        float z = lerp(z_far, 1.0, 1.0 - (1.0 - u) * (1.0 - u));   // arrives and slows down
        return float4(z, z, 1.0 - horizonAt(z), 0.0);
    }
    if (p < p_ext)
        return float4(1.0, 1.0, 1.0, 0.0);                         // reading pause
    if (p < p_follow) {
        // The front accelerates and reaches its maximum right when the letters leave (it no
        // longer gets stuck earlier)
        float u = seg(p, p_ext, p_follow);
        return float4(1.0, lerp(1.0, zf, u * u), 1.0, 0.0);
    }
    // Letters take off already moving (no pause) and the front keeps advancing
    float u = seg(p, p_follow, 0.97);
    float z = lerp(1.0, 0.02, 0.45 * u + 0.55 * u * u);
    float zo = min(lerp(zf, 0.02, u), z);
    return float4(z, zo, 1.0 - smoothstep(0.6, 1.0, u), 0.0);
}

// Closing credits: arrives from behind the camera with the streak ahead of it (toward its
// destination), the streak cuts off abruptly on arrival, pause, recedes clean, and three
// quarters of the way it blurs from blue to orange and back to blue before going out.
float4 stateClosing(float p)
{
    if (p < 0.30) {
        float u = seg(p, 0.03, 0.30);
        float z = lerp(0.02, 1.0, 1.0 - (1.0 - u) * (1.0 - u));   // arrives and slows down
        return float4(z, 1.0, smoothstep(0.0, 0.1, u), 0.0);
    }
    if (p < 0.50)
        return float4(1.0, 1.0, 1.0, 0.0);                         // reading pause
    float u = seg(p, 0.50, 0.97);
    float z = lerp(1.0, fade_dist, u);
    float ph = seg(u, 0.75, 1.0);
    return float4(z, z, 1.0 - smoothstep(0.7, 1.0, ph), ph);
}

// Emblem: born at the center with streaks toward the viewer from the first frame, advances
// until it fills the frame before fading out.
float4 stateEmblem(float p)
{
    float u = seg(p, 0.03, 0.97);
    float z = z_far * exp2(u * log2(0.5 / z_far));     // steady speed in perspective
    return float4(z, max(z * (1.0 - extrude), 0.02), smoothstep(0.0, 0.08, u) * (1.0 - smoothstep(0.85, 1.0, u)), 0.0);
}

float4 textAt(float2 tc)
{
    if (tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0 || tc.y > 1.0)
        return float4(0.0, 0.0, 0.0, 0.0);
    return image.SampleLevel(textureSampler, tc, 0.0);
}

float alphaAt(float2 tc)
{
    return textAt(tc).a;
}

// Letter outline, like the Kodalith sandwich: 1 on the edge, 0 inside and outside.
// o = half outline width in uv (x and y separately because of the screen aspect ratio).
float2 outlineAt(float2 tc, float2 o)
{
    float ac = alphaAt(tc - o);
    float gx = alphaAt(tc + float2(o.x, -o.y)) - ac;
    float gy = alphaAt(tc + float2(-o.x, o.y)) - ac;
    return float2(saturate(abs(gx) + abs(gy)), ac);
}

// Text blurred over a disc of radius r (in screen pixels) at scale s.
// Returns alpha-premultiplied color, so transparent edges do not bleed in.
float4 textBlur(float2 tc, float r, float s)
{
    float4 c = textAt(tc);
    float4 acc = float4(c.rgb * c.a, c.a);
    if (r < 0.5)
        return acc;
    float fi = 0.0;
    for (int i = 0; i < 16; i++) {
        float a = fi * 2.39996323;
        float rr = sqrt((fi + 0.5) / 16.0) * r;
        c = textAt(tc + float2(cos(a), sin(a)) * rr * uv_pixel_interval / s);
        acc += float4(c.rgb * c.a, c.a);
        fi += 1.0;
    }
    return acc / 17.0;
}

// Starfield in 4 layers that keep moving closer; each layer appears, spreads outward from the
// vanishing point and fades, so the motion never "jumps".
float3 starfield(float2 uv, float2 vp, float t)
{
    float H = uv_size.y;
    float aspect = uv_size.x / H;
    float2 q = (uv - vp) * float2(aspect, 1.0);
    float3 col = space_color.rgb * (1.0 - 0.4 * saturate(length(q)));

    float lf = 0.0;
    for (int L = 0; L < 4; L++) {
        float z = frac(t * star_speed * 0.05 + lf * 0.25);
        float sc = lerp(2.5, 0.25, z);
        float2 g = q * sc * star_density + lf * 17.0;
        float2 cell = floor(g);
        float2 f = frac(g) - 0.5;
        float h = hash12(cell + lf * 31.0);
        float2 off = float2(hash12(cell + 7.1), hash12(cell + 3.3)) - 0.5;
        float px = (1.0 + 2.5 * h * h) * lerp(0.6, 1.6, z);         // size in pixels
        float size = px * sc * star_density / H;                     // in cell units
        float d = length(f - off * 0.7);
        float on = step(0.72, h);
        float life = smoothstep(0.0, 0.2, z) * (1.0 - smoothstep(0.8, 1.0, z));
        float tw = 0.65 + 0.35 * sin(t * 3.0 + h * 60.0);
        col += (1.0 - smoothstep(0.0, size, d)) * on * life * tw * float3(0.8, 0.9, 1.0);
        lf += 1.0;
    }
    return col;
}

// Layer on top, with premultiplied alpha
float4 over(float4 dst, float3 c, float a)
{
    return float4(c * a + dst.rgb * (1.0 - a), a + dst.a * (1.0 - a));
}

// Anamorphic flare (optional): a thin horizontal line at the text's height, like the one from
// CinemaScope lenses. It lights up where it crosses the letters (8 reads, only near the line)
// and a sweep runs along it when the letters arrive.
float3 anamorphicFlare(float2 uv, float2 vp, float ca, float sa, float z, float fade,
                       float streak, float p, float t)
{
    if (!flare)
        return float3(0.0, 0.0, 0.0);
    float fy = flare_y * 0.01;
    float dyp = (uv.y - fy) * uv_size.y;
    float th = max(flare_thickness, 0.5);
    if (abs(dyp) > th * 14.0)
        return float3(0.0, 0.0, 0.0);
    float prof = exp(-(dyp * dyp) / (th * th)) + 0.25 * exp(-abs(dyp) / (th * 5.0));

    float len = flare_length * 0.01;
    float jit = frac(hash12(float2(floor(uv.x * uv_size.x), 3.0)) + frac(t * 37.0));
    float E = 0.0;
    float kf = 0.0;
    for (int i = 0; i < 8; i++) {
        float k = (kf + jit) / 8.0 * 2.0 - 1.0;
        float2 rp = (float2(uv.x + k * len, fy) - vp) * uv_size;
        float2 rl = float2(ca * rp.x + sa * rp.y, -sa * rp.x + ca * rp.y) / uv_size;
        E += alphaAt(vp + rl * z) * exp(-abs(k) * 3.0);
        kf += 1.0;
    }
    E = E / 8.0 * 4.0;

    float a0 = (mode == 2) ? 0.40 : 0.26;
    float u = seg(p, a0, a0 + 0.14);
    float on = sin(3.14159265 * u);
    float dx = (uv.x - lerp(-0.1, 1.1, u)) * uv_size.x;
    float tail = exp(-abs(dx) / (uv_size.x * 0.25)) * on;
    float r = th * 8.0;
    float hot = exp(-(dx * dx + dyp * dyp * 4.0) / (r * r)) * on;

    float I = flare_strength * fade * (E * (0.35 + 0.6 * streak) + tail * 1.2 + hot);
    return flare_color.rgb * prof * I;
}
float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    float t = elapsed_time;
    float2 vp = float2(vp_x, vp_y) * 0.01;
    float2 px = uv_pixel_interval;

    float p = auto_play ? frac(t / max(duration, 0.5)) : saturate(progress * 0.01);
    float4 st = (mode == 1) ? stateClosing(p) : ((mode == 2) ? stateEmblem(p) : stateOpening(p));
    float z = st.x;
    float z_other = st.y;
    float s = 1.0 / z;
    float fade = st.z;
    float out_phase = st.w;
    // How long the streak is (0 = no streak, 1 = very long), measured in perspective
    float streak = saturate(abs(log2(z_other / z)) * 0.5);
    // Text roll while extruding, only when the extrusion bends above/below. Rotated in pixels
    // so the screen aspect ratio does not distort it.
    float ang = radians(roll) * pass_dir * streak;
    float ca = cos(ang);
    float sa = sin(ang);
    float2 rp = (uv - vp) * uv_size;
    float2 rel = float2(ca * rp.x + sa * rp.y, -sa * rp.x + ca * rp.y) / uv_size;

    float2 tc = vp + rel * z;
    float4 src = textBlur(tc, out_phase * horizon_blur, s);
    float a = src.a;
    if (src.a > 0.0001)
        src.rgb /= src.a;    // from premultiplied back to straight color

    // Streak: the letter is at z and the streak reaches z_other (toward the camera if smaller,
    // toward the background if larger). Each sample is a copy of the letter at depth zk,
    // shifted vertically by "Pass above/below". For the copy at distance d from the letter, the
    // screen point q comes from q = (X + bend·d) / zk, so X = q·zk - bend·d. Depths follow a
    // geometric progression (even steps in perspective) with a random per-pixel offset, which
    // trades the banding of copies for a fine grain similar to the film's slit-scan.
    float dy = pass_dir * 0.6;
    float ratio = z_other / z;
    float jit = hash12(floor(uv * uv_size));
    int ns = (quality == 0) ? 8 : ((quality == 2) ? 32 : 16);
    float nsf = (float)ns;
    bool has_streak = abs(ratio - 1.0) >= 0.001;

    // CinemaScope bars: no image outside the central 2.35:1 band
    float band_half = uv_size.x / 2.35 * 0.5;
    float in_band = letterbox ? step(abs(uv.y - 0.5) * uv_size.y, band_half) : 1.0;

    // Closing-credits exit: from blue to orange and back to a diffuse blue
    float tint_w = smoothstep(0.0, 0.3, out_phase);
    float3 tint = lerp(color_warm.rgb, color_cool.rgb, smoothstep(0.4, 0.8, out_phase));

    float3 bg = stars ? starfield(uv, vp, t) : float3(0.0, 0.0, 0.0);

    if (fade <= 0.001) {
        float3 e0 = bg * in_band;
        return stars ? float4(e0, 1.0) : float4(0.0, 0.0, 0.0, 0.0);
    }

    if (style == 0) {
        // Kodalith: everything is light adding up over black, as in the optical printer.
        // Blur widens the outline and spreads the same light over more width.
        float w = kodalith_width + out_phase * horizon_blur;
        float face = outlineAt(tc, w * px * z).x * (kodalith_width / w);

        // Streak: outline light accumulated at every instant of the exposure, plus a fill (the
        // whole swept letter) that makes it opaque
        float light = 0.0;
        float fill = 0.0;
        if (has_streak) {
            float kf = 0.0;
            for (int i = 0; i < 32; i++) {
                if (i >= ns) break;
                float k = (kf + jit) / nsf;
                float zk = z * exp2(k * log2(ratio));
                float2 tck = vp + rel * zk - float2(0.0, dy * (z - zk));
                float wk = lerp(1.0, 0.6, k);
                float2 ol = outlineAt(tck, kodalith_width * px * zk);
                light += ol.x * wk;
                fill = max(fill, ol.y * wk);
                kf += 1.0;
            }
            light = light / nsf * exposure;
        }
        // The streak covers the letter in proportion to its length: it only reads sharp during
        // the pause
        float op = saturate(streak_opacity);
        float extra = saturate(streak_opacity - 1.0);
        float ramp = saturate(streak * 8.0);
        face *= 1.0 - op * ramp;
        float fill_cover = fill * ramp;
        fill = fill_cover * op * (1.0 + extra);
        bg *= 1.0 - fill_cover * extra;

        // Halo along the edges, inside and out (4·m·(1-m) peaks at the edge)
        float m = 0.0;
        float gk = 0.0;
        for (int j = 0; j < 8; j++) {
            float ga = gk * 0.7853982;
            m += alphaAt(vp + (rel + float2(cos(ga), sin(ga)) * glow_size * px) * z);
            gk += 1.0;
        }
        m /= 8.0;
        float halo = 4.0 * m * (1.0 - m) * glow_strength * (1.0 + out_phase);

        float3 lc = lerp(color_light.rgb, tint, tint_w);
        float v = (face * 1.5 + light + fill * 0.9) * fade;
        // Hue-preserving curve: the brightest light reaches the light color, not white
        float e = v + halo * fade * 0.5;
        float3 col = lc * saturate((1.0 - exp(-1.2 * e)) / 0.835) + saturate(v - 1.5) * white_core;
        col += anamorphicFlare(uv, vp, ca, sa, z, fade, streak, p, t);
        col *= in_band;
        float3 rgb = bg * in_band + col;
        float alpha = stars ? 1.0 : saturate(max(col.r, max(col.g, col.b)));
        return float4(stars ? rgb : rgb / max(alpha, 0.0001), alpha);
    }

    // Solid chrome: the block edges converge at (0, -dy) relative to the vanishing point
    float2 rd = normalize((rel + float2(0.0, dy)) * uv_size + float2(0.0001, 0.0));
    float2 tp = float2(-rd.y, rd.x) * line_width * px;    // perpendicular to the edge, in uv

    float vol = 0.0;
    float edges = 0.0;
    float fi = 0.0;
    for (int i = 0; i < 32; i++) {
        if (i >= ns) break;
        float k = (fi + jit) / nsf;                       // 0 = letter, 1 = other end
        float zk = z * exp2(k * log2(ratio));              // ratio^k (ratio is always > 0)
        float2 tck = vp + rel * zk - float2(0.0, dy * (z - zk));
        // Brighter next to the letter, dimmer toward the other end
        vol = max(vol, alphaAt(tck) * lerp(1.0, 0.6, k));
        // Edge: a letter edge lined up with the block edge is hit by every sample and adds up
        // to a bright line; a crossing edge only adds one sample
        float2 off = tp * zk;
        edges += abs(alphaAt(tck + off) - alphaAt(tck - off));
        fi += 1.0;
    }
    if (abs(ratio - 1.0) < 0.001) {
        vol = 0.0;
        edges = 0.0;
    }
    float volume = saturate(vol * volume_strength * (1.0 + saturate(streak_opacity - 1.0) * 2.0)) * fade;
    float lines = saturate(edges / nsf * 3.0 * line_strength) * fade;

    // Chrome: the bevel compares alpha above/below and left/right (in screen pixels)
    float2 o = bevel * px / s;
    float top = alphaAt(tc + float2(0.0, o.y)) - alphaAt(tc - float2(0.0, o.y));
    float left = alphaAt(tc + float2(o.x, 0.0)) - alphaAt(tc - float2(o.x, 0.0));
    // Front face darker than the extrusion, as in the film; the top edge shines
    float L = saturate(0.3 + 0.6 * top + 0.2 * left);
    float3 chrome = lerp(color_deep.rgb, color_light.rgb, L);
    chrome += pow(saturate(top), 3.0) * 0.8;
    float band = uv.x + uv.y * 0.5 - (frac(t * 0.15) * 2.5 - 0.5);
    chrome += exp(-band * band * 60.0) * sheen;
    float3 textCol = lerp(src.rgb, chrome, chrome_amount);
    // If the streak goes toward the camera, it sits between the letter and the viewer: the
    // letter darkens behind it
    bool streak_in_front = z_other < z;
    if (streak_in_front)
        textCol *= 1.0 - face_shadow * streak;

    textCol = lerp(textCol, tint * (0.7 + 0.5 * L), tint_w);
    float3 glowCol = lerp(color_light.rgb, tint, tint_w);

    // Glow: alpha averaged over a ring around the pixel
    float glow = 0.0;
    float gi = 0.0;
    for (int j = 0; j < 8; j++) {
        float ga = gi * 0.7853982;
        float2 go = float2(cos(ga), sin(ga)) * glow_size * px;
        glow += alphaAt(vp + (rel + go) * z);
        gi += 1.0;
    }
    // The halo grows as it blurs, like light scattered far away
    glow = glow / 8.0 * glow_strength * fade * (1.0 + out_phase);

    float4 acc = stars ? float4(bg * in_band, 1.0) : float4(0.0, 0.0, 0.0, 0.0);
    a *= in_band;
    volume *= in_band;
    lines *= in_band;
    glow *= in_band;
    acc = over(acc, glowCol, saturate(glow) * (1.0 - a));
    float3 volCol = color_light.rgb * lerp(0.7, 1.1, vol);
    float3 lineCol = lerp(color_light.rgb, float3(1.0, 1.0, 1.0), 0.55);
    if (streak_in_front) {
        // The streak sits between the letter and the camera: it goes over the face, dimmer
        // there so the letter still reads
        acc = over(acc, textCol, a * fade);
        acc = over(acc, volCol, saturate(volume * lerp(lerp(0.85, 1.0, saturate(streak_opacity)), saturate(streak_opacity), a)));
        acc = over(acc, lineCol, lines);
    } else {
        // The streak is behind the letter (closing credits on arrival): the letter covers it
        acc = over(acc, volCol, volume * 0.85 * (1.0 - a));
        acc = over(acc, lineCol, lines * (1.0 - a));
        acc = over(acc, textCol, a * fade);
    }

    float3 fl = anamorphicFlare(uv, vp, ca, sa, z, fade, streak, p, t) * in_band;
    acc = float4(acc.rgb + fl, saturate(acc.a + max(fl.r, max(fl.g, fl.b)) * (1.0 - acc.a)));
    return float4(acc.rgb / max(acc.a, 0.0001), acc.a);
}
