module decoder(
    input [1:0] Op,
    input [5:0] Funct,
    input [3:0] Rd,
    
    // Yeh 'always' block mein assign ho rahe hain, isliye 'reg' rahenge
    output reg [1:0] FlagW,
    output reg [1:0] ALUControl,

    // Yeh 'assign' se drive ho rahe hain, isliye 'reg' hata diya gaya
    output PCS, 
    output RegW, 
    output MemW,
    output MemtoReg, 
    output ALUSrc,
    output [1:0] ImmSrc, 
    output [1:0] RegSrc
);

    // Internal signals jo 'assign' se drive ho rahe hain
    wire Branch, ALUOp; 
    
    // Control signal jo 'always' block mein drive ho raha hai
    reg [9:0] controls;

    // Ab yeh line sahi hai kyonki iske left side mein sabhi signals 'wire' type ke hain
    assign {Branch, MemtoReg, MemW, ALUSrc, ImmSrc, RegW, RegSrc, ALUOp} = controls;
     
    // Main decoder 
    always@(*)
        casex(Op)
            2'b00: begin
                if (Funct[5]) controls = 10'b0001001001; // Data-processing immediate
                else controls = 10'b0000001001;          // Data-processing register
            end
            2'b01: begin
                if (Funct[0]) controls = 10'b0101011000; // LDR
                else controls = 10'b0011010100;          // STR
            end
            2'b10: controls = 10'b1001100010;             // B
            default: controls = 10'bx;                   // Unimplemented
        endcase

    // ALU Decoder 
    always@(*) begin
        if (ALUOp) begin
            case(Funct[4:1])
                4'b0100: ALUControl = 2'b00; // ADD
                4'b0010: ALUControl = 2'b01; // SUB
                4'b0000: ALUControl = 2'b10; // AND
                4'b1100: ALUControl = 2'b11; // ORR
                default: ALUControl = 2'bx; // unimplemented
            endcase
            FlagW[1] = Funct[0];
            FlagW[0] = Funct[0] & (ALUControl == 2'b00 | ALUControl == 2'b01);
        end
        else begin
            ALUControl = 2'b00; 
            FlagW = 2'b00;      
        end
    end
    
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
    
endmodule