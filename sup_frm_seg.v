module sup_frm_seg
(
	input             clk_i,
	input             rst_n_i,
	input  [63:0]     mipi0a_rx_axis_tdata_i, 
    input  [9:0]      mipi0a_rx_axis_tdest_i, 
    input             mipi0a_rx_axis_tlast_i, 
    input  [63:0]     mipi0a_rx_axis_tuser_i,  
    input             mipi0a_rx_axis_tvalid_i, 
    input             mipi0a_rx_axis_tready_i, 	
	input  [63:0]     mipi0b_rx_axis_tdata_i, 
    input  [9:0]      mipi0b_rx_axis_tdest_i, 
    input             mipi0b_rx_axis_tlast_i, 
    input  [63:0]     mipi0b_rx_axis_tuser_i,  
    input             mipi0b_rx_axis_tvalid_i, 	
    input             mipi0b_rx_axis_tready_i, 	
	input  [63:0]     mipi0c_rx_axis_tdata_i, 
    input  [9:0]      mipi0c_rx_axis_tdest_i, 
    input             mipi0c_rx_axis_tlast_i, 
    input  [63:0]     mipi0c_rx_axis_tuser_i,  
    input             mipi0c_rx_axis_tvalid_i, 	
    input             mipi0c_rx_axis_tready_i, 	
	input  [63:0]     mipi0d_rx_axis_tdata_i, 
    input  [9:0]      mipi0d_rx_axis_tdest_i, 
    input             mipi0d_rx_axis_tlast_i, 
    input  [63:0]     mipi0d_rx_axis_tuser_i,  
    input             mipi0d_rx_axis_tvalid_i, 	
    input             mipi0d_rx_axis_tready_i, 	
	input  [63:0]     mipi1_rx_axis_tdata_i, 
    input  [9:0]      mipi1_rx_axis_tdest_i, 
    input             mipi1_rx_axis_tlast_i, 
    input  [63:0]     mipi1_rx_axis_tuser_i,  
    input             mipi1_rx_axis_tvalid_i, 	
    input             mipi1_rx_axis_tready_i, 	
	input  [63:0]     mipi2_rx_axis_tdata_i, 
    input  [9:0]      mipi2_rx_axis_tdest_i, 
    input             mipi2_rx_axis_tlast_i, 
    input  [63:0]     mipi2_rx_axis_tuser_i,  
    input             mipi2_rx_axis_tvalid_i, 	
    input             mipi2_rx_axis_tready_i, 	
	input  [63:0]     mipi3_rx_axis_tdata_i, 
    input  [9:0]      mipi3_rx_axis_tdest_i, 
    input             mipi3_rx_axis_tlast_i, 
    input  [63:0]     mipi3_rx_axis_tuser_i,  
    input             mipi3_rx_axis_tvalid_i, 	
    input             mipi3_rx_axis_tready_i, 	
	input  [63:0]     mipi4_rx_axis_tdata_i, 
    input  [9:0]      mipi4_rx_axis_tdest_i, 
    input             mipi4_rx_axis_tlast_i, 
    input  [63:0]     mipi4_rx_axis_tuser_i,  
    input             mipi4_rx_axis_tvalid_i, 	
    input             mipi4_rx_axis_tready_i, 	
	input  [63:0]     mipi5_rx_axis_tdata_i, 
    input  [9:0]      mipi5_rx_axis_tdest_i, 
    input             mipi5_rx_axis_tlast_i, 
    input  [63:0]     mipi5_rx_axis_tuser_i,  
    input             mipi5_rx_axis_tvalid_i, 	
    input             mipi5_rx_axis_tready_i, 	
	input  [63:0]     mipi6_rx_axis_tdata_i, 
    input  [9:0]      mipi6_rx_axis_tdest_i, 
    input             mipi6_rx_axis_tlast_i, 
    input  [63:0]     mipi6_rx_axis_tuser_i,  
    input             mipi6_rx_axis_tvalid_i, 	
    input             mipi6_rx_axis_tready_i, 	
	input  [63:0]     mipi7_rx_axis_tdata_i, 
    input  [9:0]      mipi7_rx_axis_tdest_i, 
    input             mipi7_rx_axis_tlast_i, 
    input  [63:0]     mipi7_rx_axis_tuser_i,  
    input             mipi7_rx_axis_tvalid_i, 	
    input             mipi7_rx_axis_tready_i, 	
	output [63:0]     preproc_mipi0a_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi0a_rx_axis_tdest_o, 
    output            preproc_mipi0a_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi0a_rx_axis_tuser_o,  
    output            preproc_mipi0a_rx_axis_tvalid_o, 
	output [63:0]     preproc_mipi0b_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi0b_rx_axis_tdest_o, 
    output            preproc_mipi0b_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi0b_rx_axis_tuser_o,  
    output            preproc_mipi0b_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi0c_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi0c_rx_axis_tdest_o, 
    output            preproc_mipi0c_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi0c_rx_axis_tuser_o,  
    output            preproc_mipi0c_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi0d_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi0d_rx_axis_tdest_o, 
    output            preproc_mipi0d_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi0d_rx_axis_tuser_o,  
    output            preproc_mipi0d_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi1_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi1_rx_axis_tdest_o, 
    output            preproc_mipi1_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi1_rx_axis_tuser_o,  
    output            preproc_mipi1_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi2_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi2_rx_axis_tdest_o, 
    output            preproc_mipi2_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi2_rx_axis_tuser_o,  
    output            preproc_mipi2_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi3_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi3_rx_axis_tdest_o, 
    output            preproc_mipi3_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi3_rx_axis_tuser_o,  
    output            preproc_mipi3_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi4_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi4_rx_axis_tdest_o, 
    output            preproc_mipi4_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi4_rx_axis_tuser_o,  
    output            preproc_mipi4_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi5_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi5_rx_axis_tdest_o, 
    output            preproc_mipi5_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi5_rx_axis_tuser_o,  
    output            preproc_mipi5_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi6_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi6_rx_axis_tdest_o, 
    output            preproc_mipi6_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi6_rx_axis_tuser_o,  
    output            preproc_mipi6_rx_axis_tvalid_o, 	
	output [63:0]     preproc_mipi7_rx_axis_tdata_o, 
    output [9:0]      preproc_mipi7_rx_axis_tdest_o, 
    output            preproc_mipi7_rx_axis_tlast_o, 
    output [63:0]     preproc_mipi7_rx_axis_tuser_o,  
    output            preproc_mipi7_rx_axis_tvalid_o	
);

