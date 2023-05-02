/* *********************************************************************************** */
/* 模块名:FIFO模块                                                                     */
/* 版本号:V1.0.0                                                                       */
/* 发布时间:2022.11.04                                                                 */
/* 文件名:fifo                                                                         */                  
/* 作者:徐家栋                                                                         */
/* 版权:中国科学院上海光学精密机械研究所航天激光工程部航天激光软件研发中心             */  
/* 描述:单口FIFO，FIFO宽度8bit，深度可以自定义(最大不超过15)                           */                 
/* *********************************************************************************** */

module fifo 
#(parameter MAX_COUNT = 4'd12)  /* FIFO深度 最大不超过15*/
(
input	wire		clk		,   /* 系统时钟             */  
input	wire		rstp	,	/* 复位信号  1：高有效  */ 
input	wire[7:0]	din		,	/* 写入数据             */  
input	wire		readp	,	/* 读使能               */  
input	wire		writep	,	/* 写使能               */  
output	reg[7:0]	dout	,   /* 读出数据             */  
output	reg			emptyp	,	/* 空标识               */  
output	reg[3:0]	count	,   /* 当前FIFO内数据个数   */  
output	reg			fullp		/* 满标识               */  
);

             
reg [3:0]	tail;	//定义读指针
reg [3:0]	head;	//定义写指针
// 定义计数器  
//reg [(DEPTH-1):0]	count;
reg [7:0] fifomem[0:MAX_COUNT]; //定义fifomem存储器有10个8位的存储器

// dout被赋给tail指向的值
always @(posedge clk)
	begin
		if (rstp == 1) begin
			dout <= 8'h00;     //复位信号有效置0
			end
		else begin
			dout <= fifomem[tail];  //将fifomem中第tail个单元赋给dout
		end
	end 
always @(posedge clk) begin
		if (rstp == 1'b1 ) begin
            fifomem[head] <= 8'h00; 
        end
		else if (writep == 1'b1 && fullp == 1'b0) begin
			fifomem[head] <= din;      //写入
		end
	end
always @(posedge clk) begin
		if (rstp == 1'b1) begin
			head <= 4'd0;           //复位
		end
		else if (writep == 1'b1 && fullp == 1'b0)begin
            if(head==MAX_COUNT) 
                head <= 0;
            else
				head <= head + 1;
		end
	end
always @(posedge clk) begin
	if (rstp == 1'b1) begin
		tail <= 4'd0;                //复位
	end
	else if (readp == 1'b1 && emptyp == 1'b0) begin
        if(tail==MAX_COUNT)
            tail <= 0;
        else
            tail <= tail + 1;
	end
	end
always @(posedge clk)
	begin
		if (rstp == 1'b1) begin
			count <= 4'd0;
		end
		else begin
			case ({readp, writep})
				2'b00: count <= count;
				2'b01: 
					if (count != MAX_COUNT) 
					count <= count + 1;     //为写状态时计数器进行加法计数
				2'b10: 
					if (count != 4'd00)
					count <= count - 1;    //为读状态计数器进行减法计数
				2'b11:
					count <= count;
				default: count <= count;
			endcase
		end
	end
    
always @(count)
	 begin
		 if (count == 4'd0)
			 emptyp <= 1'b1;      //count为0时emptyp赋为1
	     else
		     emptyp <= 1'b0;
     end
always @(count) 
	 begin
	    if (count == MAX_COUNT)
			 fullp <= 1'b1;       //计数到最大时fullp赋为1
	    else
			 fullp <= 1'b0;
	 end

endmodule