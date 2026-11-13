// Títulos voladores: letras de cromo azul que llegan desde el fondo del espacio dejando
// estelas de luz, se detienen frente a la cámara y salen volando hacia ella. Estilo créditos
// de películas de superhéroes de los 70, para OBS Studio (plugin obs-shaderfilter, modo
// "User-defined shader").
//
// Cómo usarlo: pon tu texto (fuente de texto o PNG con transparencia) en una escena aparte,
// por ejemplo "Créditos". Agrega esa escena dentro de tu escena principal y aplica el filtro a
// la escena anidada, no a la fuente de texto: así el efecto tiene todo el lienzo para las
// estelas y las estrellas. El texto vuela hacia/desde el "Punto de fuga".
//
// Secuencia (Progreso 0 → 100):
//   0–35   El texto llega desde lejos con estelas.
//   35–75  Se queda frente a la cámara, acercándose muy despacio, con un brillo que lo cruza.
//   75–100 Sale volando hacia la cámara (o se desvanece en su lugar).

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

// Qué tan lejos arranca el texto. 40 = empieza a 1/40 de su tamaño.
uniform float z_far<
    string label = "Distancia inicial";
    string widget_type = "slider";
    float minimum = 3.0; float maximum = 100.0; float step = 1.0;
> = 40.0;

uniform bool fly_out<
    string label = "Salir volando hacia la camara (si no, se desvanece)";
> = true;

// Cada letra es un bloque 3D que se extiende hacia el punto de fuga. 0 = letra plana;
// 0.9 = la extrusión llega casi hasta el punto de fuga, como en los créditos de la película.
uniform float extrude<
    string label = "Profundidad de la extrusion";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 0.98; float step = 0.01;
> = 0.9;

// Mientras el texto se mueve, la extrusión se alarga con el rastro de dónde estuvo.
uniform float trail_length<
    string label = "Estela extra en movimiento";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 0.3; float step = 0.005;
> = 0.08;

uniform float volume_strength<
    string label = "Brillo del volumen";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.8;

// Líneas brillantes en los filos de la extrusión (donde un borde de la letra apunta al
// punto de fuga).
uniform float line_strength<
    string label = "Brillo de los filos";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 4.0; float step = 0.01;
> = 1.6;

uniform float line_width<
    string label = "Grosor de los filos (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 6.0; float step = 0.1;
> = 1.5;

// 1 = cromo azul; 0 = conserva los colores originales del texto.
uniform float chrome_amount<
    string label = "Cromo (0 = colores originales)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 1.0;

uniform float4 color_deep = {0.02, 0.10, 0.45, 1.0};
uniform float4 color_light = {0.35, 0.75, 1.0, 1.0};

uniform float bevel<
    string label = "Bisel del cromo (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 12.0; float step = 0.5;
> = 3.0;

uniform float sheen<
    string label = "Brillo que cruza el texto";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 0.45;

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

float ease(float t)
{
    return t * t * (3.0 - 2.0 * t);
}

// Escala del texto en el instante p. La distancia z cambia en línea recta y la escala es 1/z,
// como en una perspectiva real: de lejos casi no crece y al final se acerca de golpe.
float scaleAt(float p)
{
    float u = seg(p, 0.0, 0.35);
    float z = lerp(z_far, 1.0, 1.0 - (1.0 - u) * (1.0 - u));     // frena al llegar
    float s = 1.0 / z;
    if (p > 0.35)
        s = 1.0 + 0.04 * seg(p, 0.35, 0.75);
    if (fly_out && p > 0.75) {
        float o = seg(p, 0.75, 1.0);
        s = 1.0 / lerp(1.0 / 1.04, 0.02, o * o);                  // acelera hacia la cámara
    }
    return s;
}

float fadeAt(float p)
{
    float f = smoothstep(0.0, 0.03, p);
    if (fly_out)
        f *= 1.0 - smoothstep(0.85, 0.97, p);
    else
        f *= 1.0 - smoothstep(0.80, 0.97, p);
    return f;
}

float4 textAt(float2 tc)
{
    float inb = step(0.0, tc.x) * step(tc.x, 1.0) * step(0.0, tc.y) * step(tc.y, 1.0);
    return image.Sample(textureSampler, tc) * inb;
}

float alphaAt(float2 tc)
{
    return textAt(tc).a;
}

// Campo de estrellas en 4 capas que se acercan sin parar; cada capa aparece, se abre hacia
// afuera desde el punto de fuga y se desvanece, así el movimiento nunca "salta".
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
        float px = (1.0 + 2.5 * h * h) * lerp(0.6, 1.6, z);         // tamaño en pixeles
        float size = px * sc * star_density / H;                     // en unidades de celda
        float d = length(f - off * 0.7);
        float on = step(0.72, h);
        float life = smoothstep(0.0, 0.2, z) * (1.0 - smoothstep(0.8, 1.0, z));
        float tw = 0.65 + 0.35 * sin(t * 3.0 + h * 60.0);
        col += (1.0 - smoothstep(0.0, size, d)) * on * life * tw * float3(0.8, 0.9, 1.0);
        lf += 1.0;
    }
    return col;
}

