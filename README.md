# LogicPong: Consola de Videojuegos Interactiva sobre FPGA

Consola interactiva para dos jugadores basada en el videojuego clásico *Pong*, desarrollada íntegramente en **Verilog HDL** mediante lógica digital concurrente sobre una FPGA **Altera Cyclone IV E (`EP4CE10E22C8N`)**.

## Características principales
- **Controlador VGA (`640x480 @ 60 Hz`):** Generación de sincronismo y barrido mediante pulso habilitador de $25\text{ MHz}$ derivado del oscilador principal de $50\text{ MHz}$.
- **Adquisición analógica SPI:** Lectura alternada de dos joysticks analógicos mediante conversor ADC **MCP3008** de 10 bits a $781.25\text{ kHz}$ con zona muerta configurable.
- **Renderizado combinacional sin memoria externa:** Síntesis en tiempo real de cancha, paletas, pelota, pantallas de estado (`MENU`, `PLAY`, `OVER`) y marcador superpuesto (`J1:X / J2:X` y cartel de victoria a 5 puntos).
- **Bajo consumo energético:** Disipación térmica total estimada de **$72.39\text{ mW}$** en Quartus Prime Power Analyzer.

## Arquitectura de módulos (`src/`)

| Módulo | Función |
| :--- | :--- |
| `pong_top.v` | Módulo estructural superior, máquina de estados maestra (FSM) e interconexión general. |
| `vga_sync.v` | Generador de señales de sincronismo horizontal/vertical (`hsync`, `vsync`) y ventana activa (`video_on`). |
| `mcp3008.v` | Maestro SPI (Modo 0,0) para conversión analógica-digital en canales `CH0` y `CH1`. |
| `joy_dir.v` | Decodificador combinacional de dirección (`up`/`down`) con zona muerta (`350` a `670`). |
| `debounce.v` | Filtro antirrebote síncrono ($10\text{ ms}$) para controles físicos. |
| `pong_physics.v` | Cinemática de paletas y pelota sincronizada a $60\text{ Hz}$, detección de colisiones y conteo hasta 5 puntos. |
| `pong_render.v` | Generación combinacional RGB de la cancha, menú inicial y pantalla de fin de partida. |
| `score_hud.v` | Fuente bitmap $8\times 8$ para marcador superior en tiempo real y anuncio de ganador. |

## Asignación de pines externos

| Señal | Pin FPGA | Periférico / Destino |
| :--- | :--- | :--- |
| `clk_50MHz` | Reloj onboard | Oscilador principal $50\text{ MHz}$ |
| `adc_sclk` | `PIN_30` | MCP3008 Pin 13 (`CLK`) |
| `adc_cs_n` | `PIN_32` | MCP3008 Pin 10 (`CS/SHDN`) |
| `adc_mosi` | `PIN_34` | MCP3008 Pin 11 (`DIN`) |
| `adc_miso` | `PIN_39` | MCP3008 Pin 12 (`DOUT`) |
| `btn_start` | `PIN_42` | Pulsador externo de inicio |
| `btn_reset` | `PIN_49` | Pulsador externo de reset |

## Estructura del repositorio
```text
LogicPong/
├── src/        # Código fuente sintetizable en Verilog (.v)
├── quartus/    # Archivos de proyecto, asignación de pines y restricciones (.qpf, .qsf, .sdc)
└── docs/       # Informe técnico en formato IEEE (.pdf)

Autores
Juan Manuel Berdugo Torres (jberdugot@unal.edu.co)

Diego Leonardo Mahecha Castañeda (dmahechac@unal.edu.co)

Santiago Villegas Castillo (savillegas@unal.edu.co)

Departamento de Ingeniería Eléctrica y Electrónica — Universidad Nacional de Colombia, Sede Bogotá.
