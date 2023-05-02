module spi_interface
   #(
    parameter                            clk_div_set_for_spi = 8,      /* SCLK分频系数               */
    parameter                            parallel_data_length = 32     /* 并行数据长度               */
	)
    (  
	input  			                     clk,                          /* 系统时钟                   */
	input  			                     rstn,                         /* 复位信号，0：有效          */
	input          						 trig_in,                      /* 启动SPI通信标识            */
    input [parallel_data_length-1 : 0]   parallel_data_in,             /* 待发送并行数据             */
    input          						 spi_sdata_in,                 /* MISO                       */
	output                               trig_rdy,                     /* 工作状态，0：忙碌，1：空闲 */
	output                               spi_trams_done,               /* 发送完成标识               */
	output[parallel_data_length - 1 :0]  spi_rd_data_out,              /* 串并转换数据               */
	output                               spi_rd_data_vaild,            /* 串并转换数据有效标识       */
	output         						 spi_cs_n_out,                 /* CS，0：有效                */
	output          				     spi_sclk_out,                 /* SCLK                       */
	output          					 spi_sdata_out                 /* MOSI                       */
	
    );
	
	reg  [7:0] 							 bit_cnt;
	reg  [15:0] 						 div_cnt;
	reg  [parallel_data_length - 1 :0]   reg_parallel_data;
	reg      							 spi_cs_n;
	reg     							 spi_clk;
	reg   								 data_out;
	
	/* clk_div_cnt */
	always @ (posedge clk)begin
		if(spi_cs_n_out == 0) begin
			if(div_cnt == clk_div_set_for_spi/2 - 1 )begin
				div_cnt <= 0;
			end
			else begin
				div_cnt <= div_cnt + 1'b1;
			end
		end
		else begin
			div_cnt <= 0;
		end
	end
	
	/* data_bit_cnt */
	always @ (posedge clk)begin
		if(spi_cs_n_out == 0 ) begin	
			if(bit_cnt < parallel_data_length && spi_clk && div_cnt == clk_div_set_for_spi/2 - 1)begin
				bit_cnt <= bit_cnt + 1'b1;
			end
			else begin
				bit_cnt <= bit_cnt;
			end
		end
		else begin
			bit_cnt <= 0;
		end
	end
	
	
	/* reg_parallel_data_in */
	always @ (posedge clk)begin
		if(!rstn) reg_parallel_data <= 'd0;
		else if(trig_in) reg_parallel_data <= parallel_data_in;
	end	
	
	/* spi_cs_n_out */
	always @ (posedge clk)begin
		if(!rstn) spi_cs_n <= 1'b1;
		else if(trig_in) spi_cs_n <= 1'b0;
		else if(bit_cnt == parallel_data_length  &&  div_cnt == clk_div_set_for_spi/2 - 1) spi_cs_n <= 1'b1;
	end
	assign  spi_cs_n_out = spi_cs_n;
	
	/* spi_sclk_out */
	always @ (posedge clk)begin
		if( spi_cs_n==0 )begin 
			if(div_cnt == clk_div_set_for_spi/2 - 1) spi_clk  <= ~spi_clk;
			else spi_clk <= spi_clk;
		end
		else begin
			spi_clk<= 1'b0;
		end
	end
	assign  spi_sclk_out  =  (spi_cs_n==0)?spi_clk : 1'b0;
	
	/* spi_sdata_out */ 
	always @ (posedge clk)begin
		if(spi_cs_n_out == 0 && bit_cnt < parallel_data_length) begin
			data_out <= reg_parallel_data[parallel_data_length - bit_cnt - 1];
		end
		else begin
			data_out <= 'd0;
		end
	end
	assign spi_sdata_out = data_out;
	
/*/////////////////////////////////////////////////////////////SPI_RD//////*/
	reg [parallel_data_length -1 :0]      spi_rd_data;
	always @ (posedge clk)begin
		if(spi_cs_n_out)begin
			spi_rd_data <= 'd0;
		end
		else if(spi_cs_n_out == 0 && div_cnt == 'd1 && div_cnt < clk_div_set_for_spi/2)begin
			spi_rd_data[parallel_data_length - bit_cnt - 1] <= spi_sdata_in;
		end
		else begin
			spi_rd_data <= spi_rd_data;
		end
	end
	assign  spi_rd_data_out  =  spi_rd_data;
	
	reg                                  spi_rd_vaild;
	
	always @ (posedge clk)begin
		if(spi_cs_n_out) spi_rd_vaild<= 1'b0;
		else if(bit_cnt == parallel_data_length)spi_rd_vaild<= 1'b1;
		else spi_rd_vaild <= 1'b0;
	end
	
	assign  spi_rd_data_vaild = spi_rd_vaild;
	//
	assign  trig_rdy = spi_cs_n;
	assign  spi_trams_done = (bit_cnt == parallel_data_length  &&  div_cnt == clk_div_set_for_spi/2 - 1);
endmodule

