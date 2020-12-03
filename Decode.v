// //
// Decode.v
// combinational logic circuit.
//******************************************************************************

module Decode(   
	// Outputs
	MemtoReg, RegWrite, MemWrite, MemRead,ALUCode,ALUSrcA,ALUSrcB,Jump,JALR,Imm,offset,
  rs1Addr, rs2Addr, rdAddr, SB_type, funct3, 
	// Inputs
    Instruction);
	input [31:0]	Instruction;	// current instruction
	output		    MemtoReg;		// use memory output as data to write into register
	output		    RegWrite;		// enable writing back to the register
	output		    MemWrite;		// write to memory
	output         MemRead;
	output reg [3:0]   ALUCode;         // ALU operation select
	output      	ALUSrcA;
	output [1:0]   ALUSrcB;
	output         Jump;
	output         JALR;
	output reg [31:0]   Imm, offset;
  output reg [4:0] rs1Addr;
  output reg [4:0] rs2Addr;
  output reg [4:0] rdAddr;
  output SB_type;
  output [2:0]		funct3;

	
//******************************************************************************
//  instruction type decode
//******************************************************************************
	parameter  R_type_op=   7'b0110011;
	parameter  I_type_op=   7'b0010011;
	parameter  SB_type_op=  7'b1100011;
	parameter  LW_op=       7'b0000011;
	parameter  JALR_op=     7'b1100111;
	parameter  SW_op=       7'b0100011;
	parameter  LUI_op=      7'b0110111;
	parameter  AUIPC_op=    7'b0010111;	
	parameter  JAL_op=      7'b1101111;	
// Decoded ALU operation select (ALUsel) signals
   parameter	 alu_add  =  4'b0000;
   parameter	 alu_sub  =  4'b0001;
   parameter	 alu_lui  =  4'b0010;
   parameter	 alu_and  =  4'b0011;
   parameter	 alu_xor  =  4'b0100;
   parameter	 alu_or   =  4'b0101;
   parameter 	 alu_sll  =  4'b0110;
   parameter	 alu_srl  =  4'b0111;
   parameter	 alu_sra  =  4'b1000;
   parameter	 alu_slt  =  4'b1001;
   parameter	 alu_sltu =  4'b1010; 	

//******************************************************************************
// instruction field
//******************************************************************************
	wire [6:0]		op;
	wire  	 	    funct6_7;
	assign op			= Instruction[6:0];
	assign funct6_7		= Instruction[30];
 	assign funct3		= Instruction[14:12];
	
  wire R_type;
  wire I_type;
  wire LW;
  wire SW;
  wire LUI;
  wire AUIPC;
  wire JAL;

  assign R_type = (op == R_type_op);
  assign I_type = (op == I_type_op);
  assign SB_type = (op == SB_type_op);
  assign LW = (op == LW_op);
  assign SW = (op == SW_op);
  assign LUI = (op == LUI_op);
  assign AUIPC = (op == AUIPC_op);
  assign JAL = (op == JAL_op);
  assign JALR = (op == JALR_op);

  // output for the decoder
  assign MemtoReg = LW;
  assign MemRead = LW;
  assign MemWrite = SW;
  assign RegWrite = R_type || I_type || LW || JALR || LUI || AUIPC || JAL;
  assign Jump = JAL || JALR;
  assign ALUSrcA = JALR || JAL || AUIPC;
  assign ALUSrcB[1] = JALR || JAL;
  assign ALUSrcB[0] = ~(R_type || JAL || JALR);
  // ALU code
  wire [6:0] temp;
  assign temp = {R_type, I_type, LUI, funct3, funct6_7};
  always @(*)
  begin
    case (temp)
      7'b1000000:             ALUCode <= alu_add;
      7'b1000001:             ALUCode <= alu_sub;
      7'b1000010:             ALUCode <= alu_sll;
      7'b1000100:             ALUCode <= alu_slt;
      7'b1000110:             ALUCode <= alu_sltu;
      7'b1001000:             ALUCode <= alu_xor;
      7'b1001010:             ALUCode <= alu_srl;
      7'b1001011:             ALUCode <= alu_sra;
      7'b1001100:             ALUCode <= alu_or;
      7'b1001110:             ALUCode <= alu_and;
      7'b0100001, 7'b0100000: ALUCode <= alu_add;
      7'b0100011, 7'b0100010: ALUCode <= alu_sll;
      7'b0100101, 7'b0100100: ALUCode <= alu_slt;
      7'b0100111, 7'b0100110: ALUCode <= alu_sltu;
      7'b0101001, 7'b0101000: ALUCode <= alu_xor;
      7'b0101010:             ALUCode <= alu_srl;
      7'b0101011:             ALUCode <= alu_sra;
      7'b0101101, 7'b0101100: ALUCode <= alu_or;
      7'b0101111, 7'b0101110: ALUCode <= alu_and;
      7'b0010000, 7'b0010001, 7'b0010010, 7'b0010011,
      7'b0010100, 7'b0010101, 7'b0010110, 7'b0010111,
      7'b0011000, 7'b0011001, 7'b0011010, 7'b0011011,
      7'b0011100, 7'b0011101, 7'b0011110, 7'b0011111: ALUCode <= alu_lui;

      default: ALUCode <= 4'd0;
    endcase
  end

	 // immediate number and offset
  wire shift;
  assign shift = (funct3 == 1) || (funct3 == 5);

  wire [8:0] temp2;
  assign temp2 = {I_type, LW, JALR, SW, JAL, LUI, AUIPC, SB_type, shift};
  always @(*) begin
    case (temp2)
      9'b100000001: Imm <= {26'd0, Instruction[25:20]};
      9'b100000000, 9'b010000001, 9'b010000000: Imm <={{20{Instruction[31]}}, Instruction[31:20]};
      9'b001000001, 9'b001000000: offset <= {{20{Instruction[31]}}, Instruction[31:20]};
      9'b000100001, 9'b000100000: Imm <= {{20{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
      9'b000010001, 9'b000010000: offset <= {{11{Instruction[31]}},Instruction[31],Instruction[19:12],Instruction[20],Instruction[30:21],1'b0};
      9'b000001001, 9'b000001000, 9'b000000101, 9'b000000100: Imm <= {Instruction[31:12], 12'd0};
      9'b000000011, 9'b000000010: offset <= {{19{Instruction[31]}},Instruction[31],Instruction[7],Instruction[30:25],Instruction[11:8],1'b0};
    endcase
  end

  wire temp3;
  wire temp4;
  wire temp5;
  assign temp3 = R_type || SW || SB_type;
  assign temp4 = I_type || LW; 
  assign temp5 = SW || SB_type;
  always @(*) begin
    if (temp3) begin
      rs1Addr <= Instruction[19:15];
      rs2Addr <= Instruction[24:20];
    end
    else begin
      if (temp4) begin
      rs1Addr <= Instruction[19:15];
      rs2Addr <= 5'b00000;
      end
      else begin
      rs1Addr <= 5'b00000;
      rs2Addr <= 5'b00000;
      end
    end
    if (~temp5) begin
      rdAddr <= Instruction[11:7];
    end
    else begin
      rdAddr <= 5'b00000;
    end
  end

endmodule