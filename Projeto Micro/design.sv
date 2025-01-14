module Registradores(
    input clk,
    input [2:0] reg_addr,
    input [7:0] data_in,
    input write_enable,
    output [7:0] data_out
);
    reg [7:0] regs [0:2]; // 3 registradores para operações matemáticas

    initial begin
        regs[0] = 8'b00000001;
        regs[1] = 8'b00000010;
        regs[2] = 8'b00000000;
    end

    always @(posedge clk) begin
        if (write_enable)
            regs[reg_addr] <= data_in;
    end

    assign data_out = regs[reg_addr];
endmodule

module ALU(
    input [7:0] A,
    input [7:0] B,
    input [3:0] opcode,
    output reg [7:0] result,
    output reg zero_flag,
    output reg carry_flag,
    output reg overflow_flag
);
    always @(*) begin
        case (opcode)
            4'b0000: result = A + B; // Soma
            4'b0001: result = A - B; // Subtração
            4'b0010: result = A * B; // Multiplicação
            4'b0011: result = A / B; // Divisão
            4'b0100: result = A % B; // Módulo
            4'b0101: result = A & B; // AND
            4'b0110: result = A | B; // OR
            4'b0111: result = A ^ B; // XOR
            4'b1000: result = ~A;    // NOT
            4'b1001: result = (A > B) ? 8'b1 : 8'b0; // Maior
            4'b1010: result = (A >= B) ? 8'b1 : 8'b0; // Maior ou igual
            4'b1011: result = (A < B) ? 8'b1 : 8'b0; // Menor
            4'b1100: result = (A <= B) ? 8'b1 : 8'b0; // Menor ou igual
            4'b1101: result = (A == B) ? 8'b1 : 8'b0; // Igual
            4'b1110: result = (A != B) ? 8'b1 : 8'b0; // Diferente
            default: result = 8'b00010000; // NOP
        endcase

        // Flags
        zero_flag = (result == 8'b00000000);
        carry_flag = (A + B > 8'b11111111);
        overflow_flag = ((A[7] == B[7]) && (result[7] != A[7]));
    end
endmodule

module Controle(
    input clk,
    input [7:0] instr,
    output reg [2:0] reg_addr_A,
    output reg [2:0] reg_addr_B,
    output reg [7:0] data_in,
    output reg write_enable,
    output reg [3:0] alu_opcode
);
    always @(posedge clk) begin
        case (instr[7:4])
            4'b0001: begin // Instrução de soma
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 4'b0000;
            end
            4'b0010: begin // Instrução de subtração
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 4'b0001;
            end
            4'b1001: begin // Maior
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 4'b1001;
            end
            4'b1010: begin // Maior ou igual
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 4'b1010;
            end
            4'b1011: begin // Menor
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 4'b1011;
            end
            4'b1100: begin // Menor ou igual
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 4'b1100;
            end
            4'b1101: begin // Igual
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 4'b1101;
            end
            4'b1110: begin // Diferente
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 4'b1110;
            end
            default: begin
                write_enable <= 0;
                alu_opcode <= 4'b1111; // NOP
            end
        endcase
    end
endmodule

module Processador(
    input clk,
    input [7:0] instr,
    output [7:0] result,
    output zero_flag,
    output carry_flag,
    output overflow_flag
);
    wire [7:0] A, B;
    wire [2:0] reg_addr_A, reg_addr_B;
    wire [7:0] data_in;
    wire write_enable;
    wire [3:0] alu_opcode;

    Registradores regs_A (
        .clk(clk),
        .reg_addr(reg_addr_A),
        .data_in(data_in),
        .write_enable(write_enable),
        .data_out(A)
    );

    Registradores regs_B (
        .clk(clk),
        .reg_addr(reg_addr_B),
        .data_in(data_in),
        .write_enable(write_enable),
        .data_out(B)
    );

    ALU alu (
        .A(A),
        .B(B),
        .opcode(alu_opcode),
        .result(result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag)
    );

    Controle ctrl (
        .clk(clk),
        .instr(instr),
        .reg_addr_A(reg_addr_A),
        .reg_addr_B(reg_addr_B),
        .data_in(data_in),
        .write_enable(write_enable),
        .alu_opcode(alu_opcode)
    );
endmodule
