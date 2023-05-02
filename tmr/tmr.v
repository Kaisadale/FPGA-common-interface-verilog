module tmr#(
 parameter  REG_WIDTH = 1
)
(
    input  clk,
    input  rst_n,
    input  [REG_WIDTH -1:0] ls_abnorm_st_r1,
    input  [REG_WIDTH -1:0] ls_abnorm_st_r2,
    input  [REG_WIDTH -1:0] ls_abnorm_st_r3,
    output [REG_WIDTH -1:0] ls_abnorm_st
);

reg [REG_WIDTH-1:0]   ls_abnorm_st_tmr0   ;
reg [REG_WIDTH-1:0]   ls_abnorm_st_tmr1   ;
reg [REG_WIDTH-1:0]   ls_abnorm_st_tmr2   ;
always@(posedge clk or negedge rst_n)
    if(~rst_n)     begin
        ls_abnorm_st_tmr0 <= 'd0;
        ls_abnorm_st_tmr1 <= 'd0;
        ls_abnorm_st_tmr2 <= 'd0;
    end
    else begin
        ls_abnorm_st_tmr0 <= ls_abnorm_st_r1;
        ls_abnorm_st_tmr1 <= ls_abnorm_st_r2;
        ls_abnorm_st_tmr2 <= ls_abnorm_st_r3;        
    end

assign ls_abnorm_st = (ls_abnorm_st_tmr0 & ls_abnorm_st_tmr1) | (ls_abnorm_st_tmr0 & ls_abnorm_st_tmr2) | (ls_abnorm_st_tmr1 & ls_abnorm_st_tmr2); // vote

endmodule