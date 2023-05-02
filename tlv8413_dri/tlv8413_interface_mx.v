/* *********************************************************************************** */
/* 模块名:DAC8413接口模块(复用方式)                                                    */
/* 版本号:V1.0.0                                                                       */
/* 发布时间:2022.11.03                                                                 */
/* 文件名:tlv8413_interface_mx                                                         */                           
/* 作者:徐家栋                                                                         */
/* 版权:中国科学院上海光学精密机械研究所航天激光工程部航天激光软件研发中心             */                     
/* 描述:该模块用于两片DAC8413的输出控制, 两片DAC8413除片选信号外的其他控制信号皆为复用 */                  
/*      ，通道0~通道3属于第一片DAC8413，通道4~通道7属于第二片DAC8413，DA输出的优先级   */
/*      为通道0>通道1>通道2>通道3>通道4>通道5>通道6>通道7，初始DA设置值为0，当通道DA设 */
/*      置值发生变化时，模块将会执行该通道的DA输出。                                   */
/* *********************************************************************************** */

module tlv8413_interface_mx  #( parameter clk_freq_hz = 22118400 )
( 
input         clk  ,           /* 系统时钟                      */
input         rst_n,           /* 系统复位信号 低电平有效       */
input  [7:0]  DAC8413_DB0,     /* 通道0 DA设置值                */               
input  [7:0]  DAC8413_DB1,     /* 通道1 DA设置值                */
input  [7:0]  DAC8413_DB2,     /* 通道2 DA设置值                */
input  [7:0]  DAC8413_DB3,     /* 通道3 DA设置值                */
input  [7:0]  DAC8413_DB4,     /* 通道4 DA设置值                */
input  [7:0]  DAC8413_DB5,     /* 通道5 DA设置值                */
input  [7:0]  DAC8413_DB6,     /* 通道6 DA设置值                */
input  [7:0]  DAC8413_DB7,     /* 通道7 DA设置值                */
output        DAC8413_RESET,   /* DAC8413 复位信号 低电平有效   */
output        DAC8413_RW,      /* DAC8413 读写信号 1：读 0：写  */
output        DAC8413_CS1,     /* DAC8413 片选信号1             */
output        DAC8413_CS2,     /* DAC8413 片选信号2             */
output        DAC8413_LDAC,    /* DAC8413 LDAC                  */
output        DAC8413_A1,      /* DAC8413 地址高位              */
output        DAC8413_A0,      /* DAC8413 地址低位              */
output [11:0] DAC8413_DB       /* DAC8413 DA输出值              */
);

/* parameter */
localparam CLK_PERIOD_NS  = 1000000000/clk_freq_hz;
localparam CS_CNT         = 500/CLK_PERIOD_NS;  // Twcs = 300ns  Twcs,min = 150ns
localparam LDAC_HIGH_CNT  = 300/CLK_PERIOD_NS;  
localparam LOAD_HOLD_CNT  = 300/CLK_PERIOD_NS;  // Tlh = 200ns   Tlh,min = 70ns
localparam LOAD_SETUP_CNT = 300/CLK_PERIOD_NS;  // Tls = 200ns   Tls,min = 50ns

/* statements */
reg        DAC_RESET;
reg        DAC_RW;
reg        DAC_CS;
reg        DAC_LDAC;
reg        DAC_A1;
reg        DAC_A0;
reg [7:0]  DAC_DB; 

reg [7:0] DAC8413_DB0_buf; 
reg [7:0] DAC8413_DB1_buf;
reg [7:0] DAC8413_DB2_buf;
reg [7:0] DAC8413_DB3_buf;
reg [7:0] DAC8413_DB4_buf;
reg [7:0] DAC8413_DB5_buf;
reg [7:0] DAC8413_DB6_buf;
reg [7:0] DAC8413_DB7_buf;

