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
	 input				  sja_recover_trig,//���߻ָ��ź�
	 
	 input    [87:0]      tx_data_bytes,//{TX_FRAME,TX_IDENTIFY��8x8data}
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
		///////////////////////////////////////////////////��λ���
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
		else if(config_cnt == 24'h02_0180)begin//д��ɺ�����״̬
			config_cnt <= 24'h01_2000;
		end 
		else if(config_cnt == 24'h02_06C0)begin//����ɺ�����״̬
			config_cnt <= 24'h01_2000;
		end 
		else if(config_cnt == 24'h01_2060)begin//FIFO����READ
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
            
                //ģʽ�Ĵ�����ַ��'d0
                //ģʽ�Ĵ���[0]=1����λģʽ�����븴λģʽ 
				24'h01_0020 :  sja_config_data <= 17'h1_00_01; 
				24'h01_00a0 :  sja_config_data <= 17'h0_00_01; 
				
                //ʱ�ӷ�Ƶ�Ĵ�����ַ��'d31
                //ʱ�ӷ�Ƶ�Ĵ���[7]=1��pelicanģʽ
                //ʱ�ӷ�Ƶ�Ĵ���[6]=1����ֹcan����Ƚ���
                //ʱ�ӷ�Ƶ�Ĵ���[5]=0����ֹcan tx1������������ж����
                //ʱ�ӷ�Ƶ�Ĵ���[4]=0����λʼ�ձ���0
                //ʱ�ӷ�Ƶ�Ĵ���[3]=1����ֹclkout�ܽ�
                //ʱ�ӷ�Ƶ�Ĵ���[2:0]=3'b000��clkoutƵ��ѡ��Ϊfosc/2
				24'h01_0120 :  sja_config_data <= 17'h1_1F_C8; 
				24'h01_01a0 :  sja_config_data <= 17'h0_1F_C8; 
                
                //ģʽ�Ĵ�����ַ��'d0
                //ģʽ�Ĵ���[7]=0������
                //ģʽ�Ĵ���[6]=0������
                //ģʽ�Ĵ���[5]=0������	     
                //ģʽ�Ĵ���[4]=0��˯��ģʽ������ģʽ
                //ģʽ�Ĵ���[3]=1�������˲���ģʽ�����������˲���(32λ����)ģʽ
                //ģʽ�Ĵ���[2]=0���Լ��ģʽ������ģʽ
                //ģʽ�Ĵ���[1]=0��ֻ��ģʽ������ģʽ
                //ģʽ�Ĵ���[0]=1��sjaģʽ����λģʽ
				24'h01_0220 :  sja_config_data <= 17'h1_00_09;
				24'h01_02a0 :  sja_config_data <= 17'h0_00_09;
				
                //���߶�ʱ�Ĵ���0��ַ��'d6
                //���߶�ʱ�Ĵ���0[5:0]=5'b00000��CANϵͳʱ������=2*Tosc
                //���߶�ʱ�Ĵ���0[7:6]=2'b00, ͬ����ת���=CANϵͳʱ������
				24'h01_0320 :  sja_config_data <= {9'h1_06,CONFIG_BTR0};
				24'h01_03a0 :  sja_config_data <= 17'h0_06_00;

                //���߶�ʱ�Ĵ���1��ַ��'d7
                //���߶�ʱ�Ĵ���1[3:0]=4'b1100��Tseg1=13*CANϵͳʱ������
                //���߶�ʱ�Ĵ���1[6:4]=3'b001��Tseg2=2*CANϵͳʱ������
                //���߶�ʱ�Ĵ���1[7]=0�����߲���һ��
				24'h01_0420 :  sja_config_data <= {9'h1_07,CONFIG_BTR1};
				24'h01_04a0 :  sja_config_data <= 17'h0_07_1c;
				
                //�ж�ʹ�ܼĴ�����ַ��'d4
                //�ж�ʹ�ܼĴ���[0]=1�������ж�ʹ��
                //�ж�ʹ�ܼĴ���[1]=0�������жϽ�ֹ
                //�ж�ʹ�ܼĴ���[2]=0�����󱨾��жϽ�ֹ
                //�ж�ʹ�ܼĴ���[3]=0����������жϽ�ֹ
                //�ж�ʹ�ܼĴ���[4]=0�������жϽ�ֹ
                //�ж�ʹ�ܼĴ���[5]=0�����������жϽ�ֹ
                //�ж�ʹ�ܼĴ���[6]=0���ٲö�ʧ�жϽ�ֹ
                //�ж�ʹ�ܼĴ���[7]=0�����ߴ����жϽ�ֹ
				24'h01_0520 :  sja_config_data <= 17'h1_04_01;
				24'h01_05a0 :  sja_config_data <= 17'h0_04_01;
				
                //������ƼĴ�����ַ��'d8
                //������ƼĴ���[1:0]=2'b10���������ģʽ
                //������ƼĴ���[4:2]=3'b110��TX0��������
                //������ƼĴ���[7:5]=3'b000, TX1���ղ�ʹ��
				24'h01_0620 :  sja_config_data <= 17'h1_08_1A;
				24'h01_06a0 :  sja_config_data <= 17'h0_08_1A;
				
                //����Ĵ�����ַ: 'd1
                //����Ĵ���[2]=1�����ջ�����FXFIFO��������Ϣ���ڴ�ռ䱻�ͷ�
				24'h01_0720 :  sja_config_data <= 17'h1_01_04;
				24'h01_07a0 :  sja_config_data <= 17'h0_01_04;
				
                //���մ���Ĵ���0��ַ: 'd16
                //���մ���Ĵ���0[7:0]=8'b1010_1110
				24'h01_0820 :  sja_config_data <= {9'h1_10,CONFIG_ACR0};
				24'h01_08a0 :  sja_config_data <= 17'h0_10_00;
				
                //���մ���Ĵ���1��ַ: 'd17
                //���մ���Ĵ���1[7:0]=8'b0000_0000
				24'h01_0920 :  sja_config_data <= {9'h1_11,CONFIG_ACR1};
				24'h01_09a0 :  sja_config_data <= 17'h0_11_00;
				
                //���մ���Ĵ���2��ַ: 'd18
                //���մ���Ĵ���2[7:0]=8'b0000_0000
				24'h01_0a20 :  sja_config_data <= {9'h1_12,CONFIG_ACR2};
				24'h01_0aa0 :  sja_config_data <= 17'h0_12_00;
				
                //���մ���Ĵ���3��ַ: 'd19
                //���մ���Ĵ���3[7:0]=8'b0000_0000
				24'h01_0b20 :  sja_config_data <= {9'h1_13,CONFIG_ACR3};
				24'h01_0ba0 :  sja_config_data <= 17'h0_13_00;
				
                //�������μĴ���0��ַ: 'd20
				24'h01_0c20 :  sja_config_data <= {9'h1_14,CONFIG_AMR0};
				24'h01_0ca0 :  sja_config_data <= 17'h0_14_ff;
				
                //�������μĴ���1��ַ: 'd21
				24'h01_0d20 :  sja_config_data <= {9'h1_15,CONFIG_AMR1};
				24'h01_0da0 :  sja_config_data <= 17'h0_15_ff;
				
                //�������μĴ���2��ַ: 'd22
				24'h01_0e20 :  sja_config_data <= {9'h1_16,CONFIG_AMR2};
				24'h01_0ea0 :  sja_config_data <= 17'h0_16_ff;
				
                //�������μĴ���3��ַ: 'd23
				24'h01_0f20 :  sja_config_data <= {9'h1_17,CONFIG_AMR3};
				24'h01_0fa0 :  sja_config_data <= 17'h0_17_ff;
				            
                //ģʽ�Ĵ�����ַ��'d0
                //ģʽ�Ĵ���[7:5]������
                //ģʽ�Ĵ���[4]=0��˯��ģʽ������ģʽ
                //ģʽ�Ĵ���[3]=1�������˲���ģʽ�����������˲���(32λ����)ģʽ
                //ģʽ�Ĵ���[2]=0���Լ�ģʽ������ģʽ
                //ģʽ�Ĵ���[1]=0��ֻ��ģʽ������ģʽ
                //ģʽ�Ĵ���[0]=0����λģʽ������ģʽ(�ص�����ģʽ) 
				24'h01_1020 :  sja_config_data <= 17'h1_00_08;
				24'h01_10a0 :  sja_config_data <= 17'h0_00_00;
				//===================================================================================//
                
                //״̬�Ĵ�����ַ: 'd2
                //��RX����FIFO״̬
				24'h01_2020 :  sja_config_data <= 17'h0_02_00;
				
                //������֡��Ϣ
				24'h02_0500 :  sja_config_data <= {1'b0,8'h10,8'h0}; 
                //������֡ID1
				24'h02_0520 :  sja_config_data <= {1'b0,8'h11,8'b0}; 
                //������֡ID2
				24'h02_0540 :  sja_config_data <= {1'b0,8'h12,8'b0}; 
                //������֡����1
				24'h02_0560 :  sja_config_data <= {1'b0,8'h13,8'b0}; 
                //������֡����2
				24'h02_0580 :  sja_config_data <= {1'b0,8'h14,8'b0}; 
				//������֡����3
                24'h02_05a0 :  sja_config_data <= {1'b0,8'h15,8'b0}; 
				//������֡����4
                24'h02_05c0 :  sja_config_data <= {1'b0,8'h16,8'b0}; 
				//������֡����5
                24'h02_05e0 :  sja_config_data <= {1'b0,8'h17,8'b0}; 
				//������֡����6
                24'h02_0600 :  sja_config_data <= {1'b0,8'h18,8'b0}; 
				//������֡����7
                24'h02_0620 :  sja_config_data <= {1'b0,8'h19,8'b0}; 
				//������֡����8
                24'h02_0640 :  sja_config_data <= {1'b0,8'h1A,8'b0}; 
                //����Ĵ���[2]=1���ͷŽ��ջ�����FIFO��������Ϣ���ڴ�ռ�
				24'h02_0680 :  sja_config_data <= 17'h1_01_04;
				24'h02_06A0 :  sja_config_data <= 17'h1_01_04;
				
				