mipi_sup_frm_seg mipi0a
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi0a_rx_axis_tdata_i           )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi0a_rx_axis_tdest_i           )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi0a_rx_axis_tlast_i           )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi0a_rx_axis_tuser_i           )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi0a_rx_axis_tvalid_i          )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi0a_rx_axis_tready_i          )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi0a_rx_axis_tdata_o   )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi0a_rx_axis_tdest_o   )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi0a_rx_axis_tlast_o   )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi0a_rx_axis_tuser_o   ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi0a_rx_axis_tvalid_o  )
);

mipi_sup_frm_seg mipi0b
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi0b_rx_axis_tdata_i           )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi0b_rx_axis_tdest_i           )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi0b_rx_axis_tlast_i           )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi0b_rx_axis_tuser_i           )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi0b_rx_axis_tvalid_i          )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi0b_rx_axis_tready_i          )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi0b_rx_axis_tdata_o   )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi0b_rx_axis_tdest_o   )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi0b_rx_axis_tlast_o   )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi0b_rx_axis_tuser_o   ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi0b_rx_axis_tvalid_o  )
);

mipi_sup_frm_seg mipi0c
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi0c_rx_axis_tdata_i           )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi0c_rx_axis_tdest_i           )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi0c_rx_axis_tlast_i           )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi0c_rx_axis_tuser_i           )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi0c_rx_axis_tvalid_i          )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi0c_rx_axis_tready_i          )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi0c_rx_axis_tdata_o   )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi0c_rx_axis_tdest_o   )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi0c_rx_axis_tlast_o   )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi0c_rx_axis_tuser_o   ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi0c_rx_axis_tvalid_o  )
);

mipi_sup_frm_seg mipi0d
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi0d_rx_axis_tdata_i           )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi0d_rx_axis_tdest_i           )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi0d_rx_axis_tlast_i           )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi0d_rx_axis_tuser_i           )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi0d_rx_axis_tvalid_i          )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi0d_rx_axis_tready_i          )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi0d_rx_axis_tdata_o   )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi0d_rx_axis_tdest_o   )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi0d_rx_axis_tlast_o   )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi0d_rx_axis_tuser_o   ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi0d_rx_axis_tvalid_o  )
);

