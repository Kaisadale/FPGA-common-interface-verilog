/* *********************************************************************************** */
/* ģ����:UART����ģ��                                                                 */
/* �汾��:V1.0.0                                                                       */
/* ����ʱ��:2022.11.03                                                                 */
/* �ļ���:uart_tx                                                                      */                  
/* ����:��Ҷ�                                                                         */
/* ��Ȩ:�й���ѧԺ�Ϻ���ѧ���ܻ�е�о������켤�⹤�̲����켤������з�����             */                   
/* ����:��ģ�����ڶ�����Ĳ������ݰ���UARTЭ��Ҫ����д��з��ͣ�ģ���п��������Ƿ���У */
/*      ��λ��У�鷽ʽ��ѡ��                                                         */
/* *********************************************************************************** */

module uart_tx
(
	input  					clk,              /* ϵͳʱ��                         */
	input  					rst_n,            /* ��λ�źţ�0����Ч                */
	input  					i_start,          /* �������ͱ�ʶ                     */
	input  			[7:0]	i_dat,            /* �����͵Ĳ�������                 */
	input                   sel_check,        /* У��ѡ��1����У�飬0����У��   */
	input                   parity_check,     /* ��żУ�飬1����У�飬0��żУ��   */
	input       [7:0]       SmplCLKP,         /* ��Ƶϵ����=ʱ��Ƶ��/������       */
	output	reg 			o_rdy,            /* ����״̬��1�����У�0��æµ       */
	output	reg 			o_ct              /* ��������                         */
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
					if(parity_check ==1'b1) //��У��//
				     tx_cache	<= {2'b11,(~(^i_dat[7:0])),i_dat};
				  else //żУ��//
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