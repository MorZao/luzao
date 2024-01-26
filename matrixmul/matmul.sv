module matmul 
#(  parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 6,
    parameter Tn = 8)
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

typedef enum logic [1:0] {s0, s1, s2, s3} state_t;
state_t state, next_state;
logic [ADDR_WIDTH-1:0] i, next_i;
logic [ADDR_WIDTH-1:0] j, next_j;
logic [ADDR_WIDTH-1:0] k, next_k;
logic [DATA_WIDTH-1:0] product, next_product;
logic next_done, done_o;

assign done = done_o;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
        done_o <= 1'b0;
        i <= '0;
        j <= '0;
        k <= '0;
        product <= '0; // Reset product as well
    end else begin
        state <= next_state;
        done_o <= next_done;
        i <= next_i;
        j <= next_j;
        k <= next_k;
        z_din <= next_product; // Update product at clock edge
    end
end

always_comb begin
    // Default assignments
    z_wr_en = 'b0;
    x_addr = 'b0;
    y_addr = 'b0;
    next_product = product; // Hold the current product

    next_state = state;
    next_i = i;
    next_j = j;
    next_k = k;
    next_done = done_o;    

    case (state)
        s0: begin
            next_i = '0;
            next_j = '0;
            next_k = '0;
            next_product = '0; // Initialize product
            if (start == 1'b1) begin
                next_state = s1;
                next_done = 1'b0;
            end
        end

        s1: begin
            if (k == Tn) begin
                next_state = s2;
            end else begin
                if (k == 0) begin
                    next_product = $signed(y_dout) * $signed(x_dout);
                end else begin
                    next_product = $signed(y_dout) * $signed(x_dout) + product;
                end
                next_k = k + 1;
                x_addr = i * Tn + k;
                y_addr = k * Tn + j;
            end
        end 

        s2: begin
            z_addr = i * Tn + j;
            z_wr_en = 1'b1;
            if (j == Tn - 1) begin
                next_i = i + 1;
                next_j = '0;
                if (i + 1 == Tn) begin
                    next_state = s3;
                end else begin
                    next_state = s1;
                end
            end else begin
                next_j = j + 1;
            end
        end

        s3: begin
            next_done = 1'b1;
            next_state = s0;
        end
    endcase
end

endmodule
