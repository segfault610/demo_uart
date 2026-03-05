`timescale 1ns/1ps

module uart_top
(
    input clk,
    input rst,
    input start,
    input [7:0] data_in,
    output [7:0] rx_data,
    output rx_valid,
    output tx
);

    wire tx_line;

    uart_tx #(.CLKS_PER_BIT(8)) TX (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx_line),
        .busy()
    );

    uart_rx #(.CLKS_PER_BIT(8)) RX (
        .clk(clk),
        .rst(rst),
        .rx(tx_line),
        .data_out(rx_data),
        .rx_valid(rx_valid)
    );

    assign tx = tx_line;

endmodule
