// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module shift_unit (
    input ConstVar,
    input [1:0] ShiftFn,
    input [31:0] x,
    input [31:0] y,
    output reg [31:0] Shift_out
);

    reg [4:0] shift_value;
    
    always @(*) begin
        shift_value = ConstVar ? y[4:0] : {4'b0000, y[0]};
    end

    always @(*) begin
        case (ShiftFn)
            2'b00:  Shift_out = x << shift_value;
            2'b01:  Shift_out = x >> shift_value;
            2'b10:  Shift_out = $signed(x) >>> shift_value;
            default: Shift_out = x;
        endcase
    end
    
endmodule