// Capa encima, con alfa premultiplicado
float4 over(float4 dst, float3 c, float a)
{
    return float4(c * a + dst.rgb * (1.0 - a), a + dst.a * (1.0 - a));
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    float t = elapsed_time;
    float2 vp = float2(vp_x, vp_y) * 0.01;
    float2 px = uv_pixel_interval;

    float p = auto_play ? frac(t / max(duration, 0.5)) : saturate(progress * 0.01);
    float s = scaleAt(p);
    float fade = fadeAt(p);
    float2 tc = vp + (uv - vp) / s;
    float4 src = textAt(tc);
    float a = src.a;

    // Extrusión: la letra repetida a escalas cada vez menores hacia el punto de fuga forma un
    // bloque 3D. Las escalas se reparten en progresión geométrica (pasos parejos en
    // perspectiva) y con un desfase aleatorio por pixel, que cambia el bandeo de copias por
    // un grano fino parecido al slit-scan de la película.
    float s_min = min(s * (1.0 - extrude), scaleAt(max(p - trail_length, 0.0)));
    float ratio = clamp(s_min / s, 0.02, 1.0);
    float2 rd = normalize((uv - vp) * uv_size + float2(0.0001, 0.0));
    float2 tp = float2(-rd.y, rd.x) * line_width * px;    // perpendicular al rayo, en uv
    float jit = hash12(floor(uv * uv_size));

    float vol = 0.0;
    float edges = 0.0;
    float fi = 0.0;
    for (int i = 0; i < 40; i++) {
        float k = (fi + jit) / 40.0;                       // 0 = cara frontal, 1 = fondo
        float sk = s * pow(ratio, k);
        float2 tck = vp + (uv - vp) / sk;
        // Más claro hacia el fondo: la luz parece salir del punto de fuga
        vol = max(vol, alphaAt(tck) * lerp(0.55, 1.0, k));
        // Filo: un borde de la letra paralelo al rayo se cruza en todas las muestras y suma
        // una línea brillante; un borde atravesado solo suma una muestra
        float2 off = tp / sk;
        edges += abs(alphaAt(tck + off) - alphaAt(tck - off));
        fi += 1.0;
    }
    if (ratio > 0.999) {
        vol = 0.0;
        edges = 0.0;
    }
    float volume = saturate(vol * volume_strength) * fade;
    float lines = saturate(edges / 40.0 * 3.0 * line_strength) * fade;

    // Cromo: el bisel compara el alfa arriba/abajo e izquierda/derecha (en pixeles de pantalla)
    float2 o = bevel * px / s;
    float top = alphaAt(tc + float2(0.0, o.y)) - alphaAt(tc - float2(0.0, o.y));
    float left = alphaAt(tc + float2(o.x, 0.0)) - alphaAt(tc - float2(o.x, 0.0));
    // Cara frontal más oscura que la extrusión, como en la película; el filo superior brilla
    float L = saturate(0.3 + 0.6 * top + 0.2 * left);
    float3 chrome = lerp(color_deep.rgb, color_light.rgb, L);
    chrome += pow(saturate(top), 3.0) * 0.8;
    float band = uv.x + uv.y * 0.5 - (frac(t * 0.15) * 2.5 - 0.5);
    chrome += exp(-band * band * 60.0) * sheen;
    float3 textCol = lerp(src.rgb, chrome, chrome_amount);

    // Resplandor: alfa promediado en un anillo alrededor del pixel
    float glow = 0.0;
    float gi = 0.0;
    for (int j = 0; j < 12; j++) {
        float ang = gi * 0.5235988;
        float2 go = float2(cos(ang), sin(ang)) * glow_size * px;
        glow += alphaAt(vp + (uv + go - vp) / s);
        gi += 1.0;
    }
    glow = glow / 12.0 * glow_strength * fade;

    float4 acc = stars ? float4(starfield(uv, vp, t), 1.0) : float4(0.0, 0.0, 0.0, 0.0);
    acc = over(acc, color_light.rgb, saturate(glow) * (1.0 - a));
    acc = over(acc, color_light.rgb * lerp(0.7, 1.1, vol), volume * 0.85 * (1.0 - a));
    acc = over(acc, lerp(color_light.rgb, float3(1.0, 1.0, 1.0), 0.55), lines * (1.0 - a));
    acc = over(acc, textCol, a * fade);

    return float4(acc.rgb / max(acc.a, 0.0001), acc.a);
}
