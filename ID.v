
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////
module ID(clk,Instruction_id, PC_id, RegWrite_wb, rdAddr_wb, RegWriteData_wb, MemRead_ex, 
          rdAddr_ex, MemtoReg_id, RegWrite_id, MemWrite_id, MemRead_id, ALUCode_id, 
			 ALUSrcA_id, ALUSrcB_id,  Stall, Branch, Jump, IFWrite,  JumpAddr, Imm_id,
			 rs1Data_id, rs2Data_id,rs1Addr_id,rs2Addr_id,rdAddr_id);
    input  clk;
    input  [31:0] Instruction_id;
    input  [31:0] PC_id;
    input  RegWrite_wb;
    input  [4:0] rdAddr_wb;
    input  [31:0] RegWriteData_wb;
    input  MemRead_ex;
    input  [4:0] rdAddr_ex;
    output MemtoReg_id;
    output RegWrite_id;
    output MemWrite_id;
    output MemRead_id;
    output [3:0] ALUCode_id;
    output ALUSrcA_id;
    output [1:0]ALUSrcB_id;
    output Stall;
    output Branch;
    output Jump;
    output IFWrite;
    output [31:0] JumpAddr;
    output [31:0] Imm_id;
    output [31:0] rs1Data_id;
    output [31:0] rs2Data_id;
	output [4:0] rs1Addr_id,rs2Addr_id,rdAddr_id;


    wire JALR_temp;
    wire [31:0]offset_temp;
    wire SB_type_temp;
    wire [2:0]funct3_temp;
    wire [31:0]mux_temp;

    Decode decoder(.MemtoReg(MemtoReg_id),.RegWrite(RegWrite_id),.MemWrite(MemWrite_id),.MemRead(MemRead_id),
    .ALUCode(ALUCode_id),.ALUSrcA(ALUSrcA_id),.ALUSrcB(ALUSrcB_id),.Jump(Jump),.JALR(JALR_temp),.Imm(Imm_id),
    .offset(offset_temp),.rs1Addr(rs1Addr_id),.rs2Addr(rs2Addr_id),.rdAddr(rdAddr_id),.SB_type(SB_type_temp), 
    .funct3(funct3_temp), .Instruction(Instruction_id));

    Registers registers(.rs1Data(rs1Data_id),.rs2Data(rs2Data_id),.clk(clk),.rs1Addr(rs1Addr_id),
    .rs2Addr(rs2Addr_id),.WriteAddr(rdAddr_wb),.RegWrite(RegWrite_wb),.WriteData(RegWriteData_wb));

    BranchTest branchtest(.branch(Branch),.SB_type(SB_type_temp),.funct3(funct3_temp), 
    .rs1Data(rs1Data_id),.rs2Data(rs2Data_id));

    assign mux_temp = JALR_temp?rs1Data_id:PC_id;
    assign JumpAddr = mux_temp + offset_temp;

    // Hazard Detector
    assign Stall = ((rdAddr_ex==rs1Addr_id)||(rdAddr_ex==rs2Addr_id))&&MemRead_ex;
    assign IFWrite = ~Stall;
    
endmodule