/*module test () ;
  reg a , b ;
	wire c_out , sum ;
	Add_half ADD_HALF (. c_out ( c_out ) ,. sum ( sum ) ,. a ( a ) ,. b ( b ) ) ;
	initial begin
      assign a =1;
      assign b =1;
	  display;
	end

	task display ;
      #1 $display ("a:%0h, b:%0h, c_out:%0h, sum:%0h", a, b, c_out, sum) ;
       // The pound sign character , \# , is used for the delay control . Obs .: #0 is discouraged .
	endtask
  
endmodule*/

module test_fulladd () ;
  reg a, b, cin;
  wire soma, cout;
  
  Add_full ADD_FULL (.soma(soma), .cout(cout), .a(a), .b(b), .cin(cin));
  
  initial begin
    assign a =0;
    assign b = 0;
    assign cin = 1;
    display;
  end
  
  task display ;
    #1 $display ("a:%0h, b:%0h, cin: %0h, c_out:%0h, sum:%0h", a, b, cin, cout, soma) ;
       // The pound sign character , \# , is used for the delay control . Obs .: #0 is discouraged .
  endtask
  
endmodule
  
  
