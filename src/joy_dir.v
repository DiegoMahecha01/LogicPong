// joy_dir.v - Decodificador direccional con zona muerta para eje analogico de 10 bits
module joy_dir #(
    parameter INVERT = 1'b0
) (
    input  wire [9:0] value,
    output wire       up,
    output wire       down
);

    wire low_zone  = (value < 10'd350);
    wire high_zone = (value > 10'd670);

    assign up   = INVERT ? high_zone : low_zone;
    assign down = INVERT ? low_zone  : high_zone;

endmodule