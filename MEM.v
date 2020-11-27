`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ZJU
// Engineer: Jiang Shui
// 
// Create Date: 11/27/2020 01:48:50 PM
// Design Name: 
// Module Name: MEM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MEM(
    input WE,
    input [5:0] Addr,
    input Clk,
    input [31:0] Data,
    output [31:0] SPO
    );
    
dist_mem_gen_0 your_instance_name (
      .a(Addr),      // input wire [5 : 0] a
      .d(Data),      // input wire [31 : 0] d
      .clk(Clk),  // input wire clk
      .we(WE),    // input wire we
      .spo(SPO)  // output wire [31 : 0] spo
    );
endmodule
