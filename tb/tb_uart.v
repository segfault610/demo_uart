`timescale 1ns/1ps

module tb_uart;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;
    wire [7:0] rx_data;   // will be driven by dut
    wire rx_valid;        // will be driven by dut
    wire tx;              // will be driven by dut

    uart_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .tx(tx)
    );

    initial begin
    	$dumpfile("uart_tb.vcd");   // VCD output file
    	$dumpvars(0, tb_uart);      // dump all signals in tb_uart hierarchy
    end
    // 100MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    // expected signals
    reg [7:0] expected_tx [0:3];
    reg [7:0] expected_rx [0:3];

    integer tx_count = 0;
    integer rx_count = 0;
    integer pass = 0;
    integer fail = 0;
    integer i;
    
    // Task to send a byte
    task send_byte;
        input [7:0] data;
        begin
            @(posedge clk);
            data_in <= data;
            start <= 1;
            expected_tx[tx_count] = data;
            tx_count = tx_count + 1;

            @(posedge clk);
            start <= 0;

            @(posedge rx_valid);
            expected_rx[rx_count] = rx_data;
            rx_count = rx_count + 1;
        end
    endtask

    initial begin
        rst = 1;
        start = 0;
        data_in = 0;

        repeat (5) @(posedge clk);
        rst = 0;

        send_byte(8'hA5);
        send_byte(8'h3C);
        send_byte(8'hF0);
        send_byte(8'h55);

        #20;

        $display("\n==== SCOREBOARD ====");

        for (i = 0; i < tx_count; i = i + 1) begin
            if (expected_tx[i] == expected_rx[i]) begin
                pass = pass + 1;
                $display("PASS Byte %0d : %h", i, expected_rx[i]);
            end
            else begin
                fail = fail + 1;
                $display("FAIL Byte %0d : TX=%h RX=%h",
                         i, expected_tx[i], expected_rx[i]);
            end
        end

        $display("TOTAL PASS = %0d", pass);
        $display("TOTAL FAIL = %0d", fail);

        $finish;
    end

endmodule
