`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  zju
// Engineer: qmj
//////////////////////////////////////////////////////////////////////////////////
module IF(clk, reset, Branch,Jump, IFWrite, JumpAddr,Instruction_if,PC,IF_flush);
    input clk;
    input reset;
    input Branch;
    input Jump;
    input IFWrite;
    input [31:0] JumpAddr;
    output [31:0] Instruction_if;
    output reg [31:0] PC;
    output IF_flush;

    reg [31:0] NextPC_if;
    assign IF_flush = Jump | Branch;

    
    always @(posedge clk)
    begin
        if (reset==1)
        begin
            NextPC_if <= 32'h00000004;
	        PC<=32'h00000000;
        end
	    else
        begin
            if (IFWrite) begin
                PC<= (IF_flush)?JumpAddr:NextPC_if;
                NextPC_if <= (IF_flush)?(JumpAddr + 32'h00000004):(NextPC_if + 32'h00000004);
	        // Instruction_if <= 32'h00000004;
            end

       end
    end
    InstructionROM insRom(.addr(PC[7:2]),.dout(Instruction_if));
endmodule

