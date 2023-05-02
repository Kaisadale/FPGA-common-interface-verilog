/* *********************************************************************************** */
/* ģ����:FIFOģ��                                                                     */
/* �汾��:V1.0.0                                                                       */
/* ����ʱ��:2022.11.04                                                                 */
/* �ļ���:fifo                                                                         */                  
/* ����:��Ҷ�                                                                         */
/* ��Ȩ:�й���ѧԺ�Ϻ���ѧ���ܻ�е�о������켤�⹤�̲����켤������з�����             */  
/* ����:����FIFO��FIFO���8bit����ȿ����Զ���(��󲻳���15)                           */                 
/* *********************************************************************************** */

module fifo 
#(parameter MAX_COUNT = 4'd12)  /* FIFO��� ��󲻳���15*/
(
input	wire		clk		,   /* ϵͳʱ��             */  
input	wire		rstp	,	/* ��λ�ź�  1������Ч  */ 
input	wire[7:0]	din		,	/* д������             */  
input	wire		readp	,	/* ��ʹ��               */  
input	wire		writep	,	/* дʹ��               */  
output	reg[7:0]	dout	,   /* ��������             */  
output	reg			emptyp	,	/* �ձ�ʶ               */  
output	reg[3:0]	count	,   /* ��ǰFIFO�����ݸ���   */  
output	reg			fullp		/* ����ʶ               */  
);

             
reg [3:0]	tail;	//�����ָ��
reg [3:0]	head;	//����дָ��
// ���������  
//reg [(DEPTH-1):0]	count;
reg [7:0] fifomem[0:MAX_COUNT]; //����fifomem�洢����10��8λ�Ĵ洢��

// dout������tailָ���ֵ
always @(posedge clk)
	begin
		if (rstp == 1) begin
			dout <= 8'h00;     //��λ�ź���Ч��0
			end
		else begin
			dout <= fifomem[tail];  //��fifomem�е�tail����Ԫ����dout
		end
	end 
always @(posedge clk) begin
		if (rstp == 1'b1 ) begin
            fifomem[head] <= 8'h00; 
        end
		else if (writep == 1'b1 && fullp == 1'b0) begin
			fifomem[head] <= din;      //д��
		end
	end
always @(posedge clk) begin
		if (rstp == 1'b1) begin
			head <= 4'd0;           //��λ
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
		tail <= 4'd0;                //��λ
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
					count <= count + 1;     //Ϊд״̬ʱ���������мӷ�����
				2'b10: 
					if (count != 4'd00)
					count <= count - 1;    //Ϊ��״̬���������м�������
				2'b11:
					count <= count;
				default: count <= count;
			endcase
		end
	end
    
always @(count)
	 begin
		 if (count == 4'd0)
			 emptyp <= 1'b1;      //countΪ0ʱemptyp��Ϊ1
	     else
		     emptyp <= 1'b0;
     end
always @(count) 
	 begin
	    if (count == MAX_COUNT)
			 fullp <= 1'b1;       //���������ʱfullp��Ϊ1
	    else
			 fullp <= 1'b0;
	 end

endmodule