// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module fulladder1(
    input a,b,cin,
    output cout,sum
);

wire w1,w2,w3;
xor(w1,a,b);
xor(sum,w1,cin);
and(w2,a,b);
and(w3,w1,cin);
or(cout,w2,w3);

endmodule