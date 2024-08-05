// FPGA上连接master i2c和slave i2c，将i2c双向io连接作透传。

module i2c_through
#( 
	parameter CLK_FREQ   = 28'd200_000_000, 
	parameter I2C_FREQ   = 20'd100_000     
)
(

	input clk_i,
	input rst_n_i,
	inout master_scl_io,
	inout master_sda_io,
	inout slave_scl_io,
	inout slave_sda_io

);

localparam IDLE 				= 4'b0001;
localparam SLAVE_DEVICE_ADDR_RD = 4'b0010;
localparam I2C_WRITE_OPERATION  = 4'b0100;
localparam I2C_READ_OPERATION   = 4'b1000;

reg  [3:0] state;

reg  i2c_m2s_scl_dir_en;
reg  i2c_m2s_sda_dir_en;
reg  master_sda_d0, master_sda_d1;
wire master_sda_pdg;
wire master_sda_ndg;
reg  master_scl_d0, master_scl_d1;
wire master_scl_pdg;
wire master_scl_ndg;
reg  slave_scl_d0, slave_scl_d1;
wire slave_scl_pdg;
wire slave_scl_ndg;
wire i2c_start;
wire i2c_stop;
reg  i2c_rh_wl; // 1:read opertion, 0:write operation
wire i2c_scl_pdg;
wire i2c_scl_ndg;
reg  master_ack;

reg  [11:0] clk_cnt;
wire [11:0] clk_divide;
reg         dri_clk_tmp;
wire        dri_clk;

reg [3:0] scl_pdg_cnt;
reg [3:0] scl_ndg_cnt;
reg [9:0] delay_cnt_0;
reg [9:0] delay_cnt_1;

assign clk_divide = (CLK_FREQ/I2C_FREQ) >> 3'd4;

// master sda rising/falling edge
assign master_sda_pdg = i2c_m2s_sda_dir_en ? (~master_sda_d1 & master_sda_d0) : 0;
assign master_sda_ndg = i2c_m2s_sda_dir_en ? (master_sda_d1 & ~master_sda_d0) : 0;

// master scl rising/falling edge
assign master_scl_pdg = i2c_m2s_scl_dir_en ? (~master_scl_d1 & master_scl_d0) : 0;
assign master_scl_ndg = i2c_m2s_scl_dir_en ? (master_scl_d1 & ~master_scl_d0) : 0;

// slave scl rising/falling edge
assign slave_scl_pdg = ~i2c_m2s_scl_dir_en ? (~slave_scl_d1 & slave_scl_d0) : 0;
assign slave_scl_ndg = ~i2c_m2s_scl_dir_en ? (slave_scl_d1 & ~slave_scl_d0) : 0;

// i2c scl rising/falling edge
assign i2c_scl_pdg = master_scl_pdg | slave_scl_pdg;
assign i2c_scl_ndg = master_scl_ndg | slave_scl_ndg;

// i2c transfer start/stop signal
assign i2c_start = i2c_m2s_scl_dir_en ? (master_sda_ndg & master_scl_io) : 0;
assign i2c_stop  = i2c_m2s_scl_dir_en ? (master_sda_pdg & master_scl_io) : 0; 

always @ (posedge clk_i or negedge rst_n_i)begin
	
	if(!rst_n_i)				 {master_sda_d1, master_sda_d0} <= 2'b00;
	else if(i2c_m2s_sda_dir_en)  {master_sda_d1, master_sda_d0} <= {master_sda_d0, master_sda_io};

end

always @ (posedge clk_i or negedge rst_n_i)begin
	
	if(!rst_n_i)				 {master_scl_d1, master_scl_d0} <= 2'b00;
	else if(i2c_m2s_scl_dir_en)  {master_scl_d1, master_scl_d0} <= {master_scl_d0, master_scl_io};

end

