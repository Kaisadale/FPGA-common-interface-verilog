///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: adc128_top.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::ProASIC3> <Die::A3P1000> <Package::484 FBGA>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

//`timescale <time_units> / <precision>

module adc128_top( 
input			clk_i			,
input			rst_i			,
//--interface-----------	
output			AD128_SCLK		,
output			AD128_CS		,
output			AD128_DIN		,
input			AD128_DOUT		,
//---sample data		,
output	[11:00]	AD128_data0		,	
output	[11:00]	AD128_data1		,	
output	[11:00]	AD128_data2		,	
output	[11:00]	AD128_data3		,	
output	[11:00]	AD128_data4		,	
output	[11:00]	AD128_data5		,	
output	[11:00]	AD128_data6		,	
output	[11:00]	AD128_data7		,
output			AD128_vld		
	
 );

//<statements>

reg		[11:0]	ad128_data[0:7]	;
reg				AD128_vld_r		;

wire			track_cnt_end	;
wire			conv_cnt_end	;
wire			wait_cnt_end	;
 
                 
localparam      IDLE  		= 0;    // ??
localparam      TRACK  		= 1;    // ????1
localparam      CONV		= 2;    // ????1
localparam      WAIT		= 3;    // ????1

reg [WAIT:0]  ST  ;
reg [WAIT:0]  nST ;
                     
// ????                                                                      
always @(posedge clk_i)                                                            
  if(rst_i) ST <= 'd1;
  else    	ST <= nST;

always @(*) begin                                                                
  nST = 'd0;                                                                     
  case(1'b1)                                                                     
    ST[IDLE]: 												nST[TRACK] 	= 1'b1;  
    ST[TRACK]:                                                 
      if(track_cnt_end)  									nST[CONV] 	= 1'b1;   
      else                                                  nST[TRACK] 	= 1'b1;
    ST[CONV]:
      if(conv_cnt_end)   									nST[WAIT] 	= 1'b1;   
      else               									nST[CONV] 	= 1'b1;   
	ST[WAIT]:
      if(wait_cnt_end)   									nST[TRACK] 	= 1'b1;   
      else               									nST[WAIT] 	= 1'b1; 
    default:                                                nST[IDLE] 	= 1'b1;
  endcase
end


//-------------------------------------------------------                        
//---------------------------- ???????                                    
//-------------------------------------------------------                                                                          
// reg [63:0] ST_STRING;                                                            
// always @(*)                                                                      
  // case(1'b1)                                                                     
    // ST[IDLE]      : ST_STRING = "IDLE"  ;
    // ST[TRACK]     : ST_STRING = "TRACK" ;
    // ST[CONV]      : ST_STRING = "CONV"  ;
    // default       : ST_STRING = "XXXX"  ;
  // endcase
  

reg		[07:00]	st_cnt 		;
reg		[02:00]	track_addr	;
reg		[11:00]	ad128_data_r;

always@(posedge clk_i)
if(rst_i|ST[WAIT]&&nST[TRACK])					st_cnt <= 0;
else if(ST[TRACK]|ST[CONV]|ST[WAIT])			st_cnt <= st_cnt + 1'b1;
else											st_cnt <= st_cnt ;

assign track_cnt_end = st_cnt == 8'd3	;
assign conv_cnt_end = st_cnt == 8'd15	;
assign wait_cnt_end = st_cnt == 8'd24	;  //samp rate = 10M/25= 400K 400K/8= 50K;

always@(posedge clk_i)
if(rst_i)												track_addr <= 0;
else if(ST[WAIT]&&nST[TRACK]|ST[IDLE]&&nST[TRACK])		track_addr <= track_addr + 1'b1;
else													track_addr <= track_addr;

reg			ad128_din_r	;

always @(*)
  case(st_cnt)
	4'd0:ad128_din_r = 0;
	4'd1:ad128_din_r = 0;
	4'd2:ad128_din_r = track_addr[2];
	4'd3:ad128_din_r = track_addr[1];
	4'd4:ad128_din_r = track_addr[0];
	4'd5:ad128_din_r = 0;
	4'd6:ad128_din_r = 0;
	4'd7:ad128_din_r = 0;
	default:ad128_din_r = 0;
 endcase

always@(negedge clk_i)
	case(st_cnt)
	4'd4:ad128_data_r[11] 	<= AD128_DOUT;
	4'd5:ad128_data_r[10] 	<= AD128_DOUT;
	4'd6:ad128_data_r[9] 	<= AD128_DOUT;
	4'd7:ad128_data_r[8] 	<= AD128_DOUT;
	4'd8:ad128_data_r[7] 	<= AD128_DOUT;
	4'd9:ad128_data_r[6] 	<= AD128_DOUT;
	4'd10:ad128_data_r[5] 	<= AD128_DOUT;
	4'd11:ad128_data_r[4] 	<= AD128_DOUT;
	4'd12:ad128_data_r[3] 	<= AD128_DOUT;
	4'd13:ad128_data_r[2] 	<= AD128_DOUT;
	4'd14:ad128_data_r[1] 	<= AD128_DOUT;
	4'd15:ad128_data_r[0] 	<= AD128_DOUT;
	default :ad128_data_r <= ad128_data_r;
	endcase
	
always@(posedge clk_i)
if(rst_i)		{ad128_data[0],	ad128_data[1],ad128_data[2],ad128_data[3],ad128_data[4],ad128_data[5],ad128_data[6],ad128_data[7]} <= {12'd0,12'd0,12'd0,12'd0,12'd0,12'd0,12'd0,12'd0};
else if(ST[CONV]&&nST[WAIT]&&(track_addr!=0))	ad128_data[track_addr-1] <= ad128_data_r;
else if(ST[CONV]&&nST[WAIT]&&(track_addr==0))	ad128_data[7] <= ad128_data_r;

always@(posedge clk_i)
if(rst_i)										AD128_vld_r<= 0;
else if(ST[CONV]&&nST[WAIT]&&(track_addr==0))	AD128_vld_r <= 1;
else											AD128_vld_r <= 0;

assign AD128_CS 	= ~(ST[TRACK]|ST[CONV]);
assign AD128_SCLK 	= ~clk_i		;
assign AD128_DIN	= ad128_din_r	;

assign AD128_data0	= ad128_data[0]	;
assign AD128_data1	= ad128_data[1]	;
assign AD128_data2	= ad128_data[2]	;
assign AD128_data3	= ad128_data[3]	;
assign AD128_data4	= ad128_data[4]	;
assign AD128_data5	= ad128_data[5]	;
assign AD128_data6	= ad128_data[6]	;
assign AD128_data7	= ad128_data[7]	;
assign AD128_vld    = AD128_vld_r;

endmodule

