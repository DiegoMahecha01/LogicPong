// pong_top.v - Modulo superior: FSM maestra e interconexion del sistema
module pong_top (
    input  wire clk_50MHz,
    input  wire reset_n,
    input  wire btn_start,
    output wire adc_sclk,
    output wire adc_cs_n,
    output wire adc_mosi,
    input  wire adc_miso,
    output wire hsync,
    output wire vsync,
    output wire vga_r,
    output wire vga_g,
    output wire vga_b,
    output wire led_heartbeat
);

    wire game_reset = ~reset_n;

    // Antirrebote y detector de flanco para pulsador de inicio (active-low)
    wire start_db;
    debounce db_start (
        .clk(clk_50MHz),
        .reset(game_reset),
        .btn_in(~btn_start),
        .btn_out(start_db)
    );

    reg start_prev = 1'b0;
    always @(posedge clk_50MHz) start_prev <= start_db;
    wire start_pulse = (start_db && !start_prev);

    // Adquisicion analogica SPI (CH0 = Jugador 1, CH1 = Jugador 2)
    wire [9:0] joy1_y, joy2_y;
    mcp3008 adc_unit (
        .clk(clk_50MHz),
        .reset(game_reset),
        .sclk(adc_sclk),
        .cs_n(adc_cs_n),
        .mosi(adc_mosi),
        .miso(adc_miso),
        .ch0(joy1_y),
        .ch1(joy2_y)
    );

    // Decodificacion de direccion con zona muerta
    wire p1_u, p1_d, p2_u, p2_d;
    joy_dir #(.INVERT(1'b0)) dir1 (.value(joy1_y), .up(p1_u), .down(p1_d));
    joy_dir #(.INVERT(1'b0)) dir2 (.value(joy2_y), .up(p2_u), .down(p2_d));

    // Maquina de estados maestra (Menu -> Juego -> Game Over)
    localparam STATE_MENU = 2'd0;
    localparam STATE_PLAY = 2'd1;
    localparam STATE_OVER = 2'd2;

    reg [1:0] state = STATE_MENU;
    wire game_over;

    always @(posedge clk_50MHz) begin
        if (game_reset) begin
            state <= STATE_MENU;
        end else begin
            case (state)
                STATE_MENU: if (start_pulse) state <= STATE_PLAY;
                STATE_PLAY: if (game_over)   state <= STATE_OVER;
                STATE_OVER: if (start_pulse) state <= STATE_MENU;
                default:    state <= STATE_MENU;
            endcase
        end
    end

    // Senales de video y juego
    wire video_on;
    wire [9:0] pixel_x, pixel_y;
    wire [9:0] p1_y, p2_y, ball_x, ball_y;
    wire [2:0] p1_score, p2_score;
    wire r_int, g_int, b_int;

    // Divisor de cuadros para parpadeo de texto y LED testigo
    reg [5:0] frame_count = 6'd0;
    always @(negedge vsync) begin
        frame_count <= frame_count + 1'b1;
    end
    assign led_heartbeat = frame_count[5];

    // Controlador de sincronismo VGA (640x480 @ 60 Hz)
    vga_sync vga_unit (
        .clk(clk_50MHz),
        .reset(1'b0),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .x(pixel_x),
        .y(pixel_y)
    );

    // Motor de fisicas y puntuacion
    wire physics_reset = game_reset || (state == STATE_MENU);

    pong_physics phys_unit (
        .clk(clk_50MHz),
        .reset(physics_reset),
        .vsync(vsync),
        .p1_up(p1_u),
        .p1_down(p1_d),
        .p2_up(p2_u),
        .p2_down(p2_d),
        .p1_y(p1_y),
        .p2_y(p2_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .p1_score(p1_score),
        .p2_score(p2_score),
        .game_over(game_over)
    );

    // Renderizador de cancha y pantallas de estado
    pong_render render_unit (
        .video_on(video_on),
        .x(pixel_x),
        .y(pixel_y),
        .p1_y(p1_y),
        .p2_y(p2_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .game_state(state),
        .p1_won(p1_score == 3'd5),
        .blink(frame_count[4]),
        .r(r_int),
        .g(g_int),
        .b(b_int)
    );

    // Superposicion de marcador (J1:X / J2:X) y cartel de victoria
    wire hud_white, hud_yellow;
    score_hud #(.USE_P(1'b0)) hud_unit (
        .x(pixel_x),
        .y(pixel_y),
        .p1_score(p1_score),
        .p2_score(p2_score),
        .game_state(state),
        .p1_won(p1_score == 3'd5),
        .hud_white(hud_white),
        .hud_yellow(hud_yellow)
    );

    // Mezcla RGB final dentro de la ventana activa de video
    wire show_bg = (state != STATE_OVER);
    wire base_r  = r_int & show_bg;
    wire base_g  = g_int & show_bg;
    wire base_b  = b_int & show_bg;

    assign vga_r = video_on ? (base_r | hud_white | hud_yellow) : 1'b0;
    assign vga_g = video_on ? (base_g | hud_white | hud_yellow) : 1'b0;
    assign vga_b = video_on ? (base_b | hud_white)              : 1'b0;

endmodule