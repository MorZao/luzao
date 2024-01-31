
`timescale 1 ns / 1 ns

module subtract_tb;

localparam string IMG_IN_BASE_NAME  = "base_grayscale.bmp";
localparam string IMG_IN_IMG_NAME  = "img_grayscale.bmp";
localparam string IMG_OUT_NAME = "output.bmp";
localparam string IMG_CMP_NAME = "img_mask.bmp";
localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = '0;
logic start = '0;
logic done  = '0;

logic        in_full_base;
logic        in_full_img;
logic        in_wr_en_base = '0;
logic        in_wr_en_img  = '0;
logic  [23:0] in_din_base   = '0;
logic  [23:0] in_din_img    = '0;
logic        out_rd_en;
logic        out_empty;
logic  [7:0] out_dout;

logic   hold_clock    = '0;
logic   in_write_done_base = '0;
logic   in_write_done_img = '0;
logic   out_read_done = '0;
integer out_errors    = '0;

localparam WIDTH = 768;
localparam HEIGHT = 576;
localparam BMP_HEADER_SIZE = 54;
localparam BYTES_PER_PIXEL = 3;
localparam BMP_DATA_SIZE = WIDTH*HEIGHT*BYTES_PER_PIXEL;

subtract_top #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT)
) subtract_top_inst (
    .clock(clock),
    .reset(reset),
    .in_full_base(in_full_base),
    .in_full_img(in_full_img),
    .in_wr_en_base(in_wr_en_base),
    .in_wr_en_img(in_wr_en_img),
    .in_din_base(in_din_base),
    .in_din_img(in_din_img),
    .out_empty(out_empty),
    .out_rd_en(out_rd_en),
    .out_dout(out_dout)
);

always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end

initial begin : tb_process
    longint unsigned start_time, end_time;

    @(negedge reset);
    @(posedge clock);
    start_time = $time;

    // start
    $display("@ %0t: Beginning simulation...", start_time);
    start = 1'b1;
    @(posedge clock);
    start = 1'b0;

    wait(out_read_done);
    end_time = $time;

    // report metrics
    $display("@ %0t: Simulation completed.", end_time);
    $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
    $display("Total error count: %0d", out_errors);

    // end the simulation
    $finish;
end

initial begin : img_read_process
    int i, r;
    int in_file_base, in_file_img;
    logic [7:0] bmp_header_base [0:BMP_HEADER_SIZE-1];
    logic [7:0] bmp_header_img [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    $display("@ %0t: Loading base file %s...", $time, IMG_IN_BASE_NAME);
    $display("@ %0t: Loading img file %s...", $time, IMG_IN_IMG_NAME);

    in_file_base = $fopen(IMG_IN_BASE_NAME, "rb");
    in_file_img = $fopen(IMG_IN_IMG_NAME, "rb");
    in_wr_en_base = 1'b0;
    in_wr_en_img = 1'b0;

    // Skip BMP headers
    r = $fread(bmp_header_base, in_file_base, 0, BMP_HEADER_SIZE);
    r = $fread(bmp_header_img, in_file_img, 0, BMP_HEADER_SIZE);

    // Read data from image files
    i = 0;
    while (i < BMP_DATA_SIZE) begin
        @(negedge clock);
        in_wr_en_base = 1'b0;
        in_wr_en_img = 1'b0;

        // Read from base file
        if (in_full_base == 1'b0) begin
            r = $fread(in_din_base, in_file_base, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            in_wr_en_base = 1'b1;
        end

        // Read from img file
        if (in_full_img == 1'b0) begin
            r = $fread(in_din_img, in_file_img, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            in_wr_en_img = 1'b1;
        end

        i += BYTES_PER_PIXEL;
    end

    @(negedge clock);
    in_wr_en_base = 1'b0;
    in_wr_en_img = 1'b0;
    $fclose(in_file_base);
    $fclose(in_file_img);
    in_write_done_base = 1'b1;
    in_write_done_img = 1'b1;
end

initial begin : img_write_process
    int i, r;
    int out_file;
    int cmp_file;
    logic [23:0] cmp_dout;
    logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing file %s...", $time, IMG_OUT_NAME);
    
    out_file = $fopen(IMG_OUT_NAME, "wb");
    cmp_file = $fopen(IMG_CMP_NAME, "rb");
    out_rd_en = 1'b0;
    
    // Copy the BMP header
    r = $fread(bmp_header, cmp_file, 0, BMP_HEADER_SIZE);
    for (i = 0; i < BMP_HEADER_SIZE; i++) begin
        $fwrite(out_file, "%c", bmp_header[i]);
    end

    i = 0;
    while (i < BMP_DATA_SIZE) begin
        @(negedge clock);
        out_rd_en = 1'b0;
        if (out_empty == 1'b0) begin
            r = $fread(cmp_dout, cmp_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            $fwrite(out_file, "%c%c%c", out_dout, out_dout, out_dout);

            if (cmp_dout != {3{out_dout}}) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0x%x.\n", $time, IMG_OUT_NAME, i+1, {3{out_dout}}, cmp_dout, i);
            end
            out_rd_en = 1'b1;
            i += BYTES_PER_PIXEL;
        end
    end

    @(negedge clock);
    out_rd_en = 1'b0;
    $fclose(out_file);
    $fclose(cmp_file);
    out_read_done = 1'b1;
end

endmodule
