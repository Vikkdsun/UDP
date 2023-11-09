module MAC_tx#(
    parameter               P_TARGET_MAC    = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}  ,
                            P_SOURCE_MAC    = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}  ,
                            P_CRC_CHECK     = 1                                                           
)(
    input                   i_clk                   ,
    input                   i_rst                   ,

    input [47:0]            i_target_mac            ,
    input                   i_target_mac_valid      ,
    input [47:0]            i_source_mac            ,
    input                   i_source_mac_valid      ,

    input                   i_udp_valid             ,
    output                  o_udp_ready             ,

    input  [15:0]           i_send_type             ,
    input  [15:0]           i_send_len              ,
    input  [7 :0]           i_send_data             ,
    input                   i_send_last             ,
    input                   i_send_valid            ,

    output [7:0]            o_GMII_data             ,
    output                  o_GMII_valid            
);

localparam                  P_GAP = 10              ;

// save MAC 
reg [47:0]                  ri_target_mac           ;
reg [47:0]                  ri_source_mac           ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ri_target_mac <= P_TARGET_MAC;
    else if (i_target_mac_valid)
        ri_target_mac <= i_target_mac;
    else
        ri_target_mac <= ri_target_mac;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ri_source_mac <= P_SOURCE_MAC;
    else if (i_source_mac_valid)
        ri_source_mac <= i_source_mac;
    else
        ri_source_mac <= ri_source_mac;
end

// isolation
reg [15:0]                  ri_send_type            ;
reg [15:0]                  ri_send_len             ;
reg [7 :0]                  ri_send_data            ;
reg                         ri_send_last            ;
reg                         ri_send_valid           ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_send_type  <= 'd0;
        ri_send_len   <= 'd0;
        ri_send_data  <= 'd0;
        ri_send_last  <= 'd0;
        ri_send_valid <= 'd0;
    end else if (i_send_valid) begin
        ri_send_type  <= i_send_type ;
        ri_send_len   <= i_send_len  ;
        ri_send_data  <= i_send_data ;
        ri_send_last  <= i_send_last ;
        ri_send_valid <= i_send_valid;
    end else begin
        ri_send_type  <= ri_send_type;
        ri_send_len   <= 'd0;
        ri_send_data  <= 'd0;
        ri_send_last  <= 'd0;
        ri_send_valid <= 'd0;
    end
end

// use 2 FIFO to buffer the input DATA and LEN
reg                         r_data_fifo_rden            ;
wire                        w_len_fifo_wren             ;
reg                         r_len_fifo_rden             ;
wire [7:0]                  w_data_fifo_dout            ;
wire                        w_data_fifo_full            ;
wire                        w_data_fifo_empty           ;
wire [15:0]                 w_len_fifo_dout             ;
wire                        w_len_fifo_full             ;
wire                        w_len_fifo_empty            ;



FIFO_MAC_8X64 FIFO_MAC_8X1024_U0 (
  .clk              (i_clk              ), 
  .din              (ri_send_data), 
  .wr_en            (ri_send_valid), 
  .rd_en            (r_data_fifo_rden), 
  .dout             (w_data_fifo_dout ), 
  .full             (w_data_fifo_full ), 
  .empty            (w_data_fifo_empty)  
);

FIFO_16X64 FIFO_16X64_LEN (
  .clk              (i_clk              ),      
  .din              (ri_send_len),      
  .wr_en            (w_len_fifo_wren), 
  .rd_en            (r_len_fifo_rden), 
  .dout             (w_len_fifo_dout ),   
  .full             (w_len_fifo_full ),
  .empty            (w_len_fifo_empty) 
);

// delay one clk to rinput
reg [15:0]                  ri_send_type_1d             ;
reg [15:0]                  ri_send_len_1d              ;
reg [7 :0]                  ri_send_data_1d             ;
reg                         ri_send_last_1d             ;
reg                         ri_send_valid_1d            ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_send_type_1d  <= 'd0;
        ri_send_len_1d   <= 'd0;
        ri_send_data_1d  <= 'd0;
        ri_send_last_1d  <= 'd0;
        ri_send_valid_1d <= 'd0;
    end else begin
        ri_send_type_1d  <= ri_send_type ;
        ri_send_len_1d   <= ri_send_len  ;
        ri_send_data_1d  <= ri_send_data ;
        ri_send_last_1d  <= ri_send_last ;
        ri_send_valid_1d <= ri_send_valid;
    end
end

// so we can use the posedge of ri_valid to used as the wren of LEN_FIFO
assign                      w_len_fifo_wren = !ri_send_valid_1d & ri_send_valid;

