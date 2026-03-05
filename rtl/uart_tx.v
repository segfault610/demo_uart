`timescale 1ns/1ps

module uart_tx #
(
    parameter CLKS_PER_BIT = 8
)
(
    input clk,
    input rst,
    input start,
    input [7:0] data_in,
    output reg tx,
    output reg busy
);

    localparam IDLE      = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT  = 3'd3;

    reg [2:0] state;
    reg [2:0] bit_index;
    reg [15:0] clk_count;
    reg [7:0] data_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1'b1;
            busy <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
        end
        else begin
            case (state)

            IDLE: begin
                tx <= 1'b1;
                busy <= 1'b0;
                clk_count <= 0;
                bit_index <= 0;

                if (start) begin
                    busy <= 1'b1;
                    data_reg <= data_in;
                    state <= START_BIT;
                end
            end

            START_BIT: begin
                tx <= 1'b0;
                if (clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    state <= DATA_BITS;
                end
            end

            DATA_BITS: begin
                tx <= data_reg[bit_index];

                if (clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    if (bit_index < 7)
                        bit_index <= bit_index + 1;
                    else begin
                        bit_index <= 0;
                        state <= STOP_BIT;
                    end
                end
            end

            STOP_BIT: begin
                tx <= 1'b1;
                if (clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else begin
                    state <= IDLE;
                    clk_count <= 0;
                end
            end

            endcase
        end
    end

endmodule
