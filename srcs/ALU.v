// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module ALU (
    input [31:0] x,
    input [31:0] y,
    input add_sub,
    input [1:0] LogicFn,
    input [1:0] FnClass,
    output [31:0] ALU_result,
    output Overflow
);

    wire C_Flag,Z_Flag,S_Flag,V_Flag;
    wire [31:0] F;
    wire [31:0] L;
    wire [31:0] LUI16;
    wire [31:0] sl;

    assign y_input = (add_sub==1'b1) ? ~y : y; //XOR of y and add_sum

    Arithmetic A( // Arithmetic Unit
        .x(x),
        .y_input(y_input),
        .add_sub(add_sub),
        .A_out(F),
        .cout(C_Flag)
    );

    assign Z_Flag = ~|F;
    assign S_Flag = F[31];
    assign V_Flag = C_Flag ^ S_Flag;
    assign Overflow = V_Flag;

    logic L( // Logical Unit
        .x(x),
        .y(y),
        .logicfn(LogicFn),
        .l_output(L)
    );

    assign LUI16 = {y[15:0],16'b0}; // Pad 16 0's to the immediate portion

    assign sl = (S_Flag==1'b1) ? 32'b1 : 32'b0; // assigning 1 for x < y else 0

    Fn_mux M(
        .LUI16(LUI16),
        .sl(sl),
        .A_out(F),
        .L_out(L),
        .FnClass(FnClass),
        .Result(ALU_result)
    );
    
endmodule