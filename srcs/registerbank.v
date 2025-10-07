// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module registerbank(
    input clk,               // Clock signal
    input rst,               // Reset signal
    input wrReg,             // Write enable
    input [4:0] rs,          // Read register 1 address
    input [4:0] rt,          // Read register 2 address
    input [4:0] rd,          // Write register address
    input [31:0] rdIn,       // Write data
    output reg [31:0] rsOut, // Read data 1
    output reg [31:0] rtOut  // Read data 2
);

//x0 is always 0

    reg [31:0] regs [0:31];
    
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<32;i=i+1) begin
                regs[i] <= 32'b0;
            end
        end
        else begin
            if (wrReg && (rd!=5'd0)) begin //write enable and rd is not x0
                regs[rd] <= rdIn;
            end
            regs[0] <= 32'b0; //always 0
        end
    end

    //read rs
    always @(*) begin
        if (rs==5'd0) begin
            rsOut=32'b0;
        end else if (wrReg && (rd==rs) && (rd!=5'd0)) begin
            rsOut=rdIn; //forward write
            regs[rs] <= rdIn; //??
        end else begin
            rsOut=regs[rs];
        end
    end
    
    //read rt
    always @(*) begin
        if (rt==5'd0) begin
            rtOut=32'b0;
        end else if (wrReg && (rd==rt) && (rd!=5'd0)) begin
            rtOut=rdIn;  //forward write
            regs[rt] <= rdIn; //??
        end else begin
            rtOut=regs[rt];
        end
    end
endmodule