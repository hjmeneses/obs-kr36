// Títulos voladores "región 4": versión ligera de titulos-voladores.shader, pensada para
// tarjetas modestas como una GTX 1650 Ti que además codifica con NVENC. Solo estilo Kodalith.
//
// Diferencias con la versión completa, para gastar ~15 lecturas de textura por pixel en vez de
// ~190:
//   - La estela usa pocas copias (6, 8 o 12) y cada copia lee la textura una sola vez: su
//     contorno sale de la orilla suavizada del alfa, 4·a·(1-a), en vez de comparar vecinos.
//     Cerca de la cámara la letra está ampliada y esa orilla se ensancha, como las láminas de
//     luz de la película.
//   - El desfase de las copias cambia en cada cuadro: el grano baila como grano de película y
//     el ojo lo promedia, así que pocas copias se ven como muchas.
//   - Sin estilo cromo y sin desenfoque real; en los créditos finales el contorno se ensancha
//     para simular el desenfoque.
//   - Halo con 4 lecturas.
//
// Mismos efectos, mismos tiempos y los mismos nombres de parámetros que la versión completa,
// así que intro-control.lua funciona igual. Uso: igual que titulos-voladores.shader (en una
// escena anidada).

uniform bool auto_play<
    string label = "Reproducir en bucle (ignora Progreso)";
> = true;

uniform float duration<
    string label = "Duracion de la secuencia (s)";
    string widget_type = "slider";
    float minimum = 2.0; float maximum = 30.0; float step = 0.5;
> = 8.0;

uniform float progress<
    string label = "Progreso (%)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 100.0; float step = 0.1;
> = 50.0;

uniform float vp_x<
    string label = "Punto de fuga X (%)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 100.0; float step = 0.1;
> = 50.0;

uniform float vp_y<
    string label = "Punto de fuga Y (%)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 100.0; float step = 0.1;
> = 50.0;

uniform float z_far<
    string label = "Distancia del horizonte";
    string widget_type = "slider";
    float minimum = 3.0; float maximum = 100.0; float step = 1.0;
> = 40.0;

uniform int mode<
    string label = "Efecto";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Creditos iniciales: llega limpio, sale con estela hacia la camara";
    int    option_1_value = 1;
    string option_1_label = "Creditos finales: llega con estela, sale limpio con cambio de color";
    int    option_2_value = 2;
    string option_2_label = "Escudo: avanza con estelas desde el centro hasta llenar el cuadro";
> = 0;

uniform float fade_start<
    string label = "Aparicion desde el horizonte (fraccion)";
    string widget_type = "slider";
    float minimum = 0.05; float maximum = 0.95; float step = 0.01;
> = 0.3;

uniform float fade_dist<
    string label = "Finales: distancia a la que se apaga";
    string widget_type = "slider";
    float minimum = 1.5; float maximum = 40.0; float step = 0.1;
> = 12.0;

uniform float horizon_blur<
    string label = "Finales: ensanchado al apagarse (px)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 40.0; float step = 0.5;
> = 14.0;

uniform float4 color_warm = {1.0, 0.55, 0.12, 1.0};
uniform float4 color_cool = {0.15, 0.35, 1.0, 1.0};

uniform float extrude<
    string label = "Largo de la extrusion hacia la camara";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 1.2;

uniform int follow_delay<
    string label = "Tiempo antes de que las letras sigan a la extrusion";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Medio segundo";
    int    option_1_value = 1;
    string option_1_label = "1 segundo";
    int    option_2_value = 2;
    string option_2_label = "2 segundos";
> = 1;

uniform float pass_dir<
    string label = "Pasa por arriba (-) / abajo (+)";
    string widget_type = "slider";
    float minimum = -1.0; float maximum = 1.0; float step = 0.01;
> = -0.25;

uniform float roll<
    string label = "Rotacion al pasar arriba/abajo (grados)";
    string widget_type = "slider";
    float minimum = -20.0; float maximum = 20.0; float step = 0.1;
> = 6.0;

uniform float kodalith_width<
    string label = "Grosor del contorno (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 8.0; float step = 0.1;
> = 2.0;

uniform float exposure<
    string label = "Exposicion de la estela";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 20.0; float step = 0.1;
> = 6.0;

// 0–1: qué tanto tapa la estela a la letra. 1–2: estela más sólida que tapa las estrellas.
uniform float streak_opacity<
    string label = "Opacidad de la estela";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.9;

uniform int quality<
    string label = "Copias de la estela";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "6 (la mas ligera)";
    int    option_1_value = 1;
    string option_1_label = "8";
    int    option_2_value = 2;
    string option_2_label = "12";
> = 1;

uniform bool letterbox<
    string label = "Formato CinemaScope 2.35:1 (franjas negras)";
> = false;

uniform float4 color_light = {0.25, 0.50, 1.0, 1.0};

uniform float glow_strength<
    string label = "Resplandor";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.6;

uniform float glow_size<
    string label = "Ancho del resplandor (px)";
    string widget_type = "slider";
    float minimum = 1.0; float maximum = 40.0; float step = 0.5;
> = 10.0;

uniform float white_core<
    string label = "Nucleo blanco de la luz (0 = azul puro)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 0.15;

uniform bool flare<
    string label = "Destello anamorfico (linea horizontal)";
> = false;

uniform float flare_strength<
    string label = "Destello: intensidad";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.8;

