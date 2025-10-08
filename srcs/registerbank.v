// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module registerbank(
    input clk,
    input rst,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [31:0] rdIn,
    output [31:0] rtOut
    output [31:0] rsOut
);
    integer i;
    reg [31:0] regfile [31:0];

    always @(*) begin
        if(rst) begin
            for(i=0;i<32;i=1+1) begin
                regfile[i]=32'd0;
            end
        end else begin
            rsOut=regfile[rs];
            rtOut=regfile[rt];
        end
    end

    always @(negedge clk) begin
        if(wrReg) begin
            regfile[rd]=rdIn;
        end
    end
endmodule