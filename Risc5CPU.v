`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zju
// Engineer: qmj
//////////////////////////////////////////////////////////////////////////////////
module Risc5CPU(clk, reset, JumpFlag, Instruction_id, ALU_A, 
                     ALU_B, ALUResult_ex, PC, MemDout_mem,Stall);
    input clk;
    input reset;
    output[1:0] JumpFlag;
    output [31:0] Instruction_id;
    output [31:0] ALU_A;
    output [31:0] ALU_B;
    output [31:0] ALUResult_ex;
    output [31:0] PC;
    output [31:0] MemDout_mem;
    output Stall;

    // IF level
    wire IFWrite;
    wire Branch;
    wire Jump;
    wire [31:0] JumpAddr;
    wire IF_flush;
    wire [31:0] PC_if;
    wire [31:0] Instruction_if;

    IF ifIns(.clk(clk), 
        .reset(reset), 
        .Branch(Branch),
        .Jump(Jump), 
        // combinational logic, propagated from later levels
        .IFWrite(IFWrite), 
        .JumpAddr(JumpAddr),
        .Instruction_if(Instruction_if),
        .PC(PC_if),
        .IF_flush(IF_flush)
        );
    
    // IF->ID registers
    reg [31:0] PC_id;
    reg [31:0] Instruction_id;
    wire [1:0] EN_R;
    assign EN_R = {IFWrite, IF_flush};
    always @(posedge clk)
    begin
        if (reset == 1)
        begin
            PC_id <= 32'h00000000;
            Instruction_id <= 32'h00000000;
        end
        else begin
            case (EN_R)
                2'b00: 
                begin
                    PC_id <= PC_id;
                    Instruction_id <= Instruction_id;
                end
                2'b10:
                begin
                    PC_id <= PC_if;
                    Instruction_id <= Instruction_if;
                end
                default: begin
                    PC_id <= 32'h00000000;
                    Instruction_id <= 32'h00000000;
                end
            endcase
        end
    end

    reg RegWrite_wb;
    reg [4:0] rdAddr_wb;
    wire [31:0] RegWriteData_wb;
    reg MemRead_ex;
    reg [4:0] rdAddr_ex;
    wire MemtoReg_id;
    wire RegWrite_id;
    wire MemWrite_id;
    wire MemRead_id;
    wire [3:0] ALUCode_id;
    wire ALUSrcA_id;
    wire [1:0] ALUSrcB_id;
    wire [31:0] Imm_id;
    wire [31:0] rs1Data_id;
    wire [31:0] rs2Data_id;
    wire [4:0] rs1Addr_id;
    wire [4:0] rs2Addr_id;
    wire [4:0] rdAddr_id;

    ID idIns(.clk(clk),
            .Instruction_id(Instruction_id), 
            .PC_id(PC_id), 
            .RegWrite_wb(RegWrite_wb), 
            .rdAddr_wb(rdAddr_wb), 
            .RegWriteData_wb(RegWriteData_wb), 
            .MemRead_ex(MemRead_ex), 
            .rdAddr_ex(rdAddr_ex), 
            .MemtoReg_id(MemtoReg_id), 
            .RegWrite_id(RegWrite_id), 
            .MemWrite_id(MemWrite_id), 
            .MemRead_id(MemRead_id), 
            .ALUCode_id(ALUCode_id), 
			.ALUSrcA_id(ALUSrcA_id), 
            .ALUSrcB_id(ALUSrcB_id),  
            .Stall(Stall), 
            .Branch(Branch), 
            .Jump(Jump), 
            .IFWrite(IFWrite),  
            .JumpAddr(JumpAddr), 
            .Imm_id(Imm_id),
			.rs1Data_id(rs1Data_id), 
            .rs2Data_id(rs2Data_id),
            .rs1Addr_id(rs1Addr_id),
            .rs2Addr_id(rs2Addr_id),
            .rdAddr_id(rdAddr_id)
    );
    // ID->EX registers
    reg MemtoReg_ex;
    reg RegWrite_ex;
    reg MemWrite_ex;
    reg [3:0] ALUCode_ex;
    reg ALUSrcA_ex;
    reg [1:0] ALUSrcB_ex;
    reg [31:0] PC_ex;
    reg [31:0] Imm_ex;
    reg [4:0] rs1Addr_ex;
    reg [4:0] rs2Addr_ex;
    reg [31:0] rs1Data_ex;
    reg [31:0] rs2Data_ex;

    always@(posedge clk)
    begin
        if (reset || Stall) begin
            MemtoReg_ex <= 0;
            RegWrite_ex <= 0;
            MemWrite_ex <= 0;
            MemRead_ex  <= 0;
            ALUCode_ex  <= 5'h00;
            ALUSrcA_ex  <= 0;
            ALUSrcB_ex  <= 2'h0;
            PC_ex       <= 32'h00000000;
            Imm_ex      <= 32'h00000000;
            rdAddr_ex   <= 5'h00;
            rs1Addr_ex  <= 5'h00;
            rs2Addr_ex  <= 5'h00;
            rs1Data_ex  <= 5'h00;
            rs2Data_ex  <= 5'h00;
        end
        else begin
            MemtoReg_ex <= MemtoReg_id;
            RegWrite_ex <= RegWrite_id;
            MemWrite_ex <= MemWrite_id;
            MemRead_ex  <= MemRead_id;
            ALUCode_ex  <= ALUCode_id;
            ALUSrcA_ex  <= ALUSrcA_id;
            ALUSrcB_ex  <= ALUSrcB_id;
            PC_ex       <= PC_id;
            Imm_ex      <= Imm_id;
            rdAddr_ex   <= rdAddr_id;
            rs1Addr_ex  <= rs1Addr_id;
            rs2Addr_ex  <= rs2Addr_id;
            rs1Data_ex  <= rs1Data_id;
            rs2Data_ex  <= rs2Data_id;
        end
    end

    // EX level
    reg  [31:0] ALUResult_mem;
    reg [4:0] rdAddr_mem;
    reg  RegWrite_mem;
    wire [31:0] ALUResult_ex;
    wire [31:0] MemWriteData_ex;
    wire [31:0] ALU_A;
    wire [31:0] ALU_B;

    EX exIns(.ALUCode_ex(ALUCode_ex), 
        .ALUSrcA_ex(ALUSrcA_ex), 
        .ALUSrcB_ex(ALUSrcB_ex),
        .Imm_ex(Imm_ex), 
        .rs1Addr_ex(rs1Addr_ex), 
        .rs2Addr_ex(rs2Addr_ex),
        .rs1Data_ex(rs1Data_ex), 
        .rs2Data_ex(rs1Data_ex), 
        .PC_ex(PC_ex), 
        .RegWriteData_wb(RegWriteData_wb),
        .ALUResult_mem(ALUResult_mem),
        .rdAddr_mem(rdAddr_mem), 
        .rdAddr_wb(rdAddr_wb), 
		.RegWrite_mem(RegWrite_mem), 
        .RegWrite_wb(RegWrite_wb), 
        .ALUResult_ex(ALUResult_ex), 
        .MemWriteData_ex(MemWriteData_ex), 
        .ALU_A(ALU_A), 
        .ALU_B(ALU_B)
    );

    // EX/MEM register
    reg MemtoReg_mem;
    reg MemWrite_mem;
    reg [31:0] MemWriteData_mem;
    always @(posedge clk) begin
        if (reset) begin
            RegWrite_mem     <= 0;
            MemtoReg_mem     <= 0;
            MemWrite_mem     <= 0;
            ALUResult_mem    <= 32'h00000000;
            MemWriteData_mem <= 32'h00000000;
            rdAddr_mem       <= 5'h00;
        end
        else begin
            RegWrite_mem     <= RegWrite_ex    ;
            MemtoReg_mem     <= MemtoReg_ex    ;
            MemWrite_mem     <= MemWrite_ex    ;
            ALUResult_mem    <= ALUResult_ex   ;
            MemWriteData_mem <= MemWriteData_ex;
            rdAddr_mem       <= rdAddr_ex      ;
        end
    end

    // MEM level
    MEM memIns(
    .WE(MemWrite_mem),
    .Addr(ALUResult_mem[7:2]),
    .Clk(clk),
    .Data(MemWriteData_mem),
    .SPO(MemDout_mem)
    );

    // MEM->WB register
    reg MemtoReg_wb;
    reg [31:0] MemDout_wb;
    reg [31:0] ALUResult_wb;
    always @(posedge clk)
    begin
        if (reset) begin
            RegWrite_wb     <= 0;
            MemtoReg_wb     <= 0;
            MemDout_wb      <= 32'h00000000;
            ALUResult_wb    <= 32'h00000000;
            rdAddr_wb       <= 5'h00;
        end
        else begin
            RegWrite_wb     <= RegWrite_mem   ;
            MemtoReg_wb     <= MemtoReg_mem   ;
            MemDout_wb      <= MemDout_mem    ;
            ALUResult_wb    <= ALUResult_mem  ;
            rdAddr_wb       <= rdAddr_mem     ;
        end
    end

    assign RegWriteData_wb = (MemtoReg_wb)?MemDout_wb : ALUResult_wb;
    assign JumpFlag = {Jump, Branch};
    assign PC = PC_if;
    
endmodule
