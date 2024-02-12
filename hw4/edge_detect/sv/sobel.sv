module image_processor #(
    parameter integer ROW_WIDTH = 720,  
    parameter integer DATA_WIDTH = 8   
    input logic clk,                    
    input logic reset,

    output logic        in_rd_en,
    input  logic        in_empty,
    input  logic [DATA_WIDTH-1:0] in_dout,
    output logic        out_wr_en,
    input  logic        out_full,
    output logic [DATA_WIDTH-1:0]  out_din       
);

parameter integer BUFFER_WIDTH = ROW_WIDTH + 2;  

typedef enum logic [0:0] {s0, s1} state_types;
state_types state, state_c;

logic[DATA_WIDTH-1:0] buffer1[BUFFER_WIDTH-1:0];
logic[DATA_WIDTH-1:0] buffer2[BUFFER_WIDTH-1:0];
logic[DATA_WIDTH-1:0] buffer3[BUFFER_WIDTH-1:0];
// 定义3x3移位寄存器矩阵
logic[DATA_WIDTH-1:0] shift_matrix[2:0][2:0];

logic[9:0] horizontal_gradient;
logic[9:0] horizontal_gradient_abs;
logic[9:0] vertical_gradient;
logic[9:0] vertical_gradient_abs;
logic[9:0] v;
logic[7:0] sbl;
logic[7:0] sbl_c;

// 列计数器
integer col_count = 0;
integer row_count = 0;



always_ff @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin

       for (int i = 0; i < BUFFER_WIDTH; i++) begin
            buffer1[i] <= 0;
            buffer2[i] <= 0;
            buffer3[i] <= 0;
        end

        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                shift_matrix[i][j] <= 0;
            end
        end

        col_count <= 0;
        row_count <= 0;

    end else if  begin
 
        if (col_count < ROW_WIDTH) begin
            buffer3[col_count + 1] <= in_dout; 

            shift_matrix[0][0] <= shift_matrix[0][1];
            shift_matrix[0][1] <= shift_matrix[0][2];
            shift_matrix[0][2] <= buffer1[col_count+1];
            shift_matrix[1][0] <= shift_matrix[1][1];
            shift_matrix[1][1] <= shift_matrix[1][2];
            shift_matrix[1][2] <= buffer2[col_count+1];
            shift_matrix[2][0] <= shift_matrix[2][1];
            shift_matrix[2][1] <= shift_matrix[2][2];
            shift_matrix[2][2] <= in_dout;
        end

       
        if (col_count > ROW_WIDTH-1) begin
            buffer3[0] <= 0;  
            buffer3[BUFFER_WIDTH-1] <= 0;  

            buffer1 <= buffer2;
            buffer2 <= buffer3;

            col_count <= 0; 
            row_count_count <= row_count + 1;
        end else begin
            col_count <= col_count + 1;
        end
    end

end


always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state <= s0;
        gs <= 8'h0;
    end else begin
        state <= state_c;
        gs <= gs_c;
    end
end

always_comb begin
    in_rd_en  = 1'b0;
    out_wr_en = 1'b0;
    out_din   = 8'b0;
    state_c   = state;
    gs_c = gs;

    case (state)
        s0: begin
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
                state_c = s1;
            end
        end

        s1: begin
            if (out_full == 1'b0) begin
                out_din = sbl;
                out_wr_en = 1'b1;
                state_c = s0;
            end
        end

        default: begin
            in_rd_en  = 1'b0;
            out_wr_en = 1'b0;
            out_din = 8'b0;
            state_c = s0;
            sbl_c = 8'hX;
        end

    endcase
end




endmodule
