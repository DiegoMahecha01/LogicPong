// pong_render.v - Sintesis combinacional de escena VGA por estado de juego
module pong_render (
    input  wire       video_on,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire [9:0] p1_y,
    input  wire [9:0] p2_y,
    input  wire [9:0] ball_x,
    input  wire [9:0] ball_y,
    input  wire [1:0] game_state,
    input  wire       p1_won,
    input  wire       blink,
    output reg        r,
    output reg        g,
    output reg        b
);

    localparam STATE_MENU = 2'd0;
    localparam STATE_PLAY = 2'd1;
    localparam STATE_OVER = 2'd2;

    // Geometria de cancha y entidades
    wire border_on = (y < 10'd4) || (y >= 10'd476);
    wire net_on    = (x >= 10'd318 && x < 10'd322) && y[4];
    wire p1_on     = (x >= 10'd20 && x < 10'd30) && (y >= p1_y && y < p1_y + 10'd80);
    wire p2_on     = (x >= 10'd610 && x < 10'd620) && (y >= p2_y && y < p2_y + 10'd80);
    wire ball_on   = (x >= ball_x && x < ball_x + 10'd10) && (y >= ball_y && y < ball_y + 10'd10);

    // Titulo "PONG"
    wire char_P = (x >= 190 && x < 200 && y >= 90 && y < 160) ||
                  (x >= 190 && x < 240 && y >= 90 && y < 100) ||
                  (x >= 190 && x < 240 && y >= 120 && y < 130) ||
                  (x >= 230 && x < 240 && y >= 90 && y < 130);

    wire char_O = (x >= 260 && x < 270 && y >= 90 && y < 160) ||
                  (x >= 300 && x < 310 && y >= 90 && y < 160) ||
                  (x >= 260 && x < 310 && y >= 90 && y < 100) ||
                  (x >= 260 && x < 310 && y >= 150 && y < 160);

    wire char_N = (x >= 330 && x < 340 && y >= 90 && y < 160) ||
                  (x >= 370 && x < 380 && y >= 90 && y < 160) ||
                  (x >= 340 && x < 350 && y >= 100 && y < 118) ||
                  (x >= 350 && x < 360 && y >= 118 && y < 136) ||
                  (x >= 360 && x < 370 && y >= 136 && y < 150);

    wire char_G = (x >= 400 && x < 410 && y >= 90 && y < 160) ||
                  (x >= 400 && x < 450 && y >= 90 && y < 100) ||
                  (x >= 400 && x < 450 && y >= 150 && y < 160) ||
                  (x >= 440 && x < 450 && y >= 125 && y < 160) ||
                  (x >= 425 && x < 450 && y >= 125 && y < 135);

    wire title_pong = char_P | char_O | char_N | char_G;

    // Leyenda "5 PTS"
    wire dig_5  = (x >= 205 && x < 245 && y >= 210 && y < 218) ||
                  (x >= 205 && x < 213 && y >= 210 && y < 242) ||
                  (x >= 205 && x < 239 && y >= 234 && y < 242) ||
                  (x >= 237 && x < 245 && y >= 240 && y < 264) ||
                  (x >= 211 && x < 239 && y >= 262 && y < 270) ||
                  (x >= 205 && x < 213 && y >= 256 && y < 264);

    wire pts_P  = (x >= 280 && x < 288 && y >= 210 && y < 270) ||
                  (x >= 280 && x < 320 && y >= 210 && y < 218) ||
                  (x >= 280 && x < 320 && y >= 236 && y < 244) ||
                  (x >= 312 && x < 320 && y >= 210 && y < 244);

    wire pts_T  = (x >= 332 && x < 372 && y >= 210 && y < 218) ||
                  (x >= 348 && x < 356 && y >= 210 && y < 270);

    wire pts_S  = (x >= 390 && x < 418 && y >= 210 && y < 218) ||
                  (x >= 416 && x < 424 && y >= 216 && y < 224) ||
                  (x >= 384 && x < 392 && y >= 216 && y < 238) ||
                  (x >= 390 && x < 418 && y >= 236 && y < 244) ||
                  (x >= 416 && x < 424 && y >= 242 && y < 264) ||
                  (x >= 390 && x < 418 && y >= 262 && y < 270) ||
                  (x >= 384 && x < 392 && y >= 256 && y < 264);

    wire text_5pts = dig_5 | pts_P | pts_T | pts_S;

    // Aviso intermitente "START"
    wire st_S  = (x >= 230 && x < 250 && y >= 330 && y < 336) ||
                 (x >= 249 && x < 255 && y >= 334 && y < 340) ||
                 (x >= 225 && x < 231 && y >= 334 && y < 349) ||
                 (x >= 230 && x < 250 && y >= 347 && y < 353) ||
                 (x >= 249 && x < 255 && y >= 351 && y < 366) ||
                 (x >= 230 && x < 250 && y >= 364 && y < 370) ||
                 (x >= 225 && x < 231 && y >= 360 && y < 366);

    wire st_T1 = (x >= 265 && x < 295 && y >= 330 && y < 336) ||
                 (x >= 277 && x < 283 && y >= 330 && y < 370);

    wire st_A  = (x >= 305 && x < 335 && y >= 330 && y < 336) ||
                 (x >= 305 && x < 311 && y >= 330 && y < 370) ||
                 (x >= 329 && x < 335 && y >= 330 && y < 370) ||
                 (x >= 305 && x < 335 && y >= 347 && y < 353);

    wire st_R  = (x >= 345 && x < 351 && y >= 330 && y < 370) ||
                 (x >= 345 && x < 375 && y >= 330 && y < 336) ||
                 (x >= 369 && x < 375 && y >= 330 && y < 353) ||
                 (x >= 345 && x < 375 && y >= 347 && y < 353) ||
                 (x >= 360 && x < 366 && y >= 353 && y < 362) ||
                 (x >= 369 && x < 375 && y >= 362 && y < 370);

    wire st_T2 = (x >= 385 && x < 415 && y >= 330 && y < 336) ||
                 (x >= 397 && x < 403 && y >= 330 && y < 370);

    wire text_start = blink && (st_S | st_T1 | st_A | st_R | st_T2);

    // Cartel base de ganador ("P1" / "P2")
    wire win_P = (x >= 270 && x < 280 && y >= 140 && y < 210) ||
                 (x >= 270 && x < 310 && y >= 140 && y < 150) ||
                 (x >= 270 && x < 310 && y >= 170 && y < 180) ||
                 (x >= 300 && x < 310 && y >= 140 && y < 180);

    wire win_1 = (x >= 345 && x < 355 && y >= 140 && y < 210) ||
                 (x >= 335 && x < 345 && y >= 150 && y < 160);

    wire win_2 = (x >= 330 && x < 370 && y >= 140 && y < 150) ||
                 (x >= 360 && x < 370 && y >= 140 && y < 180) ||
                 (x >= 330 && x < 370 && y >= 170 && y < 180) ||
                 (x >= 330 && x < 340 && y >= 170 && y < 210) ||
                 (x >= 330 && x < 370 && y >= 200 && y < 210);

    wire winner_banner = win_P | (p1_won ? win_1 : win_2);

    // Seleccion de color RGB por estado
    always @(*) begin
        r = 1'b0;
        g = 1'b0;
        b = 1'b0;

        if (video_on) begin
            case (game_state)
                STATE_MENU: begin
                    if (border_on || text_start) begin
                        r = 1'b1; g = 1'b1; b = 1'b1;
                    end else if (title_pong) begin
                        r = 1'b0; g = 1'b1; b = 1'b1;
                    end else if (text_5pts) begin
                        r = 1'b1; g = 1'b1; b = 1'b0;
                    end
                end

                STATE_PLAY: begin
                    if (border_on || net_on || ball_on) begin
                        r = 1'b1; g = 1'b1; b = 1'b1;
                    end else if (p1_on) begin
                        r = 1'b0; g = 1'b1; b = 1'b1;
                    end else if (p2_on) begin
                        r = 1'b1; g = 1'b1; b = 1'b0;
                    end
                end

                STATE_OVER: begin
                    if (winner_banner) begin
                        r = p1_won ? 1'b0 : 1'b1;
                        g = 1'b1;
                        b = p1_won ? 1'b1 : 1'b0;
                    end else if (border_on || text_start) begin
                        r = 1'b1; g = 1'b1; b = 1'b1;
                    end
                end
            endcase
        end
    end

endmodule