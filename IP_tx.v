module IP_tx#(
    parameter       P_ST_TARGET_IP = {8'd192,8'd168,8'd1,8'd0},
    parameter       P_ST_SOURCE_IP = {8'd192,8'd168,8'd1,8'd1}
)(
    input               i_clk           ,
    input               i_rst           ,

    input [31:0]        i_target_ip     ,
    input               i_target_valid  ,
    input [31:0]        i_source_ip     ,
    input               i_source_valid  ,

    input [7:0]         i_send_data     ,
    input [15:0]        i_send_len      ,
    input [7:0]         i_send_type     ,
    input               i_send_last     ,
    input               i_send_valid    ,

    output [31:0]       o_arp_seek_ip   ,       // send to arp to seek for the target ip
    output              o_arp_seek_valid,

    output [7:0]        o_mac_data      ,
    output [15:0]       o_mac_len       ,
    output [15:0]       o_mac_type      ,
    output              o_mac_last      ,
    output              o_mac_valid     
);

// output reg
// reg [7:0]               ro_mac_data             ;
assign                  o_mac_data = r_ip_pre_dout;
// reg [15:0]              ro_mac_len              ;
assign                  o_mac_len = ri_send_len ;
reg [15:0]              ro_mac_type             ;
reg                     ro_mac_last             ;
reg                     ro_mac_valid            ;
assign                  o_mac_type  = ro_mac_type ;
assign                  o_mac_last  = ro_mac_last ;
assign                  o_mac_valid = ro_mac_valid;

// save ip
reg [31:0]              ri_target_ip            ;
reg [31:0]              ri_source_ip            ;
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
reg [7:0]               ri_send_data            ;
reg [15:0]              ri_send_len             ;
reg [7:0]               ri_send_type            ;
reg                     ri_send_last            ;
reg                     ri_send_valid           ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_send_data  <= 'd0;
        ri_send_len   <= 'd0;
        ri_send_type  <= 'd0;
        ri_send_last  <= 'd0;
        ri_send_valid <= 'd0;
    end else if (i_send_valid) begin
        ri_send_data  <= i_send_data ;
        ri_send_len   <= i_send_len + 20 ;      // plus the IP Head
        ri_send_type  <= i_send_type ;
        ri_send_last  <= i_send_last ;
        ri_send_valid <= i_send_valid;
    end else begin
        ri_send_data  <= ri_send_data;
        ri_send_len   <= ri_send_len ;
        ri_send_type  <= ri_send_type;
        ri_send_last  <= 'd0;
        ri_send_valid <= 'd0;
    end
end

// FIFO to buffer the data_in
reg                     r_fifo_rden             ;
wire [7:0]              w_fifo_dout             ;
wire                    w_fifo_full             ;
wire                    w_fifo_empty            ;
FIFO_MAC_8X64 FIFO_IP_8X1024_U0 (
  .clk              (i_clk), 
  .din              (ri_send_data), 
  .wr_en            (ri_send_valid), 
  .rd_en            (r_fifo_rden), 
  .dout             (w_fifo_dout ), 
  .full             (w_fifo_full ), 
  .empty            (w_fifo_empty)  
);

// cnt to count
reg [15:0]              r_ip_cnt                ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_ip_cnt <= 'd0;
    else if (r_ip_cnt == ri_send_len - 1)
        r_ip_cnt <= 'd0;
    else if ((!ri_send_valid_1d && ri_send_valid) || r_ip_cnt)
        r_ip_cnt <= r_ip_cnt + 1;
    else
        r_ip_cnt <= r_ip_cnt;
end

// delay one clk
reg                     ri_send_valid_1d        ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ri_send_valid_1d <= 'd0;
    else 
        ri_send_valid_1d <= ri_send_valid;
end

// logotype
reg [15:0]              r_logotype              ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_logotype <= 'd0;
    else if (ro_mac_valid_1d && !ro_mac_valid)
        r_logotype <= r_logotype + 1;
    else
        r_logotype <= r_logotype;
end

reg                     ro_mac_valid_1d         ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_mac_valid_1d <= 'd0;
    else 
        ro_mac_valid_1d <= ro_mac_valid;
end

