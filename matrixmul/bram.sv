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
