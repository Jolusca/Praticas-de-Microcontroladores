module Testbench;
    reg clk;
    reg [7:0] instr;
    wire [7:0] result;
    wire zero_flag;
    wire carry_flag;
    wire overflow_flag;

    // Instância do módulo principal do processador
    Processador uut (
        .clk(clk),
        .instr(instr),
        .result(result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag)
    );

    // Gerador de clock
    always #5 clk = ~clk;

    initial begin
        // Inicialização
        clk = 0;
        instr = 8'b00010000; // NOP
        #10;
        
        // Teste de instrução de soma
        instr = 8'b00010000;
        #10;
        
        // Verifica resultado da soma
        instr = 8'b00010001;
        #10;
        
        // Teste de instrução de subtração
        instr = 8'b00100000;
        #10;
        
        // Outros testes
        instr = 8'b00100001;
        #10;

        // Finalização
        $finish;
    end

    // Monitoramento dos sinais
    initial begin
        $monitor("Time: %0t | Instr: %b | Result: %b | Zero: %b | Carry: %b | Overflow: %b", $time, instr, result, zero_flag, carry_flag, overflow_flag);
    end
endmodule
