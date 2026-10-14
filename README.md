# Structure Alignment

**Version:** `1.0-stable` · **Author:** [pacopecox](https://github.com/pacopecox)

[English](#english) · [Español](#español)

## English

Align structures and objects when building or placing them with a configurable grid. Includes valid and invalid position indicators, a terrain tile outline, and opacity settings.

Structure Alignment adapts Don't Starve Together's native alignment system for single-player Don't Starve.

### Compatibility

- Don't Starve, including Reign of Giants, Shipwrecked, and Hamlet.
- Grid alignment is available with keyboard and mouse.
- Special placements, such as walls, turf, boats, and Hamlet interiors, keep their native placement behavior.

### Features

- Four grid intervals: Half-Wall, Wall, Half-Tile, and Tile, with spacing of 0.5, 1, 2, and 4 game units respectively.
- Green cells for valid positions and red crosses for invalid positions, using the game's placement checks.
- Optional outline of the terrain tile under the placement preview.
- Separate opacity settings for the preview and grid.
- Rebindable keyboard controls through the game's Controls menu.
- Automatic or manual menu language selection: English and Simplified Chinese.
- Corrected animation origins for the Crock Pot, Birdcage, and Campfire.
- Farm decorations no longer block adjacent farm placement. The farms themselves retain their placement restrictions.

### Installation

1. Close Don't Starve.
2. Create a folder named `structure-alignment` inside the game's `mods` directory.
3. Copy the contents of `1.0-stable` into that folder. If using a package with the mod files at its root, copy those files directly. `modinfo.lua` and `modmain.lua` must be directly inside `mods/structure-alignment`, alongside `anim` and `scripts`.
4. Launch Don't Starve and enable **Structure Alignment** in **Mods**.
5. Open **Configure Mod**, choose your settings, and click **Apply**.
6. Click **Apply** on the main **Mods** screen to reload the mods with the saved settings.

### Controls

| Default key | Action |
| --- | --- |
| Hold **Left Shift** | Temporarily bypass alignment while placing an object. |
| **V** | Cycle through the four grid intervals while alignment is active. |

Both bindings can be changed in the game's **Controls** menu under **Toggle Alignment (mod)** and **Cycle Alignment Grid**.

### Configuration

| Setting | Options | Default |
| --- | --- | --- |
| Menu Language | Auto, English, 简体中文 | Auto |
| Alignment Intervals | Half-Wall, Wall, Half-Tile, Tile | Wall |
| Tile Outline | Disabled, Enabled | Disabled |
| Placer Opacity | 25%, 50%, 75%, 100% | 100% |
| Grid Opacity | 25%, 50%, 75%, 100% | 100% |

**Auto** follows the game's language: Chinese uses Simplified Chinese; other languages use English. Manual selection changes the mod's text independently of the game's language.

The configuration menu previews language changes immediately. To use the chosen language in the Controls menu, apply the mod settings and then apply changes on the main Mods screen.

### Placement behavior

The mod aligns eligible placement previews and checks whether each position is valid. It does not move existing structures or override recipe and deployment minimum distances. Grid colors can change with the game's lighting, seasonal filters, and sanity effects.

Controller grid support and custom alignment inside Hamlet houses are planned for future development.

### Credits

Created by **pacopecox**. The alignment system is adapted from Don't Starve Together's native placement code. Don't Starve, Don't Starve Together, and the original game assets are by **Klei Entertainment**.

Report issues in [GitHub Issues](https://github.com/pacopecox/Structure-Alignment/issues), including the game/DLC, steps to reproduce, screenshots, and the relevant game log.

## Español

Alinea estructuras y objetos al construir o colocarlos mediante una cuadrícula configurable. Incluye indicadores de posiciones válidas e inválidas, contorno de terreno y ajustes de opacidad.

Structure Alignment adapta el sistema de alineamiento nativo de Don't Starve Together a Don't Starve para un jugador.

### Compatibilidad

- Don't Starve, incluidos Reign of Giants, Shipwrecked y Hamlet.
- El alineamiento con cuadrícula funciona con teclado y ratón.
- Las colocaciones especiales, como muros, terrenos, barcos e interiores de Hamlet, conservan su comportamiento nativo.

### Funciones

- Cuatro intervalos: Half-Wall, Wall, Half-Tile y Tile, con separaciones de 0,5, 1, 2 y 4 unidades del juego, respectivamente.
- Celdas verdes para posiciones válidas y cruces rojas para posiciones inválidas, según las comprobaciones de colocación del juego.
- Contorno opcional del terreno situado bajo la vista previa de colocación.
- Ajustes independientes de opacidad para la vista previa y la cuadrícula.
- Controles de teclado reasignables desde el menú de controles del juego.
- Selección automática o manual del idioma del menú: inglés y chino simplificado.
- Orígenes de animación corregidos para la olla de cocción, la jaula de pájaros y la fogata.
- Los adornos de las granjas ya no bloquean la colocación de granjas adyacentes. Las propias granjas conservan sus restricciones de colocación.

### Instalación

1. Cierra Don't Starve.
2. Crea una carpeta llamada `structure-alignment` dentro del directorio `mods` del juego.
3. Copia el contenido de `1.0-stable` en esa carpeta. Si utilizas un paquete con los archivos del mod en la raíz, cópialos directamente. `modinfo.lua` y `modmain.lua` deben quedar directamente en `mods/structure-alignment`, junto a `anim` y `scripts`.
4. Inicia Don't Starve y activa **Structure Alignment** en **Mods**.
5. Abre **Configure Mod**, elige los ajustes y pulsa **Apply**.
6. Pulsa **Apply** en la pantalla principal de **Mods** para recargar los mods con los ajustes guardados.

### Controles

| Tecla predeterminada | Acción |
| --- | --- |
| Mantener **Left Shift** | Suspender temporalmente el alineamiento al colocar un objeto. |
| **V** | Alternar entre los cuatro intervalos mientras el alineamiento está activo. |

Puedes cambiar ambas teclas en el menú **Controls** del juego, en **Toggle Alignment (mod)** y **Cycle Alignment Grid**.

### Configuración

| Ajuste | Opciones | Predeterminado |
| --- | --- | --- |
| Menu Language — Idioma del menú | Auto, English, 简体中文 | Auto |
| Alignment Intervals — Intervalos de alineamiento | Half-Wall, Wall, Half-Tile, Tile | Wall |
| Tile Outline — Contorno de terreno | Disabled, Enabled | Disabled |
| Placer Opacity — Opacidad de la vista previa | 25%, 50%, 75%, 100% | 100% |
| Grid Opacity — Opacidad de la cuadrícula | 25%, 50%, 75%, 100% | 100% |

**Auto** sigue el idioma del juego: para chino utiliza chino simplificado; para los demás idiomas utiliza inglés. La selección manual cambia los textos del mod independientemente del idioma del juego.

El menú de configuración muestra inmediatamente una vista previa del idioma. Para usar el idioma elegido en los controles, aplica los ajustes del mod y después pulsa Aplicar en la pantalla principal de Mods.

### Comportamiento de colocación

El mod alinea las vistas previas compatibles y comprueba si cada posición es válida. No mueve estructuras existentes ni cambia las distancias mínimas de construcción y despliegue. Los colores de la cuadrícula pueden variar con la iluminación, los filtros estacionales y los efectos de cordura del juego.

El soporte de cuadrícula para mando y el alineamiento personalizado dentro de las casas de Hamlet están previstos para futuras versiones.

### Créditos

Creado por **pacopecox**. El sistema de alineamiento se adapta del código de colocación nativo de Don't Starve Together. Don't Starve, Don't Starve Together y los assets originales del juego pertenecen a **Klei Entertainment**.

Puedes comunicar problemas en [GitHub Issues](https://github.com/pacopecox/Structure-Alignment/issues), indicando el juego o DLC, los pasos para reproducirlos, capturas y el log correspondiente.
