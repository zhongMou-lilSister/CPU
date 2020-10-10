module Registers(rs1Data, rs2Data, clk, rs1Addr, rs2Addr, WriteAddr, 
    RegWrite, WriteData);
    input clk;
    input [4:0]rs1Addr;
    input [4:0]rs2Addr;
    input [4:0]WriteAddr;
    input RegWrite;
    input [31:0]WriteData;
    output [31:0]rs1Data;
    output [31:0]rs2Data;

    wire rs1Sel;
    wire rs2Sel;

    wire temp1;
    wire temp2;

    assign rs1Sel = RegWrite && (WriteAddr != 0) && (WriteAddr == rs1Addr);
    assign rs2Sel = RegWrite && (WriteAddr != 0) && (WriteAddr == rs2Addr);

    insider RBWRegisters(.ReadData1(temp1),.ReadData2(temp2),.clk(clk),.ReadRegisters1(rs1Addr),.ReadRegisters2(rs2Addr), 
    .WriteRegister(WriteAddr),.RegWrite(RegWrite),.WriteData(WriteData));

    assign rs1Data = (rs1Sel)?temp1:WriteData;
    assign rs2Data = (rs2Sel)?temp2:WriteData;

endmodule