uniform float flare_y<
    string label = "Destello: altura (%)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 100.0; float step = 0.1;
> = 50.0;

uniform float flare_length<
    string label = "Destello: largo (% del ancho)";
    string widget_type = "slider";
    float minimum = 5.0; float maximum = 100.0; float step = 1.0;
> = 45.0;

uniform float flare_thickness<
    string label = "Destello: grosor (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 10.0; float step = 0.1;
> = 1.5;

uniform float4 flare_color = {0.30, 0.55, 1.0, 1.0};

uniform bool stars<
    string label = "Fondo de estrellas (si no, fondo transparente)";
> = true;

uniform float star_density<
    string label = "Densidad de estrellas";
    string widget_type = "slider";
    float minimum = 5.0; float maximum = 60.0; float step = 1.0;
> = 25.0;

uniform float star_speed<
    string label = "Velocidad de las estrellas";
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

float follow_seconds()
{
    return (follow_delay == 0) ? 0.5 : ((follow_delay == 2) ? 2.0 : 1.0);
}

// Estados: iguales a la versión completa (x = z de la letra, y = z del otro extremo de la
// estela, z = visibilidad, w = fase de salida de los créditos finales)
float4 stateOpening(float p)
{
    // Las letras salen siempre en 0.80; la extrusión empieza "Tiempo antes de que las letras
    // sigan a la extrusión" segundos antes (sin invadir la llegada). Así el final no cambia y
    // lo que se alarga o acorta es la pausa de lectura.
    float p_follow = 0.80;
    float p_ext = max(0.30, p_follow - follow_seconds() / max(duration, 0.5));
    float zf = max(1.0 - extrude, 0.02);

    if (p < 0.30) {
        float u = seg(p, 0.03, 0.30);
        float z = lerp(z_far, 1.0, 1.0 - (1.0 - u) * (1.0 - u));   // llega y frena
        return float4(z, z, 1.0 - horizonAt(z), 0.0);
    }
    if (p < p_ext)
        return float4(1.0, 1.0, 1.0, 0.0);                         // pausa de lectura
    if (p < p_follow) {
        // El frente acelera y llega a su máximo justo cuando salen las letras (sin quedarse
        // atorado antes)
        float u = seg(p, p_ext, p_follow);
        return float4(1.0, lerp(1.0, zf, u * u), 1.0, 0.0);
    }
    // Las letras arrancan ya en movimiento (sin pausa) y el frente sigue avanzando
    float u = seg(p, p_follow, 0.97);
    float z = lerp(1.0, 0.02, 0.45 * u + 0.55 * u * u);
    float zo = min(lerp(zf, 0.02, u), z);
    return float4(z, zo, 1.0 - smoothstep(0.6, 1.0, u), 0.0);
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

// Fuera de la imagen no se lee la textura
float alphaAt(float2 tc)
{
    if (tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0 || tc.y > 1.0)
        return 0.0;
    return image.SampleLevel(textureSampler, tc, 0.0).a;
}

// Contorno de la cara de la letra (3 lecturas en diagonal), 1 en el borde
float outlineAt(float2 tc, float2 o)
{
    float ac = alphaAt(tc - o);
    float gx = alphaAt(tc + float2(o.x, -o.y)) - ac;
    float gy = alphaAt(tc + float2(-o.x, o.y)) - ac;
    return saturate(abs(gx) + abs(gy));
}

// Estrellas: 4 capas que se acercan desde el punto de fuga (sin lecturas de textura)
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

// Destello anamórfico (opcional): línea horizontal delgada a la altura del texto, como la de
// los lentes de CinemaScope. Se enciende donde cruza las letras (8 lecturas, solo cerca de la
// línea) y un barrido la recorre cuando las letras llegan.
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

    // Cara: contorno que se ensancha al apagarse en los créditos finales (en vez de desenfoque)
    float w = kodalith_width + out_phase * horizon_blur;
    float face = outlineAt(tc, w * px * z) * (kodalith_width / w);

    // Estela: pocas copias, una lectura cada una. El desfase cambia cada cuadro (t * 37 avanza
    // ~0.62 por cuadro a 60 fps, un paso que no se repite pronto)
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

    // Halo: alfa promedio en 4 puntos alrededor; 4·m·(1-m) es máximo junto al borde
    float2 go = glow_size * px * z * 0.7071;
    float m = (alphaAt(tc + go) + alphaAt(tc - go)
             + alphaAt(tc + float2(go.x, -go.y)) + alphaAt(tc + float2(-go.x, go.y))) * 0.25;
    float halo = 4.0 * m * (1.0 - m) * glow_strength * (1.0 + out_phase);

    float3 lc = lerp(color_light.rgb, tint, tint_w);
    float v = (face * 1.5 + light + fill * 0.9) * fade;
    // Curva que conserva el tono: lo más brillante llega al color de la luz, no al blanco
    float e = v + halo * fade * 0.5;
    float3 col = lc * saturate((1.0 - exp(-1.2 * e)) / 0.835) + saturate(v - 1.5) * white_core;
    col += anamorphicFlare(uv, vp, ca, sa, z, fade, streak, p, t);
    col *= in_band;
    float3 rgb = bg * in_band + col;
    float alpha = stars ? 1.0 : saturate(max(col.r, max(col.g, col.b)));
    return float4(stars ? rgb : rgb / max(alpha, 0.0001), alpha);
}
