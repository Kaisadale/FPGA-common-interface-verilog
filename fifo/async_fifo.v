module async_fifo 
#(
    data_width = 8                           ,
    data_depth = 256                         ,
    addr_width = 8
)
(
    input                         rst_n      ,
    input                         wr_clk     ,
    input      [data_width-1:0]   wr_data    ,
    input                         wr_en      ,
    input                         rd_clk     ,
    input                         rd_en      ,
    output reg [data_width-1:0]   rd_data    ,
    output                        fifo_empty ,
    output                        fifo_full
);

// address
wire [addr_width-1:0]  wr_addr;
wire [addr_width-1:0]  rd_addr;
reg  [addr_width  :0]  wr_addr_ptr;
reg  [addr_width  :0]  rd_addr_ptr;

// gray code
wire [addr_width  :0]  wr_addr_gray;
reg  [addr_width  :0]  wr_addr_gray_d0;
reg  [addr_width  :0]  wr_addr_gray_d1;
wire [addr_width  :0]  rd_addr_gray;
reg  [addr_width  :0]  rd_addr_gray_d0;
reg  [addr_width  :0]  rd_addr_gray_d1;

// ram
reg [data_width-1 :0]  ram [data_depth-1:0];

// write fifo
integer i;
always @(posedge wr_clk or negedge rst_n) 
    begin
      if(~rst_n)                  for(i=0; i<data_depth; i=i+1) ram[i] <= 'd0;
      else if(wr_en & ~fifo_full) ram[wr_addr] <= wr_data; 
      else                        ram[wr_addr] <= ram[wr_addr];
    end

always @(posedge wr_clk or negedge rst_n)
    begin
      if(~rst_n)                  wr_addr_ptr <= 'd0;
      else if(wr_en & ~fifo_full) wr_addr_ptr <= wr_addr_ptr + 'd1;
      else                        wr_addr_ptr <= wr_addr_ptr;
    end

// read fifo
always @(posedge rd_clk or negedge rst_n)
    begin
      if(~rst_n)                   rd_data <= 'd0; 
      else if(rd_en & ~fifo_empty) rd_data <= ram[rd_addr]; 
      else                         rd_data <= 'd0;
    end

always @(posedge rd_clk or negedge rst_n)
    begin
      if(~rst_n)                   rd_addr_ptr <= 'd0;
      else if(rd_en & ~fifo_empty) rd_addr_ptr <= rd_addr_ptr + 'd1;
      else                         rd_addr_ptr <= rd_addr_ptr;
    end

assign rd_addr = rd_addr_ptr[addr_width-1:0];
assign wr_addr = wr_addr_ptr[addr_width-1:0];

// gray code
assign wr_addr_gray = (wr_addr_ptr >> 1) ^ wr_addr_ptr;
assign rd_addr_gray = (rd_addr_ptr >> 1) ^ rd_addr_ptr;

always @(posedge rd_clk or negedge rst_n)
    begin
      if(~rst_n) {wr_addr_gray_d1, wr_addr_gray_d0} <= 'd0;
      else       {wr_addr_gray_d1, wr_addr_gray_d0} <= {wr_addr_gray_d0, wr_addr_gray};
    end
    
always @(posedge wr_clk or negedge rst_n)
    begin
      if(~rst_n) {rd_addr_gray_d1, rd_addr_gray_d0} <= 'd0;
      else       {rd_addr_gray_d1, rd_addr_gray_d0} <= {rd_addr_gray_d0, rd_addr_gray};
    end  
    
// empty, full
assign fifo_empty = rd_addr_gray == wr_addr_gray_d1;
assign fifo_full  = wr_addr_gray == {~rd_addr_gray_d1[addr_width:addr_width-1], rd_addr_gray_d1[addr_width-2:0]};

endmodule


