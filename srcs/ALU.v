`timescale 1ns/1ps

module ALU (
    input [31:0] x,
    input [31:0] y,
    input add_sub,
    input [1:0] LogicFn,
    input [1:0] fn,
    output [31:0] ALU_result,
    output Overflow,
    output Zero,
    output Sign
);

    Arithmetic A(
        .x(x),
        .y_input(y_input),
        .add_sub(add_sub),
        .A_out($$),
        .cout());

    Logical L();

    Mux M();
    
endmodule