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

**Tip:** las letras de la película son un contorno delgado. Para lograrlo, en la fuente de texto de OBS activa el contorno y deja el relleno transparente: la estela saldrá del contorno, como en el original.

## Parámetros

| Parámetro | Efecto |
|---|---|
| Reproducir en bucle / Duración / Progreso | Bucle automático, o control manual de la secuencia |
| Punto de fuga X/Y | Hacia dónde llegan y se alejan las letras |
| Efecto | Créditos iniciales, créditos finales o escudo |
| Distancia del horizonte / Aparición desde el horizonte | Desde qué tan lejos llegan las letras (iniciales y escudo) y desde qué distancia empiezan a verse |
| Largo de la extrusión hacia la cámara | Qué tan larga es la estela (0 = sin estela; 1 o más = rebasa la cámara) |
| Pasa por arriba (−) / abajo (+) | 0 = la estela va directo a la cámara; negativo pasa por encima, positivo por debajo |
| Rotación al pasar arriba/abajo | Cuánto gira el texto con la estela; es proporcional al desvío, así que yendo directo a la cámara no gira |
| Brillo del volumen | Qué tan luminoso es el volumen translúcido de la estela |
| Brillo / Grosor de los filos | Las líneas brillantes donde un borde de la letra queda alineado con la estela |
| Sombra en la cara de la letra | Cuánto se oscurece la letra detrás de su estela; bajo para letras sólidas, alto para letras huecas |
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

Shader for **OBS Studio** inspired by late-70s superhero movie credits: blue chrome letters leave open-shutter light streaks toward the camera, over a moving starfield. Three effects: opening credits (letters arrive clean from the vanishing point, hold, then streak past the camera), closing credits (letters arrive from behind the camera with streaks ahead of them, hold, then recede clean, blurring from blue to orange and back to blue before fading out) and emblem (a logo streaks from the center until it fills the frame).

Put your text in its own scene, nest that scene in your main scene and add a **User-defined shader** filter to the nested scene with `titulos-voladores.shader` (applying it straight to the text source clips the extrusion and stars to the text box). Parameter labels are in Spanish.

To trigger the sequence once with a hotkey, load `intro-control.lua` (**Tools → Scripts**), pick the filter and press *Reproducir*, or bind *Reproducir intro (obs-kr36)* under **Settings → Hotkeys**.

Not affiliated with or endorsed by any film studio or comic publisher.

## License

MIT
