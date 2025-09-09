// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module fulladderN(
    input [31:0] a,b,
    input cin,
    output cout,
    output [31:0] sum
);

wire [31:0] carry;
fulladder1(.a(a[0]),.b(b[0]),.cin(cin),.sum(sum[0]),.cout(carry[0]));

genvar i;
generate
    for(i=1;i<32;i=i+1) begin: addmodule
        fulladder1(.a(a[i]),.b(b[i]),.cin(carry[i-1]),.sum(sum[i]),.cout(carry[i]));
    end
endgenerate
assign cout=carry[31];
endmodule
