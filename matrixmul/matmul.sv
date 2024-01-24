module matmul 
#(  parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 6,
    parameter Tn = 8) // Ensure Tn fits within ADDR_WIDTH bits
(
    input  logic                  clock,
    input  logic                  reset,
    input  logic                  start,
    output logic                  done,
    input  logic [DATA_WIDTH-1:0] x_dout,
    output logic [ADDR_WIDTH-1:0] x_addr,
    input  logic [DATA_WIDTH-1:0] y_dout,
    output logic [ADDR_WIDTH-1:0] y_addr,
    output logic [DATA_WIDTH-1:0] z_din,
    output logic [ADDR_WIDTH-1:0] z_addr,
    output logic                  z_wr_en
);

typedef enum logic [1:0] {IDLE, BUSY, WRITE, DONE} state_t;
state_t state, state_c;
logic [ADDR_WIDTH-1:0] i, i_c;
logic [ADDR_WIDTH-1:0] j, j_c;
logic [ADDR_WIDTH-1:0] k, k_c;
logic done_c, done_o;
logic [DATA_WIDTH-1:0] z_din_reg; // Register to hold the partial sum

assign done = done_o;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        done_o <= 1'b0;
        i <= '0;
        j <= '0;
        k <= '0;
        z_din_reg <= '0; // Reset the partial sum
    end else begin
        state <= state_c;
        done_o  <= done_c;
        i <= i_c;
        j <= j_c;
        k <= k_c;
        if (state_c == BUSY || state_c == WRITE) begin
            z_din_reg <= $signed(z_din_reg) + ($signed(y_dout) * $signed(x_dout));
        end else if (state_c == IDLE) begin
            z_din_reg <= '0; // Reset the partial sum
        end
    end
end

always_comb begin
    z_wr_en = '0;
    x_addr  = '0;
    y_addr  = '0;
    z_din   = '0;
    z_addr  = '0;

    state_c = state;
    i_c     = i;
    j_c     = j;
    k_c     = k;

    done_c  = done_o;

    case (state)
        IDLE: begin
            z_din   = 'b0;
            z_addr  = 'b0;
            i_c <= '0;
            j_c <= '0;
            k_c <= '0;
            if (start == 1'b1) begin
                k_c = '1;
                state_c <= BUSY;
                done_c  = 1'b0;
            end else begin
                state_c <= IDLE;
            end            
        end

        BUSY: begin
            if (k == Tn) begin
                state_c = WRITE;
                k_c = '0;
            end else begin
                state_c = BUSY;
                k_c = k + 1;
                x_addr = i * Tn + k; // Corrected to ensure the index is within the matrix dimensions
                y_addr = k * Tn + j; // Corrected similarly
            end
        end 

        WRITE: begin
            z_addr = i * N + j;
            z_wr_en = 1'b1;
            if (j == N - 1) begin
                i_c = i + 'b1;
                j_c = 'b0;
                if (i_c == N) begin
                    state_c <= DONE;
                end else begin
                    state_c <= BUSY;
                end
            end else begin
                j_c = j + 1;
                state_c <= BUSY;
            end
        end

        DONE: begin
            done_c = 1'b1;
            state_c = IDLE;
        end
    endcase

    if (state == BUSY || state == WRITE) begin
        z_din = z_din_reg; // Assign the partial sum to the output
    end
end

endmodule
