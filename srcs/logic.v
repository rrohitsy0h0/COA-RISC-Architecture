// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module logic(
    input [31:0] x,y,
    input [1:0] logicfn
    output l_output
);

assign l_output=(logicfn==2'b00) ? (x & y) : 32'b0;
assign l_output=(logicfn==2'b01) ? (x | y) : 32'b0;
assign l_output=(logicfn==2'b10) ? (x ^ y) : 32'b0;
assign l_output=(logicfn==2'b11) ? ~(x | y) : 32'b0;

endmodule