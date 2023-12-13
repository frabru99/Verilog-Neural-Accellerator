// Code your testbench here
// or browse Examples

module testbench;
  reg [15:0] A_test, B_test;
  reg [2:0] opcode_test;
  wire [16:0] Y_result;
  wire co_result;
  
  topModule dut(
    .A(A_test),
    .B(B_test),
    .opcode(opcode_test),
    .Y(Y_result),
    .co(co_result)
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
    
    // Test con diverse combinazioni di input
    A_test = 10; B_test = 5; opcode_test = 3'b001; // Esempio di input
    #10; // Attendiamo un po' per vedere i risultati
    
    A_test = 20; B_test = 30; opcode_test = 3'b110; // Altro esempio di input
    #10; // Attendiamo un po' per vedere i risultati
    
    // Aggiungi ulteriori combinazioni di input per testare più casi
    
    $finish; // Termina la simulazione
  end
endmodule

