module Seq_Det (output reg ERR, input wire Clock, Reset, Din);

    reg [2:0] current_state, next_state;
    parameter Start  = 3'b000,
              D0_is_1 = 3'b001,
              D1_is_1 = 3'b010,
              D0_not_1 = 3'b011,
              D1_not_1 = 3'b100;

    always @(posedge Clock or negedge Reset) begin : STATE_MEMORY
        if (!Reset)
            current_state <= Start;
        else
            current_state <= next_state;
    end

    always @(current_state or Din) begin : NEXT_STATE_LOGIC
        case (current_state)
            Start: 
              if (Din == 1'b1)
                    next_state = D0_is_1;
                else
                    next_state = D0_not_1;
            D0_is_1: 
                if (Din == 1'b1)
                    next_state = D1_is_1;
                else
                    next_state = D1_not_1;
            D1_is_1: 
                next_state = Start;
            D0_not_1: 
                next_state = D1_not_1;
            D1_not_1: 
                next_state = Start;
            default: 
                next_state = Start;
        endcase
    end

    always @(current_state or Din) begin : OUTPUT_LOGIC
        case (current_state)
            D1_is_1: 
              if (Din == 1'b1) begin
                    ERR = 1'b1;
                $display ("%0b", ERR);
              end
                else begin
                    ERR = 1'b0;
          $display ("%0b", ERR);
                end
            default: 
                ERR = 1'b0;
        endcase
    end

endmodule
