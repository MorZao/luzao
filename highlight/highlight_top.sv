module highlight_top #(
    parameter WIDTH = 768,
    parameter HEIGHT = 576
) (
    input  logic        clock,
    input  logic        reset,
    output logic        in_full_ped,
    output logic        in_full_mask,
    input  logic        in_wr_en_ped,
    input  logic        in_wr_en_mask,
    input  logic [23:0] in_din_ped,
    input  logic [23:0] in_din_mask,
    output logic        out_empty,
    input  logic        out_rd_en,
    output logic [23:0]  out_dout
);

logic  [23:0] in_dout_ped;
logic  [23:0] in_dout_mask;
logic         in_empty_ped;
logic         in_empty_mask;
logic         in_rd_en_ped;
logic         in_rd_en_mask;
logic  [23:0] out_din;
logic         out_full;
logic         out_wr_en;


subtract #(
) subtract_inst (
    .clock(clock),
    .reset(reset),
    .in_dout_ped(in_dout_ped),
    .in_dout_mask(in_dout_mask),
    .in_rd_en_ped(in_rd_en_ped),
    .in_rd_en_mask(in_rd_en_mask),
    .in_empty_ped(in_empty_ped),
    .in_empty_mask(in_empty_mask),
    .out_din(out_din),
    .out_full(out_full),
    .out_wr_en(out_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_in_ped_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en_ped),
    .din(in_din_ped),
    .full(in_full_ped),
    .rd_clk(clock),
    .rd_en(in_rd_en_ped),
    .dout(in_dout_ped),
    .empty(in_empty_ped)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_in_mask_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en_mask),
    .din(in_din_mask),
    .full(in_full_mask),
    .rd_clk(clock),
    .rd_en(in_rd_en_mask),
    .dout(in_dout_mask),
    .empty(in_empty_mask)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
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
