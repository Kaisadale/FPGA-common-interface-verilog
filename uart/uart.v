/* *********************************************************************************** */
/* 模块名:UART发送接收模块                                                             */
/* 版本号:V1.0.0                                                                       */
/* 发布时间:2022.11.03                                                                 */
/* 文件名:uart                                                                         */                  
/* 作者:徐家栋                                                                         */
/* 版权:中国科学院上海光学精密机械研究所航天激光工程部航天激光软件研发中心             */                   
/* 描述:该模块用于UART的发送和接收，模块中可以配置发送接收的波特率、是否有校验位、     */
/*      校验方式。                                                                     */                                                                      
/* *********************************************************************************** */
module uart 
#(
parameter clk_freq_hz  = 32'd22118400 ,
parameter baudrate     = 20'd115200   ,
parameter sel_check    = 1            ,
parameter parity_check = 1
)

(
input  wire        clk               ,  /* 系统时钟                         */
input  wire        rst_n             ,  /* 复位信号，0：有效                */
input  wire        uart_rx_i         ,  /* 接收串行数据                     */
output  wire       uart_rx_vld_o     ,  /* 输出数据有效                     */
output wire [7:0]  uart_rx_data_o    ,  /* 输出并行数据                     */
input  wire        uart_tx_en_i      ,  /* 启动发送标识                     */
input  wire [7:0]  uart_tx_data_i    ,  /* 待发送的并行数据                 */
output wire        uart_tx_rdy_o     ,  /* 发送工作状态，1：空闲，0：忙碌   */
output wire        uart_tx_o            /* 串行数据                         */
);

localparam SmplCLKP_RX = clk_freq_hz/(baudrate*3);
localparam SmplCLKP_TX = clk_freq_hz/baudrate;

uart_rx u1_uart_rx
(
/* input   wire		   */   .clk          ( clk            )   //时钟//
/* input   wire  	   */  ,.rst_n        ( rst_n          )   //复位信号，1：有效//
/* input   wire 	   */  ,.Rx           ( uart_rx_i      )   //接收数据//
/* input   wire        */  ,.sel_check    ( sel_check      )   //校验选择，1：有校验，0：无校验
/* input   wire        */  ,.parity_check ( parity_check   )   //奇偶校验，1：奇校验，0：偶校验//
/* input   wire [6:0]  */  ,.SmplCLKP     ( SmplCLKP_RX    )   //波特率设置，Vclk/vbot/3//
/* output  reg 		   */  ,.dRDY         ( uart_rx_vld_o  )   //输出数据状态 1: 串并转换完成 0：串并转换未完成//
/* output  reg	[7:0]  */  ,.dout         ( uart_rx_data_o )   //输出数据//
);

uart_tx u1_uart_tx
(
/* input   wire		  */    .clk          ( clk            )   //时钟//
/* input   wire		  */   ,.rst_n        ( rst_n          )   //复位信号，1：有效//
/* input   wire		  */   ,.i_start      ( uart_tx_en_i   )   //输入数据使能//
/* input   wire [7:0] */   ,.i_dat        ( uart_tx_data_i )   //输入数据//
/* input   wire       */   ,.sel_check    ( sel_check      )   //校验选择，1：有校验，0：无校验
/* input   wire       */   ,.parity_check ( parity_check   )   //奇偶校验，1：奇校验，0：偶校验//
/* input   wire [7:0] */   ,.SmplCLKP     ( SmplCLKP_TX    )   //波特率设置，Vclk/vbot//
/* output  reg        */   ,.o_rdy        ( uart_tx_rdy_o  )   //工作状态，1：空闲 0：忙碌//
/* output  reg 	      */   ,.o_ct         ( uart_tx_o      )   //发送数据//
);
    
endmodule