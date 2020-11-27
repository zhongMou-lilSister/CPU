module Forwarding(ForwardA, ForwardB, rs1Addr_ex, rs2Addr_ex,
RegWrite_wb, rdAddr_wb, RegWrite_mem, rdAddr_mem);
    input [4:0]rs2Addr_ex;
    input [4:0]rs1Addr_ex;
    input RegWrite_wb;
    input [4:0]rdAddr_wb;
    input RegWrite_mem;
    input [4:0]rdAddr_mem;
    output [1:0]ForwardA;
    output [1:0]ForwardB;

    assign ForwardA[0] = RegWrite_wb&&(rdAddr_wb!=0)&&(rdAddr_mem!=rs1Addr_ex)
&&(rdAddr_wb==rs1Addr_ex);
    assign ForwardA[1] = RegWrite_mem&&(rdAddr_mem!=0)&&(rdAddr_mem==rs1Addr_ex);
    assign ForwardB[0] = RegWrite_wb&&(rdAddr_wb!=0)&&(rdAddr_mem!=rs2Addr_ex)
&&(rdAddr_wb==rs2Addr_ex);
    assign ForwardB[1] = RegWrite_mem&&(rdAddr_mem!=0)&&(rdAddr_mem==rs2Addr_ex);
endmodule