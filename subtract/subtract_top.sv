module subtract_top #(
    parameter WIDTH = 720,
    parameter HEIGHT = 540
) (
    input  logic        clock,
    input  logic        reset,
    output logic        in_full_base,
    output logic        in_full_img,
    input  logic        in_wr_en,
    input  logic [7:0] in_din_base,
    input  logic [7:0] in_din_img,
    output logic        out_empty,
    input  logic        out_rd_en,
    output logic [7:0]  out_dout
);

logic  [7:0] in_dout_base;
logic  [7:0] in_dout_img;
logic        in_empty_base;
logic        in_empty_img;
logic        in_rd_en_base;
logic        in_rd_en_img;
logic  [7:0] out_din;
logic        out_full;
logic        out_wr_en;


grayscale #(
) subtract_inst (
    .clock(clock),
    .reset(reset),
    .in_dout_base(in_dout_base),
    .in_dout_img(in_dout_img),
    .in_rd_en(in_rd_en_base),
    .in_rd_en(in_rd_en_img),
    .in_empty(in_empty_base),
    .in_empty(in_empty_img),
    .out_din(out_din),
    .out_full(out_full),
    .out_wr_en(out_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_in_base_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .din(in_din_base),
    .full(in_full_base),
    .rd_clk(clock),
    .rd_en(in_rd_en_base),
    .dout(in_dout_base),
    .empty(in_empty_base)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_in_img_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .din(in_din_img),
    .full(in_full_img),
    .rd_clk(clock),
    .rd_en(in_rd_en_img),
    .dout(in_dout_base),
    .empty(in_empty_img)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_out_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en),
    .din(out_din),
    .full(out_full),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .dout(out_dout),
    .empty(out_empty)
);

endmodule
