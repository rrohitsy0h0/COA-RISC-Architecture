`timescale 1ns / 1ps

module reg_alu_top(
    input DFT_Display_Select,
    input [2:0] ALU_Operation,
    input [3:0] Rd,
    input [3:0] Rt,
    input [3:0] Rs,
    input execute,
    input clk,
    input rst,
    output reg [15:0] display_output
    );

ALU alu_init(
    .x(rsOut),
    .y(rtOut),
    .add_sub(add_sub),
    .ConstVar(ConstVar),
    .LogicFn(LogicFn),
    .ShiftFn(ShiftFn),
    .FnClass(FnClass),
    .ALU_result(rdIn),
    .Overflow()
    );

registerbank reg_bank(
    .clk(clk),
    .rst(rst),
    .rs({0,Rs}),
    .rt({0,Rt}),
    .rd({0,Rd}),
    .wEnable(execute),
    .rdIn(rdIn),
    .rsOut(rsOut),
    .rtOut(rtOut)
);

reg add_sub,ConstVar;
reg [1:0] LogicFn,ShiftFn;
ref [2:0] FnClass;


wire [31:0] rsOut;
wire [31:0] rtOut;
wire [31:0] rdIn;
    
always @(*) begin
    
    	case(ALU_operation)
		3'000: begin //add
            add_sub=1'b0;
            FnClass=3'b011;
		end
		3'001: begin //sub
            add_sub=1'b1;
            FnClass=3'b011;
		end
		3'010: begin //and
            LogicFn=2'b00;
            FnClass=3'b100;
		end
        3'011: begin //or
            LogicFn=2'b01;
            FnClass=3'b100;
		end
		3'100: begin //xor
            LogicFn=2'b10;
            FnClass=3'b100;
		end
		3'101: begin //sll
            ShiftFn=2'b00;
            FnClass=3'b101;
		end
        3'110: begin //srl
            ShiftFn=2'b01;
            FnClass=3'b101;
		end
		3'111: begin //sra
            ShiftFn=2'b10;
            FnClass=3'b101;
		end
        default: begin
            FnClass=3'b000;
        end
        endcase
end
assign display_output=(DFT_Display_Select) ? rdIn[31:16] : rdIn[15:0];



endmodule