// another use of the w_len_fifo_wren is to begin the cnt of pkg
reg [15:0]                  r_mac_pkg_cnt               ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_mac_pkg_cnt <= 'd0;
    else if (w_GMII_valid_neg)
        r_mac_pkg_cnt <= 'd0;
    else if ((r_gap_cnt == P_GAP - 1 && !w_len_fifo_empty) || r_mac_pkg_cnt)
        r_mac_pkg_cnt <= r_mac_pkg_cnt + 1;
    else
        r_mac_pkg_cnt <= r_mac_pkg_cnt;
end

// if here we are pkg ing , but another input is in, then the r_mac_pkg_cnt wil ignore the new input and dont get new cycle of cnt.
// but we can know that the DATA_FIFO isnot empty that is the signal of begining cnt !!
// and we need to consider the GAP of GAP between two FRAMES
// so we use a cnt to cnt the gap num
reg [15:0]                  r_gap_cnt                   ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_gap_cnt <= 'd0;
    else if (r_GMII_pre_valid || (r_gap_cnt == P_GAP - 1 && !w_len_fifo_empty))
        r_gap_cnt <= 'd0;
    else if (r_gap_cnt == P_GAP - 1 && w_len_fifo_empty)
        r_gap_cnt <= r_gap_cnt;
    else if (w_GMII_valid_neg || r_gap_cnt)
        r_gap_cnt <= r_gap_cnt + 1;
    else
        r_gap_cnt <= r_gap_cnt + 1;
end 

// negedge of output valid
reg                         ro_GMII_valid               ;
assign                      o_GMII_valid = ro_GMII_valid;
reg                         ro_GMII_valid_1d            ;
wire                        w_GMII_valid_neg            ;
assign                      w_GMII_valid_neg = ro_GMII_valid_1d & !ro_GMII_valid;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_GMII_valid_1d <= 'd0;
    else
        ro_GMII_valid_1d <= ro_GMII_valid;
end

// reg to buffer output
reg [7:0]                   r_GMII_pre_dout             ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_GMII_pre_dout <= 'd0;
    else case(r_mac_pkg_cnt)
        0,1,2,3,4,5,6   :   r_GMII_pre_dout <= 8'h55;
        7               :   r_GMII_pre_dout <= 8'hd5;
        8               :   r_GMII_pre_dout <= ri_send_type == 16'h0806 ? 8'hff : ri_target_mac[47:40];
        9               :   r_GMII_pre_dout <= ri_send_type == 16'h0806 ? 8'hff : ri_target_mac[39:32];
        10              :   r_GMII_pre_dout <= ri_send_type == 16'h0806 ? 8'hff : ri_target_mac[31:24];
        11              :   r_GMII_pre_dout <= ri_send_type == 16'h0806 ? 8'hff : ri_target_mac[23:16];
        12              :   r_GMII_pre_dout <= ri_send_type == 16'h0806 ? 8'hff : ri_target_mac[15: 8];
        13              :   r_GMII_pre_dout <= ri_send_type == 16'h0806 ? 8'hff : ri_target_mac[7 : 0];

        14              :   r_GMII_pre_dout <= ri_source_mac[47:40] ;
        15              :   r_GMII_pre_dout <= ri_source_mac[39:32] ;
        16              :   r_GMII_pre_dout <= ri_source_mac[31:24] ;
        17              :   r_GMII_pre_dout <= ri_source_mac[23:16] ;
        18              :   r_GMII_pre_dout <= ri_source_mac[15: 8] ;
        19              :   r_GMII_pre_dout <= ri_source_mac[7 : 0] ;

        20              :   r_GMII_pre_dout <= ri_send_type[15:8]   ;
        21              :   r_GMII_pre_dout <= ri_send_type[7: 0]   ;
        default         :   r_GMII_pre_dout <= w_data_fifo_dout     ;
    endcase
end

// CTRL DATA FIFO rden and LEN rden
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_len_fifo_rden <= 'd0;
    else if (r_mac_pkg_cnt == 19)
        r_len_fifo_rden <= 'd1;
    else
        r_len_fifo_rden <= 'd0;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_data_fifo_rden <= 'd0;
    else if (r_data_rden_cnt == w_len_fifo_dout - 1)
        r_data_fifo_rden <= 'd0;
    else if (r_mac_pkg_cnt == 20)
        r_data_fifo_rden <= 'd1;
    else
        r_data_fifo_rden <= r_data_fifo_rden;
end

// use a cnt to ctrl the rden to zero
reg [15:0]                  r_data_rden_cnt                         ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_data_rden_cnt <= 'd0;
    else if (r_data_fifo_rden)
        r_data_rden_cnt <= r_data_rden_cnt + 1;
    else
        r_data_rden_cnt <= 'd0;
end

// use a cnt to make the output out the crc and ctrl the CRC_RST
reg                         r_GMII_pre_valid                        ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_GMII_pre_valid <= 'd0;
    else if (r_crc_cnt == 4)
        r_GMII_pre_valid <= 'd0;
    else if (r_gap_cnt == P_GAP - 1 && !w_len_fifo_empty)
        r_GMII_pre_valid <= 'd1;
    else
        r_GMII_pre_valid <= r_GMII_pre_valid;
