`timescale 1ns/1ps
module testbench_ALU;
    /* ───────── registers that drive the DUT ───────── */
    reg  [31:0] x, y;
    reg         add_sub;
    reg         ConstVar;
    reg  [1:0]  LogicFn;
    reg  [1:0]  ShiftFn;
    reg  [2:0]  FnClass;

    /* ───────── wires that observe the DUT ─────────── */
    wire [31:0] ALU_result;
    wire        Overflow;

    /* ───────── DUT instantiation ──────────────────── */
    ALU uut (
        .x        (x),
        .y        (y),
        .add_sub  (add_sub),
        .ConstVar (ConstVar),
        .LogicFn  (LogicFn),
        .ShiftFn  (ShiftFn),
        .FnClass  (FnClass),
        .ALU_result (ALU_result),
        .Overflow   (Overflow)
    );

    /* pretty-print current opcode */
    reg [7*8-1:0] op_name;
    always @(*) begin
        unique case (FnClass)
            3'b000: op_name = "LUI";
            3'b001: op_name = "SLT";
            3'b010: op_name = "SGT";
            3'b011: op_name = add_sub ? "SUB/DEC" : "ADD/INC";
            3'b100: begin
                case (LogicFn)
                    2'b00: op_name = "AND";
                    2'b01: op_name = "OR";
                    2'b10: op_name = "XOR";
                    2'b11: op_name = "NOR/NOT";
                    default: op_name = "LOGIC?";
                endcase
            end
            3'b101: begin
                case (ShiftFn)
                    2'b00: op_name = ConstVar ? "SLL"  : "SLLI";
                    2'b01: op_name = ConstVar ? "SRL"  : "SRLI";
                    2'b10: op_name = ConstVar ? "SRA"  : "SRAI";
                    default: op_name = "SHIFT?";
                endcase
            end
            3'b110: op_name = "HAM";
            default: op_name = "---";
        endcase
    end

    /* ───────── waveform & header ───────────────────── */
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, testbench_ALU);
        $display("time   x            y            op       res           OV");
        $monitor("%4t  %h  %h  %s  %h  %b",
                 $time, x, y, op_name, ALU_result, Overflow);

    /* ───────── basic arithmetic & logic checks ─────── */
        x=10;  y=5;   add_sub=0; ConstVar=0; LogicFn=0; ShiftFn=0; FnClass=3'b011; #10; // ADD
        x=10;  y=5;   add_sub=1;                                 #10;               // SUB
        LogicFn=2'b00; FnClass=3'b100;                           #10;               // AND
        LogicFn=2'b01;                                           #10;               // OR
        LogicFn=2'b10;                                           #10;               // XOR
        LogicFn=2'b11;                                           #10;               // NOR

    /* ───────── SLT / SGT checks ─────────────────────── */
        x=5;   y=10;  add_sub=1; FnClass=3'b001;                 #10;               // SLT true
        x=10;  y=5;                    FnClass=3'b010;           #10;               // SGT true
        x=10;  y=10;                   FnClass=3'b010;           #10;               // SGT false (equal)

    /* ───────── LUI check ───────────────────────────── */
        x=0;   y=32'h0000_ABCD; FnClass=3'b000;                  #10;

    /* ───────── overflow checks (add / sub) ─────────── */
        x=32'h7FFFFFFF; y=1;  add_sub=0; FnClass=3'b011;         #10;               // add overflow
        x=32'h7FFFFFFF; y=-1; add_sub=1;                         #10;               // sub overflow

    /* ───────── HAM (popcount) check ────────────────── */
        x=32'hF0F0_000F;   FnClass=3'b110;                       #10;               // expect 12

    /* ───────── shift tests (variable amount) ───────── */
        ConstVar=0; ShiftFn=2'b00; x=1;   y=3; FnClass=3'b101;   #10;               // SLL by 3
        ShiftFn=2'b01;              x=32'hF000_0000; y=4;        #10;               // SRL by 4
        ShiftFn=2'b10;              x=32'hF000_0000;             #10;               // SRA by 4

    /* ───────── single-bit shift tests (ConstVar=0) ─── */
        ConstVar=1; ShiftFn=2'b00; x=1;           y=1; #10;      // SLLI by 1
        ShiftFn=2'b01;             x=32'h8000_0000; #10;         // SRLI by 1
        ShiftFn=2'b10;             x=32'h8000_0000; #10;         // SRAI by 1

    /* ───────── INC / DEC (adder with constant 1) ───── */
        FnClass=3'b011; add_sub=0; x=9; y=1;                     #10;               // INC
        add_sub=1;                                             #10;               // DEC

        $finish;
    end
endmodule
