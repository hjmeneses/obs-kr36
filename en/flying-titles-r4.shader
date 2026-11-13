// Flying titles "region 4": a light version of flying-titles.shader, made for modest cards
// such as a GTX 1650 Ti that is also encoding with NVENC. Kodalith style only.
//
// Differences from the full version, to spend ~15 texture reads per pixel instead of ~190:
//   - The streak uses few copies (6, 8 or 12) and each copy reads the texture once: its
//     outline comes from the smoothed alpha edge, 4·a·(1-a), instead of comparing neighbors.
//     Near the camera the letter is magnified and that edge widens, like the light sheets in
//     the film.
//   - The offset of the copies changes every frame: the grain dances like film grain and the
//     eye averages it, so a few copies look like many.
//   - No chrome style and no real blur; in the closing credits the outline widens to fake the
//     blur.
//   - 4-read halo.
//
// Same effects, timings and parameter names as the full version, so intro-control.lua works
// the same. Usage: same as flying-titles.shader (on a nested scene).

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

uniform float z_far<
    string label = "Horizon distance";
    string widget_type = "slider";
    float minimum = 3.0; float maximum = 100.0; float step = 1.0;
> = 40.0;

uniform int mode<
    string label = "Effect";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Opening credits: arrives clean, leaves with a streak toward the camera";
    int    option_1_value = 1;
    string option_1_label = "Closing credits: arrives with a streak, leaves clean with a color shift";
    int    option_2_value = 2;
    string option_2_label = "Emblem: advances with streaks from the center until it fills the frame";
> = 0;

uniform float fade_start<
    string label = "Appear from horizon (fraction)";
    string widget_type = "slider";
    float minimum = 0.05; float maximum = 0.95; float step = 0.01;
> = 0.3;

uniform float fade_dist<
    string label = "Closing: fade-out distance";
    string widget_type = "slider";
    float minimum = 1.5; float maximum = 40.0; float step = 0.1;
> = 12.0;

uniform float horizon_blur<
    string label = "Closing: widening as it fades (px)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 40.0; float step = 0.5;
> = 14.0;

uniform float4 color_warm = {1.0, 0.55, 0.12, 1.0};
uniform float4 color_cool = {0.15, 0.35, 1.0, 1.0};

uniform float extrude<
    string label = "Extrusion length toward camera";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 1.2;

uniform float pass_dir<
    string label = "Pass above (-) / below (+)";
    string widget_type = "slider";
    float minimum = -1.0; float maximum = 1.0; float step = 0.01;
> = -0.25;

uniform float roll<
    string label = "Roll when passing above/below (degrees)";
    string widget_type = "slider";
    float minimum = -20.0; float maximum = 20.0; float step = 0.1;
> = 6.0;

uniform float kodalith_width<
    string label = "Outline width (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 8.0; float step = 0.1;
> = 2.0;

uniform float exposure<
    string label = "Streak exposure";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 20.0; float step = 0.1;
> = 6.0;

// 0–1: how much the streak covers the letter. 1–2: a more solid streak that hides the stars.
uniform float streak_opacity<
    string label = "Streak opacity";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.9;

uniform int quality<
    string label = "Streak copies";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "6 (lightest)";
    int    option_1_value = 1;
    string option_1_label = "8";
    int    option_2_value = 2;
    string option_2_label = "12";
> = 1;

uniform bool letterbox<
    string label = "CinemaScope 2.35:1 (black bars)";
> = false;

uniform float4 color_light = {0.35, 0.75, 1.0, 1.0};

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

float horizonAt(float z)
{
    return smoothstep(z_far * fade_start, z_far * 0.97, z);
}

// States: same as the full version (x = letter z, y = z of the other end of the streak,
// z = visibility, w = closing-credits exit phase)
float4 stateOpening(float p)
{
    if (p < 0.30) {
        float u = seg(p, 0.03, 0.30);
        float z = lerp(z_far, 1.0, 1.0 - (1.0 - u) * (1.0 - u));
        return float4(z, z, 1.0 - horizonAt(z), 0.0);
    }
    if (p < 0.50)
        return float4(1.0, 1.0, 1.0, 0.0);
    if (p < 0.80) {
        float u = seg(p, 0.50, 0.80);
        return float4(1.0, max(1.0 - u * u * extrude, 0.02), 1.0, 0.0);
    }
    float u = seg(p, 0.80, 0.97);
    float zf = max(1.0 - extrude, 0.02);
    return float4(lerp(1.0, 0.02, u * u), zf, 1.0 - smoothstep(0.6, 1.0, u), 0.0);
}

float4 stateClosing(float p)
{
    if (p < 0.30) {
        float u = seg(p, 0.03, 0.30);
        float z = lerp(0.02, 1.0, 1.0 - (1.0 - u) * (1.0 - u));
        return float4(z, 1.0, smoothstep(0.0, 0.1, u), 0.0);
    }
    if (p < 0.50)
        return float4(1.0, 1.0, 1.0, 0.0);
    float u = seg(p, 0.50, 0.97);
    float z = lerp(1.0, fade_dist, u);
    float ph = seg(u, 0.75, 1.0);
    return float4(z, z, 1.0 - smoothstep(0.7, 1.0, ph), ph);
}

