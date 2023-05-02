`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SIOM
// Engineer: qian
// 
// Create Date: 2020å¹?9æœ?2æ—?
// Design Name: 
// Module Name: AD7846_Module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 	AD7846 output processs ,before DAC register being valid the output value have checked ,if check failure will resend once
//	sysclk as 40MHz
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module AD7846_Module #(
	parameter CLK_FR = 40	// min 10MHz , max 500MHz
)
(
	input				sysclk		,
	input				rst			,

	output	[15:0]		DATA_o		,
	input	[15:0]		DATA_i		,
	output				RW			,
	output				CS			,
	output				CLR			,
	output				LDAC		,
	
	input	[15:0]		dac_data	,
	input				dac_valid	,
	output				dac_ready	
);
	// --------- AD7846 Timing Parameter ---------
	localparam	PERIOD	= 1000/CLK_FR;
	localparam	T2	= 200;
	localparam	T12	= 400;
	localparam	T11	= 200;

	localparam	IDLE	= 2'b00;
	localparam	DATA	= 2'b01;
	localparam	LATCH	= 2'b11;



	reg		[1:0]		state;
	reg		[1:0]		next_state;
	
	reg		[15:0]		dac_reg;
	reg		[7:0]		time_counter;
	reg					dac_ready_r;
	reg                 dac_valid_buff1;
	//delay one clock//
	always @(posedge sysclk) begin
        if(rst) begin
           dac_valid_buff1 <= 1'b0;
        end else begin
           dac_valid_buff1 <= dac_valid;
        end
	end

	// --------- FSM ---------
	always @(*) begin
		next_state = state;
		case (state)
			IDLE : begin
				if ((1 == dac_valid) && (0 == dac_valid_buff1))
					next_state = DATA;
			end
			DATA : begin
				if (time_counter >= (T2/PERIOD))
					next_state = LATCH;
			end
			LATCH : begin
				if (time_counter >= (T11/PERIOD))
					next_state = IDLE;
			end
			default : begin
				next_state = IDLE;
			end
		endcase
	end
	
	always @(posedge sysclk) begin
		if (rst)
			state <= IDLE;
		else 
			state <= next_state;
	end
	
	always @(posedge sysclk) begin
		if (rst) begin
			dac_reg <= 16'h8000;	//initial data//
		end
		else begin
			if ((state == IDLE) && (1 == dac_valid) && (0 == dac_valid_buff1))
				dac_reg <= dac_data;
		end
	end
	
	always @(posedge sysclk) begin
		if (rst) begin
			dac_ready_r <= 0;
		end
		else begin
			if (next_state == IDLE)
				dac_ready_r <= 1'b1;
			else
				dac_ready_r <= 0;
		end
	end
	
	assign dac_ready = dac_ready_r;	
	
	always @(posedge sysclk) begin
		if (rst) begin
			time_counter <= 0;
		end
		else begin
			if (state == IDLE)
				time_counter <= 0;
			else if (state != next_state)
				time_counter <= 0;
			else
				time_counter <= time_counter + 1;
		end
	end
	
	assign DATA_o = dac_reg;
	assign RW = ~((state == DATA) & (time_counter > 0) & (time_counter <= (T2/PERIOD)));
	assign CS = ~((state == DATA) & ((time_counter > 0) & (time_counter <= (T2/PERIOD))));
	assign LDAC = ~((state == LATCH) && ((time_counter > 0) & (time_counter <= (T11/PERIOD))));
	assign CLR = 1'b1;

endmodule