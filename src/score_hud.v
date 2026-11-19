// score_hud.v - Marcador superior (J1:X / J2:X) y cartel PLAYER 1/2 WINNER!
module score_hud #(
    parameter USE_P = 1'b0 // 0 = "J1"/"J2" | 1 = "P1"/"P2"
) (
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire [2:0] p1_score,
    input  wire [2:0] p2_score,
    input  wire [1:0] game_state,
    input  wire       p1_won,
    output wire       hud_white,
    output wire       hud_yellow
);

    // Ventanas del marcador superior (escala 2x)
    wire in_score_y   = (y[9:4] == 6'd1);
    wire in_left      = (x[9:6] == 4'd2);
    wire in_right     = (x[9:6] == 4'd7);
    wire in_score_box = (game_state != 2'd0) && in_score_y && (in_left || in_right);

    // Ventana del cartel de victoria (escala 4x)
    wire in_banner_box  = (game_state == 2'd2) && (x >= 10'd48 && x < 10'd592) && (y >= 10'd200 && y < 10'd264);
    wire banner_border  = in_banner_box && (x < 10'd52 || x >= 10'd588 || y < 10'd204 || y >= 10'd260);
    wire in_banner_text = (game_state == 2'd2) && (x >= 10'd64 && x < 10'd576) && (y >= 10'd216 && y < 10'd248);

    wire [8:0] bx = x - 10'd64;
    wire [4:0] by = y - 10'd216;

    // Seleccion de glifo y coordenadas internas (fuente bitmap 8x8)
    wire [3:0] b_slot = bx[8:5];
    wire [2:0] col    = in_banner_text ? bx[4:2] : x[3:1];
    wire [2:0] row    = in_banner_text ? by[4:2] : y[3:1];

    localparam [4:0]
        CHAR_J     = 5'd6,
        CHAR_P     = 5'd7,
        CHAR_COLON = 5'd8,
        CHAR_L     = 5'd9,
        CHAR_A     = 5'd10,
        CHAR_Y     = 5'd11,
        CHAR_E     = 5'd12,
        CHAR_R     = 5'd13,
        CHAR_W     = 5'd14,
        CHAR_I     = 5'd15,
        CHAR_N     = 5'd16,
        CHAR_EXCL  = 5'd17,
        CHAR_SPACE = 5'd18;

    reg [4:0] char_id;
    always @(*) begin
        if (in_banner_text) begin
            case (b_slot)
                4'd0:    char_id = CHAR_P;
                4'd1:    char_id = CHAR_L;
                4'd2:    char_id = CHAR_A;
                4'd3:    char_id = CHAR_Y;
                4'd4:    char_id = CHAR_E;
                4'd5:    char_id = CHAR_R;
                4'd6:    char_id = CHAR_SPACE;
                4'd7:    char_id = p1_won ? 5'd1 : 5'd2;
                4'd8:    char_id = CHAR_SPACE;
                4'd9:    char_id = CHAR_W;
                4'd10:   char_id = CHAR_I;
                4'd11:   char_id = CHAR_N;
                4'd12:   char_id = CHAR_N;
                4'd13:   char_id = CHAR_E;
                4'd14:   char_id = CHAR_R;
                4'd15:   char_id = CHAR_EXCL;
                default: char_id = CHAR_SPACE;
            endcase
        end else begin
            case (x[5:4])
                2'd0: char_id = USE_P ? CHAR_P : CHAR_J;
                2'd1: char_id = in_left ? 5'd1 : 5'd2;
                2'd2: char_id = CHAR_COLON;
                2'd3: char_id = {2'b00, (in_left ? p1_score : p2_score)};
            endcase
        end
    end

    // ROM combinacional de caracteres 8x8
    reg [7:0] glyph_row;
    always @(*) begin
        case ({char_id, row})
            // '0'
            {5'd0, 3'd0}: glyph_row = 8'b01111000;
            {5'd0, 3'd1}: glyph_row = 8'b11001100;
            {5'd0, 3'd2}: glyph_row = 8'b11011100;
            {5'd0, 3'd3}: glyph_row = 8'b11110100;
            {5'd0, 3'd4}: glyph_row = 8'b11100100;
            {5'd0, 3'd5}: glyph_row = 8'b11001100;
            {5'd0, 3'd6}: glyph_row = 8'b01111000;
            // '1'
            {5'd1, 3'd0}: glyph_row = 8'b00110000;
            {5'd1, 3'd1}: glyph_row = 8'b01110000;
            {5'd1, 3'd2}: glyph_row = 8'b00110000;
            {5'd1, 3'd3}: glyph_row = 8'b00110000;
            {5'd1, 3'd4}: glyph_row = 8'b00110000;
            {5'd1, 3'd5}: glyph_row = 8'b00110000;
            {5'd1, 3'd6}: glyph_row = 8'b11111100;
            // '2'
            {5'd2, 3'd0}: glyph_row = 8'b01111000;
            {5'd2, 3'd1}: glyph_row = 8'b11001100;
            {5'd2, 3'd2}: glyph_row = 8'b00001100;
            {5'd2, 3'd3}: glyph_row = 8'b00111000;
            {5'd2, 3'd4}: glyph_row = 8'b01100000;
            {5'd2, 3'd5}: glyph_row = 8'b11000000;
            {5'd2, 3'd6}: glyph_row = 8'b11111100;
            // '3'
            {5'd3, 3'd0}: glyph_row = 8'b01111000;
            {5'd3, 3'd1}: glyph_row = 8'b11001100;
            {5'd3, 3'd2}: glyph_row = 8'b00001100;
            {5'd3, 3'd3}: glyph_row = 8'b00111000;
            {5'd3, 3'd4}: glyph_row = 8'b00001100;
            {5'd3, 3'd5}: glyph_row = 8'b11001100;
            {5'd3, 3'd6}: glyph_row = 8'b01111000;
            // '4'
            {5'd4, 3'd0}: glyph_row = 8'b00011100;
            {5'd4, 3'd1}: glyph_row = 8'b00111100;
            {5'd4, 3'd2}: glyph_row = 8'b01101100;
            {5'd4, 3'd3}: glyph_row = 8'b11001100;
            {5'd4, 3'd4}: glyph_row = 8'b11111100;
            {5'd4, 3'd5}: glyph_row = 8'b00001100;
            {5'd4, 3'd6}: glyph_row = 8'b00001100;
            // '5'
            {5'd5, 3'd0}: glyph_row = 8'b11111100;
            {5'd5, 3'd1}: glyph_row = 8'b11000000;
            {5'd5, 3'd2}: glyph_row = 8'b11111000;
            {5'd5, 3'd3}: glyph_row = 8'b00001100;
            {5'd5, 3'd4}: glyph_row = 8'b00001100;
            {5'd5, 3'd5}: glyph_row = 8'b11001100;
            {5'd5, 3'd6}: glyph_row = 8'b01111000;
            // 'J'
            {CHAR_J, 3'd0}: glyph_row = 8'b00011110;
            {CHAR_J, 3'd1}: glyph_row = 8'b00000110;
            {CHAR_J, 3'd2}: glyph_row = 8'b00000110;
            {CHAR_J, 3'd3}: glyph_row = 8'b00000110;
            {CHAR_J, 3'd4}: glyph_row = 8'b11000110;
            {CHAR_J, 3'd5}: glyph_row = 8'b11000110;
            {CHAR_J, 3'd6}: glyph_row = 8'b01111100;
            // 'P'
            {CHAR_P, 3'd0}: glyph_row = 8'b11111000;
            {CHAR_P, 3'd1}: glyph_row = 8'b11001100;
            {CHAR_P, 3'd2}: glyph_row = 8'b11001100;
            {CHAR_P, 3'd3}: glyph_row = 8'b11111000;
            {CHAR_P, 3'd4}: glyph_row = 8'b11000000;
            {CHAR_P, 3'd5}: glyph_row = 8'b11000000;
            {CHAR_P, 3'd6}: glyph_row = 8'b11000000;
            // ':'
            {CHAR_COLON, 3'd1}: glyph_row = 8'b00110000;
            {CHAR_COLON, 3'd2}: glyph_row = 8'b00110000;
            {CHAR_COLON, 3'd4}: glyph_row = 8'b00110000;
            {CHAR_COLON, 3'd5}: glyph_row = 8'b00110000;
            // 'L'
            {CHAR_L, 3'd0}: glyph_row = 8'b11000000;
            {CHAR_L, 3'd1}: glyph_row = 8'b11000000;
            {CHAR_L, 3'd2}: glyph_row = 8'b11000000;
            {CHAR_L, 3'd3}: glyph_row = 8'b11000000;
            {CHAR_L, 3'd4}: glyph_row = 8'b11000000;
            {CHAR_L, 3'd5}: glyph_row = 8'b11000000;
            {CHAR_L, 3'd6}: glyph_row = 8'b11111100;
            // 'A'
            {CHAR_A, 3'd0}: glyph_row = 8'b00110000;
            {CHAR_A, 3'd1}: glyph_row = 8'b01111000;
            {CHAR_A, 3'd2}: glyph_row = 8'b11001100;
            {CHAR_A, 3'd3}: glyph_row = 8'b11001100;
            {CHAR_A, 3'd4}: glyph_row = 8'b11111100;
            {CHAR_A, 3'd5}: glyph_row = 8'b11001100;
            {CHAR_A, 3'd6}: glyph_row = 8'b11001100;
            // 'Y'
            {CHAR_Y, 3'd0}: glyph_row = 8'b11001100;
            {CHAR_Y, 3'd1}: glyph_row = 8'b11001100;
            {CHAR_Y, 3'd2}: glyph_row = 8'b01111000;
            {CHAR_Y, 3'd3}: glyph_row = 8'b00110000;
            {CHAR_Y, 3'd4}: glyph_row = 8'b00110000;
            {CHAR_Y, 3'd5}: glyph_row = 8'b00110000;
            {CHAR_Y, 3'd6}: glyph_row = 8'b00110000;
            // 'E'
            {CHAR_E, 3'd0}: glyph_row = 8'b11111100;
            {CHAR_E, 3'd1}: glyph_row = 8'b11000000;
            {CHAR_E, 3'd2}: glyph_row = 8'b11000000;
            {CHAR_E, 3'd3}: glyph_row = 8'b11111000;
            {CHAR_E, 3'd4}: glyph_row = 8'b11000000;
            {CHAR_E, 3'd5}: glyph_row = 8'b11000000;
            {CHAR_E, 3'd6}: glyph_row = 8'b11111100;
            // 'R'
            {CHAR_R, 3'd0}: glyph_row = 8'b11111000;
            {CHAR_R, 3'd1}: glyph_row = 8'b11001100;
            {CHAR_R, 3'd2}: glyph_row = 8'b11001100;
            {CHAR_R, 3'd3}: glyph_row = 8'b11111000;
            {CHAR_R, 3'd4}: glyph_row = 8'b11011000;
            {CHAR_R, 3'd5}: glyph_row = 8'b11001100;
            {CHAR_R, 3'd6}: glyph_row = 8'b11001100;
            // 'W'
            {CHAR_W, 3'd0}: glyph_row = 8'b11000110;
            {CHAR_W, 3'd1}: glyph_row = 8'b11000110;
            {CHAR_W, 3'd2}: glyph_row = 8'b11000110;
            {CHAR_W, 3'd3}: glyph_row = 8'b11010110;
            {CHAR_W, 3'd4}: glyph_row = 8'b11111110;
            {CHAR_W, 3'd5}: glyph_row = 8'b11101110;
            {CHAR_W, 3'd6}: glyph_row = 8'b11000110;
            // 'I'
            {CHAR_I, 3'd0}: glyph_row = 8'b01111000;
            {CHAR_I, 3'd1}: glyph_row = 8'b00110000;
            {CHAR_I, 3'd2}: glyph_row = 8'b00110000;
            {CHAR_I, 3'd3}: glyph_row = 8'b00110000;
            {CHAR_I, 3'd4}: glyph_row = 8'b00110000;
            {CHAR_I, 3'd5}: glyph_row = 8'b00110000;
            {CHAR_I, 3'd6}: glyph_row = 8'b01111000;
            // 'N'
            {CHAR_N, 3'd0}: glyph_row = 8'b11000110;
            {CHAR_N, 3'd1}: glyph_row = 8'b11100110;
            {CHAR_N, 3'd2}: glyph_row = 8'b11110110;
            {CHAR_N, 3'd3}: glyph_row = 8'b11011110;
            {CHAR_N, 3'd4}: glyph_row = 8'b11001110;
            {CHAR_N, 3'd5}: glyph_row = 8'b11000110;
            {CHAR_N, 3'd6}: glyph_row = 8'b11000110;
            // '!'
            {CHAR_EXCL, 3'd0}: glyph_row = 8'b00110000;
            {CHAR_EXCL, 3'd1}: glyph_row = 8'b00110000;
            {CHAR_EXCL, 3'd2}: glyph_row = 8'b00110000;
            {CHAR_EXCL, 3'd3}: glyph_row = 8'b00110000;
            {CHAR_EXCL, 3'd4}: glyph_row = 8'b00110000;
            {CHAR_EXCL, 3'd6}: glyph_row = 8'b00110000;

            default: glyph_row = 8'b00000000;
        endcase
    end

    wire glyph_on = glyph_row[3'd7 - col];

    assign hud_white  = (in_score_box && glyph_on) || banner_border;
    assign hud_yellow = in_banner_text && glyph_on;

endmodule