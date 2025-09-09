// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module Fn_mux(
    input [31:0] LUI16,
    input [31:0] slt,
    input [31:0] sgt,    
    input [31:0] A_out,
    input [31:0] L_out,
    input [31:0] Shift_out, 
    input [31:0] HAM_out,   
    input [2:0]  FnClass,
    output reg [31:0] Result
);
    always @(*) begin
        case (FnClass)
            3'b000:  Result = LUI16;
            3'b001:  Result = slt;
            3'b010:  Result = sgt; 
            3'b011:  Result = A_out;
            3'b100:  Result = L_out;
            3'b101:  Result = Shift_out;
            3'b110:  Result = HAM_out;
            3'b111:  Result = 32'b0;
            default: Result = 32'b0;
        endcase
    end
endmodule