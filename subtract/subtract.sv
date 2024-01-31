module subtract #(
    parameter THRESHOLD = 50
) (
    input  logic        clock,
    input  logic        reset,
    output logic        in_rd_en_base,
    output logic        in_rd_en_img,
    input  logic        in_empty_base,
    input  logic        in_empty_img,
    input  logic [23:0] in_dout_base,
    input  logic [23:0] in_dout_img,
    output logic        out_wr_en,
    input  logic        out_full,
    output logic [7:0]  out_din
);

typedef enum logic [0:0] {s0, s1} state_types;
state_types state, state_c;

logic [7:0] sub, sub_c;
logic [8:0] diff;
logic [8:0] diff_abs;

always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state <= s0;
        sub <= 8'h0;
    end else begin
        state <= state_c;
        sub <= sub_c;
    end
end

always_comb begin
    //in_rd_en_base  = 1'b0;
    //in_rd_en_img  = 1'b0;
    out_wr_en = 1'b0;
    out_din   = 8'b0;
    state_c   = state;
    sub_c = sub;

    case (state)
        s0: begin
            if (in_empty_base == 1'b0 && in_empty_img == 1'b0) begin //&& in_empty_img
                diff = {1'b0, in_dout_img[7:0]} - {1'b0, in_dout_base[7:0]};
                case (diff[8]) 
                    1'b0:diff_abs = diff;
                    1'b1:diff_abs = ~diff + 1'b1;
                endcase
                sub_c = diff_abs > THRESHOLD ? 8'hFF : 8'b00;
                in_rd_en_base = 1'b1;
                in_rd_en_img = 1'b1;
                state_c = s1;
            end
        end

        s1: begin
            if (out_full == 1'b0) begin
                out_din = sub;
                out_wr_en = 1'b1;
                state_c = s0;
            end
        end

        default: begin
            in_rd_en_base  = 1'b0;
            in_rd_en_img  = 1'b0;
            out_wr_en = 1'b0;
            out_din = 8'b0;
            state_c = s0;
            sub_c = 8'hX;
        end

    endcase
end

endmodule
