
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
  reg [7:0] regs [0:7]; // 8 registradores: AX, BX, CX, DX e mais 4 para expansão futura

    // Inicialização dos registradores
    initial begin
      regs[0] = 8'b00000000; // 0
      regs[1] = 8'b00000000; // AX
      regs[2] = 8'b00000000; // BX
      regs[3] = 8'b00000000; // CX
      regs[4] = 8'b00000000; // DX
      regs[5] = 8'b00000000; // Reg extra
        regs[6] = 8'b00000000; // Reg extra
        regs[7] = 8'b00000000; // Reg extra
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

module Pilha(
    input clk,
    input push,
    input pop,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output reg empty,
    output reg full
);
    reg [7:0] stack [0:7]; // Pilha de 8 níveis
    reg [2:0] sp; // Ponteiro da pilha

    initial begin
        sp = 3'b000;
        empty = 1;
        full = 0;
    end

    always @(posedge clk) begin
        if (push && !full) begin
            stack[sp] <= data_in;
            sp <= sp + 1;
            empty <= 0;
            if (sp == 3'b111) full <= 1;
        end else if (pop && !empty) begin
            sp <= sp - 1;
            data_out <= stack[sp];
            full <= 0;
            if (sp == 3'b000) empty <= 1;
        end
    end
endmodule

module Controle(
    input clk,
    input reset,
    input [7:0] instr,
    input [7:0] instr_dest,     // Registrador de destino
    input [7:0] instr_src,
  input [7:0] result,
    output reg [2:0] reg_addr_A,
    output reg [2:0] reg_addr_B,
    output reg [7:0] data_in,
    output reg write_enable,
    output reg [7:0] alu_opcode,
    output reg [7:0] pc, // Contador de programa (Program Counter)
    output reg stack_push,
    output reg stack_pop,
    input [7:0] stack_data_out
);
    // Definição de estados
    typedef enum reg [2:0] {
        FETCH = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        WRITE_BACK = 3'b011,
        HALT = 3'b100
    } state_t;

    reg state, next_state;

    // Inicialização
    initial begin
        state = FETCH;
        pc = 8'b0;
    end

    // Transições de estado
    always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= FETCH;
    end else begin
        state <= next_state;
    end
end
  
  always @(posedge clk) begin // Armazena o resultado da operação no registrador destino
    if ((instr == 8'b00000000) || // ADD
        (instr == 8'b00000001) || // SUB
        (instr == 8'b00000010) || // MUL
        (instr == 8'b00000011) || // DIV
        (instr == 8'b00000100) || // MOD
        (instr == 8'b00000101) || // AND
        (instr == 8'b00000110) || // OR
        (instr == 8'b00000111) || // XOR
        (instr == 8'b00001101) || // Deslocamento à esquerda
        (instr == 8'b00001110))   // Deslocamento à direita
    begin
        reg_addr_A = instr_dest[2:0];
        data_in = result;    
        write_enable = 1;
    end
end

    // Lógica de transição e saída
  always @(*) begin
        reg_addr_A = 3'b000;
        reg_addr_B = 3'b001;
        write_enable = 0;
        alu_opcode = 8'b11111111; // NOP
        stack_push = 0;
        stack_pop = 0;
        data_in = 8'b0;

        case (state)
            FETCH: begin
                next_state = DECODE; // Busca a próxima instrução
            end

            DECODE: begin
                case (instr)
                    8'b00000000: begin // ADD
                        reg_addr_A <= instr_dest[2:0]; // Registrador de destino
                        reg_addr_B <= instr_src[2:0];
                        alu_opcode = 8'b00000000;
                    end
                    8'b00000001: begin // SUB
                      reg_addr_A <= instr_dest[2:0]; // Registrador de destino
                        reg_addr_B <= instr_src[2:0];
                        alu_opcode = 8'b00000001;
                    end
                    8'b00000010: begin // MUL
                      reg_addr_A <= instr_dest[2:0]; // Registrador de destino
                        reg_addr_B <= instr_src[2:0];
                        alu_opcode = 8'b00000010;
                    end
                    8'b00000011: begin // DIV
                      reg_addr_A <= instr_dest[2:0]; // Registrador de destino
                        reg_addr_B <= instr_src[2:0];
                        alu_opcode = 8'b00000011;
                    end
                    8'b00000100: begin // MOD
                      reg_addr_A <= instr_dest[2:0]; // Registrador de destino
                        reg_addr_B <= instr_src[2:0];
                        alu_opcode = 8'b00000100;
                    end
                    8'b00000101: begin // AND
                      reg_addr_A <= instr_dest[2:0]; // Registrador de destino
                        reg_addr_B <= instr_src[2:0];
                        alu_opcode = 8'b00000101;
                    end
                    8'b00000110: begin // OR
                      reg_addr_A <= instr_dest[2:0]; // Registrador de destino
                        reg_addr_B <= instr_src[2:0];
                        alu_opcode = 8'b00000110;
                    end
                    8'b00000111: begin // XOR
                      reg_addr_A <= instr_dest[2:0]; // Registrador de destino
                        reg_addr_B <= instr_src[2:0];
                        alu_opcode = 8'b00000111;
                    end
                    8'b00001000: begin // GT
                        alu_opcode = 8'b00001000;
                    end
                    8'b00001001: begin // LT
                        alu_opcode = 8'b00001001;
                    end
                    8'b00001010: begin // EQ
                        alu_opcode = 8'b00001010;
                    end
                    8'b00001011: begin // NEQ
                        alu_opcode = 8'b00001011;
                    end
                    8'b00001100: begin // MOV
                      reg_addr_A <= instr_dest[2:0];
                        data_in <= instr_src; 
                        write_enable = 1;
                    end
                    8'b00001101: begin // SHL
                      reg_addr_A <= instr_dest[2:0];
                        alu_opcode = 8'b00001101;
                    end
                    8'b00001110: begin // SHR
                      reg_addr_A <= instr_dest[2:0];
                        alu_opcode = 8'b00001110;
                    end
                    8'b00001111: begin // SET_LSB
                        alu_opcode = 8'b00001111;
                    end
                    8'b00010000: begin // SET_MSB
                        alu_opcode = 8'b00010000;
                    end
                    8'b00010001: begin // IN
                        alu_opcode = 8'b00010001;
                    end
                    8'b00010010: begin // OUT
                        write_enable = 1;
                        alu_opcode = 8'b00010010;
                    end
                    8'b00010011: begin // HALT
                        next_state = HALT;
                    end
                    8'b00010100: begin // NOT
                        alu_opcode = 8'b00010100;
                    end
                    8'b00010101: begin // JUMP
                        stack_push = 1;
                        data_in = pc + 1;
                        pc = instr_src;
                    end
                    8'b00010110: begin // RETURN
                        stack_pop = 1;
                        pc = stack_data_out;
                    end
                    default: alu_opcode = 8'b11111111; // NOP
                endcase
                next_state = EXECUTE;
            end

            EXECUTE: begin
                next_state = WRITE_BACK;
            end

            HALT: begin
                next_state = HALT; // Estado de parada
            end

            default: begin
                next_state = FETCH;
            end
        endcase
    end
endmodule

module Processador(
    input clk,
  input reset,
    input [7:0] instr,
  input [7:0] instr_dest,
    input [7:0] instr_src,
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
    wire [7:0] pc;
    wire stack_push, stack_pop;
    wire [7:0] stack_data_out;

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
      .reset(reset),
        .instr(instr),
      .result(result),
      .instr_dest(instr_dest),
        .instr_src(instr_src),
        .reg_addr_A(reg_addr_A),
        .reg_addr_B(reg_addr_B),
        .data_in(data_in),
        .write_enable(write_enable),
        .alu_opcode(alu_opcode),
        .pc(pc),
        .stack_push(stack_push),
        .stack_pop(stack_pop),
        .stack_data_out(stack_data_out)
    );

    Pilha stack (
        .clk(clk),
        .push(stack_push),
        .pop(stack_pop),
        .data_in(data_in),
        .data_out(stack_data_out),
        .empty(),
        .full()
    );
endmodule
