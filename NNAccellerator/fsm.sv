module FSM_moore (clk, reset, din, enables, dout);
    input clk, reset; 

    input [1:0] din;  //vettore di valid ready_out
    output [1:0] dout; //vettore di valid_out, ready
    output [2:0] enables; //enable dei reg dei neuroni

    wire clk, reset, din;
    reg dout;


    reg [2:0] ac_state, nx_state;

    parameter [2:0] S0 = 3'b000, S1=3'b001, S2=3'b011, S3=3'b010, S4=3'b110, idle = 3'b111;

    always @(posedge reset or posedge clk) begin

        if(reset)
            ac_state <= idle;
        else 
            ac_state <= nx_state;
    end


    always @(ac_state, din) begin

        case(ac_state)

        S0:
        S1:
        S2:
        S3:
        S4:
        

        default: nx_state <= idle;
        endcase

    end


    always @(ac_state) begin

        case(ac_state)


        default: 
        endcase
        
    end



endmodule