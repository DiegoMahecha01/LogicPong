// vga_sync.v - Generador de sincronismo VGA 640x480 @ 60 Hz
module vga_sync (
    input  wire       clk,
    input  wire       reset,
    output reg        hsync,
    output reg        vsync,
    output wire       video_on,
    output wire [9:0] x,
    output wire [9:0] y
);

    // Divisor de 50 MHz a 25 MHz (pulso de pixel)
    reg pix_tick = 1'b0;
    always @(posedge clk) begin
        pix_tick <= ~pix_tick;
    end

    // Contadores de barrido (800 x 525 totales)
    reg [9:0] h_count = 10'd0;
    reg [9:0] v_count = 10'd0;

    always @(posedge clk) begin
        if (reset) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else if (pix_tick) begin
            if (h_count == 10'd799) begin
                h_count <= 10'd0;
                if (v_count == 10'd524)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 1'b1;
            end else begin
                h_count <= h_count + 1'b1;
            end
        end
    end

    // Pulsos de sincronismo activos en bajo
    always @(posedge clk) begin
        if (pix_tick) begin
            hsync <= ~((h_count >= 10'd656) && (h_count <= 10'd751));
            vsync <= ~((v_count >= 10'd490) && (v_count <= 10'd491));
        end
    end

    assign video_on = (h_count < 10'd640) && (v_count < 10'd480);
    assign x = h_count;
    assign y = v_count;

endmodule