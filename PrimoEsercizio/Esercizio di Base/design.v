// Code your design here


module topModule(A, B, opcode, co, Y);
  input signed [15:0] A, B; //elementi di ingresso, per ora wire!
  input [2:0] opcode; //codice operativo
  
  //sono reg perchè modificate in un blocco procedurale
  output reg [16:0] Y; // uno  in più per il carry dell'operazione!
  output reg co;
  
  //ora definisco un blocco procedurale 
  
  reg signed [15:0] B2=B;
  
  
  always @(opcode) //qui capisco cosa bisogna fare a seconda dell'opcode dato in ingresso 
    begin 
      case(opcode)
        3'd0: //se 000, allora sommo solo A e B2
        begin
        B2=B;
        Y=A+B2+opcode[0];
        co = Y[16];
        end
        
        3'd1: //se 001, sommo e incremento
        begin
        B2=B;
        Y=A+B2+opcode[0]+1;
        co = Y[16];
        end
        
        3'd2: //se 010, sommo e decremento
       	begin
        B2=B;
        Y=A-B2+opcode[0]-1;
        co = Y[16];
        end
        
        3'd3: //se 011, nego B2 e sommo A-B
        begin
        B2=B;
        Y=A-B2+opcode[0];
        co = Y[16];
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
        co = Y[16];
        end
        
        3'd6: //se 110, passa A-1
        begin
        Y = A-1;
        co = Y[16];
        end
        
        3'd7: //se 111, passa solo A
        begin
        B2=16'b0;
        Y=A;
        co = 0;
        end
      endcase 
    end
  
endmodule

