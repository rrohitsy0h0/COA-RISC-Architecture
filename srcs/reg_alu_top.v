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

// Wire declarations
wire [31:0] rsOut;
wire [31:0] rtOut;
wire [31:0] ALU_result;

// ALU control signals
reg add_sub, ConstVar;
reg [1:0] LogicFn, ShiftFn;
reg [2:0] FnClass;

// FSM state declarations [web:186]
localparam [1:0] IDLE     = 2'b00,  // Waiting for execute
                 EXECUTE  = 2'b01,  // Computing ALU result  
                 WRITEBACK = 2'b10; // Writing result to register

reg [1:0] current_state, next_state;

// Internal registers
reg [31:0] ALU_reg;           // Holds ALU result for display
reg [31:0] writeback_data;    // Data to write back to register file
reg [4:0] writeback_addr;     // Address for writeback
reg writeback_enable;         // Enable signal for register file write

// Register Bank instantiation
registerbank RB(
    .clk(clk),
    .rst(rst),
    .rs({1'b0, Rs}),        
    .rt({1'b0, Rt}),        
    .rd(writeback_addr),        // Connect to FSM-controlled address
    .wEnable(writeback_enable), // Connect to FSM-controlled enable
    .rdIn(writeback_data),      // Connect to FSM-controlled data
    .rsOut(rsOut),
    .rtOut(rtOut)    
);

// ALU instantiation
ALU ALU_unit(
    .x(rsOut),
    .y(rtOut),
    .add_sub(add_sub),
    .ConstVar(ConstVar),
    .LogicFn(LogicFn),
    .ShiftFn(ShiftFn),
    .FnClass(FnClass),
    .ALU_result(ALU_result),
    .Overflow()
); 

// FSM State Register [web:186]
always @(posedge clk or posedge rst) begin
    if(rst) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// FSM Next State Logic and Outputs [web:186]
always @(*) begin
    // Default assignments to avoid latches
    next_state = current_state;
    writeback_enable = 1'b0;
    writeback_data = 32'h0;
    writeback_addr = 5'h0;
    
    case(current_state)
        IDLE: begin
            // Wait for execute signal
            if(execute) begin
                next_state = EXECUTE;
            end else begin
                next_state = IDLE;
            end
        end
        
        EXECUTE: begin
            // ALU computation happens here
            // Always transition to WRITEBACK after one cycle
            next_state = WRITEBACK;
        end
        
        WRITEBACK: begin
            // Write ALU result back to register file
            writeback_enable = 1'b1;
            writeback_data = ALU_result;
            writeback_addr = {1'b0, Rd};  // Convert 4-bit Rd to 5-bit address
            
            // Return to IDLE (ready for next operation)
            next_state = IDLE;
        end
        
        default: begin
            next_state = IDLE;
        end
    endcase
end

// ALU Control Logic (Combinational) [web:182]
always @(*) begin
    // Default values
    add_sub = 1'b0;
    ConstVar = 1'b0;
    LogicFn = 2'b00;
    ShiftFn = 2'b00;
    FnClass = 3'b000;
    
    // Only configure ALU when in EXECUTE state
    if(current_state == EXECUTE) begin
        case (ALU_Operation)
            3'b000: begin       // Addition
                add_sub = 1'b0;
                FnClass = 3'b011;   
            end
            3'b001: begin       // Subtraction
                add_sub = 1'b1;
                FnClass = 3'b011;   
            end         
            3'b010: begin       // AND
                LogicFn = 2'b00;
                FnClass = 3'b100;   
            end  
            3'b011: begin       // OR
                LogicFn = 2'b01;
                FnClass = 3'b100;
            end
            3'b100: begin       // XOR
                LogicFn = 2'b10;
                FnClass = 3'b100;
            end
            3'b101: begin       // Shift Left Logical
                ShiftFn = 2'b00;
                FnClass = 3'b101;
            end
            3'b110: begin       // Shift Right Logical
                ShiftFn = 2'b01;
                FnClass = 3'b101;
            end
            3'b111: begin       // Shift Right Arithmetic
                ShiftFn = 2'b10;
                FnClass = 3'b101;
            end
            default: begin
                FnClass = 3'b000;
            end
        endcase
    end
end

// Result Capture for Display [web:182]
always @(posedge clk or posedge rst) begin
    if(rst) begin
        ALU_reg <= 32'h0;
    end else if(current_state == WRITEBACK) begin
        // Capture result during writeback phase for display
        ALU_reg <= ALU_result;
    end
end

// Display Output Logic
always @(*) begin
    if(DFT_Display_Select) begin
        display_output = ALU_reg[31:16];     // Upper 16 bits
    end else begin
        display_output = ALU_reg[15:0];      // Lower 16 bits
    end
end

endmodule
