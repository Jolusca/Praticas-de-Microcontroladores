// Code your design here
module Registradores(
    input clk,
    input [2:0] reg_addr_a,
    input [2:0] reg_addr_b,
    input [7:0] data_in,
    input write_enable,
    output [7:0] data_out_a,
    output [7:0] data_out_b
);
    reg [7:0] regs [0:2]; // 3 registradores para operações matemáticas

    initial begin
      regs[0] = 8'b00000000;
      regs[1] = 8'b00000000;
        regs[2] = 8'b00000000;
    end

    always @(posedge clk) begin
        if (write_enable)
            regs[reg_addr_a] <= data_in;
    end

    assign data_out_a = regs[reg_addr_a];
    assign data_out_b = regs[reg_addr_b];
endmodule

module ALU(
    input [7:0] A,
    input [7:0] B,
    input [7:0] opcode,
    output reg [7:0] result,
    output reg zero_flag,
    output reg carry_flag,
    output reg sign_flag,
    output reg parity_flag,
    output reg overflow_flag
);
    always @(*) begin
        // Inicializar flags
        zero_flag = 0;
        carry_flag = 0;
        sign_flag = 0;
        parity_flag = 0;
        overflow_flag = 0;

        case (opcode)
            8'b00000000: result = A + B; // ADD
            8'b00000001: result = A - B; // SUB
            8'b00000010: result = A * B; // MUL
            8'b00000011: result = A / B; // DIV
            8'b00000100: result = A % B; // MOD
            8'b00000101: result = A & B; // AND (&&)
            8'b00000110: result = A | B; // OR (||)
            8'b00000111: result = A ^ B; // XOR
            8'b00001000: result = (A > B) ? 8'b1 : 8'b0; // >
            8'b00001001: result = (A < B) ? 8'b1 : 8'b0; // <
            8'b00001010: result = (A == B) ? 8'b1 : 8'b0; // ==
            8'b00001011: result = (A != B) ? 8'b1 : 8'b0; // !=
            8'b00001100: result = A; // Movimentação de dados
            8'b00001101: result = A << 1; // Deslocamento à esquerda
            8'b00001110: result = A >> 1; // Deslocamento à direita
            8'b00001111: result = {A[6:0], 1'b0}; // Manipulação de bit: inserção de 0 no LSB
            8'b00010000: result = {1'b0, A[7:1]}; // Manipulação de bit: inserção de 0 no MSB
            8'b00010001: result = A; // IN (Leitura)
            8'b00010010: result = A; // OUT (Escrita)
            8'b00010011: result = 8'b0; // HALT (Parar Execução)
            8'b00010100: result = ~A; // NOT
            default: result = 8'b11111111; // NOP
        endcase

        // Flags
        zero_flag = (result == 8'b00000000); // Zero Flag
        carry_flag = (opcode == 8'b00000000 && (A + B > 8'hFF)); // Carry Flag para ADD
        sign_flag = result[7]; // Sign Flag (bit mais significativo indica sinal)
        parity_flag = ~^result; // Parity Flag (paridade par)
        overflow_flag = ((opcode == 8'b00000000 || opcode == 8'b00000001) && ((A[7] == B[7]) && (result[7] != A[7]))); // Overflow para ADD/SUB
    end
endmodule

module Controle(
    input clk, 
    input [7: 0] instr, 
    output reg [2: 0] reg_addr_A, 
    output reg [2: 0] reg_addr_B, 
    output reg [7: 0] data_in, 
    output reg write_enable, 
    output reg [7: 0] alu_opcode
);
    always @(posedge clk) begin
        case (instr[7:0])
            8'b00000000: begin // ADD
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00000000;
            end
            8'b00000001: begin // SUB
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00000001;
            end
            8'b00000010: begin // MUL
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00000010;
            end
            8'b00000011: begin // DIV
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00000011;
            end
            8'b00000100: begin // MOD
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00000100;
            end
            8'b00000101: begin // &&
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00000101;
            end
            8'b00000110: begin // ||
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00000110;
            end
            8'b00000111: begin // XOR
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00000111;
            end
            8'b00001000: begin // >
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00001000;
            end
            8'b00001001: begin // <
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00001001;
            end
            8'b00001010: begin // ==
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00001010;
            end
            8'b00001011: begin // !=
                reg_addr_A <= 3'b000;
                reg_addr_B <= 3'b001;
                write_enable <= 0;
                alu_opcode <= 8'b00001011;
            end
          
          8'b00001100: begin // Movimentação de dados
                reg_addr_A <= 3'b000;
                write_enable <= 1;
                alu_opcode <= 8'b00001100;
            end
            8'b00001101: begin // Deslocamento à esquerda
                reg_addr_A <= 3'b000;
                write_enable <= 1;
                alu_opcode <= 8'b00001101;
            end
            8'b00001110: begin // Deslocamento à direita
                reg_addr_A <= 3'b000;
                write_enable <= 1;
                alu_opcode <= 8'b00001110;
            end
            8'b00001111: begin // Manipulação de bit (inserção de 0 no LSB)
                reg_addr_A <= 3'b000;
                write_enable <= 1;
                alu_opcode <= 8'b00001111;
            end
            8'b00010000: begin // Manipulação de bit (inserção de 0 no MSB)
                reg_addr_A <= 3'b000;
                write_enable <= 1;
                alu_opcode <= 8'b00010000;
            end
                        8'b00010001: begin // IN (Leitura)
                reg_addr_A <= 3'b000;  // Registra em A
                reg_addr_B <= 3'b001;  // Não importa o B
                write_enable <= 0;     //Não há necessidade de escrita
                alu_opcode <= 8'b00010001; // Instrução de leitura
            end
            8'b00010010: begin // OUT (Escrita)
                reg_addr_A <= 3'b000;  // Registra em A
                reg_addr_B <= 3'b001;  // Não importa o B
                write_enable <= 1;     // Habilita escrita
                alu_opcode <= 8'b00010010; // Instrução de escrita
            end
            8'b00010011:  begin // HALT (Parar Execução)
                reg_addr_A <= 3'b000;  // Não importa o valor
                reg_addr_B <= 3'b001;  // Não importa o valor
                write_enable <= 0;     // Não há escrita
                alu_opcode <= 8'b00010011; // HALT
            end
            8'b00010100: begin // NOT
                reg_addr_A <= 3'b000;
                write_enable <= 0;
                alu_opcode <= 8'b00010100;
            end
            default:  begin
                write_enable <= 0;
                alu_opcode <= 8'b11111111; // NOP
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
    output sign_flag,
    output parity_flag,
    output overflow_flag
);
    wire [7:0] A, B;
    wire [2:0] reg_addr_A, reg_addr_B;
    wire [7:0] data_in;
    wire write_enable;
  wire [7:0] alu_opcode;

    Registradores regs (
        .clk(clk),
        .reg_addr_a(reg_addr_A),
        .reg_addr_b(reg_addr_B),
        .data_in(data_in),
        .write_enable(write_enable),
        .data_out_a(A),
        .data_out_b(B)
    );

    ALU alu (
      .A(A),
      .B(B),
        .opcode(alu_opcode),
        .result(result),
        .zero_flag(zero_flag),
      .carry_flag(carry_flag),
      .sign_flag(sign_flag),
      .parity_flag(parity_flag),
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
