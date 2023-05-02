`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:45:38 01/17/2018 
// Design Name: 
// Module Name:    sja1000_interface_module 
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
module sja1000_interface_module(
	 input                sys_clk,
	 input                sys_rstn,
	
     input                trig_in,
	 input    [16:0]      sja_dat_in,//{w/rn,addr.data}
	 output   [7:0]       sja_rd_data,
	 output               sja_rd_vaild,
	 
	 output               sja_ale_o,
	 output               sja_csn_o,
	 output               sja_rdn_o,
	 output               sja_wrn_o,
	 inout    [7:0]       sja_ad_io,
	 output               sja_dir
    );

	reg       [7:0]       timing_cnt;
	reg                   timing_cs;
	reg                   sja_ale_reg;
	reg                   sja_rdn_reg;
	reg                   sja_wrn_reg;
	reg                   sja_csn_reg;
	
	reg       [7:0]       sja_addr;
	reg       [7:0]       sja_dat;
	reg                   sja_wr;
	
	reg       [7:0]       sja_ad_o;
    reg       [7:0]       sja_ad_i;

	//timg_cs 时序总开关
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn) timing_cs <= 1'b0;
		else if(trig_in) timing_cs <= 1'b1;
		else if(timing_cnt  == 8'd18)timing_cs <= 1'b0;
	end	
	
	//timing cnt
    always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			timing_cnt <= 8'd0;
		end 
		else if(timing_cs)begin
			 timing_cnt <= timing_cnt + 1'b1;
		end
		else begin
			timing_cnt <= 8'd0;
		end
	end	
	
	/////////////////////////////////////////////////////////
	//dat_trig
    always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			sja_dat    <=    8'd0;
			sja_addr   <=    8'd0;
			sja_wr     <=    1'b0;
		end 
		else if(trig_in)begin
			sja_dat    <=    sja_dat_in[7:0];
			sja_addr   <=    sja_dat_in[15:8];
			sja_wr     <=    sja_dat_in[16];		
		end
	end	
	
	//dat
    always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			sja_ad_o    <=    8'd0;
			sja_ad_i    <=    8'd0;
		end 
		else if(timing_cs)begin
			case(timing_cnt)
				8'd1 : 		sja_ad_o    <=    sja_addr;
				8'd5 : 		sja_ad_o    <=    sja_dat;
				8'd14 :     sja_ad_i    <=    sja_ad_io; 
				default :   sja_ad_o    <=    sja_ad_o; 
			endcase
		end
		else begin
			sja_ad_o    <=    8'd0;
		end
	end	
	
	
	//ale
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)sja_ale_reg <= 1'b1;
		else if(!timing_cs) sja_ale_reg <= 1'b1;
		else if(timing_cnt == 8'd3) sja_ale_reg <= 1'b0;
	end
	
	
	//rd
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)sja_rdn_reg <= 1'b1;
		else if(!timing_cs) sja_rdn_reg <= 1'b1;
		else if(timing_cnt == 8'd5  && !sja_wr) sja_rdn_reg <= 1'b0;
		else if(timing_cnt == 8'd13) sja_rdn_reg <= 1'b1;
	end
	
	//wr
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)sja_wrn_reg <= 1'b1;
		else if(!timing_cs) sja_wrn_reg <= 1'b1;
		else if(timing_cnt == 8'd5  && sja_wr) sja_wrn_reg <= 1'b0;
		else if(timing_cnt == 8'd13) sja_wrn_reg <= 1'b1;
	end
	
	//cs
	always @ (posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)sja_csn_reg <= 1'b1;
		else if(!timing_cs) sja_csn_reg <= 1'b1;
		else if(timing_cnt == 8'd5) sja_csn_reg <= 1'b0;
		else if(timing_cnt == 8'd13) sja_csn_reg <= 1'b1;
	end
	
	
	//dat_deal
	assign  sja_ad_io = (timing_cnt>8'd4 && !sja_wr)?  8'dz :  sja_ad_o;
	assign  sja_dir   = (timing_cnt>8'd4 && !sja_wr)?  1'b0 :  1'b1;
    assign  sja_ale_o = sja_ale_reg;
	assign  sja_csn_o = sja_csn_reg;
	assign  sja_rdn_o = sja_rdn_reg;
	assign  sja_wrn_o = sja_wrn_reg;
	assign  sja_rd_data = sja_ad_i;
	assign  sja_rd_vaild = (!sja_wr && timing_cnt== 8'd16)? 1'b1 : 1'b0;
	
endmodule