end

// compute CRC
reg                         r_crc_en                                ;
reg                         r_crc_rst                               ;
wire [31:0]                 w_crc_result                            ;

CRC32_D8 CRC32_D8(
  .i_clk     (i_clk             ),
  .i_rst     (r_crc_rst         ),
  .i_en      (r_crc_en | r_crc_en_1d),
  .i_data    (r_GMII_pre_dout   ),
  .o_crc     (w_crc_result      )   
);

// ctrl CRC_EN and CRC_RST
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_en <= 'd0;
    else if (r_data_rden_cnt == w_len_fifo_dout && r_data_fifo_rden_1d && !r_data_fifo_rden)
        r_crc_en <= 'd0;
    else if (r_mac_pkg_cnt == 8)        // 55 d5 delete
        r_crc_en <= 'd1;
    else 
        r_crc_en <= r_crc_en;
end

// en is not the full stage before CRC because 55 d5 is not be computed
reg                         r_before_crc_valid                      ;
reg                         r_before_crc_valid_1d                   ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_before_crc_valid <= 'd0;
    else if (r_data_rden_cnt == w_len_fifo_dout && r_data_fifo_rden_1d && !r_data_fifo_rden)
        r_before_crc_valid <= 'd0;
    else if (r_gap_cnt == P_GAP - 1 && !w_len_fifo_empty)
        r_before_crc_valid <= 'd1;
    else 
        r_before_crc_valid <= r_before_crc_valid;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_before_crc_valid_1d <= 'd0;
    else
        r_before_crc_valid_1d <= r_before_crc_valid;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_rst <= 'd1;
    else if (r_crc_cnt == 4)  
        r_crc_rst <= 'd1;
    else if (r_mac_pkg_cnt == 8)
        r_crc_rst <= 'd0;
    else
        r_crc_rst <= r_crc_rst;
end

// use a cnt to make the output out the crc and ctrl the CRC_RST
// delay rden_data
reg                         r_data_fifo_rden_1d                     ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_data_fifo_rden_1d <= 'd0;
    else
        r_data_fifo_rden_1d <= r_data_fifo_rden;
end

reg [2:0]                   r_crc_cnt                               ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_cnt <= 'd0;
    else if (r_crc_cnt == 5)
        r_crc_cnt <= 'd0;
    else if (w_crc_en_neg || r_crc_cnt)
        r_crc_cnt <= r_crc_cnt + 1;
    else
        r_crc_cnt <= r_crc_cnt;
end

// // a pre valid
// reg                         r_GMII_pre_valid                        ;
// always@(posedge i_clk or posedge i_rst)
// begin
//     if (i_rst)  
//         r_GMII_pre_valid <= 'd0;
//     else if (r_crc_cnt == 5)  
//         r_GMII_pre_valid <= 'd0;
//     else if (r_gap_cnt == P_GAP - 1 && !w_len_fifo_empty)
//         r_GMII_pre_valid <= 'd1;
//     else
//         r_GMII_pre_valid <= r_GMII_pre_valid;
// end

// output
reg [7:0]                   ro_GMII_data                            ;
assign                      o_GMII_data = ro_GMII_data              ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_GMII_valid <= 'd0;
    end else if (r_GMII_pre_valid) begin
        ro_GMII_valid <= r_GMII_pre_valid;
    end else begin
        ro_GMII_valid <= 'd0;
    end
end

reg                         r_crc_en_1d                             ;
wire                        w_crc_en_neg                            ;
assign                      w_crc_en_neg = r_crc_en_1d & !r_crc_en  ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_en_1d <= 'd0;
    else 
        r_crc_en_1d <= r_crc_en;
end

// reg [31:0]                  r_crc_result                            ;
// reg [2:0]                   r_crc_cnt_1d                            ;
// always@(posedge i_clk or posedge i_rst)
// begin
//     if (i_rst) begin
//         r_crc_result <= 'd0;
//         r_crc_cnt_1d <= 'd0;
//     end else begin
//         r_crc_result <= w_crc_result;
//         r_crc_cnt_1d <= r_crc_cnt   ;
//     end
// end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_GMII_data <= 'd0;
    else if (r_before_crc_valid || r_before_crc_valid_1d)
        ro_GMII_data <= r_GMII_pre_dout;
    else case(r_crc_cnt)
        1       : ro_GMII_data <= w_crc_result[7 : 0];
        2       : ro_GMII_data <= w_crc_result[15: 8];
        3       : ro_GMII_data <= w_crc_result[23:16];
        4       : ro_GMII_data <= w_crc_result[31:24];
        default : ro_GMII_data <= 'd0;
    endcase
end

endmodule
