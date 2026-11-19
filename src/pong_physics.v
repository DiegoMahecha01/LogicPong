// pong_physics.v - Motor de cinematica, colisiones y puntuacion (0 a 5)
module pong_physics (
    input  wire       clk,
    input  wire       reset,
    input  wire       vsync,
    input  wire       p1_up,
    input  wire       p1_down,
    input  wire       p2_up,
    input  wire       p2_down,
    output reg  [9:0] p1_y      = 10'd200,
    output reg  [9:0] p2_y      = 10'd200,
    output reg  [9:0] ball_x    = 10'd315,
    output reg  [9:0] ball_y    = 10'd235,
    output reg  [2:0] p1_score  = 3'd0,
    output reg  [2:0] p2_score  = 3'd0,
    output reg        game_over = 1'b0
);

    // Pulso habilitador de 60 Hz sincronizado con el flanco de bajada de vsync
    reg vsync_reg = 1'b0;
    always @(posedge clk) vsync_reg <= vsync;
    wire frame_tick = (vsync_reg && !vsync);

    localparam PAD_H        = 80;
    localparam BALL_S       = 10;
    localparam Y_MAX        = 480;
    localparam WALL_H       = 4;
    localparam PAD_SPEED    = 4;
    localparam PAD1_X_LEFT  = 10'd20;
    localparam PAD1_X_RIGHT = 10'd30;
    localparam PAD2_X_LEFT  = 10'd610;
    localparam PAD2_X_RIGHT = 10'd620;

    reg ball_dx = 1'b1;
    reg ball_dy = 1'b1;

    always @(posedge clk) begin
        if (reset) begin
            p1_y      <= 10'd200;
            p2_y      <= 10'd200;
            ball_x    <= 10'd315;
            ball_y    <= 10'd235;
            ball_dx   <= 1'b1;
            ball_dy   <= 1'b1;
            p1_score  <= 3'd0;
            p2_score  <= 3'd0;
            game_over <= 1'b0;
        end else if (frame_tick && !game_over) begin
            // Movimiento vertical de paletas
            if (p1_up && p1_y > (WALL_H + PAD_SPEED))
                p1_y <= p1_y - PAD_SPEED;
            else if (p1_down && (p1_y + PAD_H + PAD_SPEED < Y_MAX - WALL_H))
                p1_y <= p1_y + PAD_SPEED;

            if (p2_up && p2_y > (WALL_H + PAD_SPEED))
                p2_y <= p2_y - PAD_SPEED;
            else if (p2_down && (p2_y + PAD_H + PAD_SPEED < Y_MAX - WALL_H))
                p2_y <= p2_y + PAD_SPEED;

            // Desplazamiento de pelota (2 px/cuadro)
            ball_x <= ball_dx ? (ball_x + 10'd2) : (ball_x - 10'd2);
            ball_y <= ball_dy ? (ball_y + 10'd2) : (ball_y - 10'd2);

            // Rebotes en muros superior e inferior (incluye proteccion contra underflow)
            if (ball_y <= WALL_H || ball_y > 10'd500)
                ball_dy <= 1'b1;
            else if (ball_y + BALL_S >= Y_MAX - WALL_H)
                ball_dy <= 1'b0;

            // Colision con raquetas
            if (!ball_dx && (ball_x <= PAD1_X_RIGHT) && (ball_x >= PAD1_X_LEFT)) begin
                if ((ball_y + BALL_S >= p1_y) && (ball_y <= p1_y + PAD_H))
                    ball_dx <= 1'b1;
            end

            if (ball_dx && (ball_x + BALL_S >= PAD2_X_LEFT) && (ball_x + BALL_S <= PAD2_X_RIGHT)) begin
                if ((ball_y + BALL_S >= p2_y) && (ball_y <= p2_y + PAD_H))
                    ball_dx <= 1'b0;
            end

            // Conteo de puntos y condicion de victoria (5 puntos)
            if (ball_x < 10'd10 || ball_x > 10'd900) begin
                if (p2_score + 1'b1 == 3'd5) begin
                    p2_score  <= 3'd5;
                    game_over <= 1'b1;
                end else begin
                    p2_score  <= p2_score + 1'b1;
                    ball_x    <= 10'd315;
                    ball_y    <= 10'd235;
                    ball_dx   <= 1'b1;
                end
            end else if (ball_x > 10'd630) begin
                if (p1_score + 1'b1 == 3'd5) begin
                    p1_score  <= 3'd5;
                    game_over <= 1'b1;
                end else begin
                    p1_score  <= p1_score + 1'b1;
                    ball_x    <= 10'd315;
                    ball_y    <= 10'd235;
                    ball_dx   <= 1'b0;
                end
            end
        end
    end

endmodule