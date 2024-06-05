module mipi_sup_frm_seg
(
    input              clk_i,
	input              rst_n_i,
	
	input       [3:0]  cam_type_i,	
	input              mipi_rx_sf_seg_en_i,
	
	// mipi rx input    
	input       [63:0] mipi_rx_sf_axis_tdata_i,
    input       [9:0]  mipi_rx_sf_axis_tdest_i,
    input              mipi_rx_sf_axis_tlast_i, 
    input              mipi_rx_sf_axis_tuser_i,      
    input              mipi_rx_sf_axis_tvalid_i,
	input              mipi_rx_sf_axis_tready_i, 


    // mipi segregation
	output  reg [63:0] mipi_rx_sf_seg_axis_tdata_o,
    output  reg [9:0]  mipi_rx_sf_seg_axis_tdest_o,
    output  reg        mipi_rx_sf_seg_axis_tlast_o, 
    output  reg        mipi_rx_sf_seg_axis_tuser_o,      
    output  reg        mipi_rx_sf_seg_axis_tvalid_o
	
);

wire       mipi_rx_sf_axis_shake_ok;
wire       mipi_rx_sf_line_end;
wire       mipi_rx_sf_frame_start;
wire       mipi_rx_sf_pixel_valid;
reg [11:0] mipi_rx_sf_pixel_cnt;  
reg [11:0] mipi_rx_sf_line_cnt;
reg [3:0]  mipi_rx_sf_frame_cnt;

wire [3:0] video_sel;

reg  [11:0] VIDEO_ROW_NUM;
reg  [11:0] VIDEO_COL_NUM;

wire [63:0] mipi_rx_vc_0_axis_tdata;
wire [9:0]  mipi_rx_vc_0_axis_tdest;
wire        mipi_rx_vc_0_axis_tlast;
wire        mipi_rx_vc_0_axis_tuser;     
wire        mipi_rx_vc_0_axis_tvalid;
wire [63:0] mipi_rx_vc_1_axis_tdata;
wire [9:0]  mipi_rx_vc_1_axis_tdest;
wire        mipi_rx_vc_1_axis_tlast;  
wire        mipi_rx_vc_1_axis_tuser;      
wire        mipi_rx_vc_1_axis_tvalid;
wire [63:0] mipi_rx_vc_2_axis_tdata;
wire [9:0]  mipi_rx_vc_2_axis_tdest;
wire        mipi_rx_vc_2_axis_tlast;   
wire        mipi_rx_vc_2_axis_tuser;      
wire        mipi_rx_vc_2_axis_tvalid;
wire [63:0] mipi_rx_vc_3_axis_tdata;
wire [9:0]  mipi_rx_vc_3_axis_tdest;
wire        mipi_rx_vc_3_axis_tlast;   
wire        mipi_rx_vc_3_axis_tuser;      
wire        mipi_rx_vc_3_axis_tvalid;	

always @ (posedge clk_i or negedge rst_n_i) begin
    if(~rst_n_i) begin
		VIDEO_ROW_NUM <= 12'd0;
		VIDEO_COL_NUM <= 12'd0;
	end
	else begin
		case(cam_type_i)
			4'd1:begin VIDEO_ROW_NUM <= 12'd800;  VIDEO_COL_NUM <= 12'd320; end
			4'd2:begin VIDEO_ROW_NUM <= 12'd1080; VIDEO_COL_NUM <= 12'd480; end
			4'd8:begin VIDEO_ROW_NUM <= 12'd2162; VIDEO_COL_NUM <= 12'd960; end
			default:begin VIDEO_ROW_NUM <= 12'd1080; VIDEO_COL_NUM <= 12'd480; end
		endcase
	end
end

assign mipi_rx_sf_axis_shake_ok = mipi_rx_sf_axis_tvalid_i & mipi_rx_sf_axis_tready_i;
assign mipi_rx_sf_line_end      = mipi_rx_sf_axis_shake_ok & mipi_rx_sf_axis_tlast_i;
assign mipi_rx_sf_frame_start   = mipi_rx_sf_axis_shake_ok & mipi_rx_sf_axis_tuser_i;
assign mipi_rx_sf_pixel_valid   = mipi_rx_sf_axis_shake_ok;

