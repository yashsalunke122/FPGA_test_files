module uart_tx(
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);
    parameter CLKS_PER_BIT = 868; // 100_000_000 / 115200 ≈ 868

    reg [9:0] shift_reg;
    reg [3:0] bit_idx;
    reg [15:0] clk_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1;
            tx_busy <= 0;
            shift_reg <= 10'b1111111111;
            bit_idx <= 0;
            clk_cnt <= 0;
        end else begin
            if (tx_start && !tx_busy) begin
                shift_reg <= {1'b1, tx_data, 1'b0};
                tx_busy <= 1;
                bit_idx <= 0;
                clk_cnt <= 0;
            end else if (tx_busy) begin
                if (clk_cnt == CLKS_PER_BIT-1) begin
                    clk_cnt <= 0;
                    tx <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_idx <= bit_idx + 1;
                    if (bit_idx == 9)
                        tx_busy <= 0;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end
        end
    end
endmodule
