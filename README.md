# obs-kr36

*Chrome titles with open-shutter light streaks toward the camera, for OBS.*

Shader para **OBS Studio** inspirado en los créditos de las películas de superhéroes de finales de los 70: letras de cromo azul que dejan estelas de luz hacia la cámara, como una cámara de animación con el obturador abierto, sobre un campo de estrellas en movimiento.

*[English below](#english)*

## Requisitos

- OBS Studio
- Plugin [obs-shaderfilter](https://github.com/exeldro/obs-shaderfilter)

## Instalación

1. Crea una escena aparte, por ejemplo "Créditos", con tu texto (fuente de texto o PNG con transparencia). Letras gruesas y en mayúsculas se ven mejor.
2. Agrega la escena "Créditos" dentro de tu escena principal.
3. Clic derecho sobre la escena anidada → **Filtros** → **+** → **User-defined shader**.
4. Activa **Load shader text from file** y elige `titulos-voladores.shader`.

**Por qué en una escena anidada y no directo en el texto:** el filtro solo dibuja dentro del área de la fuente donde se aplica. Si lo pones en la fuente de texto, la extrusión y las estrellas se cortan en la caja del texto.

Para varios créditos seguidos, haz una escena por crédito o cambia el texto entre reproducciones.

La versión en inglés está en la carpeta `en/` (`flying-titles.shader` y su `intro-control.lua`). Tiene el mismo código y los mismos nombres de parámetros, así que puedes cambiar de idioma sin perder tus ajustes.

## Efectos

Se eligen en el selector **Efecto**. Los porcentajes son del slider *Progreso*.

**Créditos iniciales**

| Progreso | Qué pasa |
|---|---|
| 3–30 % | Las letras llegan limpias desde el punto de fuga, sin estela |
| 30 % – … | Pausa de lectura |
| … – 80 % | La estela se dispara hacia la cámara y la rebasa (por defecto pasa un poco por encima). Dura lo que digas en *Tiempo antes de que las letras sigan a la extrusión*: medio segundo, 1 o 2 segundos |
| 80–97 % | Justo cuando la estela llega a su máximo, las letras salen tras ella, ya en movimiento y sin pausa |

La salida de las letras siempre empieza en el 80 %. Si acortas el tiempo de la extrusión, la pausa de lectura dura más; si quieres que toda la secuencia sea más corta, baja también la *Duración*.

**Créditos finales**

| Progreso | Qué pasa |
|---|---|
| 3–30 % | Las letras llegan desde detrás de la cámara con la estela por delante; la estela se corta de golpe al llegar |
| 30–50 % | Pausa de lectura |
| 50–97 % | Se alejan limpias; a los 3/4 del camino se desenfocan pasando de azul a naranja y de vuelta a azul, y se apagan sin llegar al punto de fuga |

**Escudo**

| Progreso | Qué pasa |
|---|---|
| 3–97 % | Nace en el centro con estelas hacia el espectador desde el primer instante y avanza hasta llenar el cuadro antes de desvanecerse |

## Estilos

| Estilo | Cómo se ve |
|---|---|
| **Kodalith** (por defecto) | Como en la película. R/Greenberg encimaba un negativo y un positivo Kodalith de la letra con un gel azul en medio, así que solo pasaba luz por el **contorno**. Con el obturador abierto, esa luz se acumulaba: los bordes que corren en la dirección del movimiento dejan líneas brillantes y los atravesados, láminas tenues. El shader genera el contorno solo a partir de texto sólido. |
| **Cromo sólido** | Letra rellena con bisel de cromo y un volumen translúcido detrás. |

Activa **Formato CinemaScope 2.35:1** para las franjas negras: los títulos originales eran anamórficos.

## Parámetros

| Parámetro | Efecto |
|---|---|
| Reproducir en bucle / Duración / Progreso | Bucle automático, o control manual de la secuencia |
| Punto de fuga X/Y | Hacia dónde llegan y se alejan las letras |
| Efecto | Créditos iniciales, créditos finales o escudo |
| Estilo | Kodalith (contorno de luz) o cromo sólido |
| Kodalith: grosor del contorno / exposición de la estela | Ancho de la línea de luz y cuánta luz acumula la estela |
| Opacidad de la estela | 0–1: qué tanto tapa la estela al texto (1 = solo se lee en la pausa, como en la película). 1–2: la estela se vuelve más sólida y tapa las estrellas |
| Calidad | Muestras de la estela: Baja (8), Media (16, por defecto) o Alta (32). Bájala si OBS dice que el codificador está sobrecargado |
| Formato CinemaScope 2.35:1 | Franjas negras arriba y abajo |
| Distancia del horizonte / Aparición desde el horizonte | Desde qué tan lejos llegan las letras (iniciales y escudo) y desde qué distancia empiezan a verse |
| Largo de la extrusión hacia la cámara | Qué tan larga es la estela (0 = sin estela; 1 o más = rebasa la cámara) |
| Tiempo antes de que las letras sigan a la extrusión | Créditos iniciales: cuánto dura la extrusión antes de que salgan las letras (medio segundo, 1 segundo o 2 segundos) |
| Pasa por arriba (−) / abajo (+) | 0 = la estela va directo a la cámara; negativo pasa por encima, positivo por debajo |
| Rotación al pasar arriba/abajo | Cuánto gira el texto con la estela; es proporcional al desvío, así que yendo directo a la cámara no gira |
| Brillo del volumen | Cromo: qué tan luminoso es el volumen translúcido de la estela |
| Brillo / Grosor de los filos | Cromo: las líneas brillantes donde un borde de la letra queda alineado con la estela |
| Sombra en la cara de la letra | Cromo: cuánto se oscurece la letra detrás de su estela |
| Finales: distancia / desenfoque al apagarse | Hasta dónde se alejan las letras y cuánto se desenfocan |
| color_warm / color_cool | El naranja y el azul difuso por los que pasan al apagarse en los créditos finales |
| Cromo | 1 = cromo azul; 0 = conserva los colores del texto |
| color_deep / color_light | Los dos tonos del cromo, también usados en la extrusión y el resplandor |
| Bisel del cromo | Grosor del filo iluminado de las letras |
| Brillo que cruza el texto | Destello diagonal que recorre las letras |
| Resplandor | Halo alrededor del texto |
| Quemado a blanco de la estela / `streak_color` | La estela tira a cian (`streak_color`) y donde se juntan muchas líneas se quema casi a blanco, como en los títulos originales. La cara de la letra se queda azul. 0 = sin quemado |
| Destello anamórfico | **Opcional** (apagado por defecto). Una línea horizontal delgada, como la de los lentes de CinemaScope: se enciende donde cruza las letras y la recorre un barrido cuando llegan. Se ajusta con *intensidad*, *altura*, *largo*, *grosor* y `flare_color`. Combina con el formato 2.35:1 |
| Fondo de estrellas | Apagado = fondo transparente, para ponerlo encima de otra cosa |
| Densidad / Velocidad de las estrellas | Cuántas estrellas hay y qué tan rápido se acercan |

## Versión "región 4" (tarjetas modestas)

`titulos-voladores-r4.shader` es una versión ligera para GPUs como la GTX 1650 Ti, sobre todo si la misma tarjeta codifica con NVENC. Usa ~25 lecturas de textura por pixel en vez de ~210:

- Solo estilo Kodalith, sin cromo.
- La estela usa 6, 8 u 12 copias (selector **Copias de la estela**) con una lectura cada una.
- El grano de la estela cambia en cada cuadro, como grano de película, para que pocas copias se vean como muchas.
- En los créditos finales el contorno se ensancha en vez de desenfocarse.

Tiene los mismos efectos, tiempos y nombres de parámetros, así que puedes cambiar entre las dos versiones sin perder ajustes. `intro-control.lua` también la reconoce. Para aligerarla más, pon antes del shader un filtro **Escalado/Relación de aspecto** a 960×540 en la escena anidada.

## Versión con fuente hueca

`titulos-voladores-hueca.shader` es para escribir los créditos con una **tipografía hueca** (de contorno): solo la línea de fuera, con el interior transparente, como la de los créditos de la película. Pensada para **CC Up Up And Away Inline** (Comicraft), cuyos trazos gruesos con un canal hueco dejan dos líneas de luz por trazo; también sirven *Helvetica Neue Bold Outline*, *Stark Hollow* o cualquier fuente "Outline". La fuente no viene incluida.

- El shader ya no calcula el borde: la línea de la fuente es la luz Kodalith. Conserva el trazo exacto de la tipografía, con sus esquinas, contornos dobles y adornos.
- Cada trazo deja su propia línea de luz en la estela. Cuando la letra se oscurece detrás de la estela, la extrusión se sigue viendo encima, porque el interior hueco deja pasar la luz.
- La estela suaviza las altas luces para que los trazos gruesos no se quemen a blanco (exposición por defecto 3).
- Es la más ligera: ~17 lecturas por pixel con 8 copias (1 de la letra, 8 de la estela y 8 del halo).
- En vez de *Grosor del contorno* tiene **Engrosar el contorno** (0 = el trazo de la fuente tal cual; súbelo si la fuente es muy delgada) y **Brillo del contorno**. En los créditos finales la letra sí se desenfoca al apagarse.

Si le das texto sólido verás solo la silueta rellena: para texto sólido usa la región 4. Tiene los mismos efectos, tiempos y nombres de parámetros, y `intro-control.lua` también la reconoce.

## Disparar la secuencia con un hotkey (script)

`intro-control.lua` apaga el bucle y mueve el Progreso de 0 a 100 en la duración del filtro.

1. **Herramientas → Scripts → +** y elige `intro-control.lua`.
2. En **Filtro de títulos** elige tu filtro (si no aparece, **Actualizar lista**).
3. Presiona **Reproducir**, o asigna un atajo en **Configuración → Atajos de teclado → Reproducir intro (obs-kr36)**.

---

## English

Shader for **OBS Studio** inspired by late-70s superhero movie credits: blue letters leave open-shutter light streaks toward the camera, over a moving starfield. The English files are in `en/`: `flying-titles.shader` and its `intro-control.lua`. They share the code and parameter names with the Spanish files, so you can switch languages without losing your settings.

### Requirements

- OBS Studio
- [obs-shaderfilter](https://github.com/exeldro/obs-shaderfilter) plugin

### Setup

1. Make a separate scene, for example "Credits", with your text (text source or PNG with transparency). Bold capitals look best.
2. Add the "Credits" scene inside your main scene.
3. Right-click the nested scene → **Filters** → **+** → **User-defined shader**.
4. Enable **Load shader text from file** and pick `en/flying-titles.shader`.

**Why a nested scene and not the text itself:** the filter only draws inside the area of the source it is applied to. On the text source, the streaks and stars get clipped to the text box.

### Effects

Pick one in the **Effect** select. Percentages refer to the *Progress* slider.

| Progress | Opening credits | Closing credits |
|---|---|---|
| 3–30 % | Letters arrive clean from the vanishing point | Letters arrive from behind the camera with the streak ahead of them; it cuts off on arrival |
| 30–50 % | Reading pause (until 80 % minus the extrusion time) | Reading pause |
| 50–80 % | The streak shoots toward the camera and passes it (slightly above by default). It lasts half a second, 1 or 2 seconds (*Time before letters follow the extrusion*) | They recede clean… |
| 80–97 % | Right as the streak peaks, the letters leave after it, already moving, with no pause | …and three quarters of the way they blur from blue to orange and back to blue, going out before the vanishing point |

**Emblem:** born at the center with streaks toward the viewer from the first frame, it advances until it fills the frame, then fades out.

### Styles

| Style | Look |
|---|---|
| **Kodalith** (default) | As in the film. R/Greenberg stacked a Kodalith negative and positive of the letter with a blue gel in between, so light only came through the **outline**. With the shutter open that light built up: edges running along the motion leave bright lines and crossing edges faint sheets. The shader builds the outline from solid text. |
| **Solid chrome** | Filled letter with a chrome bevel and a translucent volume. |

Enable **CinemaScope 2.35:1** for black bars: the original titles were anamorphic.

### Main parameters

| Parameter | Effect |
|---|---|
| Loop playback / Sequence duration / Progress | Automatic loop, or manual control of the sequence |
| Vanishing point X/Y | Where the letters arrive from and recede to |
| Kodalith: outline width / streak exposure | Width of the light line and how much light the streak builds up |
| Streak opacity | 0–1: how much the streak covers the text (1 = it only reads during the pause, as in the film). 1–2: the streak gets more solid and hides the stars |
| Quality | Streak samples: Low (8), Medium (16, default) or High (32). Lower it if OBS says the encoder is overloaded |
| Extrusion length toward camera | Streak length (0 = none; 1 or more = passes the camera) |
| Time before letters follow the extrusion | Opening credits: how long the extrusion runs before the letters leave (half a second, 1 or 2 seconds). Letters always leave at 80 %, so a shorter extrusion means a longer reading pause; lower *Sequence duration* to shorten the whole thing |
| Pass above (−) / below (+) | 0 = straight at the camera; negative passes above, positive below |
| Roll when passing above/below | How much the text rolls with the streak; proportional to the bend, so none when going straight |
| Closing: fade-out distance / blur | How far the letters recede and how much they blur |
| color_warm / color_cool | The orange and diffuse blue of the closing-credits fade |
| Volume brightness / Edge brightness / Letter face shadow / Chrome / Bevel / Sheen | Solid chrome style only |
| Streak burn to white / `streak_color` | The streak leans cyan (`streak_color`) and where many lines pile up it burns nearly to white, as in the original titles. The letter face stays blue. 0 = no burn |
| Anamorphic flare | **Optional** (off by default). A thin horizontal line like a CinemaScope lens flare: it lights up where it crosses the letters and a sweep runs along it as they arrive. Tune with *strength*, *height*, *length*, *thickness* and `flare_color` |
| Starfield background | Off = transparent background, to overlay on something else |

### "Region 4" version (modest cards)

`en/flying-titles-r4.shader` is a light version for GPUs such as the GTX 1650 Ti, especially when the same card encodes with NVENC. It uses ~25 texture reads per pixel instead of ~210: Kodalith only, 6/8/12 streak copies (**Streak copies** select) with one read each, grain that changes every frame like film grain, and a widening outline instead of a blur on the closing credits. Same effects, timings and parameter names, and `intro-control.lua` recognizes it. To lighten it further, add a **Scaling/Aspect Ratio** filter at 960×540 before the shader on the nested scene.

### Hollow-font version

`en/flying-titles-hollow.shader` is for credits written in a **hollow (outline) typeface**: only the outer line, transparent inside, like the film credits. Made for **CC Up Up And Away Inline** (Comicraft), whose thick strokes with a hollow channel leave two light lines per stroke; *Helvetica Neue Bold Outline*, *Stark Hollow* or any "Outline" font also work. The font is not included. The shader no longer computes the edge: the font's line is the Kodalith light, keeping the exact stroke. Every stroke leaves its own light line in the streak, and when the letter darkens behind the streak, the extrusion still shows through the hollow inside. It is the lightest version, ~17 reads per pixel with 8 copies. *Outline width* is replaced by **Thicken outline** (0 = the font's stroke as is) and **Outline brightness**, and the closing credits get a real blur. Solid text only shows a filled silhouette, so use the region-4 version for solid text. Same effects, timings and parameter names, and `intro-control.lua` recognizes it.

### Hotkey (script)

`en/intro-control.lua` turns the filter loop off and moves Progress from 0 to 100 over the filter duration.

1. **Tools → Scripts → +** and pick `en/intro-control.lua`.
2. Choose your filter under **Titles filter** (if it is missing, **Refresh list**).
3. Press **Play**, or bind **Play intro (obs-kr36)** under **Settings → Hotkeys**.

Not affiliated with or endorsed by any film studio or comic publisher.

## License

MIT
