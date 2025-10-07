`timescale 1ns / 1ps

module registerbank_tb;
    reg clk,rst,wrReg;
    reg [4:0] rs,rt,rd;
    reg [31:0] rdIn;
    wire [31:0] rsOut,rtOut;
    
    registerbank uut (
        .clk(clk),.rst(rst),.wrReg(wrReg),
        .rs(rs),.rt(rt),.rd(rd),
        .rdIn(rdIn),.rsOut(rsOut),.rtOut(rtOut)
    );
    
    initial begin
        clk=0;
        forever #5 clk=~clk;
    end
    
    initial begin
        // Test reset
        rst=1; wrReg=0;
        #10 rst=0;
        
        // Write to x1
        wrReg=1; rd=5'd1; rdIn=32'hDEADBEEF;
        #10;
        
        // Read from x1
        rs=5'd1; rt=5'd0;
        #10;
        
        $display("x1=%h (expected DEADBEEF)",rsOut);
        
        rd=5'd2; rdIn=32'hCAFEBABE;
        rs=5'd2;
        #1;
        $display("Forwarded x2=%h (expected CAFEBABE)",rsOut);
        
        #20 $finish;
    end
endmodule