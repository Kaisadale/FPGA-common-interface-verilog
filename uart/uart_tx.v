/* *********************************************************************************** */
/* 模块名:UART发送模块                                                                 */
/* 版本号:V1.0.0                                                                       */
/* 发布时间:2022.11.03                                                                 */
/* 文件名:uart_tx                                                                      */                  
/* 作者:徐家栋                                                                         */
/* 版权:中国科学院上海光学精密机械研究所航天激光工程部航天激光软件研发中心             */                   
/* 描述:该模块用于对输入的并行数据按照UART协议要求进行串行发送，模块中可以配置是否有校 */
/*      验位、校验方式的选择。                                                         */
/* *********************************************************************************** */

module uart_tx
(
	input  					clk,              /* 系统时钟                         */
	input  					rst_n,            /* 复位信号，0：有效                */
	input  					i_start,          /* 启动发送标识                     */
	input  			[7:0]	i_dat,            /* 待发送的并行数据                 */
	input                   sel_check,        /* 校验选择，1：有校验，0：无校验   */
	input                   parity_check,     /* 奇偶校验，1：奇校验，0：偶校验   */
	input       [7:0]       SmplCLKP,         /* 分频系数，=时钟频率/波特率       */
	output	reg 			o_rdy,            /* 工作状态，1：空闲，0：忙碌       */
	output	reg 			o_ct              /* 串行数据                         */
);
	// localparam 		SmplCLKP	= 10'd520;//60e6/115200=520.8
	reg   [7:0]   Smplcnt;
	reg   [3:0]   tx_cnt;
	reg   [10:0]  tx_cache;
    reg 	      o_txen;
	reg   [3:0]   tx_lenth;
	always @( posedge clk or negedge rst_n)	begin
		if(~rst_n) begin 
			o_rdy     <= 1'b1; 	
			o_ct      <= 1'b1;	
			o_txen	  <= 1'b0;
			tx_cnt	  <= 4'd0;	
			tx_cache	<= 11'd0;	
			Smplcnt	  <= 8'd0;
			tx_lenth  <= 4'd0;	
		end 	  
		else 	begin
			if(i_start==1'b1) begin 
			  if(sel_check ==1'b1)begin
			    tx_lenth  <= 4'hB;	
					if(parity_check ==1'b1) //奇校验//
				     tx_cache	<= {2'b11,(~(^i_dat[7:0])),i_dat};
				  else //偶校验//
				     tx_cache	<= {2'b11,(^i_dat[7:0]),i_dat};
				end
				else begin
				  tx_lenth  <= 4'h9;
				  tx_cache	<= {2'b11,i_dat};
				end
				tx_cnt		<= 4'd0; 
				Smplcnt		<= 8'd0;
				o_txen		<= 1'b1;
				o_ct			<= 1'b0;                          //start_bit	
				o_rdy			<= 1'b0; 			 
			end 
			else 	begin
				if(o_txen==1'b1) begin  
					if(Smplcnt>=SmplCLKP)begin
					  Smplcnt	<= 8'd0;
					end
					else begin
					  Smplcnt	<= Smplcnt+8'd1;
					end
					if(Smplcnt>=SmplCLKP)begin 
						if(tx_cnt>=tx_lenth) begin 
							o_rdy			<= 1'b1;
							o_txen		<= 1'b0; 
							tx_cnt		<= 4'd0;
							tx_cache	<= 11'h7ff;
							o_ct			<= 1'b1;
						end    
						else begin 
							o_txen    <= 1'b1;
							o_rdy			<= 1'b0; 
							o_ct			<= tx_cache[0];
							tx_cache	<= {1'b1,tx_cache[10:1]}; 
							tx_cnt		<= tx_cnt+4'd1; 		  
						end
					end 
					else begin
					  o_rdy 	 <= 1'b0;
					  o_txen   <= 1'b1; 
					  tx_cnt	 <= tx_cnt;
					  tx_cache <= tx_cache;
					  o_ct     <= o_ct;					  
					end                
				end
				else begin
					o_rdy	  <= 1'b1; 
					tx_cnt	<= 4'd0; 
					o_ct	  <= 1'b1; 
					tx_cache<= 11'd0;
					o_txen	<= 1'b0;
					Smplcnt	<= 8'd0;    
				end  
			end
		end
	end     
endmodule 