mipi_sup_frm_seg mipi1
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi1_rx_axis_tdata_i            )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi1_rx_axis_tdest_i            )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi1_rx_axis_tlast_i            )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi1_rx_axis_tuser_i            )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi1_rx_axis_tvalid_i           )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi1_rx_axis_tready_i           )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi1_rx_axis_tdata_o    )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi1_rx_axis_tdest_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi1_rx_axis_tlast_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi1_rx_axis_tuser_o    ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi1_rx_axis_tvalid_o   )
);

mipi_sup_frm_seg mipi2
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi2_rx_axis_tdata_i            )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi2_rx_axis_tdest_i            )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi2_rx_axis_tlast_i            )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi2_rx_axis_tuser_i            )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi2_rx_axis_tvalid_i           )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi2_rx_axis_tready_i           )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi2_rx_axis_tdata_o    )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi2_rx_axis_tdest_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi2_rx_axis_tlast_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi2_rx_axis_tuser_o    ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi2_rx_axis_tvalid_o   )
);

mipi_sup_frm_seg mipi3
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi3_rx_axis_tdata_i            )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi3_rx_axis_tdest_i            )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi3_rx_axis_tlast_i            )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi3_rx_axis_tuser_i            )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi3_rx_axis_tvalid_i           )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi3_rx_axis_tready_i           )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi3_rx_axis_tdata_o    )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi3_rx_axis_tdest_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi3_rx_axis_tlast_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi3_rx_axis_tuser_o    ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi3_rx_axis_tvalid_o   )
);

mipi_sup_frm_seg mipi4
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi4_rx_axis_tdata_i            )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi4_rx_axis_tdest_i            )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi4_rx_axis_tlast_i            )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi4_rx_axis_tuser_i            )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi4_rx_axis_tvalid_i           )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi4_rx_axis_tready_i           )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi4_rx_axis_tdata_o    )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi4_rx_axis_tdest_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi4_rx_axis_tlast_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi4_rx_axis_tuser_o    ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi4_rx_axis_tvalid_o   )
);

mipi_sup_frm_seg mipi5
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi5_rx_axis_tdata_i            )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi5_rx_axis_tdest_i            )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi5_rx_axis_tlast_i            )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi5_rx_axis_tuser_i            )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi5_rx_axis_tvalid_i           )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi5_rx_axis_tready_i           )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi5_rx_axis_tdata_o    )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi5_rx_axis_tdest_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi5_rx_axis_tlast_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi5_rx_axis_tuser_o    ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi5_rx_axis_tvalid_o   )
);

mipi_sup_frm_seg mipi6
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi6_rx_axis_tdata_i            )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi6_rx_axis_tdest_i            )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi6_rx_axis_tlast_i            )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi6_rx_axis_tuser_i            )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi6_rx_axis_tvalid_i           )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi6_rx_axis_tready_i           )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi6_rx_axis_tdata_o    )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi6_rx_axis_tdest_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi6_rx_axis_tlast_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi6_rx_axis_tuser_o    ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi6_rx_axis_tvalid_o   )
);

mipi_sup_frm_seg mipi7
(
    /* input              */   .clk_i                         ( clk_i                            )
	/* input              */  ,.rst_n_i                       ( rst_n_i                          )
	/* input       [63:0] */  ,.mipi_rx_sf_axis_tdata_i       ( mipi7_rx_axis_tdata_i            )
    /* input       [9:0]  */  ,.mipi_rx_sf_axis_tdest_i       ( mipi7_rx_axis_tdest_i            )
    /* input              */  ,.mipi_rx_sf_axis_tlast_i       ( mipi7_rx_axis_tlast_i            )
    /* input              */  ,.mipi_rx_sf_axis_tuser_i       ( mipi7_rx_axis_tuser_i            )
    /* input              */  ,.mipi_rx_sf_axis_tvalid_i      ( mipi7_rx_axis_tvalid_i           )
	/* input              */  ,.mipi_rx_sf_axis_tready_i      ( mipi7_rx_axis_tready_i           )
	/* output  reg [63:0] */  ,.mipi_rx_sf_seg_axis_tdata_o   ( preproc_mipi7_rx_axis_tdata_o    )
    /* output  reg [9:0]  */  ,.mipi_rx_sf_seg_axis_tdest_o   ( preproc_mipi7_rx_axis_tdest_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tlast_o   ( preproc_mipi7_rx_axis_tlast_o    )
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tuser_o   ( preproc_mipi7_rx_axis_tuser_o    ) 
    /* output  reg        */  ,.mipi_rx_sf_seg_axis_tvalid_o  ( preproc_mipi7_rx_axis_tvalid_o   )
);





endmodule