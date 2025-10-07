// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module registerbank(rs,rt,rd,rdIn,rtOut,rsOut,wrReg,clk);
    input [4:0] rs,rt,rd;
    input [31:0] rdIn;
    input wrReg, clk;
    output reg [31:0] rtOut, rsOut;

    reg [31:0] regs [0:31];
    
    integer i;
    
    initial begin
        for(i=0;i<32;i=i+1) begin
            regs[i]=32'b0;
        end
    end
    
    always @(posedge clk) begin
        if (wrReg && (rd!=5'd0)) begin
            regs[rd]<=rdIn;
        end
        regs[0]<=32'b0;
    end
    
    always @(*) begin
        //rs
        if (rs==5'd0) begin
            rsOut=32'b0;
            end 
        else if (wrReg && (rd==rs) && (rd!=5'd0)) begin
            rsOut=rdIn;
            end 
        else begin
            rsOut=regs[rs];
        end

        //rt
        if (rt==5'd0) begin
            rtOut=32'b0;
            end 
        else if (wrReg && (rd==rt) && (rd!=5'd0)) begin
            rtOut=rdIn;
            end 
        else begin
            rtOut=regs[rt];
        end
    end
    
endmodule