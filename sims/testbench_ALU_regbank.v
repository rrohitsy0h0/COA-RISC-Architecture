// Dharnesh Bala 23CS10008
// Rohit Ranjeet Satpute 23CS10060

`timescale 1ns / 1ps

module ALU_regbank_tb();

    // Testbench signals
    reg DFT_Display_Select;
    reg [2:0] ALU_Operation;
    reg [3:0] Rd;
    reg [3:0] Rt;
    reg [3:0] Rs;
    reg execute;
    reg clk;
    reg rst;
    wire [15:0] display_output;
    
    // Expected results
    reg [31:0] expected_result;
    reg [31:0] actual_result;
    integer error_count;
    integer test_count;
    
    // Instantiate the Unit Under Test (UUT)
    reg_alu_top uut (
        .DFT_Display_Select(DFT_Display_Select),
        .ALU_Operation(ALU_Operation),
        .Rd(Rd),
        .Rt(Rt),
        .Rs(Rs),
        .execute(execute),
        .clk(clk),
        .rst(rst),
        .display_output(display_output)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task to apply reset
    task apply_reset;
    begin
        rst = 1;
        execute = 0;
        DFT_Display_Select = 0;
        ALU_Operation = 3'b000;
        Rd = 4'b0000;
        Rt = 4'b0000;
        Rs = 4'b0000;
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        $display("  [Registers reset to initial values: R0=0, R1=1, R2=2, ..., R15=15]");
    end
    endtask
    
    // Task to perform ALU operation
    task perform_operation;
        input [2:0] operation;
        input [3:0] rs_addr;
        input [3:0] rt_addr;
        input [3:0] rd_addr;
        input [31:0] expected;
        input [255:0] description;
    begin
        @(negedge clk);
        ALU_Operation = operation;
        Rs = rs_addr;
        Rt = rt_addr;
        Rd = rd_addr;
        execute = 1;
        expected_result = expected;
        
        @(posedge clk);
        @(posedge clk);
        execute = 0;
        @(posedge clk);
        
        test_count = test_count + 1;
        
        // Read the actual result from the written register
        DFT_Display_Select = 0;
        #1;
        actual_result[15:0] = display_output;
        
        DFT_Display_Select = 1;
        #1;
        actual_result[31:16] = display_output;
        
        // Check result
        if (actual_result !== expected_result) begin
            $display("ERROR [Test %0d]: %s", test_count, description);
            $display("  Operation=%b, Rs[%0d]=0x%h, Rt[%0d]=0x%h, Rd[%0d]", 
                     operation, rs_addr, uut.rsOut, rt_addr, uut.rtOut, rd_addr);
            $display("  Expected = 0x%h, Got = 0x%h", expected_result, actual_result);
            error_count = error_count + 1;
        end
        else begin
            $display("PASS [Test %0d]: %s", test_count, description);
            $display("  Op=%b Rs[%0d]=0x%h Rt[%0d]=0x%h -> Rd[%0d]=0x%h", 
                     operation, rs_addr, uut.rsOut, rt_addr, uut.rtOut, 
                     rd_addr, actual_result);
        end
    end
    endtask
    
    // Main test sequence
    initial begin
        $display("========================================");
        $display("Starting Exhaustive ALU Register Bank Test");
        $display("========================================");
        
        error_count = 0;
        test_count = 0;
        
        // Initialize signals
        apply_reset();
        
        $display("\n========================================");
        $display("--- Test Section 1: Arithmetic Operations ---");
        $display("========================================");
        
        $display("\n--- Addition Tests ---");
        perform_operation(3'b000, 4'd0, 4'd1, 4'd15, 32'd1, "ADD: R0(0) + R1(1) = 1");
        perform_operation(3'b000, 4'd2, 4'd3, 4'd14, 32'd5, "ADD: R2(2) + R3(3) = 5");
        perform_operation(3'b000, 4'd5, 4'd7, 4'd13, 32'd12, "ADD: R5(5) + R7(7) = 12");
        perform_operation(3'b000, 4'd10, 4'd11, 4'd12, 32'd21, "ADD: R10(10) + R11(11) = 21");
        
        $display("\n--- Subtraction Tests ---");
        perform_operation(3'b001, 4'd5, 4'd3, 4'd11, 32'd2, "SUB: R5(5) - R3(3) = 2");
        perform_operation(3'b001, 4'd10, 4'd2, 4'd10, 32'd8, "SUB: R10(10) - R2(2) = 8");
        perform_operation(3'b001, 4'd1, 4'd5, 4'd9, 32'hFFFFFFFC, "SUB: R1(1) - R5(5) = -4 (0xFFFFFFFC)");
        perform_operation(3'b001, 4'd15, 4'd15, 4'd8, 32'd0, "SUB: R15(15) - R15(15) = 0");
        
        $display("\n========================================");
        $display("--- Test Section 2: Logical Operations ---");
        $display("========================================");
        apply_reset();
        
        $display("\n--- AND Tests ---");
        perform_operation(3'b010, 4'd15, 4'd14, 4'd8, 32'd14, "AND: R15(15) & R14(14) = 14");
        perform_operation(3'b010, 4'd7, 4'd3, 4'd7, 32'd3, "AND: R7(7) & R3(3) = 3");
        perform_operation(3'b010, 4'd12, 4'd10, 4'd6, 32'd8, "AND: R12(12) & R10(10) = 8");
        
        apply_reset();  
        $display("\n--- OR Tests ---");
        perform_operation(3'b011, 4'd2, 4'd1, 4'd5, 32'd3, "OR: R2(2) | R1(1) = 3");
        perform_operation(3'b011, 4'd8, 4'd4, 4'd9, 32'd12, "OR: R8(8) | R4(4) = 12");
        perform_operation(3'b011, 4'd1, 4'd2, 4'd10, 32'd3, "OR: R1(1) | R2(2) = 3");
        
        apply_reset();          
        $display("\n--- XOR Tests ---");
        perform_operation(3'b100, 4'd6, 4'd5, 4'd4, 32'd3, "XOR: R6(6) ^ R5(5) = 3");
        perform_operation(3'b100, 4'd7, 4'd3, 4'd3, 32'd4, "XOR: R7(7) ^ R3(3) = 4");
        perform_operation(3'b100, 4'd15, 4'd15, 4'd11, 32'd0, "XOR: R15(15) ^ R15(15) = 0");
        
        $display("\n========================================");
        $display("--- Test Section 3: Shift Operations ---");
        $display("========================================");
        apply_reset();
        
        $display("\n--- Shift Left Logical (SLL) Tests ---");
      	perform_operation(3'b101, 4'd5, 4'd0, 4'd15, 32'd5, "SLL: R5(5) << R0[0](0) = 5");
      	perform_operation(3'b101, 4'd5, 4'd1, 4'd14, 32'd10, "SLL: R5(5) << R1[0](1) = 10");
      	perform_operation(3'b101, 4'd4, 4'd2, 4'd13, 32'd4, "SLL: R4(4) << R2[0](0) = 4");
      	perform_operation(3'b101, 4'd7, 4'd3, 4'd12, 32'd14, "SLL: R7(7) << R3[0](1) = 14");
      
        apply_reset();        
        $display("\n--- Shift Right Logical (SRL) Tests ---");
      	perform_operation(3'b110, 4'd12, 4'd0, 4'd10, 32'd12, "SRL: R12(12) >> R0[0](0) = 12");
      	perform_operation(3'b110, 4'd12, 4'd1, 4'd14, 32'd6, "SRL: R12(12) >> R1[0](1) = 6");
      	perform_operation(3'b110, 4'd15, 4'd1, 4'd13, 32'd7, "SRL: R15(15) >> R1[0](1) = 7");
        perform_operation(3'b110, 4'd8, 4'd2, 4'd12, 32'd8, "SRL: R8(8) >> R2[0](0) = 7");
        
        $display("\n--- Shift Right Arithmetic (SRA) Tests ---");
        // Test with negative number
       perform_operation(3'b001, 4'd1, 4'd15, 4'd10, 32'hFFFFFFF2, "SUB: R1(1) - R15(15) = -14");
        perform_operation(3'b111, 4'd10, 4'd0, 4'd11, 32'hFFFFFFF2, "SRA: R10(-14) >>> R0[0](0) = -14");
        perform_operation(3'b111, 4'd10, 4'd1, 4'd12, 32'hFFFFFFF9, "SRA: R10(-14) >>> R1[0](1) = -7");
        apply_reset();   
        // Test with positive number
        perform_operation(3'b111, 4'd14, 4'd0, 4'd13, 32'd14, "SRA: R14(14) >>> R0[0](0) = 14");
        perform_operation(3'b111, 4'd14, 4'd1, 4'd14, 32'd7, "SRA: R14(14) >>> R1[0](1) = 7");
        
        $display("\n========================================");
        $display("--- Test Section 4: Edge Cases ---");
        $display("========================================");
        apply_reset();
        
        $display("\n--- Zero Result Tests ---");
        perform_operation(3'b001, 4'd5, 4'd5, 4'd1, 32'd0, "SUB: R5(5) - R5(5) = 0");
        perform_operation(3'b100, 4'd7, 4'd7, 4'd2, 32'd0, "XOR: R7(7) ^ R7(7) = 0");
        perform_operation(3'b010, 4'd8, 4'd1, 4'd3, 32'd0, "AND: R8(8) & R1(1) = 0");
        
        $display("\n--- Maximum Value Tests ---");
        perform_operation(3'b011, 4'd15, 4'd15, 4'd4, 32'd15, "OR: R15(15) | R15(15) = 15");
        perform_operation(3'b010, 4'd15, 4'd15, 4'd5, 32'd15, "AND: R15(15) & R15(15) = 15");
        
        $display("\n========================================");
        $display("--- Test Section 5: Chained Operations ---");
        $display("========================================");
        apply_reset();
        
        $display("\n--- Sequential Dependencies ---");
        perform_operation(3'b000, 4'd1, 4'd2, 4'd0, 32'd3, "ADD: R1(1) + R2(2) = 3 -> R0");
        perform_operation(3'b000, 4'd0, 4'd3, 4'd1, 32'd6, "ADD: R0(3) + R3(3) = 6 -> R1");
        perform_operation(3'b000, 4'd1, 4'd4, 4'd2, 32'd10, "ADD: R1(6) + R4(4) = 10 -> R2");
        perform_operation(3'b000, 4'd2, 4'd5, 4'd3, 32'd15, "ADD: R2(10) + R5(5) = 15 -> R3");
        
        $display("\n--- Overwriting Same Register ---");
        perform_operation(3'b000, 4'd10, 4'd1, 4'd10, 32'd16, "ADD: R10(10) + R1(6) = 16 -> R10");
        perform_operation(3'b000, 4'd10, 4'd10, 4'd10, 32'd32, "ADD: R10(16) + R10(16) = 32 -> R10");
        perform_operation(3'b001, 4'd10, 4'd5, 4'd10, 32'd27, "SUB: R10(32) - R5(5) = 27 -> R10");
        
        $display("\n========================================");
        $display("Test Summary:");
        $display("========================================");
        $display("  Total Tests: %0d", test_count);
        $display("  Errors: %0d", error_count);
        if (error_count == 0)
            $display("  STATUS: ALL TESTS PASSED! ✓");
        else
            $display("  STATUS: TESTS FAILED! ✗");
        $display("========================================");
        
        #100;
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #50000;
        $display("\nERROR: Simulation timeout!");
        $finish;
    end
    
    // Waveform dump (for viewing in GTKWave or similar)
//    initial begin
//        $dumpfile("reg_alu_top_tb.vcd");
//        $dumpvars(0, tb_reg_alu_top);
//    end

endmodule
