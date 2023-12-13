// Code your design here
module topModule(A, B, opcode, co, Y, clk, rst, arst);
  parameter nbits = 15;
  parameter pipe =0;
  
  input clk;
  input rst;
  input arst;
  
  input signed [nbits:0] A, B; //elementi di ingresso, per ora wire!
  input [2:0] opcode; //codice operativo
  
  //sono reg perchè modificate in un blocco procedurale
  output reg [nbits+1:0] Y; // un bit in più per il carry dell'operazione!
  output reg co;
  
  reg signed [nbits:0] Ar, Br; //reg di appoggio per soluzione con pipelining
  reg [nbits+1:0] Yr;
  reg [2:0] opcode_r;
  
  reg signed [nbits:0] B2; //reg di appoggio, per valori intermedi
  
  
  //per pipe=1, instanzio vari registri per l'utilizzo pipe-lined.
  myReg #(.nbits(nbits)) A_reg(.clk(clk), .Q(Ar), .D(A), .rst(rst), .arst(arst));
  myReg #(.nbits(nbits)) B_reg(.clk(clk), .Q(Br), .D(B), .rst(rst), .arst(arst));
  myReg #(.nbits(nbits)) opcode_reg(.clk(clk), .Q(opcode_r), .D(opcode), .rst(rst), .arst(arst));
  myReg #(.nbits(nbits)) Y_reg(.clk(clk), .Q(Yr), .D(Y), .rst(rst), .arst(arst));
  
  //ora definisco un blocco procedurale 
  
  
  
  always @(posedge(clk) or posedge(rst)) //qui capisco cosa bisogna fare a seconda dell'opcode dato in ingresso 
    begin 
       //fare solo il reset
      if(pipe==0)
        
        case(opcode)
          3'd0: //se 000, allora sommo solo A e B2
          begin
          B2=B;
          Y=A+B2+opcode[0];
          co = Y[nbits+1];
          end

          3'd1: //se 001, sommo e incremento
          begin
          B2=B;
          Y=A+B2+opcode[0]+1;
          co = Y[nbits+1];
          end

          3'd2: //se 010, sommo e decremento
          begin
          B2=~B;
          Y=A+B2+opcode[0]-1;
            co = Y[nbits+1];
          end

          3'd3: //se 011, nego B2 e sommo A-B
          begin
          B2=~B;
          Y=A+B2+opcode[0];
            co = Y[nbits+1];
          end

          3'd4: //se 100, passa solo A  
          begin
          B2=16'b0;
          Y=A;
          co = 0;
          end

          3'd5: //se 101 passa A+1

          begin
          Y = A+1;
            co = Y[nbits+1];
          end

          3'd6: //se 110, passa A-1
          begin
          Y = A-1;
          co = Y[nbits+1];
          end

          3'd7: //se 111, passa solo A
          begin
          B2=16'b0;
          Y=A;
          co = 0;
          end
        endcase 
         
      else
        
        case(opcode)
          3'd0: //se 000, allora sommo solo A e B2
          begin
          B2=Br;
          Y=Ar+B2+opcode_r[0];
          co = Y[nbits+1];
          end

          3'd1: //se 001, sommo e incremento
          begin
          B2=Br;
          Y=Ar+B2+opcode_r[0]+1;
          co = Y[nbits+1];
          end

          3'd2: //se 010, sommo e decremento
          begin
          B2=~Br;
          Y=Ar+B2+opcode_r[0]-1;
          co = Y[nbits+1];
          end

          3'd3: //se 011, nego B2 e sommo A-B
          begin
          B2=~Br;
          Y=Ar+B2+opcode_r[0];
          co = Y[nbits+1];
          end

          3'd4: //se 100, passa solo A  
          begin
          Y=Ar;
          co = 0;
          end

          3'd5: //se 101 passa A+1
          begin
          Y = Ar+1;
          co = Y[nbits+1];
          end

          3'd6: //se 110, passa A-1
          begin
          Y = Ar-1;
          co = Y[nbits+1];
          end

          3'd7: //se 111, passa solo A
          begin
          B2=16'b0;
          Y=Ar;
          co = 0;
          end
        endcase
      end 
endmodule


module myReg(clk, Q, D, arst, rst);
  parameter nbits=7;
  input [nbits:0] D;
  output reg [nbits:0] Q;
  input clk;
  input arst;
  input rst;
  
  
  always @ (posedge clk or arst)
    begin 
      if(arst) begin
        Q<=8'd0;
      end else if (rst) begin
        Q<=8'd0;
      end else begin
        Q<=D;
      end
    end
  
endmodule
