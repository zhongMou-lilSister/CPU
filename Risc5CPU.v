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



endmodule
