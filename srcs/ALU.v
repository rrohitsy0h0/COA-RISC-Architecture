// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module ALU (
    input [31:0] x,
    input [31:0] y,
    input add_sub,
    input ConstVar,
    input [1:0]  LogicFn,
    input [1:0] ShiftFn,
    input [2:0]  FnClass,
    output [31:0] ALU_result,
    output Overflow
);
    wire [31:0] F;
    wire [31:0] L;
    wire [31:0] LUI16;
    wire [31:0] slt;
    wire [31:0] sgt;
    wire [31:0] Shift_out;
    wire [31:0] HAM_out;
    wire [31:0] y_input = add_sub ? ~y : y; //1'
    wire C_Flag;

    Arithmetic A_unit (
        .x(x),
        .y_input(y_input),
        .add_sub(add_sub),
        .A_out(F),
        .cout(C_Flag),
        .Overflow(Overflow)
    );

    logic_unit L_unit (
        .x(x),
        .y(y),
        .logicfn(LogicFn),
        .l_output(L)
    );

    wire Z_Flag = ~|F;
    wire S_Flag = F[31];
    // wire V_Flag = C_Flag ^ S_Flag;
    
    // assign Overflow = V_Flag;

    assign LUI16 = {y[15:0], 16'b0};
    assign slt = {31'b0, S_Flag};
    assign sgt = {31'b0, ~(S_Flag|Z_Flag)};

    shift_unit S_unit(
        .ConstVar(ConstVar),
        .ShiftFn(ShiftFn),
        .x(x),
        .y(y),
        .Shift_out(Shift_out)
    );

    HAM_unit H_unit(
        .x(x),
        .HAM_out(HAM_out)        
    );

    Fn_mux M_unit (
        .LUI16(LUI16),
        .slt(slt),
        .sgt(sgt),
        .A_out(F),
        .L_out(L),
        .Shift_out(Shift_out),
        .HAM_out(HAM_out),
        .FnClass(FnClass),
        .Result(ALU_result)
    );
    
endmodule