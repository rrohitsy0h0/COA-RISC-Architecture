`timescale 1ns / 1ps

module registerbank(
    input clk,
    input rst,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input wEnable,  
    input [31:0] rdIn,
    output reg [31:0] rsOut,
    output reg [31:0] rtOut    
);
    
    integer i;
    reg [31:0] regfile [0:31];
    
    // FIXED: Asynchronous reset with proper sensitivity list
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= i;  // Initialize register[i] = i
            end
        end else if (wEnable) begin
            regfile[rd] <= rdIn;        
        end
    end
    
    // Combinational read logic
    always @(*) begin
        rsOut = regfile[rs];
        rtOut = regfile[rt];
    end 
    
endmodule
