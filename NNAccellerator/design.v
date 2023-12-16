`timescale 1ns/1ps

/*------------------FSM------------------*/

module FSM (
    input clk,                // Clock input
    input reset,              // Reset input
    input valid,              // valid data dato dal testbench
    input ready_out,          // data ready del consumer
    
    output reg valid_out,     // valid di output per il consumer
    output reg ready,         // ready dell'acceleratore per il testbench
    output reg enable_reg1,   //segnale di enable per il primo registro 
    output reg enable_reg2,   //segnale di enable per il secondo registro  
    output reg enable_reg3  //segnale di enable per il terzo registro 
);

    // codifica degli stati
    parameter [2:0] EMPTY_REGISTERS = 3'b000;
    parameter [2:0] FIRST_PIPE_STAGE_FULL = 3'b001;
    parameter [2:0] SECOND_PIPE_STAGE_FULL = 3'b010;
  	parameter [2:0] PIPE_FULL_RESULT_UNREAD = 3'b011;
    parameter [2:0] PIPE_FULL_RESULT_READ = 3'b100;

    //Segnali di appoggio intermedi 
    reg [2:0] state;
    reg [1:0] reg_count; // Count of valid data registers

    //Logica della FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= EMPTY_REGISTERS;
            reg_count <= 0;
            ready <= 1'b0;
            valid_out <= 1'b0;
            enable_reg1 <= 1'b0;
            enable_reg2 <= 1'b0;
            enable_reg3 <= 1'b0;

        end else begin
            case (state)
                EMPTY_REGISTERS: begin
                    ready=1'b1;
                    enable_reg1 = 1'b1;
                    enable_reg2 = 1'b1;
                    enable_reg3 = 1'b0;
                    valid_out=1'b0;
                    if (valid) begin
                        state = FIRST_PIPE_STAGE_FULL;
                    end else begin
                        state = EMPTY_REGISTERS;
                    end
                end

                FIRST_PIPE_STAGE_FULL: begin
                  	    state = SECOND_PIPE_STAGE_FULL;
                        enable_reg1 = 1'b0;
                        enable_reg2 = 1'b0;
                        enable_reg3 = 1'b1;
                        ready=1'b0;
                        valid_out=1'b0;
                end

                SECOND_PIPE_STAGE_FULL: begin
                  if (ready_out) begin
                        state = PIPE_FULL_RESULT_UNREAD;
                        enable_reg1 = 1'b0;
                        enable_reg2 = 1'b0;
                        enable_reg3 = 1'b0;
                        ready=1'b0;
                        valid_out=1'b1;
                    end else begin
                        state = SECOND_PIPE_STAGE_FULL;
                    end
                end

                PIPE_FULL_RESULT_UNREAD: begin
                    if (ready_out && valid_out) begin
                        state = PIPE_FULL_RESULT_READ;
                        enable_reg1 = 1'b0;
                        enable_reg2 = 1'b0;
                        enable_reg3 = 1'b0;
                      
                        ready=1'b0;
                        valid_out=1'b0;
                    end else begin
                        state = PIPE_FULL_RESULT_UNREAD;
                    end
                end

                PIPE_FULL_RESULT_READ: begin
                  if (valid) begin
                        state = FIRST_PIPE_STAGE_FULL;
                        enable_reg1 = 1'b1;
                        enable_reg2 = 1'b1;
                        enable_reg3 = 1'b0;
                    
                        ready=1'b1;
                        valid_out=1'b0;
                    end else begin
                        state =  PIPE_FULL_RESULT_READ;
                    end
                end
            endcase
        end
    end
endmodule



/*------------------REGISTRO------------------*/

module Register (clk, reset, data_in, data_out, enable);
input clk;         // Clock input
input reset;      // Reset input
input [7:0] data_in;   // data da immettere nel registro
output reg [7:0] data_out; //output del registro
input enable;

  always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 8'b0; // Inizializzazione a 0 in caso di reset
        end else if(enable) begin
            data_out <= data_in; // Aggiornamento del registro con il nuovo dato in ingresso
        end
    end
    
endmodule





/*------------------NEURONE------------------*/

module neuron(X1, X2, X3, X4, W1, W2, W3, W4, bias, xmin, xmax, Y);
	input signed [7:0] X1, X2, X3, X4, W1, W2, W3, W4;
	input signed [15:0] bias;
	input signed [11:0] xmin, xmax;
	output signed [7:0] Y;
	
	wire signed [18:0] Sum;

	wire signed [15:0] Z1, Z2, Z3, Z4; //Wire per l'assegnazione dei prodotti
	

  assign Z1 = (X1*W1); //prodotti
  assign Z2 = (X2*W2);
  assign Z3 = (X3*W3);
  assign Z4 = (X4*W4);

  assign Sum = (Z1+Z2+Z3+Z4+bias)>>7; //somma col biasi shiftata di 7 bit verso destra

  activationFunc func(.x(Sum[11:0]), .f(Y), .xmin(xmin), .xmax(xmax)); //funzione di attivazione
	
endmodule

module activationFunc(x,f,xmin,xmax);

input signed [11:0] x;
output reg signed [7:0] f;
input signed [11:0] xmin, xmax;

	
  always @(*) begin
    if (x <= xmin) begin
      f <= xmin; // Pendenza costante prima di xmin, essendo lo slope = 1
    end else if (x >= xmax) begin
      f <= xmax; // Pendenza costante dopo xmax, essendo lo slope = 1
	end else begin
      f <= x;  // Mantieni la tangente nel range
	end
	end
endmodule




/*------------------TOP MODULE------------------*/

module acc_pipe(X1, X2, X3, X4, Y, ready, valid, ready_out, valid_out, clk, arst);
	input signed [7:0] X1, X2, X3, X4;
	output signed [7:0] Y;
	input valid, ready_out;
	output ready, valid_out;
	input clk, arst;

	wire signed [7:0] S1, S2;
	wire signed [7:0] Y1, Y2, Y3;

	wire enable1, enable2, enable3;

	
	//parameters for N1
	parameter [7:0] n1_w1 = -8'd115;
	parameter [7:0] n1_w2 = 8'd1;
	parameter [7:0] n1_w3 = -8'd105;
	parameter [7:0] n1_w4 = 8'd16;
	parameter [15:0] n1_bias = 16'd12571;
	parameter [11:0] n1_xmin = -12'd127;
	parameter [11:0] n1_xmax = 12'd127;
	//parameters for N2


	parameter [7:0] n2_w1 = 8'd103;
	parameter [7:0] n2_w2 = -8'd22;
	parameter [7:0] n2_w3 = 8'd32;
	parameter [7:0] n2_w4 = -8'd56;
	parameter [15:0] n2_bias = -16'd8139;
	parameter [11:0] n2_xmin = -12'd127;
	parameter [11:0] n2_xmax = 12'd127;


	//parameters for N3
	parameter [7:0] n3_w1 = 8'd75;
	parameter [7:0] n3_w2 = -8'd85;
	parameter [7:0] n3_w3 = -8'd38;
	parameter [7:0] n3_w4 = 8'd92;
	parameter [15:0] n3_bias = 16'd10182;
	parameter [11:0] n3_xmin = -12'd127;
	parameter [11:0] n3_xmax = 12'd127;

	
    //Istanziazione dei moduli

	FSM fsm(.clk(clk), .reset(arst), .valid(valid), .ready_out(ready_out), .valid_out(valid_out), .ready(ready), .enable_reg1(enable1), .enable_reg2(enable2), .enable_reg3(enable3));
	Register reg1(.clk(clk), .reset(arst), .data_in(Y1), .data_out(S1), .enable(enable1));
	Register reg2(.clk(clk), .reset(arst), .data_in(Y2), .data_out(S2), .enable(enable2)); 
	Register reg3(.clk(clk), .reset(arst), .data_in(Y3), .data_out(Y), .enable(enable3));

	neuron n1(.X1(X1),.X2(X2), .X3(X3), .X4(X4), .W1(n1_w1), .W2(n1_w2), .W3(n1_w3), .W4(n1_w4), .bias(n1_bias), .xmin(n1_xmin), .xmax(n1_xmax), .Y(Y1));
	neuron n2(.X1(X1),.X2(X2), .X3(X3), .X4(X4), .W1(n2_w1), .W2(n2_w2), .W3(n2_w3), .W4(n2_w4), .bias(n2_bias), .xmin(n2_xmin), .xmax(n2_xmax), .Y(Y2));
    neuron n3(.X1(S1),.X2(S2), .X3(8'b0), .X4(8'b0), .W1(n3_w1), .W2(n3_w2), .W3(n3_w3), .W4(n3_w4), .bias(n3_bias), .xmin(n3_xmin), .xmax(n3_xmax), .Y(Y3));

	
endmodule