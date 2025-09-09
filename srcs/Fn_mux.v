// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module Fn_mux(
    input  [31:0] LUI16,
    input  [31:0] sl,
    input  [31:0] A_out,
    input  [31:0] L_out,
    input  [1:0]  FnClass,
    output reg [31:0] Result
);
    always @(*) begin
        case (FnClass)
            2'b00:  Result = LUI16;
            2'b01:  Result = sl;
            2'b10:  Result = A_out;
            2'b11:  Result = L_out;
            default: Result = 32'b0;
        endcase
    end
endmodule