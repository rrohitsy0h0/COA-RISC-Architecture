`timescale 1ns/1ps

module ALU (
    input [31:0] x,
    input [31:0] y,
    input add_sub,
    input [4:0] ALU_op,
    output [31:0] ALU_result,
    output Overflow,
    output Zero,
    output Sign
);

    Arithmetic A();

    Logical L();

    Mux M();
    
endmodule