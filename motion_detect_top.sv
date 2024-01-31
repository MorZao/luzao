
module motion_detect_top #(
    parameter WIDTH = 768,
    parameter HEIGHT = 576
) (
    input  logic        clock,
    input  logic        reset,
    output logic        in_full_base,
    input  logic        in_wr_en_base,
    input  logic        in_wr_en_ped,
    input  logic [23:0] in_din_base,
    input  logic [23:0] in_din_ped,
    output logic        out_empty,
    input  logic        out_rd_en,
    output logic [7:0]  out_dout



);

logic        in_full_ped
logic [23:0] in_dout_base;
logic [23:0] in_dout_ped;
logic        in_empty_base;
logic        in_empty_ped;
logic        in_rd_en_base;
logic        in_rd_en_ped;
logic  [7:0] out_din_base;
logic  [7:0] out_din_ped;
logic        out_full_base;
logic        out_full_ped;
logic        out_wr_en_base;
logic        out_wr_en_ped;


grayscale #(
) grayscale_base_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout_base),
    .in_rd_en(in_rd_en_base),
    .in_empty(in_empty_base),
    .out_din(out_din_base),
    .out_full(out_full_base),
    .out_wr_en(out_wr_en_base)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_in_base_inst (  
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en_base),
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
) fifo_out_base_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en_base),
    .din(out_din_base),
    .full(out_full_base),
    .rd_clk(clock),
    .rd_en(out_rd_en),//
    .dout(out_dout),//
    .empty(out_empty)//
);

grayscale #(
) grayscale_ped_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout_ped),
    .in_rd_en(in_rd_en_ped),
    .in_empty(in_empty_ped),
    .out_din(out_din_ped),
    .out_full(out_full_ped),
    .out_wr_en(out_wr_en_ped)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_in_ped_inst (   //hai yao zhi jie lian highlight
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en_ped),
    .din(in_din_ped),
    .full(in_full_ped),//jie highlight
    .rd_clk(clock),
    .rd_en(in_rd_en_ped),
    .dout(in_dout_ped),
    .empty(in_empty_ped)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_out_ped_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en_ped),
    .din(out_din_ped),
    .full(out_full_ped),
    .rd_clk(clock),
    .rd_en(out_rd_en),//
    .dout(out_dout),//
    .empty(out_empty)//
);

endmodule
