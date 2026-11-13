# obs-flying-titles

*Chrome titles that fly in from deep space with light streaks, for OBS.*

Shader para **OBS Studio** inspirado en los créditos de las películas de superhéroes de finales de los 70: letras de cromo azul que llegan volando desde el fondo del espacio dejando estelas de luz, se detienen frente a la cámara y salen volando hacia ella, sobre un campo de estrellas en movimiento.

*[English below](#english)*

## Requisitos

- OBS Studio
- Plugin [obs-shaderfilter](https://github.com/exeldro/obs-shaderfilter)

## Instalación

1. Crea una escena aparte, por ejemplo "Créditos", con tu texto (fuente de texto o PNG con transparencia). Letras gruesas y en mayúsculas se ven mejor.
2. Agrega la escena "Créditos" dentro de tu escena principal.
3. Clic derecho sobre la escena anidada → **Filtros** → **+** → **User-defined shader**.
4. Activa **Load shader text from file** y elige `titulos-voladores.shader`.

**Por qué en una escena anidada y no directo en el texto:** el filtro solo dibuja dentro del área de la fuente donde se aplica. Si lo pones en la fuente de texto, las estelas y las estrellas se cortan en la caja del texto.

Para varios créditos seguidos, haz una escena por crédito o cambia el texto entre reproducciones.

## Secuencia

| Progreso | Qué pasa |
|---|---|
| 0–35 % | El texto llega desde lejos dejando estelas |
| 35–75 % | Se queda frente a la cámara, acercándose muy despacio; un brillo lo cruza |
| 75–100 % | Sale volando hacia la cámara (o se desvanece en su lugar) |

## Parámetros

| Parámetro | Efecto |
|---|---|
| Reproducir en bucle / Duración / Progreso | Bucle automático, o control manual de la secuencia |
| Punto de fuga X/Y | Desde dónde llega el texto y hacia dónde apuntan las estelas |
| Distancia inicial | Qué tan chico arranca el texto (40 = 1/40 de su tamaño) |
| Salir volando hacia la cámara | Si está apagado, el texto se desvanece en su lugar |
| Largo / Brillo de las estelas | El rastro de luz que deja el texto al moverse |
| Cromo | 1 = cromo azul; 0 = conserva los colores del texto |
| color_deep / color_light | Los dos tonos del cromo, también usados en estelas y resplandor |
| Bisel del cromo | Grosor del filo iluminado de las letras |
| Brillo que cruza el texto | Destello diagonal que recorre las letras |
| Resplandor | Halo alrededor del texto |
| Fondo de estrellas | Apagado = fondo transparente, para ponerlo encima de otra cosa |
| Densidad / Velocidad de las estrellas | Cuántas estrellas hay y qué tan rápido se acercan |

## Disparar la secuencia con un hotkey (script)

`intro-control.lua` apaga el bucle y mueve el Progreso de 0 a 100 en la duración del filtro.

1. **Herramientas → Scripts → +** y elige `intro-control.lua`.
2. En **Filtro de títulos** elige tu filtro (si no aparece, **Actualizar lista**).
3. Presiona **Reproducir**, o asigna un atajo en **Configuración → Atajos de teclado → Reproducir intro (obs-flying-titles)**.

---

## English

Shader for **OBS Studio** inspired by late-70s superhero movie credits: blue chrome letters fly in from deep space leaving light streaks, hold in front of the camera, then fly past it, over a moving starfield.

Put your text in its own scene, nest that scene in your main scene and add a **User-defined shader** filter to the nested scene with `titulos-voladores.shader` (applying it straight to the text source clips the streaks and stars to the text box). Parameter labels are in Spanish.

To trigger the sequence once with a hotkey, load `intro-control.lua` (**Tools → Scripts**), pick the filter and press *Reproducir*, or bind *Reproducir intro (obs-flying-titles)* under **Settings → Hotkeys**.

Not affiliated with or endorsed by any film studio or comic publisher.

## License

MIT
