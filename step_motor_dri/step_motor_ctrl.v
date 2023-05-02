/* *********************************************************************************** */
/* 模块名:步进电机控制模块                                                             */
/* 版本号:V1.0.0                                                                       */
/* 发布时间:2022.11.03                                                                 */
/* 文件名:step_motor_ctrl                                                              */         
/* 作者:徐家栋                                                                         */
/* 版权:中国科学院上海光学精密机械研究所航天激光工程部航天激光软件研发中心             */                   
/* 描述:控制步进电机，收到电机启动信号后，电机首先回零位(右限位)，到达零位后电机向左步 */
/*      进(步进量*8)个脉冲，到达指定位置后停止，模块可以配置电机的速度。               */
/* *********************************************************************************** */
module step_motor_ctrl
#( parameter motor_speed = 13,                /* 电机速度，单位：Hz      */
   parameter clk_freq    = 100)               /* 系统时钟频率，单位：MHz */
(
    input   wire       sys_clk            ,   /* 系统时钟                */
    input   wire       rst_n              ,   /* 复位信号，0：有效       */
    input   wire       motor_start        ,   /* 电机启动信号，1：有效   */
    input   wire [7:0] step_volumn_i      ,   /* 电机步进量              */
    input   wire       left_limit_sig_i   ,   /* 电机左限位              */
    input   wire       right_limit_sig_i  ,   /* 电机右限位              */
    output  wire       step_motor_dir_a_o ,   /* 电机dira信号            */
    output  wire       step_motor_dir_b_o ,   /* 电机dirb信号            */
    output  wire       step_motor_pwm_a_o ,   /* 电机pwma信号            */
    output  wire       step_motor_pwm_b_o     /* 电机pwmb信号            */
);


parameter idle = 4'd1;
parameter limit_sig_receive = 4'd2;
parameter goto_destination = 4'd3;

reg        step_motor_dir_a;
reg        step_motor_dir_b;
reg        step_motor_pwm_a;
reg        step_motor_pwm_b;
reg [3:0]  pr_state; /* synthesis syn_encoding = "safe" */
reg [3:0]  nx_state; /* synthesis syn_encoding = "safe" */
reg        left_drive;
reg        right_drive;
reg        arrive_destination;
reg [7:0]  step_motor_en;
reg [11:0] step_volumn_r;
reg        pulse_cnt_en;
reg [11:0] pulse_cnt;
reg        step_motor_dir_a_d0;
reg        step_motor_dir_a_d1;
reg        cnt_1s_delay_en;
reg [27:0] cnt_1s_delay;

