module mipi_tx_data_gen
#(
	parameter VIDEO_WIDTH  			= 16'd1920,
	parameter VIDEO_HEIGHT 			= 16'd4320,
	parameter VIDEO_LINE_INTERVAL 	= 32'd15000,   // ns
	parameter VIDEO_FRAME_INTERVAL 	= 32'd20000000 //ns
)
(
	input          clk_i                          ,
	input          rst_n_i                        ,
	input          gen_en_i                       ,
	input          mipi_tx_axis_ready_i           ,
	output  [63:0] mipi_tx_axis_video_gen_data_o  ,
	output  	   mipi_tx_axis_video_gen_valid_o ,
	output  	   mipi_tx_axis_video_gen_last_o  ,
	output  [95:0] mipi_tx_axis_video_gen_user_o  ,
	output  [9:0]  mipi_tx_axis_video_gen_dest_o  
);

reg [63:0]  mipi_tx_axis_video_gen_data  = 64'h0000_0000_0000_000a;
reg 	    mipi_tx_axis_video_gen_valid ;
reg [95:0]  mipi_tx_axis_video_gen_user;

reg [15:0] video_gen_line_cnt;
reg [15:0] video_gen_pixel_cnt;
reg [15:0] video_gen_frame_cnt;
reg [31:0] wait_cnt;

reg [3:0]  state;

localparam video_gen_st1 = 4'b0001;
localparam video_gen_st2 = 4'b0010;
localparam video_gen_st3 = 4'b0100;
localparam video_gen_st4 = 4'b1000;

always @(posedge clk_i or negedge rst_n_i)begin
	if(!rst_n_i)begin
		state 						 <= video_gen_st1;
		mipi_tx_axis_video_gen_valid <= 1'b0;
		video_gen_pixel_cnt          <= 16'd0;
		video_gen_line_cnt           <= 16'd0;
		video_gen_frame_cnt          <= 16'd0;
		wait_cnt		             <= 32'd0;
	end
	else begin
		case(state)
			
			video_gen_st1: begin
				mipi_tx_axis_video_gen_valid <= 1'b0;
				video_gen_pixel_cnt          <= 16'd0;
				video_gen_line_cnt           <= 16'd0;
				wait_cnt		             <= 32'd0;
				if(gen_en_i) state <= video_gen_st2;
				else		 state <= video_gen_st1;	
			end
			
			video_gen_st2: begin     // frame interval
				if(wait_cnt == VIDEO_FRAME_INTERVAL/5 - 1)	state <= video_gen_st3;
				else										state <= video_gen_st2;
				wait_cnt <= wait_cnt + 32'd1;
			end
			
			video_gen_st3:begin      // send one-line data
				wait_cnt <= 32'd0;
				if((video_gen_pixel_cnt == VIDEO_WIDTH/4 - 1) && mipi_tx_axis_video_gen_valid && mipi_tx_axis_ready_i)	mipi_tx_axis_video_gen_valid <= 1'b0;
				else																									mipi_tx_axis_video_gen_valid <= 1'b1;				
				if(mipi_tx_axis_video_gen_valid & mipi_tx_axis_ready_i)													video_gen_pixel_cnt  <= video_gen_pixel_cnt + 16'd1;
				else												    												video_gen_pixel_cnt  <= video_gen_pixel_cnt;
				if((video_gen_pixel_cnt == VIDEO_WIDTH/4 - 1) && mipi_tx_axis_video_gen_valid && mipi_tx_axis_ready_i)	state <= video_gen_st4;
				else																									state <= video_gen_st3;
				if((video_gen_pixel_cnt == VIDEO_WIDTH/4 - 1) && mipi_tx_axis_video_gen_valid && mipi_tx_axis_ready_i)	video_gen_line_cnt 	<= video_gen_line_cnt + 16'd1;
				else																									video_gen_line_cnt  <= video_gen_line_cnt;				
			end
			
			video_gen_st4:begin		// line interval
				video_gen_pixel_cnt <= 16'd0;
				if((wait_cnt == VIDEO_LINE_INTERVAL/5 - 1) && (video_gen_line_cnt == VIDEO_HEIGHT))	     begin video_gen_frame_cnt <= video_gen_frame_cnt + 1; state <= video_gen_st1; end
				else if((wait_cnt == VIDEO_LINE_INTERVAL/5 - 1) && (video_gen_line_cnt != VIDEO_HEIGHT)) state <= video_gen_st3;
				else                                                                                     state <= video_gen_st4;
				wait_cnt <= wait_cnt + 32'd1;
			end
			
			default:;
		endcase	
	end
end

assign mipi_tx_axis_video_gen_last_o    = ((video_gen_pixel_cnt == VIDEO_WIDTH/4 - 1) && mipi_tx_axis_video_gen_valid && mipi_tx_axis_ready_i) ? 1 : 0;
assign mipi_tx_axis_video_gen_user_o    = ((video_gen_pixel_cnt == 16'd0) && (video_gen_line_cnt == 16'd0) && mipi_tx_axis_video_gen_valid && mipi_tx_axis_ready_i) ? 96'h0000001e0f00_000000000001 : 96'h0000001e0f00_000000000000;
assign mipi_tx_axis_video_gen_dest_o    = (video_gen_line_cnt[1:0] == 2'd0) ? 10'h1e0 : (video_gen_line_cnt[1:0] == 2'd1) ? 10'h1e1 : (video_gen_line_cnt[1:0] == 2'd2) ? 10'h1e2 :(video_gen_line_cnt[1:0] == 2'd3) ? 10'h1e3 : 10'd0;
//assign mipi_tx_axis_video_gen_dest_o    =  10'h1e0;
assign mipi_tx_axis_video_gen_data_o    =  mipi_tx_axis_video_gen_data;
assign mipi_tx_axis_video_gen_valid_o   =  mipi_tx_axis_video_gen_valid;

endmodule