always @ (posedge clk_i or negedge rst_n_i) begin
    if(~rst_n_i)           				mipi_rx_sf_pixel_cnt <= 12'd0; 
	else if(mipi_rx_sf_line_end)		mipi_rx_sf_pixel_cnt <= 12'd0; 
    else if(mipi_rx_sf_pixel_valid)		mipi_rx_sf_pixel_cnt <= mipi_rx_sf_pixel_cnt + 12'd1; 
	else								mipi_rx_sf_pixel_cnt <= mipi_rx_sf_pixel_cnt;
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if(~rst_n_i)           				mipi_rx_sf_line_cnt <= 12'd0;
	else if(mipi_rx_sf_frame_start)		mipi_rx_sf_line_cnt <= 12'd0;
    else if(mipi_rx_sf_line_end)		mipi_rx_sf_line_cnt <= mipi_rx_sf_line_cnt + 12'd1;
	else								mipi_rx_sf_line_cnt <= mipi_rx_sf_line_cnt;
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if(~rst_n_i)           				mipi_rx_sf_frame_cnt <= 4'd0;
	else if(mipi_rx_sf_frame_start)		mipi_rx_sf_frame_cnt <= mipi_rx_sf_frame_cnt + 4'd1;
	else								mipi_rx_sf_frame_cnt <= mipi_rx_sf_frame_cnt;
end

