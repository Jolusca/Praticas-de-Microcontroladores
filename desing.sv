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
