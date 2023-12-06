module FSM (
    input clk,                // Clock input
    input reset,              // Reset input
    input valid,              // Input data valid from feeder
    input ready_out,          // Input data ready from consumer
    
    output reg valid_out,     // Output data valid to consumer
    output reg ready,         // Output data ready to accelerator
    output reg enable_reg1,   // Enable signal for Reg 1
    output reg enable_reg2,   // Enable signal for Reg 2
    output reg enable_reg3,   // Enable signal for Reg 3
);

    // Define FSM states
    parameter [2:0] EMPTY_REGISTERS = 3'b000;
    parameter [2:0] FIRST_PIPE_STAGE_FULL = 3'b001;
    parameter [2:0] SECOND_PIPE_STAGE_FULL = 3'b010;
    parameter [2:0] PIPE_FULL_RESULT_UNREAD = 3'b011;
    parameter [2:0] PIPE_FULL_RESULT_READ = 3'b100;

    // Define FSM signals
    reg [2:0] state, next_state;
    reg [1:0] reg_count; // Count of valid data registers

    // FSM logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= EMPTY_REGISTERS;
            reg_count <= 0;
            ready <= 1'b1;
            valid_out <= 1'b0;
            enable_reg1 <= 1'b0;
            enable_reg2 <= 1'b0;
            enable_reg3 <= 1'b0;
        end else begin
            state <= next_state;
            ready <= (state == EMPTY_REGISTERS || state == FIRST_PIPE_STAGE_FULL || state == SECOND_PIPE_STAGE_FULL);
            valid_out <= (state == FIRST_PIPE_STAGE_EMPTY || state == SECOND_PIPE_STAGE_FULL || state == PIPE_FULL_RESULT_UNREAD);
        end
    end

    // Next-state logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            next_state <= EMPTY_REGISTERS;
        end else begin
            case (state)
                EMPTY_REGISTERS: begin
                    if (valid && ready_out) begin
                        next_state <= FIRST_PIPE_STAGE_FULL;
                        enable_reg1 <= 1'b1;
                        enable_reg2 <= 1'b1;
                        enable_reg3 <= 1'b0;
                    end else begin
                        next_state <= EMPTY_REGISTERS;
                    end
                end

                FIRST_PIPE_STAGE_FULL: begin
                    if (valid && ready_out) begin
                        next_state <= SECOND_PIPE_STAGE_FULL;
                        enable_reg1 <= 1'b0;
                        enable_reg2 <= 1'b0;
                        enable_reg3 <= 1'b1;
                    end else begin
                        next_state <= FIRST_PIPE_STAGE_FULL;
                    end
                end

                SECOND_PIPE_STAGE_FULL: begin
                    if (ready_out && valid_out) begin
                        next_state <= PIPE_FULL_RESULT_READ;
                        enable_reg1 <= 1'b0;
                        enable_reg2 <= 1'b0;
                        enable_reg3 <= 1'b0;
                    end else begin
                        next_state <= SECOND_PIPE_STAGE_FULL;
                    end
                end

                PIPE_FULL_RESULT_UNREAD: begin
                    if (ready_out && valid_out) begin
                        next_state <= PIPE_FULL_RESULT_READ;
                        enable_reg1 <= 1'b0;
                        enable_reg2 <= 1'b0;
                        enable_reg3 <= 1'b0;
                    end else begin
                        next_state <= PIPE_FULL_RESULT_UNREAD;
                    end
                end

                PIPE_FULL_RESULT_READ: begin
                    if (valid && ready_out) begin
                        next_state <= FIRST_PIPE_STAGE_FULL;
                        enable_reg1 <= 1'b1;
                        enable_reg2 <= 1'b1;
                        enable_reg3 <= 1'b0;
                    end else begin
                        next_state <= EMPTY_REGISTERS;
                    end
                end
            endcase
        end
    end
endmodule
