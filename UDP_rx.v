module UDP_rx#(
    parameter           P_TARGET_PORT   =  16'h8080 ,
                        P_SOURCE_PORT   =  16'h8080
)(
    input               i_clk                   ,
    input               i_rst                   ,

    input [15:0]        i_target_port           ,
    input               i_target_port_valid     ,   
    input [15:0]        i_source_port           ,
    input               i_source_port_valid     ,

    input [7:0]         i_ip_data               ,
    input [15:0]        i_ip_len                ,
    input               i_ip_last               ,
    input               i_ip_valid              ,

    output [7:0]        o_udp_data              ,
    output [15:0]       o_udp_len               ,
    output              o_udp_last              ,
    output              o_udp_valid             
);

// get port
reg [15:0]              ri_target_port          ;
reg [15:0]              ri_source_port          ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ri_target_port <= P_TARGET_PORT;
    else if (i_target_port_valid)
        ri_target_port <= i_target_port;
    else    
        ri_target_port <= ri_target_port;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ri_source_port <= P_SOURCE_PORT;
    else if (i_source_port_valid)
        ri_source_port <= i_source_port;
    else
        ri_source_port <= ri_source_port;
end 

// isolation
reg [7:0]               ri_ip_data              ;
reg [15:0]              ri_ip_len               ;
reg                     ri_ip_last              ;
reg                     ri_ip_valid             ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_ip_data  <= 'd0;
        ri_ip_len   <= 'd0;
        ri_ip_last  <= 'd0;
        ri_ip_valid <= 'd0;
    end else if (i_ip_valid) begin
        ri_ip_data  <= i_ip_data ;
        ri_ip_len   <= i_ip_len  ;
        ri_ip_last  <= i_ip_last ;
        ri_ip_valid <= i_ip_valid;
    end else begin
        ri_ip_data  <= ri_ip_data ;
        ri_ip_len   <= ri_ip_len  ;
        ri_ip_last  <= 'd0;
        ri_ip_valid <= 'd0;
    end    
end

// cnt 
reg [15:0]              r_udp_cnt               ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_udp_cnt <= 'd0;
    else if (ri_ip_valid)
        r_udp_cnt <= r_udp_cnt + 1;
    else
        r_udp_cnt <= 'd0;
end

// get port
reg [15:0]              r_udp_port_s            ;
reg [15:0]              r_udp_port_t            ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_udp_port_t <= 'd0;
    else if (r_udp_cnt >= 0 && r_udp_cnt <= 1 && ri_ip_valid)
        r_udp_port_t <= {r_udp_port_t[7:0], ri_ip_data};
    else
        r_udp_port_t <= r_udp_port_t;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_udp_port_s <= 'd0;
    else if (r_udp_cnt >= 2 && r_udp_cnt <= 3 && ri_ip_valid)
        r_udp_port_s <= {r_udp_port_s[7:0], ri_ip_data};
    else
        r_udp_port_s <= r_udp_port_s;
end

// // len
// reg [15:0]              r_udp_len               ;
// always@(posedge i_clk or posedge i_rst)
// begin
//     if (i_rst)
//         r_udp_len <= 'd0;
//     else if (r_udp_cnt >= 4 && r_udp_cnt <= 5 && ri_ip_valid)
//         r_udp_len <= {r_udp_len[7:0], ri_ip_data};
//     else
//         r_udp_len <= r_udp_len;
// end

// assign output
assign                  o_udp_data = ri_ip_data ;
reg [15:0]              ro_udp_len              ;
reg                     ro_udp_last             ;
reg                     ro_udp_valid            ;
assign                  o_udp_len   = ro_udp_len  ;
assign                  o_udp_last  = ro_udp_last ;
assign                  o_udp_valid = ro_udp_valid;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_udp_len <= 'd0;
    else
        ro_udp_len <= ri_ip_len - 8;
end

// ctrl valid
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_udp_valid <= 'd0;
    else if (ri_ip_last)
        ro_udp_valid <= 'd0;
    else if (r_udp_cnt == 7 && ri_ip_valid && ri_source_port == r_udp_port_s)
        ro_udp_valid <= 'd1;
    else
        ro_udp_valid <= ro_udp_valid;
end

// ctrl last
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_udp_last <= 'd0;
    else if (r_udp_cnt == ri_ip_len - 2)  
        ro_udp_last <= 'd1;
    else
        ro_udp_last <= 'd0;
end

endmodule
