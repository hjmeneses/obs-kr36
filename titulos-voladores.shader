// Títulos voladores: letras de cromo azul que se extruyen como bloques de luz hacia la cámara.
// Estilo créditos de películas de superhéroes de los 70, para OBS Studio (plugin
// obs-shaderfilter, modo "User-defined shader").
//
// Cómo usarlo: pon tu texto (fuente de texto o PNG con transparencia) en una escena aparte,
// por ejemplo "Créditos". Agrega esa escena dentro de tu escena principal y aplica el filtro a
// la escena anidada, no a la fuente de texto: así el efecto tiene todo el lienzo para la
// extrusión y las estrellas.
//
// Tres efectos (selector "Efecto"), Progreso 0 → 100:
//
// Créditos iniciales
//   3–30   Las letras llegan limpias desde el punto de fuga.
//   30–50  Pausa de lectura.
//   50–80  La estela se dispara hacia la cámara y la rebasa (por defecto pasa un poco por
//          encima, como si las letras volaran sobre nosotros).
//   80–97  Las letras siguen a su estela y se van.
//
// Créditos finales
//   3–30   Las letras llegan desde detrás de la cámara con la estela por delante; la estela
//          se corta de golpe al llegar.
//   30–50  Pausa de lectura.
//   50–97  Se alejan limpias; a los 3/4 del camino se desenfocan pasando de azul a naranja y
//          de vuelta a azul, y se apagan sin llegar al punto de fuga.
//
// Escudo
//   3–97   Nace en el centro con estelas hacia el espectador desde el primer instante y avanza
//          hasta llenar el cuadro antes de desvanecerse.
//
// Estilo Kodalith (por defecto): recrea la técnica de R/Greenberg. El contorno de luz azul se
// genera solo a partir de texto sólido, y la estela es la luz que el contorno acumula con el
// obturador abierto.

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

// Qué tan lejos está el horizonte. 40 = ahí el texto mide 1/40 de su tamaño.
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

// Al llegar desde el punto de fuga, desde qué distancia empieza a verse (fracción del horizonte).
uniform float fade_start<
    string label = "Aparicion desde el horizonte (fraccion)";
    string widget_type = "slider";
    float minimum = 0.05; float maximum = 0.95; float step = 0.01;
> = 0.3;

// Créditos finales: hasta qué distancia se aleja antes de apagarse. A los 3/4 del camino
// empieza el desenfoque con el cambio azul → naranja → azul.
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

// Qué tanto se oscurece la cara de la letra detrás de su extrusión. Con letras huecas se
// nota más; con letras sólidas conviene dejarlo bajo.
uniform float face_shadow<
    string label = "Sombra en la cara de la letra";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 0.35;

// Cada letra es un bloque 3D que se extiende desde la letra hacia la cámara, en unidades de
// la distancia a la que el texto se ve a tamaño normal. 1 o más = el bloque rebasa la cámara.
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

// 0 = la extrusión va directo a la cámara; negativo = pasa por arriba; positivo = por abajo.
uniform float pass_dir<
    string label = "Pasa por arriba (-) / abajo (+)";
    string widget_type = "slider";
    float minimum = -1.0; float maximum = 1.0; float step = 0.01;
> = -0.25;

// Giro del texto mientras se extruye. Es proporcional a "Pasa por arriba/abajo", así que
// yendo directo a la cámara no gira.
uniform float roll<
    string label = "Rotacion al pasar arriba/abajo (grados)";
    string widget_type = "slider";
    float minimum = -20.0; float maximum = 20.0; float step = 0.1;
> = 6.0;

uniform float volume_strength<
    string label = "Brillo del volumen";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.8;

// Líneas brillantes en los filos de la extrusión (donde un borde de la letra queda alineado
// con la dirección en que se extruye).
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

// Kodalith: como en la película. Un negativo y un positivo de la letra encimados con un gel azul
// en medio solo dejan pasar luz en el contorno, y con el obturador abierto la luz se acumula
// en la película: los bordes que corren en la dirección del movimiento dan líneas brillantes y
// los atravesados, láminas tenues. Cromo: letra sólida con bisel y volumen translúcido.
uniform int style<
    string label = "Estilo";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Kodalith (contorno de luz, como la pelicula)";
    int    option_1_value = 1;
    string option_1_label = "Cromo solido";
