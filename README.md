# obs-kr36

*Chrome titles that fly in from deep space, extrude toward the camera and fade away at the horizon, for OBS.*

Shader para **OBS Studio** inspirado en los créditos de las películas de superhéroes de finales de los 70: letras de cromo azul que llegan desde el fondo del espacio, se extruyen como bloques de luz hacia la cámara y se alejan hasta desenfocarse y desvanecerse en el horizonte, sobre un campo de estrellas en movimiento.

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

## Secuencia

Hay dos modos; el inverso es exactamente la secuencia normal al revés.

| Progreso | Normal: salto al hiperespacio | Inverso |
|---|---|---|
| 3–33 % | El texto plano llega desde el horizonte | Llega desde el horizonte ya extruido |
| 33–50 % | Se queda a tamaño normal; un brillo lo cruza | La extrusión se retrae |
| 50–65 % | Se extruye hacia la cámara | Se queda plano a tamaño normal |
| 65–97 % | El bloque se aleja, se desenfoca y se desvanece | Se aleja plano, se desenfoca y se desvanece |

## Parámetros

| Parámetro | Efecto |
|---|---|
| Reproducir en bucle / Duración / Progreso | Bucle automático, o control manual de la secuencia |
| Punto de fuga X/Y | Desde dónde llega el texto y hacia dónde se aleja |
| Distancia del horizonte | Qué tan lejos está el horizonte (40 = ahí el texto mide 1/40 de su tamaño) |
| Inverso | Llega extruido y se aleja plano, en lugar de llegar plano y alejarse extruido |
| Desenfoque en el horizonte / Inicio del desvanecido | Cuánto se desenfoca el texto al llegar al horizonte y desde qué distancia empieza a desvanecerse |
| Largo de la extrusión hacia la cámara | Cada letra es un bloque 3D que sale de la letra hacia el espectador (0 = plana; 1 o más = el bloque rebasa la cámara) |
| Pasa por arriba (−) / abajo (+) | 0 = la extrusión va directo a la cámara; negativo pasa por encima, positivo por debajo |
| Rotación al pasar arriba/abajo | Cuánto gira el texto al extruirse; es proporcional al desvío, así que yendo directo a la cámara no gira |
| Brillo del volumen | Qué tan luminoso es el bloque translúcido de la extrusión |
| Brillo / Grosor de los filos | Las líneas brillantes donde un borde de la letra queda alineado con la extrusión |
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

Shader for **OBS Studio** inspired by late-70s superhero movie credits: blue chrome letters fly in from deep space, extrude as glowing blocks toward the camera (straight at it, or passing above or below) and recede until they blur and fade at the horizon, over a moving starfield. A reverse mode plays the same sequence backwards.

Put your text in its own scene, nest that scene in your main scene and add a **User-defined shader** filter to the nested scene with `titulos-voladores.shader` (applying it straight to the text source clips the extrusion and stars to the text box). Parameter labels are in Spanish.

To trigger the sequence once with a hotkey, load `intro-control.lua` (**Tools → Scripts**), pick the filter and press *Reproducir*, or bind *Reproducir intro (obs-kr36)* under **Settings → Hotkeys**.

Not affiliated with or endorsed by any film studio or comic publisher.

## License

MIT
