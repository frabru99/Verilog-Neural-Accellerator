`include "register.v"
`include "neuron.v"
`include "exampleFSM.v"

module acc_pipe(X1, X2, X3, X4, Y, ready, valid, ready_out, valid_out, clk, arst);
	input signed [7:0] X1, X2, X3, X4;
	output signed [7:0] Y;
	input valid, ready_out;
	output ready, valid_out;
	input clk, arst;


	reg signed [7:0] S1, S2;
	wire signed [7:0] Y1, Y2, Y3;

	reg enable1, enable2, enable3;

	
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

	/*Add your code to complete the description*/

	FSM fsm(.clk(clk), .reset(arst), .valid(valid), .ready_out(ready_out), .valid_out(valid_out), .ready(ready), .enable_reg1(enable1), .enable_reg2(enable2), .enable_reg3(enable3));
	Register reg1(.clk(clk), .reset(arst), .data_in(Y1), .data_out(S1), .enable(enable1));
	Register reg2(.clk(clk), .reset(arst), .data_in(Y2), .data_out(S2), .enable(enable2)); //aggiungere segnali di enable registri
	Register reg3(.clk(clk), .reset(arst), .data_in(Y3), .data_out(Y), .enable(enable3));

	neuron n1(.X1(X1),.X2(X2), .X3(X3), .X4(X4), .W1(n1_w1), .W2(n1_w2), .W3(n1_w3), .W4(n1_w4), .bias(n1_bias), .xmin(n1_xmin), .xmax(n1_xmax), .Y(Y1));
	neuron n2(.X1(X1),.X2(X2), .X3(X3), .X4(X4), .W1(n2_w1), .W2(n2_w2), .W3(n2_w3), .W4(n2_w4), .bias(n2_bias), .xmin(n2_xmin), .xmax(n2_xmax), .Y(Y2));
	neuron n3(.X1(S1),.X2(S2), .X3(0), .X4(0), .W1(n3_w1), .W2(n3_w2), .W3(n3_w3), .W4(n3_w4), .bias(n3_bias), .xmin(n3_xmin), .xmax(n3_xmax), .Y(Y3));

	
endmodule