// CRC
reg [31:0]              r_crc_result            ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_result <= 'd0;
    else if (r_ip_cnt == 0 && !ri_send_valid_1d && ri_send_valid)  
        r_crc_result <= 16'h4500 +                  // Version + Len of Head + serve
                        ri_send_len +               // Len
                        r_logotype +                // logotype
                        16'h4000 +                  // logo + sheet offset
                        {8'd64, ri_send_type} +     // living time + agreement
                        ri_source_ip[31:16] +       // source_ip
                        ri_source_ip[15:0] +
                        ri_target_ip[31:16] +       // target_ip
                        ri_target_ip[15:0];               
    else if (r_ip_cnt == 1)  
        r_crc_result <= r_crc_result[31:16] + r_crc_result[15:0];
    else if (r_ip_cnt == 2)
        r_crc_result <= r_crc_result[31:16] + r_crc_result[15:0];
    else if (r_ip_cnt == 3)
        r_crc_result <= ~r_crc_result;
    else
        r_crc_result <= r_crc_result;
end

// output buffer
reg [7:0]               r_ip_pre_dout           ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_ip_pre_dout <= 'd0;
    else case(r_ip_cnt)
        0       : r_ip_pre_dout <= 8'h45;
        1       : r_ip_pre_dout <= 8'h00;
        2       : r_ip_pre_dout <= ri_send_len[15:8];
        3       : r_ip_pre_dout <= ri_send_len[7: 0];
        4       : r_ip_pre_dout <= r_logotype[15: 8];
        5       : r_ip_pre_dout <= r_logotype[7 : 0];
        6       : r_ip_pre_dout <= 8'h40;
        7       : r_ip_pre_dout <= 8'h00;
        8       : r_ip_pre_dout <= 8'd64;
        9       : r_ip_pre_dout <= ri_send_type;
        10      : r_ip_pre_dout <= r_crc_result[15: 8];
        11      : r_ip_pre_dout <= r_crc_result[7 : 0];
        12      : r_ip_pre_dout <= ri_source_ip[31:24];
        13      : r_ip_pre_dout <= ri_source_ip[23:16];
        14      : r_ip_pre_dout <= ri_source_ip[15: 8];
        15      : r_ip_pre_dout <= ri_source_ip[7 : 0];
        16      : r_ip_pre_dout <= ri_target_ip[31:24];
        17      : r_ip_pre_dout <= ri_target_ip[23:16];
        18      : r_ip_pre_dout <= ri_target_ip[15: 8];
        19      : r_ip_pre_dout <= ri_target_ip[7 : 0];
        default : r_ip_pre_dout <= w_fifo_dout;
    endcase
end

// ctrl rden
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_fifo_rden <= 'd0;
    else if (r_rden_cnt == ri_send_len - 20 - 1 && r_fifo_rden)
        r_fifo_rden <= 'd0;
    else if (r_ip_cnt == 18)
        r_fifo_rden <= 'd1;
    else
        r_fifo_rden <= r_fifo_rden;
end

// use a rden cnt
reg [15:0]              r_rden_cnt              ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_rden_cnt <= 'd0;
    else if (r_rden_cnt == ri_send_len - 20)
        r_rden_cnt <= 'd0;
    else if (r_fifo_rden)
        r_rden_cnt <= r_rden_cnt + 1;
    else
        r_rden_cnt <= r_rden_cnt;
end

// ctrl TYPE LAST VALID
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_mac_type <= 'd0;
    else
        ro_mac_type <= 16'h0800;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_mac_valid <= 'd0;
    else if (ro_mac_last)
        ro_mac_valid <= 'd0;
    else if (!ri_send_valid_1d && ri_send_valid && r_ip_cnt == 0)
        ro_mac_valid <= 'd1;
    else
        ro_mac_valid <= ro_mac_valid;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_mac_last <= 'd0;
    else if (r_rden_cnt == ri_send_len - 20)
        ro_mac_last <= 'd1;
    else
        ro_mac_last <= 'd0;
end

// ctrl to ARP
reg [31:0]              ro_arp_seek_ip              ;
reg                     ro_arp_seek_valid           ;
assign                  o_arp_seek_ip    = ro_arp_seek_ip   ;
assign                  o_arp_seek_valid = ro_arp_seek_valid;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_arp_seek_ip <= 'd0;
    else if (!ri_send_valid_1d && ri_send_valid && r_ip_cnt == 0)      
        ro_arp_seek_ip <= ri_target_ip;
    else
        ro_arp_seek_ip <= ro_arp_seek_ip;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_arp_seek_valid <= 'd0;
    else if (!ri_send_valid_1d && ri_send_valid && r_ip_cnt == 0)
        ro_arp_seek_valid <= 'd1;
    else
        ro_arp_seek_valid <= 'd0;
end


endmodule
