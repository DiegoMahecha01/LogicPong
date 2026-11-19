// debounce.v - Filtro antirrebote sincrono (10 ms @ 50 MHz)
module debounce (
    input  wire clk,
    input  wire reset,
    input  wire btn_in,
    output reg  btn_out
);

    reg [18:0] count;
    reg        btn_state;

    always @(posedge clk) begin
        if (reset) begin
            count     <= 19'd0;
            btn_state <= 1'b0;
            btn_out   <= 1'b0;
        end else begin
            if (btn_in != btn_state) begin
                btn_state <= btn_in;
                count     <= 19'd0;
            end else if (count < 19'd500_000) begin
                count <= count + 19'd1;
            end else begin
                btn_out <= btn_state;
            end
        end
    end

endmodule