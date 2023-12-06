module neuron(X1, X2, X3, X4, W1, W2, W3, W4, bias, xmin, xmax, Y);
	input signed [7:0] X1, X2, X3, X4, W1, W2, W3, W4;
	input signed [15:0] bias;
	input signed [11:0] xmin, xmax;
	output signed [7:0] Y;
	
	reg signed [18:0] Sum;
	/* add your code to complete the description */

	wire signed [16:0] Z1, Z2, Z3, Z4;
	

  assign Z1= (X1*W1);
  assign Z2= (X2*W2);
  assign Z3= (X3*W3);
  assign Z4= (X4*W4);

  assign Sum = (Z1+Z2+Z3+Z4+bias)>>7;

  activationFunc func(.x(Sum), .f(Y), .xmin(xmin), .xmax(xmax));
	
endmodule



module activationFunc(x,f,xmin,xmax);

input signed [11:0] x;esa<
output reg signed [7:0] f;
input signed [11:0] xmin, xmax;

	/*add your code to complete the description*/
  always @(x, f, xmin, xmax) begin
    if (x <= xmin) begin
      f = xmin; // Pendenza costante prima di xmin, essendo lo slope = 1
    end else if (x >= xmax) begin
      f = xmax; // Pendenza costante dopo xmax, essendo lo slope = 1
	end else begin
      f = x;  // Mantieni la tangente nel range
	end
	end
endmodule