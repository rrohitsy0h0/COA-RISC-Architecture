`timescale 1ns/1ps

module ALU (
    input [31:0] x,
    input [31:0] y,
    input add_sub,
    input [1:0] LogicFn,
    input [1:0] fn,
    output [31:0] ALU_result,
    output Overflow,
);

    wire C_Flag,Z_Flag,S_Flag,V_Flag;
    wire [31:0] F;
    Arithmetic A(
        .x(x),
        .y_input(y_input),
        .add_sub(add_sub),
        .A_out($$),
        .cout());

    logic L(
        .x(x),.y(y),.logicfn(LogicFn),.l_output(F)
    );

    Mux M();
    
endmodule