module bram 
#(parameter BRAM_ADDR_WIDTH = 6,
  parameter BRAM_DATA_WIDTH = 32) 
(
  input  logic clock,
  input  logic [BRAM_ADDR_WIDTH-1:0] rd_addr,
  input  logic [BRAM_ADDR_WIDTH-1:0] wr_addr,
  input  logic wr_en,
  input  logic [BRAM_DATA_WIDTH-1:0] din, 
  output logic [BRAM_DATA_WIDTH-1:0] dout
);


  logic [2**BRAM_ADDR_WIDTH-1:0][BRAM_DATA_WIDTH-1:0] mem;

  
  always_comb begin
    dout = mem[rd_addr]; 
  end

  always_ff @(posedge clock) begin
    if (wr_en) begin
      mem[wr_addr] <= din; 
    end
  end

endmodule


module bram 
#(parameter BRAM_ADDR_WIDTH = 6,
  parameter BRAM_DATA_WIDTH = 32) 
(
  input  logic clock,
  input  logic [BRAM_ADDR_WIDTH-3:0] rd_addr,
  input  logic [BRAM_ADDR_WIDTH-3:0] wr_addr,
  input  logic wr_en,
  input  logic [BRAM_DATA_WIDTH-3:0] din, 
  output logic [BRAM_DATA_WIDTH-3:0] dout
);

  // 内存定义
  logic [2**BRAM_ADDR_WIDTH-1:0][BRAM_DATA_WIDTH-1:0] mem;

  // 组合逻辑读操作
  always_comb begin
    dout = mem[rd_addr]; // 使用rd_addr直接读取，而不是read_addr
  end
  
  // 时序逻辑写操作
  always_ff @(posedge clock) begin
    if (wr_en) begin
      mem[wr_addr] <= din; // 时序写入
    end
  end

endmodule