reg       da_sel;
reg [3:0] cnt;
reg [2:0] state /* synthesis syn_encoding = "safe" */ ;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)begin
        DAC8413_DB0_buf <= 8'd0;        
        DAC8413_DB1_buf <= 8'd0;       
        DAC8413_DB2_buf <= 8'd0;       
        DAC8413_DB3_buf <= 8'd0;       
        DAC8413_DB4_buf <= 8'd0;       
        DAC8413_DB5_buf <= 8'd0;       
        DAC8413_DB6_buf <= 8'd0;       
        DAC8413_DB7_buf <= 8'd0;       
        DAC_RESET       <= 1'b0;              
        DAC_RW          <= 1'b1;               
        DAC_CS          <= 1'b1;               
        DAC_LDAC        <= 1'b1;                
        DAC_A1          <= 1'b0;             
        DAC_A0          <= 1'b0;               
        DAC_DB          <= 8'd0;  
        cnt             <= 4'd0;
        state           <= 3'd0;
        da_sel          <= 1'b0;
    end else begin
    case(state)
    3'd0:begin
        DAC8413_DB0_buf <= DAC8413_DB0_buf;        
        DAC8413_DB1_buf <= DAC8413_DB1_buf;       
        DAC8413_DB2_buf <= DAC8413_DB2_buf;
        DAC8413_DB3_buf <= DAC8413_DB3_buf;      
        DAC8413_DB4_buf <= DAC8413_DB4_buf;      
        DAC8413_DB5_buf <= DAC8413_DB5_buf;      
        DAC8413_DB6_buf <= DAC8413_DB6_buf;      
        DAC8413_DB7_buf <= DAC8413_DB7_buf;      
        DAC_RESET       <= 1'b1;              
        DAC_RW          <= 1'b1;               
        DAC_CS          <= 1'b1;               
        DAC_LDAC        <= 1'b1;                
        DAC_A1          <= 1'b0;             
        DAC_A0          <= 1'b0;               
        DAC_DB          <= 8'd0;    
        cnt             <= 4'd0;
        state           <= 3'd1; 
        da_sel          <= 1'b0;
    end
    
    3'd1:begin
        if(DAC8413_DB0 != DAC8413_DB0_buf)begin
            DAC8413_DB0_buf <= DAC8413_DB0;   
            DAC_RW          <= 1'b1;            
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b0;             
            DAC_A0          <= 1'b0;               
            DAC_DB          <= DAC8413_DB0;  
            cnt             <= 4'd0;
            state           <= 3'd2;
            da_sel          <= 1'b0;
        end else if(DAC8413_DB1 != DAC8413_DB1_buf)begin
            DAC8413_DB1_buf <= DAC8413_DB1;    
            DAC_RW          <= 1'b1;          
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b0;             
            DAC_A0          <= 1'b1;               
            DAC_DB          <= DAC8413_DB1;   
            cnt             <= 4'd0;
            state           <= 3'd2;
            da_sel          <= 1'b0;
        end else if(DAC8413_DB2 != DAC8413_DB2_buf)begin
            DAC8413_DB2_buf <= DAC8413_DB2;  
            DAC_RW          <= 1'b1;              
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b1;             
            DAC_A0          <= 1'b0;               
            DAC_DB          <= DAC8413_DB2;   
            cnt             <= 4'd0;
            state           <= 3'd2;  
            da_sel          <= 1'b0;            
        end else if(DAC8413_DB3 != DAC8413_DB3_buf)begin
            DAC8413_DB3_buf <= DAC8413_DB3;  
            DAC_RW          <= 1'b1;                    
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b1;             
            DAC_A0          <= 1'b1;               
            DAC_DB          <= DAC8413_DB3;
            cnt             <= 4'd0;
            state           <= 3'd2; 
            da_sel          <= 1'b0;            
        end else if(DAC8413_DB4 != DAC8413_DB4_buf)begin
            DAC8413_DB4_buf <= DAC8413_DB4;  
            DAC_RW          <= 1'b1;                    
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b0;             
            DAC_A0          <= 1'b0;               
            DAC_DB          <= DAC8413_DB4;
            cnt             <= 4'd0;
            state           <= 3'd2;  
            da_sel          <= 1'b1;            
        end else if(DAC8413_DB5 != DAC8413_DB5_buf)begin
            DAC8413_DB5_buf <= DAC8413_DB5;  
            DAC_RW          <= 1'b1;                    
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b0;             
            DAC_A0          <= 1'b1;               
            DAC_DB          <= DAC8413_DB5;
            cnt             <= 4'd0;
            state           <= 3'd2;  
            da_sel          <= 1'b1;            
        end else if(DAC8413_DB6 != DAC8413_DB6_buf)begin
            DAC8413_DB6_buf <= DAC8413_DB6;  
            DAC_RW          <= 1'b1;                    
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b1;             
            DAC_A0          <= 1'b0;               
            DAC_DB          <= DAC8413_DB6;
            cnt             <= 4'd0;
            state           <= 3'd2;   
            da_sel          <= 1'b1;            
        end else if(DAC8413_DB7 != DAC8413_DB7_buf)begin
            DAC8413_DB7_buf <= DAC8413_DB7;  
            DAC_RW          <= 1'b1;                    
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b1;             
            DAC_A0          <= 1'b1;               
            DAC_DB          <= DAC8413_DB7;
            cnt             <= 4'd0;
            state           <= 3'd2;  
            da_sel          <= 1'b1;            
        end else begin
            DAC8413_DB0_buf <= DAC8413_DB0_buf;        
            DAC8413_DB1_buf <= DAC8413_DB1_buf;       
            DAC8413_DB2_buf <= DAC8413_DB2_buf;
            DAC8413_DB3_buf <= DAC8413_DB3_buf;       
            DAC8413_DB4_buf <= DAC8413_DB4_buf;       
            DAC8413_DB5_buf <= DAC8413_DB5_buf;       
            DAC8413_DB6_buf <= DAC8413_DB6_buf;       
            DAC8413_DB7_buf <= DAC8413_DB7_buf;       
            DAC_RESET       <= 1'b1;              
            DAC_RW          <= 1'b1;               
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                
            DAC_A1          <= 1'b0;             
            DAC_A0          <= 1'b0;               
            DAC_DB          <= 8'd0; 
            cnt             <= 4'd0;
            state           <= 3'd1;  
            da_sel          <= 1'b0;                      
        end 
    end

    3'd2:begin
            DAC_A1          <= DAC_A1;             
            DAC_A0          <= DAC_A0;               
            DAC_DB          <= DAC_DB;
        if(cnt < LDAC_HIGH_CNT)begin
            DAC_RW          <= 1'b1;               
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                                 
            cnt             <= cnt + 1'b1;
            state           <= 3'd2;    
        end else begin
            DAC_RW          <= 1'b1;               
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b0;                                
            cnt             <= 4'd0;
            state           <= 3'd3;    
        end
    end 

    3'd3:begin
            DAC_A1          <= DAC_A1;             
            DAC_A0          <= DAC_A0;               
            DAC_DB          <= DAC_DB;
        if(cnt < LOAD_SETUP_CNT)begin
            DAC_RW          <= 1'b1;               
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b0;                                 
            cnt             <= cnt + 1'b1;
            state           <= 3'd3;    
        end else begin
            DAC_RW          <= 1'b0;               
            DAC_CS          <= 1'b0;               
            DAC_LDAC        <= 1'b0;                                
            cnt             <= 4'd0;
            state           <= 3'd4;    
        end
    end

    3'd4:begin
            DAC_A1          <= DAC_A1;             
            DAC_A0          <= DAC_A0;               
            DAC_DB          <= DAC_DB;
        if(cnt < CS_CNT)begin
            DAC_RW          <= 1'b0;               
            DAC_CS          <= 1'b0;               
            DAC_LDAC        <= 1'b0;                                 
            cnt             <= cnt + 1'b1;
            state           <= 3'd4;    
        end else begin
            DAC_RW          <= 1'b1;               
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b0;                                
            cnt             <= 4'd0;
            state           <= 3'd5;    
        end
    end

    3'd5:begin
            DAC_A1          <= DAC_A1;             
            DAC_A0          <= DAC_A0;               
            DAC_DB          <= DAC_DB;
        if(cnt < LOAD_HOLD_CNT)begin
            DAC_RW          <= 1'b1;               
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b0;                                 
            cnt             <= cnt + 1'b1;
            state           <= 3'd5;    
        end else begin
            DAC_RW          <= 1'b1;               
            DAC_CS          <= 1'b1;               
            DAC_LDAC        <= 1'b1;                                
            cnt             <= 4'd0;
            state           <= 3'd0;    
        end
    end

    default : state           <= 3'd0;
    endcase
    end
end

assign DAC8413_RESET = DAC_RESET;           
assign DAC8413_RW    = DAC_RW;                         
assign DAC8413_LDAC  = DAC_LDAC;            
assign DAC8413_A1    = DAC_A1;                
assign DAC8413_A0    = DAC_A0;                
assign DAC8413_DB    = {DAC_DB, 4'd0};  
assign {DAC8413_CS2, DAC8413_CS1} = da_sel?{DAC_CS,1'b1}:{1'b1,DAC_CS};            

endmodule