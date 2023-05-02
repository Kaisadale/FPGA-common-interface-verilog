`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:12:48 01/17/2018 
// Design Name: 
// Module Name:    sja_config_module 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sja_config_module#(
		parameter	CONFIG_BTR0 =  8'h00,
		parameter	CONFIG_BTR1 =  8'h1C,
		parameter	CONFIG_ACR0 =  8'h00,
		parameter	CONFIG_ACR1 =  8'h00,
		parameter	CONFIG_ACR2 =  8'h00,
		parameter	CONFIG_ACR3 =  8'h00,
		parameter	CONFIG_AMR0 =  8'hFF,
		parameter	CONFIG_AMR1 =  8'hFF,
		parameter	CONFIG_AMR2 =  8'hFF,
		parameter	CONFIG_AMR3 =  8'hFF
	)(
	 input                sys_clk,
	 input                sys_rstn,
	 input				  sja_recover_trig,//总线恢复信号
	 
	 input    [87:0]      tx_data_bytes,//{TX_FRAME,TX_IDENTIFY，8x8data}
	 input                tx_trig_in,
	 output               trams_vld,
	 output   [7:0]       sja_status,
	 output   [87:0]      rx_data_bytes,
	 output               rx_data_vld,
	 
	 output               sja_ale_o,
	 output               sja_csn_o,
	 output               sja_rdn_o,
	 output               sja_wrn_o,
	 inout    [7:0]       sja_ad_io,
	 output               sja_dir
    );
	
	
	reg    [16:0]     sja_config_data;
	reg               trig_sja;	
	wire              sja_rd_vaild;
	wire   [7:0]      sja_rd_data;

	reg    [7:0]          sja_status_r;
	reg                   rd_status_trig;
	reg                   trams_status_trig;
	reg    [16:0]         sja_reset_state_check;
	
	
	reg  [23:0]  			config_cnt;
	
	reg	  [87:0]			tx_data_bytes_r;
	always @ (posedge sys_clk or negedge sys_rstn)begin
			if(!sys_rstn)begin
				tx_data_bytes_r <= 88'd0;
			end
			else if(tx_trig_in)begin
				tx_data_bytes_r <= tx_data_bytes;
			end
			else begin
				tx_data_bytes_r <= tx_data_bytes_r;
			end
	end
	
	
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			config_cnt <= 24'd0;
		end
		else if(sja_recover_trig)begin
			config_cnt <= 24'd0;
		end
		///////////////////////////////////////////////////复位检测
		else if(config_cnt > 24'h01_1200 && (sja_reset_state_check != 17'h1FFFF))begin
			config_cnt <=  24'd0;
		end
		////////////////////////////////////////////////////////
		else if(tx_trig_in)begin
			config_cnt <= 24'h01_FFE0;
		end
		else if(rd_status_trig)begin
			config_cnt <= 24'h02_04E0;
		end 
		else if(config_cnt == 24'h02_0180)begin//写完成后进入读状态
			config_cnt <= 24'h01_2000;
		end 
		else if(config_cnt == 24'h02_06C0)begin//读完成后进入读状态
			config_cnt <= 24'h01_2000;
		end 
		else if(config_cnt == 24'h01_2060)begin//FIFO——READ
			config_cnt <= 24'h01_2000;
		end 
		else begin
			config_cnt <= config_cnt + 1'b1;
		end
	end
	
	
	
	//config
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			sja_config_data <= 17'h0;  // {wr/rd_n, addr[7:0], data[7:0]}
		end
		else begin
			case (config_cnt)
            
                //模式寄存器地址：'d0
                //模式寄存器[0]=1，复位模式：进入复位模式 
				24'h01_0020 :  sja_config_data <= 17'h1_00_01; 
				24'h01_00a0 :  sja_config_data <= 17'h0_00_01; 
				
                //时钟分频寄存器地址：'d31
                //时钟分频寄存器[7]=1，pelican模式
                //时钟分频寄存器[6]=1，禁止can输入比较器
                //时钟分频寄存器[5]=0，禁止can tx1输出用做接收中断输出
                //时钟分频寄存器[4]=0，该位始终保持0
                //时钟分频寄存器[3]=1，禁止clkout管脚
                //时钟分频寄存器[2:0]=3'b000，clkout频率选择为fosc/2
				24'h01_0120 :  sja_config_data <= 17'h1_1F_C8; 
				24'h01_01a0 :  sja_config_data <= 17'h0_1F_C8; 
                
                //模式寄存器地址：'d0
                //模式寄存器[7]=0，保留
                //模式寄存器[6]=0，保留
                //模式寄存器[5]=0，保留	     
                //模式寄存器[4]=0，睡眠模式：唤醒模式
                //模式寄存器[3]=1，验收滤波器模式：单个验收滤波器(32位长度)模式
                //模式寄存器[2]=0，自检测模式：正常模式
                //模式寄存器[1]=0，只听模式：正常模式
                //模式寄存器[0]=1，sja模式：复位模式
				24'h01_0220 :  sja_config_data <= 17'h1_00_09;
				24'h01_02a0 :  sja_config_data <= 17'h0_00_09;
				
                //总线定时寄存器0地址：'d6
                //总线定时寄存器0[5:0]=5'b00000，CAN系统时钟周期=2*Tosc
                //总线定时寄存器0[7:6]=2'b00, 同步跳转宽度=CAN系统时钟周期
				24'h01_0320 :  sja_config_data <= {9'h1_06,CONFIG_BTR0};
				24'h01_03a0 :  sja_config_data <= 17'h0_06_00;

                //总线定时寄存器1地址：'d7
                //总线定时寄存器1[3:0]=4'b1100，Tseg1=13*CAN系统时钟周期
                //总线定时寄存器1[6:4]=3'b001，Tseg2=2*CAN系统时钟周期
                //总线定时寄存器1[7]=0，总线采样一次
				24'h01_0420 :  sja_config_data <= {9'h1_07,CONFIG_BTR1};
				24'h01_04a0 :  sja_config_data <= 17'h0_07_1c;
				
                //中断使能寄存器地址：'d4
                //中断使能寄存器[0]=1，接收中断使能
                //中断使能寄存器[1]=0，发送中断禁止
                //中断使能寄存器[2]=0，错误报警中断禁止
                //中断使能寄存器[3]=0，数据溢出中断禁止
                //中断使能寄存器[4]=0，唤醒中断禁止
                //中断使能寄存器[5]=0，错误消极中断禁止
                //中断使能寄存器[6]=0，仲裁丢失中断禁止
                //中断使能寄存器[7]=0，总线错误中断禁止
				24'h01_0520 :  sja_config_data <= 17'h1_04_01;
				24'h01_05a0 :  sja_config_data <= 17'h0_04_01;
				
                //输出控制寄存器地址：'d8
                //输出控制寄存器[1:0]=2'b10，正常输出模式
                //输出控制寄存器[4:2]=3'b110，TX0上拉驱动
                //输出控制寄存器[7:5]=3'b000, TX1悬空不使用
				24'h01_0620 :  sja_config_data <= 17'h1_08_1A;
				24'h01_06a0 :  sja_config_data <= 17'h0_08_1A;
				
                //命令寄存器地址: 'd1
                //命令寄存器[2]=1，接收缓存器FXFIFO中载有信息的内存空间被释放
				24'h01_0720 :  sja_config_data <= 17'h1_01_04;
				24'h01_07a0 :  sja_config_data <= 17'h0_01_04;
				
                //验收代码寄存器0地址: 'd16
                //验收代码寄存器0[7:0]=8'b1010_1110
				24'h01_0820 :  sja_config_data <= {9'h1_10,CONFIG_ACR0};
				24'h01_08a0 :  sja_config_data <= 17'h0_10_00;
				
                //验收代码寄存器1地址: 'd17
                //验收代码寄存器1[7:0]=8'b0000_0000
				24'h01_0920 :  sja_config_data <= {9'h1_11,CONFIG_ACR1};
				24'h01_09a0 :  sja_config_data <= 17'h0_11_00;
				
                //验收代码寄存器2地址: 'd18
                //验收代码寄存器2[7:0]=8'b0000_0000
				24'h01_0a20 :  sja_config_data <= {9'h1_12,CONFIG_ACR2};
				24'h01_0aa0 :  sja_config_data <= 17'h0_12_00;
				
                //验收代码寄存器3地址: 'd19
                //验收代码寄存器3[7:0]=8'b0000_0000
				24'h01_0b20 :  sja_config_data <= {9'h1_13,CONFIG_ACR3};
				24'h01_0ba0 :  sja_config_data <= 17'h0_13_00;
				
                //验收屏蔽寄存器0地址: 'd20
				24'h01_0c20 :  sja_config_data <= {9'h1_14,CONFIG_AMR0};
				24'h01_0ca0 :  sja_config_data <= 17'h0_14_ff;
				
                //验收屏蔽寄存器1地址: 'd21
				24'h01_0d20 :  sja_config_data <= {9'h1_15,CONFIG_AMR1};
				24'h01_0da0 :  sja_config_data <= 17'h0_15_ff;
				
                //验收屏蔽寄存器2地址: 'd22
				24'h01_0e20 :  sja_config_data <= {9'h1_16,CONFIG_AMR2};
				24'h01_0ea0 :  sja_config_data <= 17'h0_16_ff;
				
                //验收屏蔽寄存器3地址: 'd23
				24'h01_0f20 :  sja_config_data <= {9'h1_17,CONFIG_AMR3};
				24'h01_0fa0 :  sja_config_data <= 17'h0_17_ff;
				            
                //模式寄存器地址：'d0
                //模式寄存器[7:5]，保留
                //模式寄存器[4]=0，睡眠模式：唤醒模式
                //模式寄存器[3]=1，验收滤波器模式：单个验收滤波器(32位长度)模式
                //模式寄存器[2]=0，自检模式：正常模式
                //模式寄存器[1]=0，只听模式：正常模式
                //模式寄存器[0]=0，复位模式：正常模式(回到工作模式) 
				24'h01_1020 :  sja_config_data <= 17'h1_00_08;
				24'h01_10a0 :  sja_config_data <= 17'h0_00_00;
				//===================================================================================//
                
                //状态寄存器地址: 'd2
                //读RX——FIFO状态
				24'h01_2020 :  sja_config_data <= 17'h0_02_00;
				
                //读接收帧信息
				24'h02_0500 :  sja_config_data <= {1'b0,8'h10,8'h0}; 
                //读接收帧ID1
				24'h02_0520 :  sja_config_data <= {1'b0,8'h11,8'b0}; 
                //读接收帧ID2
				24'h02_0540 :  sja_config_data <= {1'b0,8'h12,8'b0}; 
                //读接收帧数据1
				24'h02_0560 :  sja_config_data <= {1'b0,8'h13,8'b0}; 
                //读接收帧数据2
				24'h02_0580 :  sja_config_data <= {1'b0,8'h14,8'b0}; 
				//读接收帧数据3
                24'h02_05a0 :  sja_config_data <= {1'b0,8'h15,8'b0}; 
				//读接收帧数据4
                24'h02_05c0 :  sja_config_data <= {1'b0,8'h16,8'b0}; 
				//读接收帧数据5
                24'h02_05e0 :  sja_config_data <= {1'b0,8'h17,8'b0}; 
				//读接收帧数据6
                24'h02_0600 :  sja_config_data <= {1'b0,8'h18,8'b0}; 
				//读接收帧数据7
                24'h02_0620 :  sja_config_data <= {1'b0,8'h19,8'b0}; 
				//读接收帧数据8
                24'h02_0640 :  sja_config_data <= {1'b0,8'h1A,8'b0}; 
                //命令寄存器[2]=1，释放接收缓冲器FIFO中载有信息的内存空间
				24'h02_0680 :  sja_config_data <= 17'h1_01_04;
				24'h02_06A0 :  sja_config_data <= 17'h1_01_04;
				
				
///////////////////////////////////////////////////////////////////////////////////////////////发送时序			
                //写发送帧信息
				24'h02_0000 :  sja_config_data <= {1'b1,8'h10,tx_data_bytes_r[87:80]}; 
                //写发送帧ID1
				24'h02_0020 :  sja_config_data <= {1'b1,8'h11,tx_data_bytes_r[79:72]}; 
                //写发送帧ID2
				24'h02_0040 :  sja_config_data <= {1'b1,8'h12,tx_data_bytes_r[71:64]}; 
                //写发送帧数据1
				24'h02_0060 :  sja_config_data <= {1'b1,8'h13,tx_data_bytes_r[63:56]}; 
                //写发送帧数据2
				24'h02_0080 :  sja_config_data <= {1'b1,8'h14,tx_data_bytes_r[55:48]}; 
                //写发送帧数据3
				24'h02_00a0 :  sja_config_data <= {1'b1,8'h15,tx_data_bytes_r[47:40]}; 
                //写发送帧数据4
				24'h02_00c0 :  sja_config_data <= {1'b1,8'h16,tx_data_bytes_r[39:32]}; 
		        //写发送帧数据5
                24'h02_00e0 :  sja_config_data <= {1'b1,8'h17,tx_data_bytes_r[31:24]}; 
				//写发送帧数据6
                24'h02_0100 :  sja_config_data <= {1'b1,8'h18,tx_data_bytes_r[23:16]}; 
				//写发送帧数据7
                24'h02_0120 :  sja_config_data <= {1'b1,8'h19,tx_data_bytes_r[15:8]}; 
				//写发送帧数据8
                24'h02_0140 :  sja_config_data <= {1'b1,8'h1A,tx_data_bytes_r[7:0]}; 
                //命令寄存器[0]=1，当前信息被发送
				24'h02_0160 :  sja_config_data <= 17'h1_01_01;//发送
				
				default :  sja_config_data <= sja_config_data;
			endcase
		end
	end 
	
	//spi_trig
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			trig_sja <= 1'b0;
		end
		else begin
			case (config_cnt)
				24'h01_0020 :  trig_sja <= 1'b1;
				24'h01_00a0 :  trig_sja <= 1'b1;
				24'h01_0120 :  trig_sja <= 1'b1;
				24'h01_01a0 :  trig_sja <= 1'b1;
				24'h01_0220 :  trig_sja <= 1'b1;
				24'h01_02a0 :  trig_sja <= 1'b1;
				24'h01_0320 :  trig_sja <= 1'b1;
				24'h01_03a0 :  trig_sja <= 1'b1;
				24'h01_0420 :  trig_sja <= 1'b1;
				24'h01_04a0 :  trig_sja <= 1'b1;
				24'h01_0520 :  trig_sja <= 1'b1;
				24'h01_05a0 :  trig_sja <= 1'b1;
				24'h01_0620 :  trig_sja <= 1'b1;
				24'h01_06a0 :  trig_sja <= 1'b1;
				24'h01_0720 :  trig_sja <= 1'b1;
				24'h01_07a0 :  trig_sja <= 1'b1;
				24'h01_0820 :  trig_sja <= 1'b1;
				24'h01_08a0 :  trig_sja <= 1'b1;
				24'h01_0920 :  trig_sja <= 1'b1;
				24'h01_09a0 :  trig_sja <= 1'b1;
				24'h01_0a20 :  trig_sja <= 1'b1;
				24'h01_0aa0 :  trig_sja <= 1'b1;
				24'h01_0b20 :  trig_sja <= 1'b1;
				24'h01_0ba0 :  trig_sja <= 1'b1;
				24'h01_0c20 :  trig_sja <= 1'b1;
				24'h01_0ca0 :  trig_sja <= 1'b1;
				24'h01_0d20 :  trig_sja <= 1'b1;
				24'h01_0da0 :  trig_sja <= 1'b1;
				24'h01_0e20 :  trig_sja <= 1'b1;
				24'h01_0ea0 :  trig_sja <= 1'b1;
				24'h01_0f20 :  trig_sja <= 1'b1;
				24'h01_0fa0 :  trig_sja <= 1'b1;
				24'h01_1020 :  trig_sja <= 1'b1;
				24'h01_10a0 :  trig_sja <= 1'b1;
				
				24'h01_2020 :  trig_sja <= 1'b1;
				
				24'h02_0500 :  trig_sja <= 1'b1;
				24'h02_0520 :  trig_sja <= 1'b1;
				24'h02_0540 :  trig_sja <= 1'b1;
				24'h02_0560 :  trig_sja <= 1'b1;
				24'h02_0580 :  trig_sja <= 1'b1;
				24'h02_05a0 :  trig_sja <= 1'b1;
				24'h02_05c0 :  trig_sja <= 1'b1; 
				24'h02_05e0 :  trig_sja <= 1'b1;
				24'h02_0600 :  trig_sja <= 1'b1; 
				24'h02_0620 :  trig_sja <= 1'b1;
				24'h02_0640 :  trig_sja <= 1'b1;
				24'h02_0680 :  trig_sja <= 1'b1;
				24'h02_06A0 :  trig_sja <= 1'b1;
				
				24'h02_0000 :  trig_sja <= 1'b1;
				24'h02_0020 :  trig_sja <= 1'b1;
				24'h02_0040 :  trig_sja <= 1'b1;
				24'h02_0060 :  trig_sja <= 1'b1;
				24'h02_0080 :  trig_sja <= 1'b1;
				24'h02_00a0 :  trig_sja <= 1'b1;
				24'h02_00c0 :  trig_sja <= 1'b1;
				24'h02_00e0 :  trig_sja <= 1'b1;
				24'h02_0100 :  trig_sja <= 1'b1;
				24'h02_0120 :  trig_sja <= 1'b1;
				24'h02_0140 :  trig_sja <= 1'b1;
				24'h02_0160 :  trig_sja <= 1'b1;
				default :  trig_sja <= 1'b0;
			endcase
		end
	end
	
	reg  [87:0]		rx_data_bytes_r;
	reg      		rx_data_vld_r;
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			rx_data_bytes_r <= 88'd0;
			rx_data_vld_r <= 1'b0;
		end
		else if(sja_rd_vaild)begin
			if(config_cnt>= 24'h02_0500  && config_cnt< 24'h02_0520) begin rx_data_bytes_r[87:80] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_0520  && config_cnt< 24'h02_0540) begin rx_data_bytes_r[79:72] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_0540  && config_cnt< 24'h02_0560) begin rx_data_bytes_r[71:64] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_0560  && config_cnt< 24'h02_0580) begin rx_data_bytes_r[63:56] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_0580  && config_cnt< 24'h02_05a0) begin rx_data_bytes_r[55:48] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_05a0  && config_cnt< 24'h02_05c0) begin rx_data_bytes_r[47:40] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_05c0  && config_cnt< 24'h02_05e0) begin rx_data_bytes_r[39:32] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_05e0  && config_cnt< 24'h02_0600) begin rx_data_bytes_r[31:24] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_0600  && config_cnt< 24'h02_0620) begin rx_data_bytes_r[23:16] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_0620  && config_cnt< 24'h02_0640) begin rx_data_bytes_r[15:8] <= sja_rd_data; rx_data_vld_r <= 1'b0; end
			else if(config_cnt>= 24'h02_0640  && config_cnt< 24'h02_0660) begin rx_data_bytes_r[7:0] <= sja_rd_data; rx_data_vld_r <= 1'b1; end
		end
		else begin
			rx_data_vld_r <= 1'b0;
		end
	end
	
	
	//复位检测
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			sja_reset_state_check <= 17'b0_0000_0000_0000_0000;
		end
		else if(sja_rd_vaild)begin
			     if(config_cnt>= 24'h01_00a0  && config_cnt< 24'h01_0120 && sja_rd_data[0] == 1'b1) 		begin sja_reset_state_check <= {1'b1,sja_reset_state_check[15:0]}; end
			else if(config_cnt>= 24'h01_01a0  && config_cnt< 24'h01_0220 && sja_rd_data == 8'hC8) 		begin sja_reset_state_check <= {sja_reset_state_check[16],1'b1,sja_reset_state_check[14:0]};  end
			else if(config_cnt>= 24'h01_02a0  && config_cnt< 24'h01_0320 && sja_rd_data == 8'h09) 		begin sja_reset_state_check <= {sja_reset_state_check[16:15],1'b1,sja_reset_state_check[13:0]};    end
			else if(config_cnt>= 24'h01_03a0  && config_cnt< 24'h01_0420 && sja_rd_data == CONFIG_BTR0) begin sja_reset_state_check <= {sja_reset_state_check[16:14],1'b1,sja_reset_state_check[12:0]};    end
			else if(config_cnt>= 24'h01_04a0  && config_cnt< 24'h01_0520 && sja_rd_data == CONFIG_BTR1) begin sja_reset_state_check <= {sja_reset_state_check[16:13],1'b1,sja_reset_state_check[11:0]};    end
			else if(config_cnt>= 24'h01_05a0  && config_cnt< 24'h01_0620 && sja_rd_data == 8'h01) 		begin sja_reset_state_check <= {sja_reset_state_check[16:12],1'b1,sja_reset_state_check[10:0]};    end
			else if(config_cnt>= 24'h01_06a0  && config_cnt< 24'h01_0720 && sja_rd_data == 8'h1A) 		begin sja_reset_state_check <= {sja_reset_state_check[16:11],1'b1,sja_reset_state_check[9:0]};    end
			else if(config_cnt>= 24'h01_07a0  && config_cnt< 24'h01_0820 /*&& sja_rd_data == 8'h04*/) 		begin sja_reset_state_check <= {sja_reset_state_check[16:10],1'b1,sja_reset_state_check[8:0]};    end
			else if(config_cnt>= 24'h01_08a0  && config_cnt< 24'h01_0920 && sja_rd_data == CONFIG_ACR0) begin sja_reset_state_check <= {sja_reset_state_check[16:9],1'b1,sja_reset_state_check[7:0]};    end
			else if(config_cnt>= 24'h01_09a0  && config_cnt< 24'h01_0a20 && sja_rd_data == CONFIG_ACR1) begin sja_reset_state_check <= {sja_reset_state_check[16:8],1'b1,sja_reset_state_check[6:0]};    end
			else if(config_cnt>= 24'h01_0aa0  && config_cnt< 24'h01_0b20 && sja_rd_data == CONFIG_ACR2) begin sja_reset_state_check <= {sja_reset_state_check[16:7],1'b1,sja_reset_state_check[5:0]};    end
			else if(config_cnt>= 24'h01_0ba0  && config_cnt< 24'h01_0c20 && sja_rd_data == CONFIG_ACR3) begin sja_reset_state_check <= {sja_reset_state_check[16:6],1'b1,sja_reset_state_check[4:0]};    end
			else if(config_cnt>= 24'h01_0ca0  && config_cnt< 24'h01_0d20 && sja_rd_data == CONFIG_AMR0)	begin sja_reset_state_check <= {sja_reset_state_check[16:5],1'b1,sja_reset_state_check[3:0]};    end
			else if(config_cnt>= 24'h01_0da0  && config_cnt< 24'h01_0e20 && sja_rd_data == CONFIG_AMR1)	begin sja_reset_state_check <= {sja_reset_state_check[16:4],1'b1,sja_reset_state_check[2:0]};    end
			else if(config_cnt>= 24'h01_0ea0  && config_cnt< 24'h01_0f20 && sja_rd_data == CONFIG_AMR2)	begin sja_reset_state_check <= {sja_reset_state_check[16:3],1'b1,sja_reset_state_check[1:0]};    end
			else if(config_cnt>= 24'h01_0fa0  && config_cnt< 24'h01_1020 && sja_rd_data == CONFIG_AMR3)	begin sja_reset_state_check <= {sja_reset_state_check[16:2],1'b1,sja_reset_state_check[0]};    end
			else if(config_cnt>= 24'h01_10a0  && config_cnt< 24'h01_1120 && sja_rd_data == 8'h08)		begin sja_reset_state_check <= {sja_reset_state_check[16:1],1'b1};    end
		end
		else begin
			sja_reset_state_check <= sja_reset_state_check;
		end
	end
	
	
	
	
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			sja_status_r <= 8'd0;
			rd_status_trig <= 1'b0;
			trams_status_trig <= 1'b0;
		end
		else if(sja_rd_vaild)begin
			if(config_cnt>= 24'h01_2020  && config_cnt< 24'h01_2040) begin 
				sja_status_r <= sja_rd_data;
				rd_status_trig <= sja_rd_data[0];//FIFO中有可读数据，一个脉冲表示
				trams_status_trig <= sja_rd_data[2];//Transmit Buffer Status;the CPU may write a message into the transmit buffer
				                                     // 表示可以往FIFO写数据，后面会用一个时钟脉冲表示，防止一直置高造成的误判
			end
		end
		else begin
			rd_status_trig <= 1'b0;
			trams_status_trig <= 1'b0;
		end
	end
	
	assign sja_status = sja_status_r;
	assign trams_vld =  trams_status_trig;//查询发送FIFO是否可以写入状态，但只会标志一个脉冲，写入数据可以根据有脉冲后写入
	assign rx_data_bytes = rx_data_bytes_r;
	assign rx_data_vld = rx_data_vld_r;
	
	sja1000_interface_module inst_sja_interface (
		.sys_clk(sys_clk), 
		.sys_rstn(sys_rstn), 
		.trig_in(trig_sja), 
		.sja_dat_in(sja_config_data), 
		
		.sja_rd_data(sja_rd_data), 
		.sja_rd_vaild(sja_rd_vaild),
		
		.sja_ale_o(sja_ale_o), 
		.sja_csn_o(sja_csn_o), 
		.sja_rdn_o(sja_rdn_o), 
		.sja_wrn_o(sja_wrn_o), 
		.sja_ad_io(sja_ad_io), 
		.sja_dir(sja_dir)
		);
endmodule
