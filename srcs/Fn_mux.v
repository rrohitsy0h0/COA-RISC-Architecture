// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module Fn_mux(
    input [31:0] LUI16,
    input [31:0] sl,
    input [31:0] A_out,
    input [31:0] L_out,
    input [1:0] FnClass,
    output Result
);

assign Result=(FnClass==2'b00) ? LUI16 : 32'b0;
assign Result=(FnClass==2'b01) ? sl : 32'b0;
assign Result=(FnClass==2'b10) ? A_out : 32'b0;
assign Result=(FnClass==2'b11) ? L_out : 32'b0;

endmodule