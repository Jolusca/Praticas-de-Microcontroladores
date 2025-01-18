module Testbench();
    // Parâmetros
    reg clk;
  reg reset;
    reg [7:0] instr;
  reg [7:0] instr_src;
  reg [7:0] instr_dest;
    wire [7:0] result;
    wire zero_flag;
    wire carry_flag;
    wire overflow_flag;
  wire sign_flag;
  wire parity_flag;
    int i;
    int operands;

    // Instanciando o processador
    Processador processador (
        .clk(clk),
      .reset(reset),
      .instr(instr),
      .instr_dest(instr_dest),
      .instr_src(instr_src),
        .result(result),
        .zero_flag(zero_flag),
      .carry_flag(carry_flag),
      .sign_flag(sign_flag),
      .parity_flag(parity_flag),
        .overflow_flag(overflow_flag)
    );

    function int num_operands(input [7:0] opcode);
        case (opcode)
            8'b00000000: num_operands = 2; // ADD
            8'b00000001: num_operands = 2; // SUB
            8'b00000010: num_operands = 2; // MUL
            8'b00000011: num_operands = 2; // DIV
            8'b00000100: num_operands = 2; // MOD
            8'b00000101: num_operands = 2; // AND
            8'b00000110: num_operands = 2; // OR
            8'b00000111: num_operands = 2; // XOR
            8'b00001000: num_operands = 2; // >
            8'b00001001: num_operands = 2; // <
            8'b00001010: num_operands = 2; // ==
            8'b00001011: num_operands = 2; // !=
            8'b00001100: num_operands = 2; // MOV
            8'b00001101: num_operands = 1; // Deslocamento à esquerda
            8'b00001110: num_operands = 1; // Deslocamento à direita
            8'b00001111: num_operands = 1; // Manipulação de bit (inserção de 0 no LSB)
            8'b00010000: num_operands = 1; // Manipulação de bit (inserção de 0 no MSB)
            8'b00010001: num_operands = 1; // IN (Leitura)
            8'b00010010: num_operands = 1; // OUT (Escrita)
            8'b00010011: num_operands = 1; // HALT
            8'b00010100: num_operands = 1; // NOT
            default:     num_operands = 0; // NOP e instruções inválidas
        endcase
    endfunction

    // Gerador de clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
      reset = 1;       // Ativa o reset
        #15;            
        reset = 0;
        i = 0;
        
      $readmemb("jump.bin", memory);
        
        forever begin
            if (i < $size(memory)) begin
                instr = memory[i]; // Carrega a instrução
                operands = num_operands(instr);
              
              if (instr == 8'b00010101) begin // Caso seja um JUMP
                    instr_dest = 8'b00000000;
                    instr_src = memory[i + 1]; // Endereço de destino
                    i = instr_src; // Salta para o endereço especificado          
              end else if (instr == 8'b00010110) begin // RETURN
                    instr_dest = 8'b00000000;
                    instr_src = 8'b00000000;
                    i = processador.ctrl.stack_data_out; // Recupera o endereço da pilha
                end else if (operands == 2) begin
                    instr_dest = memory[i+1];
                    instr_src = memory[i+2];
                    i = i + 3;
                end else if (operands == 1) begin
                    instr_dest = memory[i+1];
                    instr_src = 8'b00000000;
                    i = i + 2;
                end else begin
                    instr_dest = 8'b00000000;
                    instr_src = 8'b00000000;
                    i = i + 1;
                end
                #20; 
            end else begin
                $finish; 
            end
        end
    end

    reg [7:0] memory [0:255];
  


    initial begin
      $monitor("Tempo=%0t, Instrucao=%b, Operando1=%b, Operando2=%b, Resultado=%b, ZeroFlag=%b, CarryFlag=%b, OverflowFlag=%b, SignFlag =%b, Parity_Flag = %b",
                 $time, instr, instr_dest, instr_src, result, zero_flag, carry_flag, overflow_flag, sign_flag, parity_flag);
    end

endmodule