///////////////////////////////////////////////////////////////////////////////////////////////����ʱ��			
                //д����֡��Ϣ
				24'h02_0000 :  sja_config_data <= {1'b1,8'h10,tx_data_bytes_r[87:80]}; 
                //д����֡ID1
				24'h02_0020 :  sja_config_data <= {1'b1,8'h11,tx_data_bytes_r[79:72]}; 
                //д����֡ID2
				24'h02_0040 :  sja_config_data <= {1'b1,8'h12,tx_data_bytes_r[71:64]}; 
                //д����֡����1
				24'h02_0060 :  sja_config_data <= {1'b1,8'h13,tx_data_bytes_r[63:56]}; 
                //д����֡����2
				24'h02_0080 :  sja_config_data <= {1'b1,8'h14,tx_data_bytes_r[55:48]}; 
                //д����֡����3
				24'h02_00a0 :  sja_config_data <= {1'b1,8'h15,tx_data_bytes_r[47:40]}; 
                //д����֡����4
				24'h02_00c0 :  sja_config_data <= {1'b1,8'h16,tx_data_bytes_r[39:32]}; 
		        //д����֡����5
                24'h02_00e0 :  sja_config_data <= {1'b1,8'h17,tx_data_bytes_r[31:24]}; 
				//д����֡����6
                24'h02_0100 :  sja_config_data <= {1'b1,8'h18,tx_data_bytes_r[23:16]}; 
				//д����֡����7
                24'h02_0120 :  sja_config_data <= {1'b1,8'h19,tx_data_bytes_r[15:8]}; 
				//д����֡����8
                24'h02_0140 :  sja_config_data <= {1'b1,8'h1A,tx_data_bytes_r[7:0]}; 
                //����Ĵ���[0]=1����ǰ��Ϣ������
				24'h02_0160 :  sja_config_data <= 17'h1_01_01;//����
				
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
	
	
	//��λ���
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
				rd_status_trig <= sja_rd_data[0];//FIFO���пɶ����ݣ�һ�������ʾ
				trams_status_trig <= sja_rd_data[2];//Transmit Buffer Status;the CPU may write a message into the transmit buffer
				                                     // ��ʾ������FIFOд���ݣ��������һ��ʱ�������ʾ����ֹһֱ�ø���ɵ�����
			end
		end
		else begin
			rd_status_trig <= 1'b0;
			trams_status_trig <= 1'b0;
		end
	end
	
	assign sja_status = sja_status_r;
	assign trams_vld =  trams_status_trig;//��ѯ����FIFO�Ƿ����д��״̬����ֻ���־һ�����壬д�����ݿ��Ը����������д��
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
