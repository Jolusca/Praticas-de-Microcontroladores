module tb_Processador;

    reg clk;
    reg [7:0] instr;
    wire [7:0] result;
    wire zero_flag;
    wire carry_flag;
    wire overflow_flag;

    // Instanciação do módulo processador
    Processador uut (
        .clk(clk),
        .instr(instr),
        .result(result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag)
    );

    // Gera o clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Teste
    initial begin
        $display("Instrucao\tResultado\tZero Flag\tCarry Flag\tOverflow Flag");
        
        // Inicializando valores dos registradores para teste
        uut.regs.regs[0] = 8'b00000101; // Valor inicial: 5
        uut.regs.regs[1] = 8'b00000011; // Valor inicial: 3
        
        instr = 8'b00110000; // Multiplicação
        #10;
        $display("%b\t%b\t%b\t%b\t%b", instr, result, zero_flag, carry_flag, overflow_flag);
        
        uut.regs.regs[0] = 8'b00001010; // Valor inicial: 10
        uut.regs.regs[1] = 8'b00000010; // Valor inicial: 2
        
        instr = 8'b00110011; // Divisão
        #10;
        $display("%b\t%b\t%b\t%b\t%b", instr, result, zero_flag, carry_flag, overflow_flag);
        
        uut.regs.regs[0] = 8'b00001011; // Valor inicial: 11
        uut.regs.regs[1] = 8'b00000011; // Valor inicial: 3
        
        instr = 8'b00110100; // Módulo
        #10;
        $display("%b\t%b\t%b\t%b\t%b", instr, result, zero_flag, carry_flag, overflow_flag);
        
        $finish;
    end
endmodule
