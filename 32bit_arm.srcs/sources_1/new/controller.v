module controller(
    input clk, 
    input reset,
    input [31:12] Instr,
    input [3:0] ALUFlags,

    // FIX: All outputs driven by sub-modules must be wires (reg keyword removed).
    // FIX: Bit-widths adjusted to match the sub-modules.
    output [1:0] RegSrc,
    output RegWrite,
    output [1:0] ImmSrc,
    output ALUSrc,            // FIX: Changed from [1:0] to 1-bit
    output [1:0] ALUControl,  // FIX: Changed from 1-bit to [1:0]
    output MemWrite,
    output MemtoReg,
    output PCSrc
);

    // Internal wires to connect the decoder and condlogic modules
    wire [1:0] FlagW;
    wire PCS, RegW, MemW_internal; // Renamed MemW to avoid conflict with output port

    // Instantiate decoder
    // The outputs of this module drive the controller's wires and outputs
    decoder dec(
        .Op(Instr[27:26]), 
        .Funct(Instr[25:20]), 
        .Rd(Instr[15:12]),
        .FlagW(FlagW), 
        .PCS(PCS), 
        .RegW(RegW), 
        .MemW(MemW_internal), // Connect to internal wire
        .MemtoReg(MemtoReg), 
        .ALUSrc(ALUSrc), 
        .ImmSrc(ImmSrc), 
        .RegSrc(RegSrc), 
        .ALUControl(ALUControl)
    );

    // Instantiate condlogic block
    // The outputs of this module drive the controller's outputs
    condlogic cl(
        .clk(clk), 
        .reset(reset), 
        .Cond(Instr[31:28]), 
        .ALUFlags(ALUFlags),
        .FlagW(FlagW), 
        .PCS(PCS), 
        .RegW(RegW), 
        .MemW(MemW_internal), // Use the same internal wire
        .PCSrc(PCSrc), 
        .RegWrite(RegWrite), 
        .MemWrite(MemWrite)
    );
    
endmodule