float4 stateEmblem(float p)
{
    float u = seg(p, 0.03, 0.97);
    float z = z_far * exp2(u * log2(0.5 / z_far));
    return float4(z, max(z * (1.0 - extrude), 0.02), smoothstep(0.0, 0.08, u) * (1.0 - smoothstep(0.85, 1.0, u)), 0.0);
}

// No texture read outside the image
float alphaAt(float2 tc)
{
    if (tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0 || tc.y > 1.0)
        return 0.0;
    return image.SampleLevel(textureSampler, tc, 0.0).a;
}

// Outline of the letter face (3 diagonal reads), 1 on the edge
float outlineAt(float2 tc, float2 o)
{
    float ac = alphaAt(tc - o);
    float gx = alphaAt(tc + float2(o.x, -o.y)) - ac;
    float gy = alphaAt(tc + float2(-o.x, o.y)) - ac;
    return saturate(abs(gx) + abs(gy));
}

// Stars: 4 layers approaching from the vanishing point (no texture reads)
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
        float px = (1.0 + 2.5 * h * h) * lerp(0.6, 1.6, z);
        float size = px * sc * star_density / H;
        float d = length(f - off * 0.7);
        float on = step(0.72, h);
        float life = smoothstep(0.0, 0.2, z) * (1.0 - smoothstep(0.8, 1.0, z));
        float tw = 0.65 + 0.35 * sin(t * 3.0 + h * 60.0);
        col += (1.0 - smoothstep(0.0, size, d)) * on * life * tw * float3(0.8, 0.9, 1.0);
        lf += 1.0;
    }
    return col;
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
    float fade = st.z;
    float out_phase = st.w;
    float streak = saturate(abs(log2(z_other / z)) * 0.5);

    float ang = radians(roll) * pass_dir * streak;
    float ca = cos(ang);
    float sa = sin(ang);
    float2 rp = (uv - vp) * uv_size;
    float2 rel = float2(ca * rp.x + sa * rp.y, -sa * rp.x + ca * rp.y) / uv_size;
    float2 tc = vp + rel * z;

    float band_half = uv_size.x / 2.35 * 0.5;
    float in_band = letterbox ? step(abs(uv.y - 0.5) * uv_size.y, band_half) : 1.0;
    float3 bg = stars ? starfield(uv, vp, t) : float3(0.0, 0.0, 0.0);

    if (fade <= 0.001) {
        float3 e0 = bg * in_band;
        return stars ? float4(e0, 1.0) : float4(0.0, 0.0, 0.0, 0.0);
    }

    float tint_w = smoothstep(0.0, 0.3, out_phase);
    float3 tint = lerp(color_warm.rgb, color_cool.rgb, smoothstep(0.4, 0.8, out_phase));

    // Face: outline that widens as the closing credits fade (instead of a blur)
    float w = kodalith_width + out_phase * horizon_blur;
    float face = outlineAt(tc, w * px * z) * (kodalith_width / w);

    // Streak: few copies, one read each. The offset changes every frame (t * 37 moves
    // ~0.62 per frame at 60 fps, a step that does not repeat soon)
    float ratio = z_other / z;
    float light = 0.0;
    float fill = 0.0;
    if (abs(ratio - 1.0) >= 0.001) {
        int ns = (quality == 0) ? 6 : ((quality == 2) ? 12 : 8);
        float nsf = (float)ns;
        float jit = frac(hash12(floor(uv * uv_size)) + frac(t * 37.0));
        float dy = pass_dir * 0.6;
        float lr = log2(ratio);
        float kf = 0.0;
        for (int i = 0; i < 12; i++) {
            if (i >= ns) break;
            float k = (kf + jit) / nsf;
            float zk = z * exp2(k * lr);
            float a = alphaAt(vp + rel * zk - float2(0.0, dy * (z - zk)));
            float wk = lerp(1.0, 0.6, k);
            light += 4.0 * a * (1.0 - a) * wk;
            fill = max(fill, a * wk);
            kf += 1.0;
        }
        light = light / nsf * exposure;
    }

    float op = saturate(streak_opacity);
    float extra = saturate(streak_opacity - 1.0);
    float ramp = saturate(streak * 8.0);
    face *= 1.0 - op * ramp;
    float fill_cover = fill * ramp;
    fill = fill_cover * op * (1.0 + extra);
    bg *= 1.0 - fill_cover * extra;

    // Halo: average alpha at 4 points around; 4·m·(1-m) peaks next to the edge
    float2 go = glow_size * px * z * 0.7071;
    float m = (alphaAt(tc + go) + alphaAt(tc - go)
             + alphaAt(tc + float2(go.x, -go.y)) + alphaAt(tc + float2(-go.x, go.y))) * 0.25;
    float halo = 4.0 * m * (1.0 - m) * glow_strength * (1.0 + out_phase);

    float3 lc = lerp(color_light.rgb, tint, tint_w);
    float v = (face * 1.5 + light + fill * 0.9) * fade;
    float3 col = lc * (v + halo * fade * 0.5) + saturate(v - 1.0) * 0.6;
    col *= in_band;
    float3 rgb = bg * in_band + col;
    float alpha = stars ? 1.0 : saturate(max(col.r, max(col.g, col.b)));
    return float4(stars ? rgb : rgb / max(alpha, 0.0001), alpha);
}
