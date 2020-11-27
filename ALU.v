
//******************************************************************************
// MIPS verilog model
//
// ALU.v
//******************************************************************************

module ALU (
	// Outputs
	   ALUResult,
	// Inputs
	   ALUCode, A, B);
	input [3:0]	ALUCode;				// Operation select
	input [31:0]	A, B;
	output  reg [31:0]	ALUResult;
	
// Decoded ALU operation select (ALUsel) signals
   parameter	 alu_add=  4'b0000;
   parameter	 alu_sub=  4'b0001;
   parameter	 alu_lui=  4'b0010;
   parameter	 alu_and=  4'b0011;
   parameter	 alu_xor=  4'b0100;
   parameter	 alu_or =  4'b0101;
   parameter 	 alu_sll=  4'b0110;
   parameter	 alu_srl=  4'b0111;
   parameter	 alu_sra=  4'b1000;
   parameter	 alu_slt=  4'b1001;
   parameter	 alu_sltu= 4'b1010; 	
   
   always@(*)
   begin
      case (ALUCode)
      alu_add: ALUResult <= A + B;
      alu_sub: ALUResult <= A + ~B + 1;
      alu_lui: ALUResult <= B; // B = imm, already taken care of.
      alu_and: ALUResult <= A & B;
      alu_xor: ALUResult <= A ^ B;
      alu_or:  ALUResult <= A | B;
      alu_sll: ALUResult <= A << B[4:0];
      alu_srl: ALUResult <= A >> B[4:0];
      alu_sra: ALUResult <= ($signed(A)) >>> B[4:0]; 
      alu_slt: ALUResult <= ($signed(A) < $signed(B))? 1 : 0;
      alu_sltu: ALUResult <= ((A) < (B))? 1 : 0;
      endcase
   end


endmodule