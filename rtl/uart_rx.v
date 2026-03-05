`timescale 1ns/1ps

module uart_rx #
(
    parameter CLKS_PER_BIT = 8
)
(
    input        clk,
    input        rst,
    input        rx,
    output reg [7:0] data_out,
    output reg   rx_valid
);

    localparam IDLE      = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT  = 3'd3;

    reg [2:0] state;
    reg [2:0] bit_index;
    reg [15:0] clk_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            rx_valid  <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end
        else begin
            rx_valid <= 0;

            case (state)

            IDLE: begin
                if (rx == 0) begin
                    state <= START_BIT;
                    clk_count <= 0;
                end
            end

            START_BIT: begin
                if (clk_count == (CLKS_PER_BIT/2)) begin
                    if (rx == 0) begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                    end
                    else
                        state <= IDLE;
                end
                else
                    clk_count <= clk_count + 1;
            end

            DATA_BITS: begin
                if (clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    data_out[bit_index] <= rx;

                    if (bit_index < 7)
                        bit_index <= bit_index + 1;
                    else begin
                        bit_index <= 0;
                        state <= STOP_BIT;
                    end
                end
            end

            STOP_BIT: begin
                if (clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else begin
                    rx_valid <= 1;
                    state <= IDLE;
                    clk_count <= 0;
                end
            end

            endcase
        end
    end

endmodule
