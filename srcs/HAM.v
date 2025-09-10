// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module HAM_unit (
    input [31:0] x,
    output [31:0] HAM_out
);

    integer i;
    reg [5:0] count;

    always @(*) begin
        count = 0;
        for (i = 0; i < 32; i = i + 1) begin
            count = count + x[i];
        end
    end

    assign HAM_out = {26'b0,count};

endmodule