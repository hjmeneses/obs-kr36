# obs-kr36

*Chrome titles that extrude toward the camera as glowing blocks of light, for OBS.*

Shader para **OBS Studio** inspirado en los créditos de las películas de superhéroes de finales de los 70: letras de cromo azul que se extruyen como bloques de luz hacia la cámara, sobre un campo de estrellas en movimiento. Tiene dos efectos: las letras llegan desde el punto de fuga y salen siguiendo su extrusión hacia la cámara, o llegan desde la cámara y se alejan desenfocándose mientras cambian de color.

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

| Progreso | Normal | Progreso | Inverso |
|---|---|---|---|
| 3–30 % | Las letras llegan desde el punto de fuga | 3–35 % | Llegan desde la cámara con la extrusión detrás |
| 30–45 % | Se quedan a tamaño normal; un brillo las cruza | 35–50 % | La extrusión se retrae |
| 45–62 % | Se extruyen hacia la cámara | 50–62 % | Se quedan a tamaño normal |
| 62–97 % | Siguen a su extrusión hasta rebasar la cámara | 62–97 % | Se alejan sin llegar al punto de fuga: se desenfocan, pasan a naranja, luego a azul y se desvanecen |

## Parámetros

| Parámetro | Efecto |
|---|---|
| Reproducir en bucle / Duración / Progreso | Bucle automático, o control manual de la secuencia |
| Punto de fuga X/Y | Hacia dónde llegan y se alejan las letras |
| Distancia del horizonte / Aparición desde el horizonte | Desde qué tan lejos llegan las letras en el modo normal y desde qué distancia empiezan a verse |
| Inverso | Cambia al segundo efecto |
| Inverso: distancia / desenfoque al desvanecerse | Hasta dónde se alejan (4 = a 1/4 de su tamaño) y cuánto se desenfocan |
| color_warm / color_cool | El naranja y el azul por los que pasan al desvanecerse en el modo inverso |
| Sombra en la cara de la letra | Cuánto se oscurece la letra detrás de su extrusión; bajo para letras sólidas, alto para letras huecas |
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

Shader for **OBS Studio** inspired by late-70s superhero movie credits: blue chrome letters extrude as glowing blocks toward the camera (straight at it, or passing above or below), over a moving starfield. In normal mode the letters arrive from the vanishing point and follow their extrusion past the camera; in reverse mode they arrive from the camera, then recede while blurring and shifting to orange, then blue, before fading out.

Put your text in its own scene, nest that scene in your main scene and add a **User-defined shader** filter to the nested scene with `titulos-voladores.shader` (applying it straight to the text source clips the extrusion and stars to the text box). Parameter labels are in Spanish.

To trigger the sequence once with a hotkey, load `intro-control.lua` (**Tools → Scripts**), pick the filter and press *Reproducir*, or bind *Reproducir intro (obs-kr36)* under **Settings → Hotkeys**.

Not affiliated with or endorsed by any film studio or comic publisher.

## License

MIT
