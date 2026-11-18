// Títulos voladores con fuente HUECA: escribe tus créditos con una tipografía de contorno
// (letras huecas, solo la línea de fuera, con el interior transparente), como la de los
// créditos de la película. El shader ya no calcula el borde: la línea de la fuente ES la
// luz Kodalith que pasa por el negativo.
//
// Basada en la versión "región 4" (titulos-voladores-r4.shader):
//   - La cara de la letra es el alfa tal cual: 1 lectura, y la línea conserva el trazo exacto
//     de la fuente (esquinas, contornos dobles, adornos) en vez de una orilla aproximada.
//   - Cada copia de la estela suma directamente su contorno, así que los trazos que corren en
//     la dirección del movimiento dejan líneas brillantes y los atravesados láminas tenues,
//     como con el obturador abierto.
//   - Con la letra oscurecida por la estela, la extrusión se sigue viendo encima: el interior
//     hueco deja ver las líneas de luz que pasan por detrás.
//   - Engrosar el contorno y el desenfoque de los créditos finales usan 4 lecturas extra solo
//     cuando hacen falta. Halo con 4 lecturas.
//
// Mismos efectos, tiempos y nombres de parámetros que las otras versiones, así que
// intro-control.lua funciona igual. Uso: igual que titulos-voladores.shader (en una escena
// anidada). Si le das texto sólido verás solo la silueta rellena: necesita fuente hueca.

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
    string label = "Finales: desenfoque al apagarse (px)";
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

// 0 = el trazo de la fuente tal cual. Súbelo si la fuente es muy delgada.
uniform float line_width<
    string label = "Engrosar el contorno (px)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 6.0; float step = 0.1;
> = 0.0;

uniform float line_brightness<
    string label = "Brillo del contorno";
    string widget_type = "slider";
    float minimum = 0.2; float maximum = 3.0; float step = 0.05;
> = 1.5;

uniform float exposure<
    string label = "Exposicion de la estela";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 20.0; float step = 0.1;
> = 3.0;

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

uniform float4 color_light = {0.35, 0.75, 1.0, 1.0};

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

// Cara de la letra: la fuente ya es el contorno. thick engrosa (máximo de 4 vecinos) y blur
// desenfoca (promedio); con los dos en 0 es una sola lectura.
float faceAt(float2 tc, float2 o, float blur)
{
    float a0 = alphaAt(tc);
    if (o.x <= 0.0 && o.y <= 0.0)
        return a0;
    float a1 = alphaAt(tc + o);
    float a2 = alphaAt(tc - o);
    float a3 = alphaAt(tc + float2(o.x, -o.y));
    float a4 = alphaAt(tc + float2(-o.x, o.y));
    float thick = max(a0, max(max(a1, a2), max(a3, a4)));
    float soft = (a0 + a1 + a2 + a3 + a4) * 0.2;
    return lerp(thick, soft, blur);
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

    // Cara: el trazo de la fuente, engrosado si se pide y desenfocado al apagarse en los
    // créditos finales
    float bw = out_phase * horizon_blur;
    float w = line_width + bw;
    float face = faceAt(tc, w * px * z * 0.7071, (w > 0.0) ? bw / w : 0.0);

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
            light += a * wk;                                   // la copia ya es contorno
            fill = max(fill, a * wk);
            kf += 1.0;
        }
        light = light / nsf * exposure;
        light = 1.6 * (1.0 - exp(-light / 1.6));            // trazos gruesos: sin quemarse
    }

    float op = saturate(streak_opacity);
    float extra = saturate(streak_opacity - 1.0);
    float ramp = saturate(streak * 8.0);
    face *= 1.0 - op * ramp;
    float fill_cover = fill * ramp;
    fill = fill_cover * op * (1.0 + extra);
    bg *= 1.0 - fill_cover * extra;

    // Halo: alfa promedio en 4 puntos alrededor. Con fuente hueca ya es luz cerca de la línea
    // (dentro y fuera de la letra), así que va directo.
    float2 go = glow_size * px * z * 0.7071;
    float m = (alphaAt(tc + go) + alphaAt(tc - go)
             + alphaAt(tc + float2(go.x, -go.y)) + alphaAt(tc + float2(-go.x, go.y))) * 0.25;
    float halo = saturate(2.0 * m) * glow_strength * (1.0 + out_phase);

    float3 lc = lerp(color_light.rgb, tint, tint_w);
    float v = (face * line_brightness + light + fill * 0.9) * fade;
    float3 col = lc * (v + halo * fade * 0.5) + saturate(v - 1.0) * 0.6;
    col *= in_band;
    float3 rgb = bg * in_band + col;
    float alpha = stars ? 1.0 : saturate(max(col.r, max(col.g, col.b)));
    return float4(stars ? rgb : rgb / max(alpha, 0.0001), alpha);
}
