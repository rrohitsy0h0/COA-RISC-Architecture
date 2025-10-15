// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module registerbank(
    input clk,
    input rst,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input wEnable,  
    input [31:0] rdIn,
    output [31:0] rsOut,
    output [31:0] rtOut,
    output [31:0] rdOut    
);
    integer i;
    reg [31:0] regfile [0:31];

    assign rsOut = regfile[rs];
    assign rtOut = regfile[rt];
    assign rdOut = regfile[rd];
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= i;
            end
        end else if (wEnable) begin
            regfile[rd] <= rdIn;        
        end
    end
    
endmodule