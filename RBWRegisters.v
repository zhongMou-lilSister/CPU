module RBWRegisters(ReadData1, ReadData2, clk, ReadRegisters1, ReadRegisters2, 
WriteRegister, RegWrite, WriteData);
    input clk;
    input [4:0] ReadRegisters1;
    input [4:0] ReadRegisters2;
    input [4:0] WriteRegister;
    input RegWrite;
    input [31:0] WriteData;

    output [31:0] ReadData1;
    output [31:0] ReadData2;

    reg [31:0] regs[31:0];
    assign ReadData1 = (ReadRegisters1 == 5'b0) ? 32'b0:regs[ReadRegisters1];
    assign ReadData2 = (ReadRegisters2 == 5'b0) ? 32'b0:regs[ReadRegisters2];
    always @(posedge clk)
    begin
        if (RegWrite) begin
            regs[WriteRegister] <= WriteData;
        end
    end
endmodule