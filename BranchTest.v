module BranchTest(branch, SB_type, funct3, rs1Data, rs2Data);
    output reg branch;
    input SB_type;
    input [2:0] funct3;
    input [31:0] rs1Data;
    input [31:0] rs2Data;

    wire isLT;
    wire [31:0] sum;
    wire isLTU;
    wire [3:0]temp;

    parameter beq_temp = 4'b1000;
    parameter bne_temp = 4'b1000;
    parameter blt_temp = 4'b1100;
    parameter bge_temp = 4'b1101;
    parameter bltu_temp = 4'b1110;
    parameter bgeu_temp = 4'b1111;

    assign sum = rs1Data + (~rs2Data) + 1;
    assign isLT = rs1Data[31]&&(~rs2Data[31])||(rs1Data[31]~^rs2Data[31])&&sum[31];
    assign isLTU = (~rs1Data[31])&&rs2Data[31]||(rs1Data[31]~^rs2Data[31])&&sum[31];
    assign temp = {SB_type, funct3};

    always @(*) begin
        case (temp)
            beq_temp : branch <= ~(|sum[31:0]);
            bne_temp : branch <= |sum[31:0];
            blt_temp : branch <= isLT;
            bge_temp : branch <= ~isLT;
            bltu_temp: branch <= isLTU;
            bgeu_temp: branch <= ~isLTU;
            default: branch <= 0;
        endcase
    end


endmodule