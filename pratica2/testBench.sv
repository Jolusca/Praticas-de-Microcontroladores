// Code your design here
module Add_half ( output c_out , sum , input a , b ) ;
	xor ( sum ,a , b ) ;
	and ( c_out ,a , b ) ;
endmodule

module Add_full (output soma, cout, input a, b, cin);
  	
  wire carry_1, carry_2, soma_1;
  
  Add_half B1(carry_1, soma_1, a, b);
  Add_half B2(carry_2, soma, cin, soma_1);
  or B3(cout, carry_1, carry_2);
  
endmodule	
module readfile ();
  
  int fd;
  string line;
  integer lin;
  reg [7:0] data;
  reg [7:0] parcela1;
  reg [7:0] parcela2;
  reg [7:0] resultado;
  reg [7:0] dados;
  reg [7:0] soma1;
  reg [7:0] sub1;
  int i;
  
  initial begin
    
    reg [7:0] soma1 = 8'b00000000;
    reg [7:0] sub1 = 8'b00000001;
    int i = 0;
    
    fd = $fopen ("./output", "rb");
  	//if (fd)  $display("File was opened successfully : %0d", fd);
    //else     $display("File was NOT opened successfully : %0d", fd);
    
    
    while (!$feof(fd)) begin
      
      lin = $fgets(data, fd);
     // $display ("Line read : %0b", lin);
      dados[i] = lin;
     // $display ("%0b", dados[i]) ;
      i = i + 1;
      
      if (data == soma1) begin
        lin = $fgets(parcela1, fd);
        lin = $fgets(parcela2, fd);
        resultado = parcela1 + parcela2;
        
        $display ("resultado soma %0b", resultado); // IMPORTANTE, PRITAR BINARIO
        
        
       //$display ("soma");
      end
      
      
      if (data == sub1) begin
        lin = $fgets(parcela1, fd);
        lin = $fgets(parcela2, fd);
        resultado = parcela1 - parcela2;
        
        $display ("resultado sub %0b", resultado);
       //$display ("sub");
      end
        
    end
    
    $fclose(fd);

  end
  
endmodule
