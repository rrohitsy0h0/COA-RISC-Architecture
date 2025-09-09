// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module logic_unit(
    input  [31:0] x, y,
    input  [1:0]  logicfn,
    output reg [31:0] l_output 
);
    always @(*) begin
        case (logicfn)
            2'b00:  l_output = x & y;
            2'b01:  l_output = x | y;
            2'b10:  l_output = x ^ y;
            2'b11:  l_output = ~(x | y);
            default: l_output = 32'b0;
        endcase
    end
endmodule