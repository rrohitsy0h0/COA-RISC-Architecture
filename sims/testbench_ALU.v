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

    /* ───────── test tracking variables ─────────────── */
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    reg [31:0] expected_result;
    reg expected_overflow;

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

    /* ───────── pretty-print current opcode ─────────── */
    reg [8*8-1:0] op_name;
    always @(*) begin
        case (FnClass)
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
            default: op_name = "UNKNOWN";
        endcase
    end

    /* ───────── test checking task ───────────────────── */
    task check_result(
        input [31:0] expected_res,
        input expected_ov,
        input [8*20-1:0] test_name
    );
        begin
            test_count = test_count + 1;
            #1; // small delay to ensure signals settle
            
            if (ALU_result === expected_res && Overflow === expected_ov) begin
                $display("PASS: %s - Got: %h (OV=%b)", test_name, ALU_result, Overflow);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s", test_name);
                $display("      Expected: %h (OV=%b), Got: %h (OV=%b)", 
                        expected_res, expected_ov, ALU_result, Overflow);
                fail_count = fail_count + 1;
            end
        end
    endtask

    /* ───────── comprehensive test suite ─────────────── */
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, testbench_ALU);
        
        $display("========================================");
        $display("         ALU COMPREHENSIVE TEST         ");
        $display("========================================");
        
        // Initialize all control signals
        x = 0; y = 0; add_sub = 0; ConstVar = 0; 
        LogicFn = 0; ShiftFn = 0; FnClass = 0;
        #5;

        $display("\n--- ARITHMETIC TESTS (ADD/SUB) ---");
        
        // Basic addition tests
        FnClass = 3'b011; add_sub = 0; ConstVar = 0;
        x = 10; y = 5; #10;
        check_result(32'd15, 1'b0, "ADD: 10 + 5");
        
        x = 0; y = 0; #10;
        check_result(32'd0, 1'b0, "ADD: 0 + 0");
        
        x = 32'hFFFFFFFF; y = 1; #10;
        check_result(32'd0, 1'b0, "ADD: -1 + 1 (wrap)");
        
        // Basic subtraction tests
        add_sub = 1;
        x = 10; y = 5; #10;
        check_result(32'd5, 1'b0, "SUB: 10 - 5");
        
        x = 5; y = 10; #10;
        check_result(32'hFFFFFFFB, 1'b0, "SUB: 5 - 10 (negative)");
        
        x = 0; y = 1; #10;
        check_result(32'hFFFFFFFF, 1'b0, "SUB: 0 - 1");

        // Overflow tests
        add_sub = 0;
        x = 32'h7FFFFFFF; y = 1; #10;
        check_result(32'h80000000, 1'b1, "ADD overflow: MAX_POS + 1");
        
        x = 32'h7FFFFFFF; y = 32'h7FFFFFFF; #10;
        check_result(32'hFFFFFFFE, 1'b1, "ADD overflow: MAX_POS + MAX_POS");
        
        add_sub = 1;
        x = 32'h80000000; y = 1; #10;
        check_result(32'h7FFFFFFF, 1'b1, "SUB overflow: MIN_NEG - 1");
        
        x = 32'h7FFFFFFF; y = 32'h80000000; #10;
        check_result(32'hFFFFFFFF, 1'b1, "SUB overflow: MAX_POS - MIN_NEG");

        $display("\n--- LOGIC OPERATION TESTS ---");
        
        FnClass = 3'b100; ConstVar = 0;
        x = 32'hAAAAAAAA; y = 32'h55555555;
        
        LogicFn = 2'b00; #10; // AND
        check_result(32'h00000000, 1'b1, "AND: 0xAAAAAAAA & 0x55555555");
        
        LogicFn = 2'b01; #10; // OR
        check_result(32'hFFFFFFFF, 1'b1, "OR: 0xAAAAAAAA | 0x55555555");
        
        LogicFn = 2'b10; #10; // XOR
        check_result(32'hFFFFFFFF, 1'b1, "XOR: 0xAAAAAAAA ^ 0x55555555");
        
        LogicFn = 2'b11; #10; // NOR
        check_result(32'h00000000, 1'b1, "NOR: ~(0xAAAAAAAA | 0x55555555)");
        
        // Test with same values
        x = 32'hF0F0F0F0; y = 32'hF0F0F0F0;
        
        LogicFn = 2'b00; #10; // AND
        check_result(32'hF0F0F0F0, 1'b0, "AND: same values");
        
        LogicFn = 2'b10; #10; // XOR
        check_result(32'h00000000, 1'b0, "XOR: same values");

        $display("\n--- COMPARISON TESTS (SLT/SGT) ---");
        
        // SLT tests
        FnClass = 3'b001;
        x = 5; y = 10; #10;
        check_result(32'd1, 1'b0, "SLT: 5 < 10 (true)");
        
        x = 10; y = 5; #10;
        check_result(32'd0, 1'b0, "SLT: 10 < 5 (false)");
        
        x = 5; y = 5; #10;
        check_result(32'd0, 1'b0, "SLT: 5 < 5 (false)");
        
        x = 32'hFFFFFFFF; y = 1; #10; // -1 < 1
        check_result(32'd1, 1'b0, "SLT: -1 < 1 (true)");
        
        x = 1; y = 32'hFFFFFFFF; #10; // 1 < -1
        check_result(32'd0, 1'b0, "SLT: 1 < -1 (false)");
        
        // SGT tests
        FnClass = 3'b010;
        x = 10; y = 5; #10;
        check_result(32'd1, 1'b0, "SGT: 10 > 5 (true)");
        
        x = 5; y = 10; #10;
        check_result(32'd0, 1'b0, "SGT: 5 > 10 (false)");
        
        x = 5; y = 5; #10;
        check_result(32'd0, 1'b0, "SGT: 5 > 5 (false)");
        
        x = 1; y = 32'hFFFFFFFF; #10; // 1 > -1
        check_result(32'd1, 1'b0, "SGT: 1 > -1 (true)");

        $display("\n--- LUI (Load Upper Immediate) TESTS ---");
        
        FnClass = 3'b000;
        x = 32'hDEADBEEF; y = 32'h0000ABCD; #10; // x should be ignored
        check_result(32'hABCD0000, 1'b0, "LUI: load 0xABCD");
        
        y = 32'h00000000; #10;
        check_result(32'h00000000, 1'b0, "LUI: load 0x0000");
        
        y = 32'h0000FFFF; #10;
        check_result(32'hFFFF0000, 1'b0, "LUI: load 0xFFFF");

        $display("\n--- SHIFT OPERATION TESTS ---");
        
        FnClass = 3'b101;
        
        // Logical Left Shift tests
        ShiftFn = 2'b00; ConstVar = 0; // Variable shift
        x = 32'h00000001; y = 4; #10;
        check_result(32'h00000010, 1'b0, "SLL: 1 << 4");
        
        x = 32'hF0000000; y = 1; #10;
        check_result(32'hE0000000, 1'b0, "SLL: 0xF0000000 << 1");
        
        x = 32'h00000001; y = 31; #10;
        check_result(32'h80000000, 1'b0, "SLL: 1 << 31");
        
        x = 32'h00000001; y = 32; #10; // Should shift by 0 (y[4:0] = 0)
        check_result(32'h00000000, 1'b0, "SLL: 1 << 32");
        
        // Logical Right Shift tests
        ShiftFn = 2'b01;
        x = 32'h80000000; y = 1; #10;
        check_result(32'h40000000, 1'b1, "SRL: 0x80000000 >> 1");
        
        x = 32'h0000000F; y = 2; #10;
        check_result(32'h00000003, 1'b0, "SRL: 0xF >> 2");
        
        x = 32'h80000000; y = 31; #10;
        check_result(32'h00000001, 1'b1, "SRL: 0x80000000 >> 31");
        
        // Arithmetic Right Shift tests
        ShiftFn = 2'b10;
        x = 32'h80000000; y = 1; #10;
        check_result(32'hC0000000, 1'b1, "SRA: 0x80000000 >> 1 (sign extend)");
        
        x = 32'h7FFFFFFF; y = 1; #10;
        check_result(32'h3FFFFFFF, 1'b0, "SRA: 0x7FFFFFFF >> 1");
        
        x = 32'hFFFFFFFF; y = 4; #10;
        check_result(32'hFFFFFFFF, 1'b0, "SRA: -1 >> 4 (all 1s)");
        
        // Constant shift tests (by 1)
        ConstVar = 1;
        
        ShiftFn = 2'b00; // SLLI
        x = 32'h12345678; y = 32'hDEADBEEF; #10; // y ignored
        check_result(32'h2468ACF0, 1'b0, "SLLI: 0x12345678 << 1");
        
        ShiftFn = 2'b01; // SRLI
        x = 32'h12345678; #10;
        check_result(32'h091A2B3C, 1'b0, "SRLI: 0x12345678 >> 1");
        
        ShiftFn = 2'b10; // SRAI
        x = 32'h92345678; #10; // negative number
        check_result(32'hC91A2B3C, 1'b0, "SRAI: 0x92345678 >> 1 (sign extend)");

        $display("\n--- HAMMING WEIGHT (POPCOUNT) TESTS ---");
        
        FnClass = 3'b110;
        x = 32'h00000000; y = 32'hDEADBEEF; #10; // y ignored
        check_result(32'd0, 1'b0, "HAM: popcount(0x00000000)");
        
        x = 32'hFFFFFFFF; #10;
        check_result(32'd32, 1'b0, "HAM: popcount(0xFFFFFFFF)");
        
        x = 32'h0000000F; #10;
        check_result(32'd4, 1'b0, "HAM: popcount(0x0000000F)");
        
        x = 32'hF0F0000F; #10;
        check_result(32'd12, 1'b0, "HAM: popcount(0xF0F0000F)");
        
        x = 32'hAAAAAAAA; #10;
        check_result(32'd16, 1'b0, "HAM: popcount(0xAAAAAAAA)");
        
        x = 32'h80000001; #10;
        check_result(32'd2, 1'b0, "HAM: popcount(0x80000001)");

        $display("\n--- EDGE CASE TESTS ---");
        
        // Test all zeros
        x = 0; y = 0;
        FnClass = 3'b011; add_sub = 0; #10;
        check_result(32'd0, 1'b0, "Edge: 0 + 0");
        
        // Test maximum values
        x = 32'hFFFFFFFF; y = 32'hFFFFFFFF;
        FnClass = 3'b100; LogicFn = 2'b00; #10; // AND
        check_result(32'hFFFFFFFF, 1'b0, "Edge: 0xFFFFFFFF & 0xFFFFFFFF");
        
        // Test shift by maximum amount
        FnClass = 3'b101; ShiftFn = 2'b00; ConstVar = 0;
        x = 32'hFFFFFFFF; y = 31; #10;
        check_result(32'h80000000, 1'b0, "Edge: 0xFFFFFFFF << 31");

        // Final results
        $display("\n========================================");
        $display("           TEST SUMMARY                 ");
        $display("========================================");
        $display("Total Tests: %d", test_count);
        $display("Passed:      %d", pass_count);
        $display("Failed:      %d", fail_count);
        $display("Success Rate: %.1f%%", (pass_count * 100.0) / test_count);
        
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("Some tests failed. Check the output above.");
        end
        
        $display("========================================");
        $finish;
    end

    // Timeout protection
    initial begin
        #100000; // 100us timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule