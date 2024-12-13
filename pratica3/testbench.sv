`timescale 1ns/1ns

module test();
  
 reg err, clock, din, reset;
  
  Seq_Det seq_det (.ERR(err), .Clock(clock), .Reset(reset), .Din(din));
  
  initial begin
    assign clock = 1;
    assign reset = 0;
    
    forever begin
      #1 assign clock = !clock;
      assign din = 1;
      assign reset = 1;
      $monitor ("%0t, %0d, %0d, %0d", $time, din, reset, clock);
    end
  end
endmodule