> = 0;

uniform float kodalith_width<
    string label = "Kodalith: grosor del contorno (px)";
    string widget_type = "slider";
    float minimum = 0.5; float maximum = 8.0; float step = 0.1;
> = 2.0;

// Cuánta luz acumula la estela. Las líneas se saturan a casi blanco; las láminas quedan tenues.
uniform float exposure<
    string label = "Kodalith: exposicion de la estela";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 20.0; float step = 0.1;
> = 6.0;

// Qué tanto tapa la estela. De 0 a 1 tapa la letra (en 1 la oculta por completo mientras hay
// estela, así que solo se lee en la pausa, como en la película). De 1 a 2 la estela se vuelve
// más sólida: más brillante y sin dejar ver las estrellas a través.
uniform float streak_opacity<
    string label = "Opacidad de la estela";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 2.0; float step = 0.01;
> = 0.9;

// Cuántas muestras usa la estela. Si OBS dice que el codificador está sobrecargado o se saltan
// cuadros mientras transmites o grabas, bájala: la estela se ve un poco más granulada.
uniform int quality<
    string label = "Calidad (bajala si OBS se sobrecarga)";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Baja (8 muestras, la mas ligera)";
    int    option_1_value = 1;
    string option_1_label = "Media (16 muestras)";
    int    option_2_value = 2;
    string option_2_label = "Alta (32 muestras, la mas pesada)";
> = 1;

uniform bool letterbox<
    string label = "Formato CinemaScope 2.35:1 (franjas negras)";
> = false;

// 1 = cromo azul; 0 = conserva los colores originales del texto.
uniform float chrome_amount<
    string label = "Cromo (0 = colores originales)";
    string widget_type = "slider";
    float minimum = 0.0; float maximum = 1.0; float step = 0.01;
> = 1.0;

uniform float4 color_deep = {0.02, 0.10, 0.45, 1.0};
uniform float4 color_light = {0.25, 0.50, 1.0, 1.0};

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

float ease(float t)
{
    return t * t * (3.0 - 2.0 * t);
}

// 0 cerca, 1 en el horizonte: desvanecido de la llegada desde el punto de fuga
float horizonAt(float z)
{
    return smoothstep(z_far * fade_start, z_far * 0.97, z);
}

// Estado en el instante p. Devuelve:
//   x = distancia z de la letra (1 = tamaño normal; la escala en pantalla es 1/z)
//   y = distancia z del otro extremo de la estela (igual a x = sin estela). Menor que x = la
//       estela va de la letra hacia la cámara; mayor = va de la letra hacia el fondo.
//   z = visibilidad (0..1)
//   w = fase del desenfoque con cambio de color de los créditos finales (0..1)
//
// Las estelas imitan el obturador abierto de la cámara de animación: un extremo queda donde
// estaba la letra al abrir el obturador y el otro donde está ahora.

float follow_seconds()
{
    return (follow_delay == 0) ? 0.5 : ((follow_delay == 2) ? 2.0 : 1.0);
}

// Créditos iniciales: llega limpio desde el punto de fuga, pausa de lectura, y la estela se
// dispara hacia la cámara (rebasándola); al final la letra la sigue.
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

// Créditos finales: llega desde detrás de la cámara con la estela por delante (hacia su
// destino), la estela se corta de golpe al llegar, pausa, se aleja limpio y a los 3/4 del
// camino se desenfoca pasando de azul a naranja y de vuelta a azul antes de apagarse.
float4 stateClosing(float p)
{
    if (p < 0.30) {
        float u = seg(p, 0.03, 0.30);
        float z = lerp(0.02, 1.0, 1.0 - (1.0 - u) * (1.0 - u));   // llega y frena
        return float4(z, 1.0, smoothstep(0.0, 0.1, u), 0.0);
    }
    if (p < 0.50)
        return float4(1.0, 1.0, 1.0, 0.0);                         // pausa de lectura
    float u = seg(p, 0.50, 0.97);
    float z = lerp(1.0, fade_dist, u);
    float ph = seg(u, 0.75, 1.0);
    return float4(z, z, 1.0 - smoothstep(0.7, 1.0, ph), ph);
}

