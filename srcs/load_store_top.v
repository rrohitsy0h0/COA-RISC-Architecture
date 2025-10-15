// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module load_store_top(
    input DFT_Display_Select,
    input operation_select,
    input clk,
    input rst,
    input execute,
    input [3:0] reg_select,
    input [3:0] base_reg,
    input [5:0] offset,
    output reg [15:0] display_output
);

endmodule