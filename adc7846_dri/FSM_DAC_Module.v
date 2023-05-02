module FSM_DAC_Module
(
	input					sysclk				,
	input					rst					,

	output	[15:0]			DAC_DATA_JGFSM		,
	output	[15:0]			DAC_DATA_CQFSM		,
	output					JG_RW				,
	output					CQ_RW				,
	output					JG_FY1_CS_DAC		,	//JG master DAC//
	output					JG_FY1_CLR_DAC		,	//JG master DAC//
	output					JG_FY1_LDAC_DAC		,	//JG master DAC//
	output					JG_FW1_CS_DAC		,	//JG master DAC//
	output					JG_FW1_CLR_DAC		,	//JG master DAC//
	output					JG_FW1_LDAC_DAC		,	//JG master DAC//
	output					JG_FY2_CS_DAC		,   //JG backup DAC//
	output					JG_FY2_CLR_DAC		,   //JG backup DAC//
	output					JG_FY2_LDAC_DAC		,   //JG backup DAC//
	output					JG_FW2_CS_DAC		,   //JG backup DAC//
	output					JG_FW2_CLR_DAC		,   //JG backup DAC//
	output					JG_FW2_LDAC_DAC		,   //JG backup DAC//
	output					CQ_FY1_CS_DAC		,   //CQ master DAC//
	output					CQ_FY1_CLR_DAC		,   //CQ master DAC//
	output					CQ_FY1_LDAC_DAC		,   //CQ master DAC//
	output					CQ_FW1_CS_DAC		,   //CQ master DAC//
	output					CQ_FW1_CLR_DAC		,   //CQ master DAC//
	output					CQ_FW1_LDAC_DAC		,   //CQ master DAC//
	output					CQ_FY2_CS_DAC		,   //CQ backup DAC//
	output					CQ_FY2_CLR_DAC		,   //CQ backup DAC//
	output					CQ_FY2_LDAC_DAC		,   //CQ backup DAC//
	output					CQ_FW2_CS_DAC		,   //CQ backup DAC//
	output					CQ_FW2_CLR_DAC		,   //CQ backup DAC//
	output					CQ_FW2_LDAC_DAC		,   //CQ backup DAC//
	input	[15:0]			dac_data_JG_FY1		,   //JG master DAC//
	input					dac_valid_JG_FY1	,   //JG master DAC//
	input	[15:0]			dac_data_JG_FW1		,   //JG master DAC//
	input					dac_valid_JG_FW1	,   //JG master DAC//
	input	[15:0]			dac_data_JG_FY2	    ,   //JG backup DAC//
	input					dac_valid_JG_FY2	,   //JG backup DAC//
	input	[15:0]			dac_data_JG_FW2	    ,   //JG backup DAC//
	input					dac_valid_JG_FW2	,   //JG backup DAC//
	output					dac_ready_JG		,   //
	input	[15:0]			dac_data_CQ_FY1		,   //CQ master DAC//
	input					dac_valid_CQ_FY1	,   //CQ master DAC//
	input	[15:0]			dac_data_CQ_FW1		,   //CQ master DAC//
	input					dac_valid_CQ_FW1	,   //CQ master DAC//
	input	[15:0]			dac_data_CQ_FY2	    ,   //CQ backup DAC//
	input					dac_valid_CQ_FY2	,   //CQ backup DAC//
	input	[15:0]			dac_data_CQ_FW2	    ,   //CQ backup DAC//
	input					dac_valid_CQ_FW2	,   //CQ backup DAC//
	output					dac_ready_CQ		    //
);

	wire	[15:0]			DATA_i_AD7846_JG		;
	wire	[15:0]			DATA_i_AD7846_CQ		;
	wire	[15:0]			DATA_o_AD7846_JG_FY1	;
	wire	[15:0]			DATA_o_AD7846_CQ_FY1	;
	wire	[15:0]			DATA_o_AD7846_JG_FW1	;
	wire	[15:0]			DATA_o_AD7846_CQ_FW1	;
	wire    [15:0]          DATA_o_AD7846_JG_FW2    ;
	wire    [15:0]          DATA_o_AD7846_JG_FY2    ;
	wire    [15:0]          DATA_o_AD7846_CQ_FW2    ;
	wire    [15:0]          DATA_o_AD7846_CQ_FY2    ;
	wire	[15:0]			DATA_i_AD7846_JG_FY1	;
	wire	[15:0]			DATA_i_AD7846_CQ_FY1	;
	wire	[15:0]			DATA_i_AD7846_JG_FW1	;
	wire	[15:0]			DATA_i_AD7846_CQ_FW1	;
	wire	[15:0]			DATA_i_AD7846_JG_FY2	;
	wire	[15:0]			DATA_i_AD7846_CQ_FY2	;
	wire	[15:0]			DATA_i_AD7846_JG_FW2	;
	wire	[15:0]			DATA_i_AD7846_CQ_FW2	;
	wire					JG_FW1_RW_DAC			;
	wire					JG_FY1_RW_DAC			;
	wire					CQ_FW1_RW_DAC			;
	wire					CQ_FY1_RW_DAC			;
	wire					JG_FW2_RW_DAC			;
	wire					JG_FY2_RW_DAC			;
	wire					CQ_FW2_RW_DAC			;
	wire					CQ_FY2_RW_DAC			;
	                                            	
	wire					dac_ready_JG_FW1		;
	wire					dac_ready_JG_FY1		;
	wire					dac_ready_CQ_FW1		;
	wire					dac_ready_CQ_FY1		;
	wire					dac_ready_JG_FW2		;
	wire					dac_ready_JG_FY2		;
	wire					dac_ready_CQ_FW2		;
	wire					dac_ready_CQ_FY2		;
	wire	[3:0] 			JG_DataCs				;
	wire	[3:0]			CQ_DataCs				;
	
	assign JG_RW = JG_FW1_RW_DAC & JG_FY1_RW_DAC & JG_FW2_RW_DAC & JG_FY2_RW_DAC;		//RW:0 write 1 read//
	assign CQ_RW = CQ_FW1_RW_DAC & CQ_FY1_RW_DAC & CQ_FW2_RW_DAC & CQ_FY2_RW_DAC;		//RW:0 write 1 read//
	assign DATA_i_AD7846_JG_FY1 = DATA_i_AD7846_JG;
	assign DATA_i_AD7846_CQ_FY1 = DATA_i_AD7846_CQ;
	assign DATA_i_AD7846_JG_FW1 = DATA_i_AD7846_JG;
	assign DATA_i_AD7846_CQ_FW1 = DATA_i_AD7846_CQ;
	assign DATA_i_AD7846_JG_FY2 = DATA_i_AD7846_JG;
	assign DATA_i_AD7846_CQ_FY2 = DATA_i_AD7846_CQ;
	assign DATA_i_AD7846_JG_FW2 = DATA_i_AD7846_JG;
	assign DATA_i_AD7846_CQ_FW2 = DATA_i_AD7846_CQ;
	assign dac_ready_JG	= dac_ready_JG_FW1 & dac_ready_JG_FY1 & dac_ready_JG_FW2 & dac_ready_JG_FY2;					  
	assign dac_ready_CQ = dac_ready_CQ_FW1 & dac_ready_CQ_FY1 & dac_ready_CQ_FW2 & dac_ready_CQ_FY2;
	assign JG_DataCs = {JG_FW1_CS_DAC,JG_FY1_CS_DAC,JG_FW2_CS_DAC,JG_FY2_CS_DAC};
	assign CQ_DataCs = {CQ_FW1_CS_DAC,CQ_FY1_CS_DAC,CQ_FW2_CS_DAC,CQ_FY2_CS_DAC};
	assign DAC_DATA_JGFSM = (4'b0111 == JG_DataCs) ? DATA_o_AD7846_JG_FW1 : (4'b1011 == JG_DataCs) ? DATA_o_AD7846_JG_FY1 : (4'b1101 == JG_DataCs)? DATA_o_AD7846_JG_FW2 : DATA_o_AD7846_JG_FY2;	//cs signal 0 valid, cs select which DAC data output//
	//modify 20230331
	//assign DAC_DATA_CQFSM = (4'b0111 == CQ_DataCs) ? DATA_o_AD7846_CQ_FW1 : (4'b1011 == CQ_DataCs) ? DATA_o_AD7846_CQ_FY1 : (4'b1101 == CQ_DataCs)? DATA_o_AD7846_CQ_FW2 : DATA_o_AD7846_CQ_FY2;	//cs signal 0 valid, cs select which DAC data output//  
	assign DAC_DATA_CQFSM = DATA_o_AD7846_CQ_FY1;
	
	AD7846_Module AD7846_Module_JGFW1_inst
	(
		.sysclk					(	sysclk					),
		.rst					(	rst						),
		.DATA_o					(	DATA_o_AD7846_JG_FW1	),
		.DATA_i					(	DATA_i_AD7846_JG_FW1	),
		.RW						(	JG_FW1_RW_DAC			),
		.CS						(	JG_FW1_CS_DAC			),
		.CLR					(	JG_FW1_CLR_DAC			),
		.LDAC					(	JG_FW1_LDAC_DAC			),
		.dac_data				(	dac_data_JG_FW1			),
		.dac_valid				(	dac_valid_JG_FW1		),
		.dac_ready				(	dac_ready_JG_FW1		)
	);
	//master fsm fy//
	AD7846_Module AD7846_Module_JGFY1_inst
	(
		.sysclk					(	sysclk					),
		.rst					(	rst						),
		.DATA_o					(	DATA_o_AD7846_JG_FY1	),
		.DATA_i					(	DATA_i_AD7846_JG_FY1	),
		.RW						(	JG_FY1_RW_DAC			),
		.CS						(	JG_FY1_CS_DAC			),
		.CLR					(	JG_FY1_CLR_DAC			),
		.LDAC					(	JG_FY1_LDAC_DAC			),
		.dac_data				(	dac_data_JG_FY1			),
		.dac_valid				(	dac_valid_JG_FY1		),
		.dac_ready				(	dac_ready_JG_FY1		)
	);
	//backup track FSM fw//
	AD7846_Module AD7846_Module_JGFW2_inst
	(
		.sysclk					(	sysclk					),
		.rst					(	rst						),
		.DATA_o					(	DATA_o_AD7846_JG_FW2	),
		.DATA_i					(	DATA_i_AD7846_JG_FW2	),
		.RW						(	JG_FW2_RW_DAC			),
		.CS						(	JG_FW2_CS_DAC			),
		.CLR					(	JG_FW2_CLR_DAC			),
		.LDAC					(	JG_FW2_LDAC_DAC			),
		.dac_data				(	dac_data_JG_FW2			),
		.dac_valid				(	dac_valid_JG_FW2		),	
		.dac_ready				(	dac_ready_JG_FW2		)
	);

	//backup track fsm fy//
	AD7846_Module AD7846_Module_JGFY2_inst
	(
		.sysclk					(	sysclk					),
		.rst					(	rst						),
		.DATA_o					(	DATA_o_AD7846_JG_FY2	),
		.DATA_i					(	DATA_i_AD7846_JG_FY2	),
		.RW						(	JG_FY2_RW_DAC			),
		.CS						(	JG_FY2_CS_DAC			),
		.CLR					(	JG_FY2_CLR_DAC			),
		.LDAC					(	JG_FY2_LDAC_DAC			),
		.dac_data				(	dac_data_JG_FY2			),
		.dac_valid				(	dac_valid_JG_FY2		),	
		.dac_ready				(	dac_ready_JG_FY2		)
	);
	//modify 20230331
	//master cq fsm fw// 
	AD7846_Module AD7846_Module_CQFW1_inst
	(
		.sysclk					(	sysclk					),
		.rst					(	rst						),
		.DATA_o					(	DATA_o_AD7846_CQ_FW1	),
		.DATA_i					(	DATA_i_AD7846_CQ_FW1	),
		.RW						(	CQ_FW1_RW_DAC			),
		//.CS						(	CQ_FW1_CS_DAC			),
		.CS						(),
		.CLR					(	CQ_FW1_CLR_DAC			),
		.LDAC					(	CQ_FW1_LDAC_DAC			),
		.dac_data				(	dac_data_CQ_FW1			),
		.dac_valid				(	dac_valid_CQ_FW1		),
		.dac_ready				(	dac_ready_CQ_FW1		)
	);
	assign CQ_FW1_CS_DAC = 1'b1;
	
	//master cq fsm fy// 
	AD7846_Module AD7846_Module_CQFY1_inst
	(
		.sysclk					(	sysclk					),
		.rst					(	rst						),
		.DATA_o					(	DATA_o_AD7846_CQ_FY1	),
		.DATA_i					(	DATA_i_AD7846_CQ_FY1	),
		.RW						(	CQ_FY1_RW_DAC			),
		.CS						(	CQ_FY1_CS_DAC			),
		.CLR					(	CQ_FY1_CLR_DAC			),
		.LDAC					(	CQ_FY1_LDAC_DAC			),
		.dac_data				(	dac_data_CQ_FY1			),
		.dac_valid				(	dac_valid_CQ_FY1		),
		.dac_ready				(	dac_ready_CQ_FY1		)
	);
	
	//backup cq fsm fw// 
	AD7846_Module AD7846_Module_CQFW2_inst
	(
		.sysclk					(	sysclk					),
		.rst					(	rst						),
		.DATA_o					(	DATA_o_AD7846_CQ_FW2	),
		.DATA_i					(	DATA_i_AD7846_CQ_FW2	),
		.RW						(	CQ_FW2_RW_DAC			),
		//.CS						(	CQ_FW2_CS_DAC			),
		.CS						(				),
		.CLR					(	CQ_FW2_CLR_DAC			),
		.LDAC					(	CQ_FW2_LDAC_DAC			),
		.dac_data				(	dac_data_CQ_FW2			),
		.dac_valid				(	dac_valid_CQ_FW2		),
		.dac_ready				(	dac_ready_CQ_FW2		)
	);
	assign CQ_FW2_CS_DAC = 1'b1;
	//backup cq fsm fy// 
	AD7846_Module AD7846_Module_CQFY2_inst
	(
		.sysclk					(	sysclk					),
		.rst					(	rst						),
		.DATA_o					(	DATA_o_AD7846_CQ_FY2	),
		.DATA_i					(	DATA_i_AD7846_CQ_FY2	),
		.RW						(	CQ_FY2_RW_DAC			),
		//.CS						(	CQ_FY2_CS_DAC			),
		.CS						(				),
		.CLR					(	CQ_FY2_CLR_DAC			),
		.LDAC					(	CQ_FY2_LDAC_DAC			),
		.dac_data				(	dac_data_CQ_FY2			),
		.dac_valid				(	dac_valid_CQ_FY2		),
		.dac_ready				(	dac_ready_CQ_FY2		)
	);
	assign CQ_FY2_CS_DAC = 1'b1;

endmodule