// Escudo: nace en el centro con estelas hacia el espectador desde el primer instante y avanza
// hasta llenar el cuadro antes de desvanecerse.
float4 stateEmblem(float p)
{
    float u = seg(p, 0.03, 0.97);
    float z = z_far * exp2(u * log2(0.5 / z_far));     // velocidad pareja en perspectiva
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

// Contorno de la letra, como el sándwich Kodalith: 1 en el borde, 0 dentro y fuera.
// o = medio ancho del contorno en uv (x e y por separado por la proporción de la pantalla).
float2 outlineAt(float2 tc, float2 o)
{
    float ac = alphaAt(tc - o);
    float gx = alphaAt(tc + float2(o.x, -o.y)) - ac;
    float gy = alphaAt(tc + float2(-o.x, o.y)) - ac;
    return float2(saturate(abs(gx) + abs(gy)), ac);
}

// Texto desenfocado en un disco de radio r (en pixeles de pantalla) a escala s.
// Devuelve color premultiplicado por alfa, para que los bordes transparentes no ensucien.
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
// Halo: alfa promedio en 8 puntos sobre dos anillos (a media distancia y a la distancia
// completa). El patrón gira al azar por pixel y por cuadro: así las copias desplazadas de la
// letra no forman bordes dobles en las esquinas y el resplandor queda redondo.
float haloAt(float2 tc, float2 r, float jit)
{
    float m = 0.0;
    float a0 = jit * 1.5707963;
    float fi = 0.0;
    for (int i = 0; i < 8; i++) {
        float a = a0 + fi * 0.7853982;
        float rr = (i == 0 || i == 2 || i == 4 || i == 6) ? 0.5 : 1.0;
        m += alphaAt(tc + float2(cos(a), sin(a)) * r * rr);
        fi += 1.0;
    }
    return m * 0.125;
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
    // Qué tan larga es la estela (0 = sin estela, 1 = muy larga), medida en perspectiva
    float streak = saturate(abs(log2(z_other / z)) * 0.5);
    // Giro del texto al extruirse, solo si la extrusión se desvía arriba/abajo. Se rota en
    // pixeles para no deformar con la proporción de la pantalla.
    float ang = radians(roll) * pass_dir * streak;
    float ca = cos(ang);
    float sa = sin(ang);
    float2 rp = (uv - vp) * uv_size;
    float2 rel = float2(ca * rp.x + sa * rp.y, -sa * rp.x + ca * rp.y) / uv_size;

    float2 tc = vp + rel * z;
    float4 src = textBlur(tc, out_phase * horizon_blur, s);
    float a = src.a;
    if (src.a > 0.0001)
        src.rgb /= src.a;    // de premultiplicado a color normal

    // Estela: la letra está en z y la estela llega hasta z_other (hacia la cámara si es menor,
    // hacia el fondo si es mayor). Cada muestra es una copia de la letra a la profundidad zk,
    // desplazada en vertical según "Pasa por arriba/abajo". Para la copia a distancia d de la
    // letra, el punto de pantalla q viene de q = (X + desvío·d) / zk, así que
    // X = q·zk - desvío·d. Las profundidades van en progresión geométrica (pasos parejos en
    // perspectiva) con un desfase aleatorio por pixel, que cambia el bandeo de copias por un
    // grano fino parecido al slit-scan de la película.
    float dy = pass_dir * 0.6;
    float ratio = z_other / z;
    float jit = hash12(floor(uv * uv_size));
    int ns = (quality == 0) ? 8 : ((quality == 2) ? 32 : 16);
    float nsf = (float)ns;
    bool has_streak = abs(ratio - 1.0) >= 0.001;

    // Franjas negras de CinemaScope: fuera de la banda central de 2.35:1 no hay imagen
    float band_half = uv_size.x / 2.35 * 0.5;
    float in_band = letterbox ? step(abs(uv.y - 0.5) * uv_size.y, band_half) : 1.0;

    // Salida de los créditos finales: del azul pasa a naranja y vuelve a un azul difuso
    float tint_w = smoothstep(0.0, 0.3, out_phase);
    float3 tint = lerp(color_warm.rgb, color_cool.rgb, smoothstep(0.4, 0.8, out_phase));

    float3 bg = stars ? starfield(uv, vp, t) : float3(0.0, 0.0, 0.0);

    if (fade <= 0.001) {
        float3 e0 = bg * in_band;
        return stars ? float4(e0, 1.0) : float4(0.0, 0.0, 0.0, 0.0);
    }

    if (style == 0) {
        // Kodalith: todo es luz que se suma sobre el negro, como en la copiadora óptica.
        // El desenfoque ensancha el contorno y reparte la misma luz en más ancho.
        float w = kodalith_width + out_phase * horizon_blur;
        float face = outlineAt(tc, w * px * z).x * (kodalith_width / w);

        // Estela: luz acumulada del contorno en cada instante de la exposición, más un relleno
        // (la letra completa barrida) que la vuelve opaca
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
        // La estela tapa la letra en proporción a su largo: solo se lee nítida en la pausa
        float op = saturate(streak_opacity);
        float extra = saturate(streak_opacity - 1.0);
        float ramp = saturate(streak * 8.0);
        face *= 1.0 - op * ramp;
        float fill_cover = fill * ramp;
        fill = fill_cover * op * (1.0 + extra);
        bg *= 1.0 - fill_cover * extra;

        // Halo junto a los bordes, por dentro y por fuera (4·m·(1-m) es máximo en el borde)
        float m = haloAt(tc, glow_size * px * z, frac(hash12(floor(uv * uv_size) + 7.3) + frac(t * 23.0)));
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

    // Cromo sólido: las aristas del bloque convergen en (0, -dy) respecto al punto de fuga
    float2 rd = normalize((rel + float2(0.0, dy)) * uv_size + float2(0.0001, 0.0));
    float2 tp = float2(-rd.y, rd.x) * line_width * px;    // perpendicular a la arista, en uv

    float vol = 0.0;
    float edges = 0.0;
    float fi = 0.0;
    for (int i = 0; i < 32; i++) {
        if (i >= ns) break;
        float k = (fi + jit) / nsf;                       // 0 = letra, 1 = otro extremo
        float zk = z * exp2(k * log2(ratio));              // ratio^k (ratio siempre > 0)
        float2 tck = vp + rel * zk - float2(0.0, dy * (z - zk));
        // Más claro junto a la letra, más tenue hacia el otro extremo
        vol = max(vol, alphaAt(tck) * lerp(1.0, 0.6, k));
        // Filo: un borde de la letra alineado con la arista se cruza en todas las muestras y
        // suma una línea brillante; un borde atravesado solo suma una muestra
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
    // Si la estela va hacia la cámara, queda entre la letra y el espectador: la letra se
    // oscurece detrás de ella
    bool streak_in_front = z_other < z;
    if (streak_in_front)
        textCol *= 1.0 - face_shadow * streak;

    textCol = lerp(textCol, tint * (0.7 + 0.5 * L), tint_w);
    float3 glowCol = lerp(color_light.rgb, tint, tint_w);

    // Resplandor: alfa promediado en un anillo alrededor del pixel
    float glow = haloAt(tc, glow_size * px * z, frac(hash12(floor(uv * uv_size) + 7.3) + frac(t * 23.0))) * 8.0;
    // El halo crece al desenfocarse, como la luz dispersa a lo lejos
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
        // La estela está entre la letra y la cámara: va encima de la cara, más tenue sobre
        // ella para que la letra se siga leyendo
        acc = over(acc, textCol, a * fade);
        acc = over(acc, volCol, saturate(volume * lerp(lerp(0.85, 1.0, saturate(streak_opacity)), saturate(streak_opacity), a)));
        acc = over(acc, lineCol, lines);
    } else {
        // La estela va detrás de la letra (créditos finales al llegar): la letra la tapa
        acc = over(acc, volCol, volume * 0.85 * (1.0 - a));
        acc = over(acc, lineCol, lines * (1.0 - a));
        acc = over(acc, textCol, a * fade);
    }

    float3 fl = anamorphicFlare(uv, vp, ca, sa, z, fade, streak, p, t) * in_band;
    acc = float4(acc.rgb + fl, saturate(acc.a + max(fl.r, max(fl.g, fl.b)) * (1.0 - acc.a)));
    return float4(acc.rgb / max(acc.a, 0.0001), acc.a);
}
