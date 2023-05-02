module uart_rx
(
	input 				rst_n,           /* 复位信号，0：有效                */
	input   		    clk,             /* 系统时钟                         */  
	input 				Rx,              /* 接收串行数据                     */
	input               sel_check,       /* 校验选择，1：有校验，0：无校验   */
	input               parity_check,    /* 奇偶校验，1：奇校验，0：偶校验   */
	input       [6:0]   SmplCLKP,        /* 采样分频系数，=时钟频率/波特率/3 结果为小数结果向下取整，结果为整数结果-1*/
	output	reg 		dRDY,            /* 输出数据有效                     */
	output	reg	[7:0]   dout             /* 输出并行数据                     */ 
);
// localparam 	SmplCLKP 	= 8'd173;  //60e6/115200/3=173.6
reg	[6:0]	Smpl_cnt;
reg  				SmplFlag;  
reg [1:0]   Rx_R; 
always @(posedge clk or negedge rst_n)	begin
	if(~rst_n)begin
		Smpl_cnt<= 7'd0;	
		SmplFlag<= 1'b0; 
		Rx_R    <=2'b11;
	end
	else	begin			
		Rx_R<={Rx_R[0],Rx};
		if(Smpl_cnt==SmplCLKP)begin
			Smpl_cnt<=7'd0;
			SmplFlag<=1'b1;	
		end
		else begin
		  Smpl_cnt<=Smpl_cnt+7'd1;
		  SmplFlag<=1'b0;
	  end  
	end
end

reg  	[1:0] 	state /* synthesis syn_encoding = "safe" */ ;
reg  	[2:0] 	DatR; 		
reg  	[1:0] 	SmplCnt;
reg  					StartBit,EndBit;
reg  	[8:0] 	RcvData;	
reg  	[3:0] 	RcvCounter; 	
wire 	[1:0] 	acc;
assign 				acc		= {1'b0,DatR[0]}+{1'b0,DatR[1]}+{1'b0,DatR[2]};
always	@(posedge clk or negedge rst_n)	begin
	if(~rst_n)		begin
		dRDY		    <= 1'b0;	
		dout		    <= 8'd0;		
		state		    <= 2'd0;	
		DatR		    <= 3'b111;	
		SmplCnt	    <= 2'd0;			
		EndBit      <= 1'b0;
		StartBit    <= 1'b0;	
		RcvData	    <= 9'd0;		
		RcvCounter	<= 4'd0;	
	end
	else begin		
    case(state)
      2'd0:begin
        RcvCounter <= RcvCounter;
        RcvData	<= RcvData;
        StartBit <= StartBit; 
        dRDY <= 1'b0;
			  dout <= dout;
        if((SmplFlag==1'b1)&&(EndBit==1'b0)&&(StartBit==1'b1))begin
			    SmplCnt	<= SmplCnt+2'd1;
			  end
			  else begin
			    SmplCnt	<= SmplCnt;
			  end
        if((SmplFlag==1'b1)&&(EndBit==1'b1))begin
			    EndBit<=1'b0;
			  end
			  else begin
			    EndBit<=EndBit;
			  end
        if((SmplFlag==1'b1)&&(EndBit==1'b0))begin
          DatR <= {DatR[1:0],Rx_R[1]};
        end
        else begin
          DatR <= DatR;
        end        
        if((SmplFlag==1'b1)&&(EndBit==1'b0))begin
			    if(StartBit==1'b1)begin
					  state <= 2'd2;
				  end
				  else begin
				    state	<= 2'd1;
				  end
				end
				else begin
				  state	<= 2'd0;
				end
		  end
		  2'd2:begin
		    if(SmplCnt==2'b11)begin
			    SmplCnt <= 2'd0;
			    RcvCounter <= RcvCounter+4'd1;
			    state <= 2'd3;
			    if(acc>2'd1)begin
			      RcvData	<= {1'b1,RcvData[8:1]};
			    end
			    else begin
			      RcvData	<= {1'b0,RcvData[8:1]};
			    end
			  end
			  else begin
			    SmplCnt <= SmplCnt;
			    RcvCounter <= RcvCounter;
			    state	<= 2'd0;
			    RcvData	<= RcvData;
			  end
		    StartBit <= 1'b1; 
		    EndBit <= 1'b0;
		    dRDY <= 1'b0;
			  dout <= dout;
		    DatR <= DatR;
		  end
		  2'd1:begin
        SmplCnt	<= DatR[1:0];	
        RcvCounter <= 4'd0;
        RcvData	<= RcvData;
        EndBit <= 1'b0;
		    dRDY <= 1'b0;
			  dout <= dout;
		    DatR <= DatR;
		    state<= 2'd0;
		    if(DatR<3'd2)begin
			    StartBit <= 1'b1; 
			  end
			  else begin
			    StartBit <= 1'b0;
			  end
		  end
		  2'd3:begin
		    if(sel_check==1'b1)begin
				  if(RcvCounter==4'h9)	begin
			      RcvCounter	<= 4'd0;
			      StartBit <= 1'b0;
			      EndBit <= 1'b1;
			      DatR <= 3'b111;
		      end
		      else begin
            RcvCounter <= RcvCounter;
            StartBit <= 1'b1;
            EndBit <= 1'b0;
            DatR <= DatR;
		      end
		      if(RcvCounter==4'h9)begin
				    if(parity_check==1'b1)begin //奇校验//
		           if(RcvData[8]==~(^RcvData[7:0]))begin  
                 dRDY <= 1'b1;
			           dout <= RcvData[7:0];
	             end
	             else begin
			             dRDY <= 1'b0;
			             dout <= dout;
			         end
				  	end
				  	else begin //偶校验//
		           if(RcvData[8]==(^RcvData[7:0]))begin  
                 dRDY <= 1'b1;
			           dout <= RcvData[7:0];
	             end
	             else begin
			             dRDY <= 1'b0;
			             dout <= dout;
			         end
				  	end
			    end
	        else begin
	          dRDY <= 1'b0;
			      dout <= dout;
	        end
				end
				else begin  //无奇偶校验//
          if(RcvCounter==4'h8)	begin
			      RcvCounter	<= 4'd0;
			      StartBit <= 1'b0;
			      EndBit <= 1'b1;
			      DatR <= 3'b111;
		      end
		      else begin
            RcvCounter <= RcvCounter;
            StartBit <= 1'b1;
            EndBit <= 1'b0;
            DatR <= DatR;
		      end
		      if(RcvCounter==4'h8)begin
				    dRDY <= 1'b1;
			      dout <= RcvData[8:1];
			    end
	        else begin
	          dRDY <= 1'b0;
			      dout <= dout;
	        end
				end
	      SmplCnt <= 2'd0;
		    RcvData	<= RcvData;
		    state<= 2'd0;
		  end
		  default:begin
		    SmplCnt <= 2'd0;
		    RcvCounter	<= 4'd0;
		    RcvData <= 9'd0;
		    StartBit <= 1'b0;
		    EndBit <= 1'b0;
		    dRDY <= 1'b0;
			  dout <= dout;
		    DatR <= 3'b111;
		    state<= 2'd0;
		  end
	  endcase
	end
end
endmodule 