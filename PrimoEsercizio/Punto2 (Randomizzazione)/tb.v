// Code your testbench here
// or browse Examples

module testbench;
  reg [7:0] A_test, B_test;
  reg [2:0] opcode_test;
  wire [8:0] Y_result;
  wire co_result;
  
  
  topModule #(.nbits(7)) dut(
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
    A_test = {$random() % 15}; B_test = {$random() % 20}; opcode_test = 3'b001; // Esempio di input
    #10; // Attendiamo un po' per vedere i risultati
    
    A_test = {$random() % 15}; B_test = {$random() % 20}; opcode_test = 3'b110; // Altro esempio di input
    #10; // Attendiamo un po' per vedere i risultati
    
    A_test = {$random() % 15}; B_test = {$random() % 20}; opcode_test = 3'b000;
    #10
    
    
    // Aggiungi ulteriori combinazioni di input per testare più casi
    
    $finish; // Termina la simulazione
  end
endmodule


