module Arithmetic (
    input [31:0] x,
    input [31:0] y_input,
    input add_sub,
    output [31:0] A_out,
    output cout
);
    fulladderN(.a(x),.b(y_input),.cin(add_sub),.cout(cout),.sum(A_out));
endmodule