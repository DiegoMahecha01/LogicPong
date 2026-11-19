// mcp3008.v - Interfaz maestra SPI (Modo 0,0) para lectura alternada de CH0 y CH1
module mcp3008 (
    input  wire       clk,
    input  wire       reset,
    output reg        sclk,
    output reg        cs_n,
    output reg        mosi,
    input  wire       miso,
    output reg  [9:0] ch0,
    output reg  [9:0] ch1
);

    // Divisor de reloj: 50 MHz / 64 = 781.25 kHz
    reg [4:0] clk_div = 5'd0;
    wire spi_tick = (clk_div == 5'd31);

    always @(posedge clk) begin
        if (reset)
            clk_div <= 5'd0;
        else
            clk_div <= clk_div + 5'd1;
    end

    localparam ST_IDLE     = 1'b0;
    localparam ST_TRANSFER = 1'b1;

    reg       state    = ST_IDLE;
    reg       chan_sel = 1'b0;
    reg [4:0] bit_idx  = 5'd0;
    reg [9:0] shift_in = 10'd0;

    always @(posedge clk) begin
        if (reset) begin
            state    <= ST_IDLE;
            chan_sel <= 1'b0;
            bit_idx  <= 5'd0;
            shift_in <= 10'd0;
            sclk     <= 1'b0;
            cs_n     <= 1'b1;
            mosi     <= 1'b1;
            ch0      <= 10'd512;
            ch1      <= 10'd512;
        end else if (spi_tick) begin
            case (state)
                ST_IDLE: begin
                    sclk     <= 1'b0;
                    cs_n     <= 1'b0;
                    mosi     <= 1'b1;
                    bit_idx  <= 5'd0;
                    shift_in <= 10'd0;
                    state    <= ST_TRANSFER;
                end

                ST_TRANSFER: begin
                    if (sclk == 1'b0) begin
                        // Flanco de subida: muestreo de palabra de 10 bits desde DOUT
                        sclk <= 1'b1;
                        if (bit_idx >= 5'd7 && bit_idx <= 5'd16)
                            shift_in <= {shift_in[8:0], miso};
                    end else begin
                        // Flanco de bajada: envio de trama de configuracion single-ended
                        sclk <= 1'b0;
                        if (bit_idx == 5'd16) begin
                            if (chan_sel == 1'b0)
                                ch0 <= shift_in;
                            else
                                ch1 <= shift_in;
                            cs_n     <= 1'b1;
                            chan_sel <= ~chan_sel;
                            state    <= ST_IDLE;
                        end else begin
                            case (bit_idx)
                                5'd0:    mosi <= 1'b1;     // Bit de inicio
                                5'd1:    mosi <= 1'b0;     // Modo single-ended (SGL/DIFF)
                                5'd2:    mosi <= 1'b0;     // D2
                                5'd3:    mosi <= chan_sel; // D1/D0: seleccion CH0 / CH1
                                default: mosi <= 1'b0;
                            endcase
                            bit_idx <= bit_idx + 5'd1;
                        end
                    end
                end
            endcase
        end
    end

endmodule