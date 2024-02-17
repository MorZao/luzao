module sobel #(
    parameter integer ROW_WIDTH = 720,
    parameter integer DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    output logic in_rd_en,
    input logic in_empty,
    input logic [DATA_WIDTH-1:0] in_dout,
    output logic out_wr_en,
    input logic out_full,
    output logic [DATA_WIDTH-1:0] out_din
);


typedef enum {IDLE, READ, PROCESS, WRITE, UPDATE_BUFFERS} state_t;
state_t state, next_state;

logic[DATA_WIDTH-1:0] buffer1[BUFFER_WIDTH-1:0];
logic[DATA_WIDTH-1:0] buffer2[BUFFER_WIDTH-1:0];
logic[DATA_WIDTH-1:0] buffer3[BUFFER_WIDTH-1:0];
logic[DATA_WIDTH-1:0] shift_matrix[2:0][2:0];

logic[9:0] horizontal_gradient;
logic[9:0] horizontal_gradient_abs;
logic[9:0] vertical_gradient;
logic[9:0] vertical_gradient_abs;
logic[9:0] v;
logic[7:0] sbl;
logic[7:0] sbl_c;

logic [9:0] col_count , row_count , next_col_count , next_row_count;

// Define logic for gradients, abs gradients, and other Sobel-related variables

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        col_count <= 0;
        row_count <= 0;
        // Initialize buffers and shift_matrix to 0
       for (int i = 0; i < ROW_WIDTH; i++) begin
            buffer1[i] <= 0;
            buffer2[i] <= 0;
            buffer3[i] <= 0;
        end

        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                shift_matrix[i][j] <= 0;
            end
        end

    end else begin
        state <= next_state;
        col_count <= next_col_count;
        row_count <= next_row_count;
        sbl <= sbl_c;
    end
end

always_comb begin
    in_rd_en  = 1'b0;
    out_wr_en = 1'b0;
    out_din   = 8'b0;
    next_state   = state;
    sbl_c = sbl;

        case (state)
            IDLE: begin
                if (!in_empty) next_state = READ;
            end
            READ: begin
                // Implement reading and updating shift_matrix logic
                buffer3[col_count] = in_dout; 

                shift_matrix[0][0] = shift_matrix[0][1];
                shift_matrix[0][1] = shift_matrix[0][2];
                shift_matrix[0][2] = buffer1[col_count+1];
                shift_matrix[1][0] = shift_matrix[1][1];
                shift_matrix[1][1] = shift_matrix[1][2];
                shift_matrix[1][2] = buffer2[col_count+1];
                shift_matrix[2][0] = shift_matrix[2][1];
                shift_matrix[2][1] = shift_matrix[2][2];
                shift_matrix[2][2] = in_dout;

                next_col_count = col_count + 1;
                if (col_count >= ROW_WIDTH) next_state = UPDATE_BUFFERS;
                else if (col_count >= 1 and row_count >= 1) next_state = PROCESS; //need change, 
                else next_state = READ;
            end
            PROCESS: begin
                if (in_empty == 1'b0) begin
                    horizontal_gradient = shift_matrix[2][0] + 2 * shift_matrix[2][1] + shift_matrix[2][2] - shift_matrix[0][0] - 2 * shift_matrix[0][1] - shift_matrix[0][2];
                    vertical_gradient = shift_matrix[0][2] + 2 * shift_matrix[1][2] + shift_matrix[2][2] - shift_matrix[0][0] - 2 * shift_matrix[1][0] - shift_matrix[2][0];
                    if (horizontal_gradient[9]) begin
                        horizontal_gradient_abs = -horizontal_gradient; 
                    end else begin
                        horizontal_gradient_abs = horizontal_gradient;
                    end
                    if (vertical_gradient[9]) begin
                    vertical_gradient_abs = -vertical_gradient; 
                    end else begin
                    vertical_gradient_abs = vertical_gradient;
                    end
                    v = (horizontal_gradient_abs + vertical_gradient_abs)/2
  
                    sbl_c = v > 0xFF ? 0xFF :v[7:0];
                    in_rd_en = 1'b1;
                    next_state = WRITE;
                end
            end
            WRITE: begin
                if (out_full == 1'b0) begin
                out_din = sbl;
                out_wr_en = 1'b1;
                next_state = READ;
                end
            end
            UPDATE_BUFFERS: begin
                buffer3[0] = 0;  
                buffer3[BUFFER_WIDTH-1] = 0;  

                buffer1 = buffer2;
                buffer2 = buffer3;

                next_col_count = 0; 
                next_row_count = row_count + 1;

                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
end


endmodule
