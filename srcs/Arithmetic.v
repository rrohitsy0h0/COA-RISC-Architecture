// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module Arithmetic (
    input [31:0] x,
    input [31:0] y_input,
    input add_sub,
    output [31:0] A_out,
    output cout
);
    fulladderN(.a(x),.b(y_input),.cin(add_sub),.cout(cout),.sum(A_out));
endmodule