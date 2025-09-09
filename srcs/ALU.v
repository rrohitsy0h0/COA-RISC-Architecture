// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module ALU (
    input  [31:0] x,
    input  [31:0] y,
    input         add_sub,
    input  [1:0]  LogicFn,
    input  [1:0]  FnClass,
    output [31:0] ALU_result,
    output        Overflow
);
    wire [31:0] F;
    wire [31:0] L;
    wire [31:0] LUI16;
    wire [31:0] sl;
    wire [31:0] y_input;
    wire        carry_out_31;

    assign y_input = add_sub ? ~y : y; //1'

    Arithmetic A_unit (
        .x(x),
        .y_input(y_input),
        .add_sub(add_sub),
        .A_out(F),
        .cout(carry_out_31)
    );

    logic_unit L_unit (
        .x(x),
        .y(y),
        .logicfn(LogicFn),
        .l_output(L)
    );

    wire S_Flag = F[31];
    wire V_Flag = (x[31] == y_input[31]) && (S_Flag != x[31]);
    assign Overflow = V_Flag;

    assign LUI16 = {y[15:0], 16'b0};
    assign sl = {31'b0, S_Flag};

    Fn_mux M_unit (
        .LUI16(LUI16),
        .sl(sl),
        .A_out(F),
        .L_out(L),
        .FnClass(FnClass),
        .Result(ALU_result)
    );
    
endmodule