/* 1s delay */
always@(posedge sys_clk or negedge rst_n)
    begin
        if(~rst_n)  cnt_1s_delay <= 28'd0;
        else if(cnt_1s_delay_en)
			 if(cnt_1s_delay == 28'd999999)   cnt_1s_delay <= 28'd0;
			 else                             cnt_1s_delay <= cnt_1s_delay + 1;
        else                               cnt_1s_delay <= 28'd0;
    end

/* state machine */
always@(posedge sys_clk or negedge rst_n)
    begin
       if(~rst_n) pr_state <= idle;
       else       pr_state <= nx_state;
    end
    
always@(*)
    begin
        case(pr_state)
            idle:
            begin
               if(motor_start)  nx_state = limit_sig_receive;
               else 					   nx_state = idle;
            end
				
            limit_sig_receive:
            begin
               if(right_limit_sig_i == 1'b1)  nx_state = goto_destination;
               else                           nx_state = limit_sig_receive;
            end
				
            goto_destination:
            begin
               if(arrive_destination)             nx_state = idle;
               else if(left_limit_sig_i == 1'b1)  nx_state = idle;
               else                               nx_state = goto_destination;
            end
            default: nx_state = idle;
         endcase
    end
    
always@(posedge sys_clk or negedge rst_n)
    begin
        if(~rst_n) 
			  begin
					step_motor_en   <= 8'h00;
					pulse_cnt_en    <= 1'b0;
					left_drive      <= 1'b0;
					right_drive     <= 1'b0;
					cnt_1s_delay_en <= 1'b0;
			  end
        else 
			  begin
					case(pr_state) 
						 idle:
						 begin
							  pulse_cnt_en    <= 1'b0;
							  step_motor_en   <= 8'h00;
							  left_drive      <= 1'b0;
							  right_drive     <= 1'b0;
							  cnt_1s_delay_en <= 1'b0;
						 end
						 
						 limit_sig_receive:
						 begin
							  step_motor_en <= 8'hAA;
							  right_drive   <= 1'b1;
							  left_drive    <= 1'b0;
						 end
						 
						 goto_destination:
						 begin
							  cnt_1s_delay_en <= 1'b0;
							  step_motor_en   <= 8'hAA;
							  right_drive     <= 1'b0;
							  left_drive      <= 1'b1;
							  pulse_cnt_en    <= 1'b1;
						 end
						 default:begin
										step_motor_en   <= 8'h00;
										pulse_cnt_en    <= 1'b0;
										left_drive      <= 1'b0;
										right_drive     <= 1'b0;
										cnt_1s_delay_en <= 1'b0;
									end
				  endcase 
			  end
      end
 
always@(posedge sys_clk or negedge rst_n)
 begin
	  if(~rst_n)
		  begin
				step_motor_dir_a_d0 <= 1'b0;
				step_motor_dir_a_d1 <= 1'b1;
		  end
	  else 
		  begin
				step_motor_dir_a_d0 <= step_motor_dir_a;
				step_motor_dir_a_d1 <= step_motor_dir_a_d0;
		  end
 end
 
always@(posedge sys_clk or negedge rst_n)
 begin
	  if(~rst_n)  step_volumn_r <= 12'd0;
	  else        step_volumn_r <= (step_volumn_i<<3);
 end
 
always@(posedge sys_clk or negedge rst_n)
 begin
	  if(~rst_n)
		  begin
				pulse_cnt <= 12'd0;
				arrive_destination <= 1'b0;
		  end
	  else if(pulse_cnt_en)
			if(pulse_cnt == step_volumn_r)
				begin
					 arrive_destination <= 1'b1;
					 pulse_cnt          <= 12'd0;
				end
			else if(step_motor_dir_a_d1 == 1'b1 && step_motor_dir_a_d0 == 1'b0)
				begin
					 pulse_cnt          <= pulse_cnt + 1;
					 arrive_destination <= 1'b0;
				end
			else 
				begin
					 pulse_cnt          <= pulse_cnt;
					 arrive_destination <= 1'b0;
				end
	  else 
		  begin
				pulse_cnt <= 12'd0;
				arrive_destination <= 1'b0;
		  end   
 end
 

 
reg [23:0]  speed_count_num;
reg [1:0]   drive_state;
 
always@(posedge sys_clk or negedge rst_n)
 begin
	  if(~rst_n)
		  begin
				speed_count_num <= 24'd0;
				drive_state     <= 2'b10;
		  end
	  else if(step_motor_en == 8'hAA )
			if(speed_count_num == 250000*clk_freq/motor_speed - 24'd1)
				begin
					 speed_count_num  <= 24'd0;
					 if(left_drive)        drive_state <= drive_state + 1;
					 else if(right_drive)  drive_state <= drive_state - 1;
					 else                  drive_state <= drive_state;
				end
			else  speed_count_num <= speed_count_num + 1;
	  else 
		  begin
				drive_state <= 2'b10;
				speed_count_num <=24'd0;
		  end
 end
    
reg [1:0] step_motor_out;

always@(posedge sys_clk or negedge rst_n)
    begin
        if(~rst_n)  step_motor_out <= 2'b00;
        else if(step_motor_en == 8'hAA)
			  begin
					case (drive_state)
						 2'b00: step_motor_out <= 2'b11;
						 2'b01: step_motor_out <= 2'b01;
						 2'b10: step_motor_out <= 2'b00;
						 2'b11: step_motor_out <= 2'b10;
						 default: step_motor_out <= step_motor_out;
					endcase
			  end
        else step_motor_out <= 2'b00;
    end
 
always@(posedge sys_clk or negedge rst_n)
    begin
        if(~rst_n)
			  begin
					step_motor_dir_a <= 1'b0;
					step_motor_dir_b <= 1'b0;
					step_motor_pwm_a <= 1'b0;
					step_motor_pwm_b <= 1'b0;
			  end
        else if(step_motor_en == 8'hAA )
			  begin
					step_motor_dir_a <= step_motor_out[0];
					step_motor_dir_b <= step_motor_out[1];
					step_motor_pwm_a <= 1'b1;
					step_motor_pwm_b <= 1'b1;
			  end
        else 
			  begin
					step_motor_dir_a <= 1'b0;
					step_motor_dir_b <= 1'b0;
					step_motor_pwm_a <= 1'b0;
					step_motor_pwm_b <= 1'b0;
			  end
    end

assign step_motor_dir_a_o = step_motor_dir_a;
assign step_motor_dir_b_o = step_motor_dir_b;
assign step_motor_pwm_a_o = step_motor_pwm_a;
assign step_motor_pwm_b_o = step_motor_pwm_b;

 endmodule