assign mipi_rx_vc_0_axis_tdata  = ((mipi_rx_sf_pixel_cnt >= 12'd0) && (mipi_rx_sf_pixel_cnt <= VIDEO_COL_NUM - 12'd1)) ? mipi_rx_sf_axis_tdata_i : 64'd0;
assign mipi_rx_vc_0_axis_tdest  = 10'h1e0;	
assign mipi_rx_vc_0_axis_tlast  = (mipi_rx_sf_pixel_cnt == VIDEO_COL_NUM - 12'd1) ? 1'b1 : 1'b0;
assign mipi_rx_vc_0_axis_tuser  = mipi_rx_sf_axis_tuser_i;
assign mipi_rx_vc_0_axis_tvalid = ((mipi_rx_sf_pixel_cnt >= 12'd0) && (mipi_rx_sf_pixel_cnt <= VIDEO_COL_NUM - 12'd1)) ? mipi_rx_sf_axis_tvalid_i : 64'd0;

assign mipi_rx_vc_1_axis_tdata  = ((mipi_rx_sf_pixel_cnt >= VIDEO_COL_NUM) && (mipi_rx_sf_pixel_cnt <= VIDEO_COL_NUM*2 - 12'd1)) ? mipi_rx_sf_axis_tdata_i : 64'd0;
assign mipi_rx_vc_1_axis_tdest  = 10'h1e1;
assign mipi_rx_vc_1_axis_tlast  = (mipi_rx_sf_pixel_cnt == VIDEO_COL_NUM*2 - 12'd1) ? 1'b1 : 1'b0;
assign mipi_rx_vc_1_axis_tuser  = ((mipi_rx_sf_pixel_cnt == VIDEO_COL_NUM) && (mipi_rx_sf_line_cnt == 12'd0)) ? 1'b1 : 1'b0;
assign mipi_rx_vc_1_axis_tvalid = ((mipi_rx_sf_pixel_cnt >= VIDEO_COL_NUM) && (mipi_rx_sf_pixel_cnt <= VIDEO_COL_NUM*2 - 12'd1)) ? mipi_rx_sf_axis_tvalid_i : 64'd0;

assign mipi_rx_vc_2_axis_tdata  = ((mipi_rx_sf_pixel_cnt >= VIDEO_COL_NUM*2) && (mipi_rx_sf_pixel_cnt <= VIDEO_COL_NUM*3 - 12'd1)) ? mipi_rx_sf_axis_tdata_i : 64'd0;
assign mipi_rx_vc_2_axis_tdest  = 10'h1e2;
assign mipi_rx_vc_2_axis_tlast  = (mipi_rx_sf_pixel_cnt == VIDEO_COL_NUM*3 - 12'd1) ? 1'b1 : 1'b0;
assign mipi_rx_vc_2_axis_tuser  = ((mipi_rx_sf_pixel_cnt == VIDEO_COL_NUM*2) && (mipi_rx_sf_line_cnt == 12'd0)) ? 1'b1 : 1'b0;
assign mipi_rx_vc_2_axis_tvalid = ((mipi_rx_sf_pixel_cnt >= VIDEO_COL_NUM*2) && (mipi_rx_sf_pixel_cnt <= VIDEO_COL_NUM*3 - 12'd1)) ? mipi_rx_sf_axis_tvalid_i : 64'd0;

assign mipi_rx_vc_3_axis_tdata  = ((mipi_rx_sf_pixel_cnt >= VIDEO_COL_NUM*3) && (mipi_rx_sf_pixel_cnt <= VIDEO_COL_NUM*4 - 12'd1)) ? mipi_rx_sf_axis_tdata_i : 64'd0;
assign mipi_rx_vc_3_axis_tdest  = 10'h1e3;
assign mipi_rx_vc_3_axis_tlast  = (mipi_rx_sf_pixel_cnt == VIDEO_COL_NUM*4 - 12'd1) ? 1'b1 : 1'b0;
assign mipi_rx_vc_3_axis_tuser  = ((mipi_rx_sf_pixel_cnt == VIDEO_COL_NUM*3) && (mipi_rx_sf_line_cnt == 12'd0)) ? 1'b1 : 1'b0;
assign mipi_rx_vc_3_axis_tvalid = ((mipi_rx_sf_pixel_cnt >= VIDEO_COL_NUM*3) && (mipi_rx_sf_pixel_cnt <= VIDEO_COL_NUM*4 - 12'd1)) ? mipi_rx_sf_axis_tvalid_i : 64'd0;

assign video_sel = {mipi_rx_vc_3_axis_tvalid, mipi_rx_vc_2_axis_tvalid, mipi_rx_vc_1_axis_tvalid, mipi_rx_vc_0_axis_tvalid};

always @ (*) begin
	if(~rst_n_i)begin
		mipi_rx_sf_seg_axis_tdata_o  <= 64'd0;
		mipi_rx_sf_seg_axis_tdest_o  <= 10'd0;
		mipi_rx_sf_seg_axis_tlast_o  <= 1'b0;
		mipi_rx_sf_seg_axis_tuser_o  <= 1'b0;
		mipi_rx_sf_seg_axis_tvalid_o <= 1'b0;
	end
	else if(mipi_rx_sf_seg_en_i == 1'b0)begin
		mipi_rx_sf_seg_axis_tdata_o  <=  mipi_rx_sf_axis_tdata_i;   
		mipi_rx_sf_seg_axis_tdest_o  <=  mipi_rx_sf_axis_tdest_i;
		mipi_rx_sf_seg_axis_tlast_o  <=  mipi_rx_sf_axis_tlast_i; 
		mipi_rx_sf_seg_axis_tuser_o  <=  mipi_rx_sf_axis_tuser_i; 	
		mipi_rx_sf_seg_axis_tvalid_o <=  mipi_rx_sf_axis_tvalid_i;	
	end
	else begin
		case(video_sel)
			4'b0001:begin
						mipi_rx_sf_seg_axis_tdata_o  <= mipi_rx_vc_0_axis_tdata;
						mipi_rx_sf_seg_axis_tdest_o  <= mipi_rx_vc_0_axis_tdest;
						mipi_rx_sf_seg_axis_tlast_o  <= mipi_rx_vc_0_axis_tlast;
						mipi_rx_sf_seg_axis_tuser_o  <= mipi_rx_vc_0_axis_tuser;
						mipi_rx_sf_seg_axis_tvalid_o <= mipi_rx_vc_0_axis_tvalid;					
					end
			4'b0010:begin
						mipi_rx_sf_seg_axis_tdata_o  <= mipi_rx_vc_1_axis_tdata;
						mipi_rx_sf_seg_axis_tdest_o  <= mipi_rx_vc_1_axis_tdest;
						mipi_rx_sf_seg_axis_tlast_o  <= mipi_rx_vc_1_axis_tlast;
						mipi_rx_sf_seg_axis_tuser_o  <= mipi_rx_vc_1_axis_tuser;
						mipi_rx_sf_seg_axis_tvalid_o <= mipi_rx_vc_1_axis_tvalid;					
					end
			4'b0100:begin
						mipi_rx_sf_seg_axis_tdata_o  <= mipi_rx_vc_2_axis_tdata;
						mipi_rx_sf_seg_axis_tdest_o  <= mipi_rx_vc_2_axis_tdest;
						mipi_rx_sf_seg_axis_tlast_o  <= mipi_rx_vc_2_axis_tlast;
						mipi_rx_sf_seg_axis_tuser_o  <= mipi_rx_vc_2_axis_tuser;
						mipi_rx_sf_seg_axis_tvalid_o <= mipi_rx_vc_2_axis_tvalid;					
					end
			4'b1000:begin
						mipi_rx_sf_seg_axis_tdata_o  <= mipi_rx_vc_3_axis_tdata;
						mipi_rx_sf_seg_axis_tdest_o  <= mipi_rx_vc_3_axis_tdest;
						mipi_rx_sf_seg_axis_tlast_o  <= mipi_rx_vc_3_axis_tlast;
						mipi_rx_sf_seg_axis_tuser_o  <= mipi_rx_vc_3_axis_tuser;
						mipi_rx_sf_seg_axis_tvalid_o <= mipi_rx_vc_3_axis_tvalid;					
					end
			default:begin
				mipi_rx_sf_seg_axis_tdata_o  <= 64'd0;
				mipi_rx_sf_seg_axis_tdest_o  <= 10'd0;
				mipi_rx_sf_seg_axis_tlast_o  <= 1'b0;
				mipi_rx_sf_seg_axis_tuser_o  <= 1'b0;
				mipi_rx_sf_seg_axis_tvalid_o <= 1'b0;			
			end
		endcase
	end
end

endmodule