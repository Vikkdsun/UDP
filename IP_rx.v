module IP_rx#(
    parameter       P_ST_TARGET_IP = {8'd192,8'd168,8'd1,8'd0},
    parameter       P_ST_SOURCE_IP = {8'd192,8'd168,8'd1,8'd1}
)(
    input               i_clk               ,
    input               i_rst               ,

    input [31:0]        i_target_ip         ,
    input               i_target_valid      ,
    input [31:0]        i_source_ip         ,
    input               i_source_valid      ,

    output [7:0]        o_udp_data          ,
    output [15:0]       o_udp_len           ,
    output              o_udp_last          ,
    output              o_udp_valid         ,
    output [7:0]        o_icmp_data         ,
    output [15:0]       o_icmp_len          ,
    output              o_icmp_last         ,
    output              o_icmp_valid        ,

    input [7:0]         i_mac_data          ,
    input               i_mac_last          ,
    input               i_mac_valid         
);

// save input info of IP
reg [31:0]              ri_target_ip        ;
reg [31:0]              ri_source_ip        ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ri_target_ip <= P_ST_TARGET_IP;
    else if (i_target_valid)
        ri_target_ip <= i_target_ip;
    else
        ri_target_ip <= ri_target_ip;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ri_source_ip <= P_ST_SOURCE_IP;
    else if (i_source_valid)
        ri_source_ip <= i_source_ip;
    else
        ri_source_ip <= ri_source_ip;
end

// isolation
reg [7:0]               ri_mac_data         ;
reg                     ri_mac_last         ;
reg                     ri_mac_valid        ;
// maybe there is no "ke xuan bu fen" or  "tian chong" so when we get "target addr" there will be one delay
reg [7:0]               ri_mac_data_1d      ;
reg                     ri_mac_last_1d      ;
reg                     ri_mac_valid_1d     ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_mac_data  <= 'd0;
        ri_mac_last  <= 'd0;
        ri_mac_valid <= 'd0;
    end else if (i_mac_valid) begin
        ri_mac_data  <= i_mac_data ;
        ri_mac_last  <= i_mac_last ;
        ri_mac_valid <= i_mac_valid;
    end else begin
        ri_mac_data  <= ri_mac_data;
        ri_mac_last  <= 'd0;
        ri_mac_valid <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_mac_data_1d  <= 'd0;
        ri_mac_last_1d  <= 'd0;
        ri_mac_valid_1d <= 'd0;
    end else begin
        ri_mac_data_1d  <= ri_mac_data ;
        ri_mac_last_1d  <= ri_mac_last ;
        ri_mac_valid_1d <= ri_mac_valid;
    end
end

// a cnt to cnt the number of input mac_data
reg [15:0]              r_ip_cnt            ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_ip_cnt <= 'd0;
    else if (ri_mac_valid)
        r_ip_cnt <= r_ip_cnt + 1;
    else    
        r_ip_cnt <= 'd0;
end

// reg to output
// reg [7:0]               ro_udp_data         ;
reg [15:0]              ro_udp_len          ;
reg                     ro_udp_last         ;
reg                     ro_udp_valid        ;
// reg [7:0]               ro_icmp_data        ;
reg [15:0]              ro_icmp_len         ;
reg                     ro_icmp_last        ;
reg                     ro_icmp_valid       ;
assign                  o_udp_data   = ri_mac_data_1d   ;
assign                  o_udp_len    = ro_udp_len       ;
assign                  o_udp_last   = ro_udp_last      ;
assign                  o_udp_valid  = ro_udp_valid     ;
assign                  o_icmp_data  = ri_mac_data_1d   ;
assign                  o_icmp_len   = ro_icmp_len      ;
assign                  o_icmp_last  = ro_icmp_last     ;
assign                  o_icmp_valid = ro_icmp_valid    ;

// resolving
reg [15:0]              r_ip_len            ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        r_ip_len  <= 'd0;
    end else if (r_ip_cnt >= 2 && r_ip_cnt <=3 && ri_mac_valid) begin
        r_ip_len  <= {r_ip_len[7:0], ri_mac_data};
    end else begin
        r_ip_len  <= r_ip_len ;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_udp_len  <= 'd0;
        ro_icmp_len <= 'd0;
    end else if (r_ip_cnt == 4 && ri_mac_valid) begin
        ro_udp_len  <= r_ip_len - 20;   // minus the IP HEAD
        ro_icmp_len <= r_ip_len - 20;
    end else begin
        ro_udp_len  <= ro_udp_len ;
        ro_icmp_len <= ro_icmp_len;
    end
end

reg [7:0]               r_ip_type           ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_ip_type <= 'd0;
    else if (r_ip_cnt == 9 && ri_mac_valid)
        r_ip_type <= ri_mac_data;
    else
        r_ip_type <= r_ip_type;
end

reg [31:0]              r_ip_target         ;
reg [31:0]              r_ip_source         ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_ip_target <= 'd0;
    else if (r_ip_cnt >= 12 && r_ip_cnt <= 15 && ri_mac_valid)
        r_ip_target <= {r_ip_target[23:0], ri_mac_data};
    else
        r_ip_target <= r_ip_target;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_ip_source <= 'd0;
    else if (r_ip_cnt >= 16 && r_ip_cnt <= 19 && ri_mac_valid)  
        r_ip_source <= {r_ip_source[23:0], ri_mac_data};
    else
        r_ip_source <= r_ip_source;
end     

// ctrl valid
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_udp_valid <= 'd0;
    else if (ri_mac_last_1d && ri_mac_valid_1d)
        ro_udp_valid <= 'd0;
    else if (r_ip_cnt == 20 && r_ip_type == 17 && r_ip_source == ri_source_ip)  
        ro_udp_valid <= 'd1;
    else
        ro_udp_valid <= ro_udp_valid;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_icmp_valid <= 'd0;
    else if (ri_mac_last_1d && ri_mac_valid_1d)
        ro_icmp_valid <= 'd0;
    else if (r_ip_cnt == 20 && r_ip_type == 1 && r_ip_source == ri_source_ip)  
        ro_icmp_valid <= 'd1;
    else
        ro_icmp_valid <= ro_icmp_valid;
end

// ctrl last
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_udp_last <= 'd0;
    end else if (ri_mac_valid_1d && r_ip_type == 17 && ri_mac_last) 
        ro_udp_last <= 'd1;
    else
        ro_udp_last <= 'd0;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_icmp_last <= 'd0;
    end else if (ri_mac_valid_1d && r_ip_type == 1 && ri_mac_last)      // cant use ro_valid becase if there only one data it will not work
        ro_icmp_last <= 'd1;
    else
        ro_icmp_last <= 'd0;
end


endmodule
