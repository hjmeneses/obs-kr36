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
| 30–50 % | Pausa de lectura |
| 50–80 % | La estela se dispara hacia la cámara y la rebasa (por defecto pasa un poco por encima) |
| 80–97 % | Las letras siguen a su estela y se van |

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
| Formato CinemaScope 2.35:1 | Franjas negras arriba y abajo |
| Distancia del horizonte / Aparición desde el horizonte | Desde qué tan lejos llegan las letras (iniciales y escudo) y desde qué distancia empiezan a verse |
| Largo de la extrusión hacia la cámara | Qué tan larga es la estela (0 = sin estela; 1 o más = rebasa la cámara) |
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
| Fondo de estrellas | Apagado = fondo transparente, para ponerlo encima de otra cosa |
| Densidad / Velocidad de las estrellas | Cuántas estrellas hay y qué tan rápido se acercan |

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
| 30–50 % | Reading pause | Reading pause |
| 50–80 % | The streak shoots toward the camera and passes it (slightly above by default) | They recede clean… |
| 80–97 % | The letters follow their streak and leave | …and three quarters of the way they blur from blue to orange and back to blue, going out before the vanishing point |

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
| Extrusion length toward camera | Streak length (0 = none; 1 or more = passes the camera) |
| Pass above (−) / below (+) | 0 = straight at the camera; negative passes above, positive below |
| Roll when passing above/below | How much the text rolls with the streak; proportional to the bend, so none when going straight |
| Closing: fade-out distance / blur | How far the letters recede and how much they blur |
| color_warm / color_cool | The orange and diffuse blue of the closing-credits fade |
| Volume brightness / Edge brightness / Letter face shadow / Chrome / Bevel / Sheen | Solid chrome style only |
| Starfield background | Off = transparent background, to overlay on something else |

### Hotkey (script)

`en/intro-control.lua` turns the filter loop off and moves Progress from 0 to 100 over the filter duration.

1. **Tools → Scripts → +** and pick `en/intro-control.lua`.
2. Choose your filter under **Titles filter** (if it is missing, **Refresh list**).
3. Press **Play**, or bind **Play intro (obs-kr36)** under **Settings → Hotkeys**.

Not affiliated with or endorsed by any film studio or comic publisher.

## License

MIT
