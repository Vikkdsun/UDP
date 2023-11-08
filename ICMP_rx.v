module ICMP_rx(
    input               i_clk           ,
    input               i_rst           ,

    input   [7:0]       i_icmp_data     ,
    input   [15:0]      i_icmp_len      ,
    input               i_icmp_last     ,
    input               i_icmp_valid    ,

    output [15:0]       o_trig_seq      ,
    output              o_trig_reply    
);

/*
    This module(rx) is means to get message and send SEQ and check the TYPE if equal to 8 (which means this message is sent to request)
    if TYPE = 8, we send a trig_reply to ICMP_tx to replay the sender.
*/

// isolation
reg [7:0]           ri_icmp_data        ;
reg [15:0]          ri_icmp_len         ;
reg                 ri_icmp_last        ;
reg                 ri_icmp_valid       ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_icmp_data  <= 'd0;
        ri_icmp_len   <= 'd0;
        ri_icmp_last  <= 'd0;
        ri_icmp_valid <= 'd0;
    end else if (i_icmp_valid) begin
        ri_icmp_data  <= i_icmp_data ;
        ri_icmp_len   <= i_icmp_len  ;
        ri_icmp_last  <= i_icmp_last ;
        ri_icmp_valid <= i_icmp_valid;
    end else begin
        ri_icmp_data  <= 'd0;
        ri_icmp_len   <= 'd0;
        ri_icmp_last  <= 'd0;
        ri_icmp_valid <= 'd0;
    end
end

// use a cnt
reg [15:0]          r_icmp_cnt          ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_icmp_cnt <= 'd0;
    else if (ri_icmp_valid)
        r_icmp_cnt <= r_icmp_cnt + 1;
    else        
        r_icmp_cnt <= 'd0;
end

// get TYPE
reg [7:0]           r_type              ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_type <= 'd0;
    else if (r_icmp_cnt == 0 && ri_icmp_valid)
        r_type <= ri_icmp_data;
    else    
        r_type <= r_type;
end

// get SEQ
reg [15:0]          ro_trig_seq         ;
assign              o_trig_seq = ro_trig_seq;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_trig_seq <= 'd0;
    else if (r_icmp_cnt >= 6 && r_icmp_cnt <= 7 && ri_icmp_valid)
        ro_trig_seq <= {ro_trig_seq[7:0], ri_icmp_data};
    else
        ro_trig_seq <= ro_trig_seq;
end

// ctrl trig_reply
reg                 ro_trig_reply       ;
assign              o_trig_reply = ro_trig_reply;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_trig_reply <= 'd0;
    else if (r_icmp_cnt == 7 && ri_icmp_valid && r_type == 8)
        ro_trig_reply <= 'd1;
    else
        ro_trig_reply <= 'd0;
end


endmodule
