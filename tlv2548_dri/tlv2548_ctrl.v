module tlv2548_ctrl
    #(
        parameter  clk_freq_hz                      = 32'd22118400,  /* 系统时钟频率，单位：Hz                                                                          */
        parameter  sample_time_ns             		= 32'd10_0000,   /* 通道切换间隔，单位：ns                                                                          */
        parameter  refernce                         = 1'b0,          /* 参考电压，0:外部，1：内部                                                                       */
        parameter  Internal_reference_voltage       = 1'b0,          /* 内部参考电压选择，0:4V，1：2V                                                                   */
        parameter  sample_period                    = 1'b0,          /* 采样周期选择，0:短采样，1：长采样                                                               */
        parameter  conversion_clk_source            = 2'b01,         /* 转换时钟源，00：内部晶振，01：SCLK，10：SCLK/4，11：SCLK/2                                      */
        parameter  conversion_mode                  = 2'b00,         /* 转换模式选择，00：单次模式，01：重复模式，10：平扫模式，11：重复平扫模式                        */  
        parameter  sweep_auto_sequence              = 2'b00,         /* 平扫模式顺序，00:0-1-2-3-4-5-6-7，01：0?2?4?6?0?2?4?6，10：0?0?2?2?4?4?6?6，11：0?2?0?2?0?2?0?2 */
        parameter  pin_function                     = 1'b0,          /* tlv2548_eoc_in引脚功能定义，0：用作接收中断，1：用作EOC                                         */
        parameter  FIFO_trigger_level               = 2'b00          /* FIFO触发条件，00：Full，01：3/4FULL，10：1/2FULL，11：1/4FULL                                   */
        
    )(
        
        //phy_interface
        output          tlv2548_cs_n_out,           /* TLV2548 CS                   */
        output          tlv2548_sclk_out,           /* TLV2548 SCLK                 */
        output          tlv2548_sdata_out,          /* TLV2548 MOSI                 */
        input           tlv2548_sdata_in,           /* TLV2548 MISO                 */
        output          tlv2548_cstartn_out,        /* TLV2548 CSTART               */
        input           tlv2548_eoc_in,             /* TLV2548 EOC                  */
        output 			tlv2548_pwdn_out,           /* TLV2548 POWERDOWN            */
        output  [11:0]  tlv2548_data_ch0,           /* TLV2548 通道0输出            */
        output  [11:0]  tlv2548_data_ch1,           /* TLV2548 通道1输出            */
        output  [11:0]  tlv2548_data_ch2,           /* TLV2548 通道2输出            */
        output  [11:0]  tlv2548_data_ch3,           /* TLV2548 通道3输出            */
        output  [11:0]  tlv2548_data_ch4,           /* TLV2548 通道4输出            */
        output  [11:0]  tlv2548_data_ch5,           /* TLV2548 通道5输出            */
        output  [11:0]  tlv2548_data_ch6,           /* TLV2548 通道6输出            */
        output  [11:0]  tlv2548_data_ch7,           /* TLV2548 通道7输出            */
        input           clk,                        /* 系统时钟                     */
        input           rstn                        /* 复位信号 低电平有效          */
    );
    
    localparam      clk_div_set_for_spi  = clk_freq_hz/4000000;
    localparam  	sample_clk_cycle_cnt = sample_time_ns/(1000000000/clk_freq_hz);
    
    localparam      IDLE             = 16'h00;
    localparam      CONFIG_INIT      = 16'h01;
    localparam      CONFIG           = 16'h02;
    localparam      CONFIG_READ      = 16'h03;
    localparam      CONFIG_JUDGE     = 16'h04;
    
    localparam      CHANEL_SELECT    = 16'h05;
    localparam      CHANEL_TRIG      = 16'h06;
    localparam      CONV_READ        = 16'h07;
    
    localparam      SAMPLE_WAIT      = 16'h30;

    
    localparam      Transition1     = 16'h10;
    localparam      Transition2     = 16'h11;
    localparam      Transition3     = 16'h12;
    localparam      Transition4     = 16'h13;
    localparam      Transition5     = 16'h14;
    
    localparam      Receive1        = 16'h15;
    localparam      Receive2        = 16'h16;
    localparam      Receive3        = 16'h17;
    localparam      Receive4        = 16'h18;
    localparam      Receive5        = 16'h19;
    
    reg  [15:0]     current_state;
    reg  [15:0]     next_state;
    
    reg    [29:0]   spi_parallel_data;
    reg             trig_spi;
    wire            trig_rdy;    
    wire            spi_trams_done;    
    wire            spi_rd_data_vaild;
    wire   [29:0]   spi_rd_data_out; 

    
    
    reg [4:0] delay_cnt;
    reg       delay_en;
    
    wire      conv_done;
    
    reg       int_reg1;
    reg       int_reg2;
    reg       int_reg3;

    
    reg  [2:0]  current_channel;
    
    
    reg  [11:0] adc_buffer;
    reg  [11:0] adc_ch0;
    reg  [11:0] adc_ch1;
    reg  [11:0] adc_ch2;
    reg  [11:0] adc_ch3;
    reg  [11:0] adc_ch4;
    reg  [11:0] adc_ch5;
    reg  [11:0] adc_ch6;
    reg  [11:0] adc_ch7;
    
    reg  [31:0]cycle_cnt;
    
    always @ (posedge clk)begin
        int_reg1 <= tlv2548_eoc_in;
        int_reg2 <= int_reg1;
        int_reg3  <= int_reg2;
    end
    //转换完成信号
    assign conv_done    =  ~int_reg3; //高电平有效
    
    always @ (posedge clk)begin
        if(!rstn)begin
            cycle_cnt <= 32'd0;
        end
        else if(current_state == CHANEL_SELECT)begin
            cycle_cnt <= 32'd0;
        end
        else begin
            cycle_cnt <= cycle_cnt + 1'b1;
        end   
    end
    
    
    always @ (posedge clk)begin
        if(!rstn)begin
            delay_cnt <= 5'd0;
        end
        else if(delay_en)begin
            delay_cnt <= delay_cnt + 1'b1;
        end
        else begin
            delay_cnt <= 5'd0;
        end   
    end
    always @(posedge clk)begin
        if(!rstn)begin
            current_state            <= IDLE;
            next_state               <= IDLE;
            trig_spi                 <= 1'b0;
            spi_parallel_data        <= 30'd0;
            delay_en                 <= 1'b0;
            current_channel          <= 3'd0;
            adc_buffer               <= 12'd0;
        end
        else begin
            case (current_state)
                IDLE ://16'h00
                    begin
                        current_state            <= CONFIG_INIT;
                        trig_spi                 <= 1'b0;
                        spi_parallel_data        <= 30'd0;
                    end
                CONFIG_INIT ://16'h01
                    begin
                        current_state            <= Transition1;
                        next_state               <= CONFIG;
                        trig_spi                 <= 1'b0;
                        spi_parallel_data        <= {16'hA000,14'd0};
                    end
                CONFIG ://16'h02
                    begin
                        current_state            <= Transition1;
                        next_state               <= CONFIG_READ;
                        trig_spi                 <= 1'b0;
                        spi_parallel_data        <= {4'hA,refernce,Internal_reference_voltage,sample_period,conversion_clk_source,conversion_mode,sweep_auto_sequence,pin_function, FIFO_trigger_level,14'd0};
                    end
                CONFIG_READ : //16'h03
                    begin
                            current_state            <= Receive1;
                            next_state               <= CONFIG_JUDGE;
                            trig_spi                 <= 1'b0;
                            spi_parallel_data        <= {4'hA,refernce,Internal_reference_voltage,sample_period,conversion_clk_source,conversion_mode,sweep_auto_sequence,pin_function, FIFO_trigger_level,14'd0};                                  
                    end
                CONFIG_JUDGE : //16'h04
                    begin  
                       // if(adc_buffer[11:0] == {refernce,Internal_reference_voltage,sample_period,conversion_clk_source,conversion_mode,sweep_auto_sequence,pin_function, FIFO_trigger_level})
                            current_state            <= CHANEL_SELECT; 
                        //else 
                        //    current_state            <= CONFIG;
                    end
                /////////////////////////////////////////////////////////////////////////////////////////////
                CHANEL_SELECT :
                    begin
                        current_state            <= CHANEL_TRIG;
                        current_channel          <= current_channel + 1'b1;
                    end
                                          
                CHANEL_TRIG :
                    begin
                        current_state            <= Receive1;
                        next_state               <= CONV_READ;
                        trig_spi                 <= 1'b0;
                        spi_parallel_data        <= {1'b0,current_channel,26'd0};
                    end                    
                CONV_READ :
                    begin
                        if(conv_done)
                            current_state            <= SAMPLE_WAIT;
                        else 
                            current_state            <= CONV_READ;
                    end                     
          
                
                SAMPLE_WAIT : 
                    begin
                        if(cycle_cnt == sample_clk_cycle_cnt)begin//采样周期
                             current_state               <= CHANEL_SELECT;
                        end
                        else if(cycle_cnt[31])begin
                             current_state               <= CHANEL_SELECT;
                        end
                        else begin
                            current_state               <=SAMPLE_WAIT;
                        end
                    end
                                                                    
                //传输状态机    
                Transition1 : //16'h10
                    begin
                        trig_spi                 <= 1'b1;
                        current_state            <= Transition2;
                    end
                Transition2 : //16'h11
                    begin
                        trig_spi                 <= 1'b0;
                        if(spi_trams_done)begin
                            current_state            <= Transition3;
                        end
                    end
                Transition3 : //16'h12
                    begin
                        delay_en                 <= 1'b1;
                        current_state            <= Transition4;
                    end
                Transition4 : //16'h13
                    begin
                        if(delay_cnt[4])begin
                            current_state            <= Transition5;
                        end
                    end
                Transition5 : //16'h14
                    begin
                        delay_en                 <= 1'b0;
                        current_state            <= next_state;
                    end
                    
              //接收    
               Receive1 : 
                   begin
                       trig_spi                 <= 1'b1;
                       current_state            <= Receive2;
                   end
               Receive2 : 
                   begin
                       trig_spi                 <= 1'b0;
                       if(spi_rd_data_vaild)begin
                           adc_buffer           <= spi_rd_data_out[29:18]; 
                           current_state        <= Receive3;
                       end
                   end
               Receive3 : 
                   begin
                       delay_en                 <= 1'b1;
                       current_state            <= Receive4;
                   end
               Receive4 : 
                   begin
                       if(delay_cnt[4])begin
                           current_state        <= Receive5;
                       end
                   end
               Receive5 : 
                   begin
                       delay_en                 <= 1'b0;
                       current_state            <= next_state;
                   end
                default : 
                    begin
                        current_state            <= IDLE;
                    end
            endcase
        end
    end
    
    
    always @(posedge clk)begin
        if(spi_rd_data_vaild)begin
            case(current_channel)
            	3'd0 :  adc_ch7 <= spi_rd_data_out [29:18];
				3'd1 :  adc_ch0 <= spi_rd_data_out [29:18];
            	3'd2 :  adc_ch1 <= spi_rd_data_out [29:18];
           		3'd3 :  adc_ch2 <= spi_rd_data_out [29:18];
            	3'd4 :  adc_ch3 <= spi_rd_data_out [29:18];
				3'd5 :  adc_ch4 <= spi_rd_data_out [29:18];
				3'd6 :  adc_ch5 <= spi_rd_data_out [29:18];
				3'd7 :  adc_ch6 <= spi_rd_data_out [29:18];
				default :;	            		     
            endcase             
        end
    end     
    
    spi_interface 
    #(
        .clk_div_set_for_spi(clk_div_set_for_spi),
        .parallel_data_length(30)
    )
    tlv2548_spi_interface(
        .clk(clk), 
        .rstn(rstn), 
        .trig_in(trig_spi), 
        .trig_rdy(trig_rdy), 
        .spi_trams_done(spi_trams_done), 
        .parallel_data_in(spi_parallel_data),//后14位用于14个时钟的ADC采样 
        .spi_rd_data_out(spi_rd_data_out), 
        .spi_rd_data_vaild(spi_rd_data_vaild), 
        
        .spi_sdata_in(tlv2548_sdata_in), 
        .spi_cs_n_out(tlv2548_cs_n_out), 
        .spi_sclk_out(tlv2548_sclk_out), 
        .spi_sdata_out(tlv2548_sdata_out)
    );
    
     assign  tlv2548_cstartn_out = 1'b1;
     assign	 tlv2548_pwdn_out    = 1'b1;
     assign  tlv2548_data_ch0    = adc_ch0;
     assign  tlv2548_data_ch1    = adc_ch1;
     assign  tlv2548_data_ch2    = adc_ch2;
     assign  tlv2548_data_ch3    = adc_ch3;
     assign  tlv2548_data_ch4    = adc_ch4;
     assign  tlv2548_data_ch5    = adc_ch5;
     assign  tlv2548_data_ch6    = adc_ch6;
     assign  tlv2548_data_ch7    = adc_ch7;
     
endmodule