always @ (posedge clk_i or negedge rst_n_i)begin
	
	if(!rst_n_i)				  {slave_scl_d1, slave_scl_d0} <= 2'b00;
	else if(!i2c_m2s_scl_dir_en)  {slave_scl_d1, slave_scl_d0} <= {slave_scl_d0, slave_scl_io};

end


always @ (posedge clk_i or negedge rst_n_i)begin

	if(!rst_n_i)begin  
	
		state 			   <= IDLE;
		i2c_m2s_scl_dir_en <= 1'b1;
		i2c_m2s_sda_dir_en <= 1'b1;
		scl_ndg_cnt    	   <= 4'd0;
		scl_pdg_cnt        <= 4'd0;
		delay_cnt_0        <= 10'd0;
		delay_cnt_1        <= 10'd0;
		master_ack         <= 1'b0;
		i2c_rh_wl          <= 1'b0;
		
	end
	else begin
		
		case(state)
			
			IDLE:begin
					
				i2c_m2s_scl_dir_en <= 1'b1;
				i2c_m2s_sda_dir_en <= 1'b1;
				scl_ndg_cnt        <= 4'd0;
				scl_pdg_cnt        <= 4'd0;	
				master_ack         <= 1'b0;
				i2c_rh_wl          <= 1'b0;				
				
				if(i2c_start)	state <= SLAVE_DEVICE_ADDR_RD;
				else		   	state <= IDLE;
				
			end
			
			SLAVE_DEVICE_ADDR_RD:begin
			
				// scl rising/falling count
				if(i2c_scl_ndg)  scl_ndg_cnt <= scl_ndg_cnt + 4'd1;
				if(i2c_scl_pdg)	 scl_pdg_cnt <= scl_pdg_cnt + 4'd1;
				
				// 8th bit: READ/WRITE bit
				if((scl_pdg_cnt == 4'd7) && i2c_scl_pdg)	 i2c_rh_wl <= master_sda_io; 
				
				// 9th bit: Slave control i2c bus ACK
				if(scl_ndg_cnt == 4'd9) begin 
					
					i2c_m2s_scl_dir_en <= 1'b1; 
					i2c_m2s_sda_dir_en <= 1'b0; 
					
				end
				
//				if(delay_cnt_0 == 10'd500)    delay_cnt_0 <= 10'd0;
//				else if(scl_ndg_cnt == 4'd9)  delay_cnt_0 <= delay_cnt_0 + 10'd1;
				
//				if(delay_cnt_1 == 10'd1000)   delay_cnt_1 <= 10'd0;
//				else if(scl_pdg_cnt == 4'd9)  delay_cnt_1 <= delay_cnt_1 + 10'd1;
				
				if((scl_ndg_cnt == 4'd10) && ~i2c_rh_wl) begin // WRITE
					
					state 			   <= I2C_WRITE_OPERATION; 
					i2c_m2s_scl_dir_en <= 1'b1; 
					i2c_m2s_sda_dir_en <= 1'b1;
					scl_pdg_cnt 	   <= 4'd0; 
					scl_ndg_cnt 	   <= 4'd0; 
				
				end
				else if((scl_ndg_cnt == 4'd10) && i2c_rh_wl) begin // READ
				
					state 			   <= I2C_READ_OPERATION; 
					i2c_m2s_scl_dir_en <= 1'b1; 
					i2c_m2s_sda_dir_en <= 1'b0;					
					scl_pdg_cnt        <= 4'd0; 
					scl_ndg_cnt        <= 4'd0; 
					
				end
			
			end
			
			I2C_WRITE_OPERATION:begin
			
				if(i2c_stop) 		state <= IDLE;
				else if(i2c_start)  state <= SLAVE_DEVICE_ADDR_RD;
			
				// scl rising/falling count
				if(i2c_scl_ndg)  scl_ndg_cnt <= scl_ndg_cnt + 4'd1;
				if(i2c_scl_pdg)	 scl_pdg_cnt <= scl_pdg_cnt + 4'd1;	
				
				// 9th bit: Slave control i2c bus ACK
				if(scl_ndg_cnt == 4'd8) begin 
					
					i2c_m2s_scl_dir_en <= 1'b1; 
					i2c_m2s_sda_dir_en <= 1'b0; 
					
				end
				
				// Master control i2c bus
				if((scl_ndg_cnt == 4'd9) | i2c_start) begin 
				
					i2c_m2s_scl_dir_en <= 1'b1; 
					i2c_m2s_sda_dir_en <= 1'b1; 
					scl_ndg_cnt        <= 4'd0; 
					scl_pdg_cnt        <= 4'd0; 
					
				end 
			
			end
			
			I2C_READ_OPERATION:begin
			
				if(i2c_stop)  state <= IDLE; 
				
				// scl rising/falling count
				if(i2c_scl_ndg)  scl_ndg_cnt <= scl_ndg_cnt + 4'd1;
				if(i2c_scl_pdg)	 scl_pdg_cnt <= scl_pdg_cnt + 4'd1;		
				
				// 9th bit: Master control i2c bus ACK
				if(scl_ndg_cnt == 4'd8) begin 
				
					i2c_m2s_scl_dir_en <= 1'b1; 
					i2c_m2s_sda_dir_en <= 1'b1; 
				
				end			

				// master ack ff
				if((scl_pdg_cnt == 4'd8) && i2c_scl_pdg)	master_ack <= master_sda_io;
					
				if((scl_ndg_cnt == 4'd9) && master_ack) begin

					i2c_m2s_scl_dir_en <= 1'b1; 
					i2c_m2s_sda_dir_en <= 1'b1; 
					scl_ndg_cnt        <= 4'd0; 
					scl_pdg_cnt        <= 4'd0; 				
				
				end
				else if((scl_ndg_cnt == 4'd9) && ~master_ack)begin

					i2c_m2s_scl_dir_en <= 1'b1; 
					i2c_m2s_sda_dir_en <= 1'b0; 
					scl_ndg_cnt        <= 4'd0; 
					scl_pdg_cnt        <= 4'd0; 				
				
				end
			
			end
			
			default:;
			
		endcase
	
	end

end

i2c_ila i2c_ila 
(
	.clk(clk_i), // input wire clk
	.probe0(master_scl_io), // input wire [0:0]  probe0  
	.probe1(master_sda_io), // input wire [0:0]  probe1 
	.probe2(i2c_m2s_scl_dir_en), // input wire [0:0]  probe2 
	.probe3(i2c_m2s_sda_dir_en), // input wire [0:0]  probe3 
	.probe4(state), // input wire [3:0]  probe4 
	.probe5(scl_ndg_cnt), // input wire [3:0]  probe5 
	.probe6(scl_pdg_cnt), // input wire [3:0]  probe6 
	.probe7(i2c_start), // input wire [0:0]  probe7 
	.probe8(i2c_stop), // input wire [0:0]  probe8 
	.probe9(i2c_scl_pdg), // input wire [0:0]  probe9 
	.probe10(i2c_scl_ndg), // input wire [0:0]  probe10
	.probe11(master_sda_pdg), // input wire [0:0]  probe11
	.probe12(master_sda_ndg), // input wire [0:0]  probe12
	.probe13(master_sda_d1), // input wire [0:0]  probe13
	.probe14(master_sda_d0), // input wire [0:0]  probe14
	.probe15(slave_scl_io), // input wire [0:0]  probe15
	.probe16(slave_sda_io) // input wire [0:0]  probe16
	
);



assign slave_scl_io  = i2c_m2s_scl_dir_en ? master_scl_io : 1'bz;
assign slave_sda_io  = i2c_m2s_sda_dir_en ? master_sda_io : 1'bz;
assign master_scl_io = ~i2c_m2s_scl_dir_en ? slave_scl_io : 1'bz;
assign master_sda_io = ~i2c_m2s_sda_dir_en ? slave_sda_io : 1'bz;

endmodule