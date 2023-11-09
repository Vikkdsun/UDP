`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: MAC_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MAC_tx#(
    parameter       P_TARTGET_MAC   =   {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
                    P_SOURCE_MAC    =   {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
                    P_CRC_CHECK     =   1
)(
    input           i_clk       ,
    input           i_rst       ,

    /*--------info port--------*/   
    input  [47:0]   i_target_mac        ,
    input           i_target_mac_valid  ,
    input  [47:0]   i_source_mac        ,
    input           i_source_mac_valid  ,

    /*--------data port--------*/
    input           i_udp_valid         ,
    output          o_udp_ready         ,
    input  [15:0]   i_send_type         ,
    input  [15:0]   i_send_len          ,
    input  [7 :0]   i_send_data         ,
    input           i_send_last         ,
    input           i_send_valid        ,
    
    /*--------GMII port--------*/
    output [7 :0]   o_GMII_data         ,
    output          o_GMII_valid        
);

/***************function**************/

/***************parameter*************/
localparam          P_GAP = 10          ;
/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [15:0]         ri_send_type        ;
reg  [15:0]         ri_send_len         ;
reg  [7 :0]         ri_send_data        ;
reg                 ri_send_valid       ;
reg                 ri_send_valid_1d    ;
reg  [7 :0]         ro_GMII_data        ;
reg                 ro_GMII_valid       ;
reg                 ro_GMII_valid_1d    ;
reg  [47:0]         r_target_mac        ;
reg  [47:0]         r_source_mac        ;
reg                 r_fifo_mac_rd_en    ;
reg  [15:0]         r_mac_pkg_cnt       ;
reg  [7 :0]         r_mac_data          ;
reg                 r_mac_data_valid    ;
reg                 r_mac_data_valid_1d ;
reg  [15:0]         r_mac_data_cnt      ;
reg                 r_crc_rst           ;          
reg                 r_crc_en            ;
reg  [1 :0]         r_crc_out_cnt       ;  
reg                 r_crc_out_cnt_1d    ;
reg  [15:0]         r_gap_lat           ;
reg                 r_gap_lock          ;
reg  [15:0]         r_gap_cnt           ;
reg                 ri_udp_valid        ;
reg                 ro_udp_ready        ;
reg                 r_fifo_mac_rd_en_1d ;

/***************wire******************/
wire [7 :0]         w_fifo_mac_dout     ;
wire                w_fifo_mac_full     ;
wire                w_fifo_mac_empty    ;
wire                w_send_valid_pos    ;
wire                w_send_valid_neg    ;
wire [31:0]         w_crc_result        ;
wire [15:0]         w_fifo_len_dout     ;
wire                w_fifo_len_empty    ;
wire                w_fifo_len_full     ;

/***************component*************/
FIFO_MAC_8X64 FIFO_MAC_8X1024_U0 (
  .clk              (i_clk              ),      // input wire clk
  .din              (ri_send_data       ),      // input wire [7 : 0] din
  .wr_en            (ri_send_valid      ),  // input wire wr_en
  .rd_en            (r_fifo_mac_rd_en   ),  // input wire rd_en
  .dout             (w_fifo_mac_dout    ),    // output wire [7 : 0] dout
  .full             (w_fifo_mac_full    ),    // output wire full
  .empty            (w_fifo_mac_empty   )  // output wire empty
);

FIFO_16X64 FIFO_16X64_LEN (
  .clk              (i_clk              ),      
  .din              (i_send_len         ),      
  .wr_en            (i_send_valid & !ri_send_valid), 
  .rd_en            (r_fifo_mac_rd_en & !r_fifo_mac_rd_en_1d), 
  .dout             (w_fifo_len_dout    ),   
  .full             (w_fifo_len_full    ),
  .empty            (w_fifo_len_empty   ) 
);

CRC32_D8 CRC32_D8_u0(
  .i_clk            (i_clk              ),
  .i_rst            (r_crc_rst          ),
  .i_en             (r_crc_en           ),
  .i_data           (r_mac_data         ),
  .o_crc            (w_crc_result       )   
);

/***************assign****************/
assign o_GMII_data      = ro_GMII_data      ;
assign o_GMII_valid     = ro_GMII_valid     ;
assign w_send_valid_pos = r_gap_cnt == P_GAP && !w_fifo_len_empty;
assign w_send_valid_neg = !ri_send_valid & ri_send_valid_1d;
assign o_udp_ready      = ro_udp_ready      ;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_mac_rd_en_1d <= 'd0;
    else 
        r_fifo_mac_rd_en_1d <= r_fifo_mac_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_target_mac <= P_TARTGET_MAC;
    else if(i_target_mac_valid)
        r_target_mac <= i_target_mac;
    else
        r_target_mac <= r_target_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_source_mac <= P_SOURCE_MAC ;
    else if(i_source_mac_valid)
        r_source_mac <= i_source_mac;
    else
        r_source_mac <= r_source_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_send_type  <= 'd0;
        ri_send_len   <= 'd0;
        ri_send_data  <= 'd0;
        ri_send_valid <= 'd0;
    end else if(i_send_valid) begin
        ri_send_type  <= i_send_type ;
        ri_send_len   <= i_send_len  ;
        ri_send_data  <= i_send_data ;
        ri_send_valid <= i_send_valid;
    end else begin
        ri_send_type  <= ri_send_type ;
        ri_send_len   <= ri_send_len  ;
        ri_send_data  <= 'd0 ;
        ri_send_valid <= 'd0;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_pkg_cnt <= 'd0;
    else if(r_crc_out_cnt == 3)
        r_mac_pkg_cnt <= 'd0;
    else if(w_send_valid_pos || r_mac_pkg_cnt)
        r_mac_pkg_cnt <= r_mac_pkg_cnt + 1;
    else 
        r_mac_pkg_cnt <= r_mac_pkg_cnt;
end
      

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_data <= 'd0;
    else case(r_mac_pkg_cnt)
        0,1,2,3,4,5,6   :r_mac_data <= 8'h55;
        7               :r_mac_data <= 8'hd5;
        8               :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[47:40];
        9               :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[39:32];
        10              :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[31:24];
        11              :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[23:16];
        12              :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[15: 8];
        13              :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[7 : 0];
        14              :r_mac_data <= r_source_mac[47:40];
        15              :r_mac_data <= r_source_mac[39:32];
        16              :r_mac_data <= r_source_mac[31:24];
        17              :r_mac_data <= r_source_mac[23:16];
        18              :r_mac_data <= r_source_mac[15: 8];
        19              :r_mac_data <= r_source_mac[7 : 0];
        20              :r_mac_data <= ri_send_type[15: 8];
        21              :r_mac_data <= ri_send_type[7 : 0];
        default         :r_mac_data <= w_fifo_mac_dout;
    endcase
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_data_valid <= 'd0;
    else if(r_mac_data_cnt == w_fifo_len_dout + 1)
        r_mac_data_valid <= 'd0;
    else if(w_send_valid_pos)
        r_mac_data_valid <= 'd1;
    else 
        r_mac_data_valid <= r_mac_data_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_data_cnt <= 'd0;
    else if(r_mac_data_cnt == w_fifo_len_dout + 1)
        r_mac_data_cnt <= 'd0;
    else if(r_fifo_mac_rd_en | r_mac_data_cnt)
        r_mac_data_cnt <= r_mac_data_cnt + 1;
    else 
        r_mac_data_cnt <= r_mac_data_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_mac_rd_en <= 'd0;
    else if(r_mac_data_cnt == w_fifo_len_dout - 1)
        r_fifo_mac_rd_en <= 'd0;
    else if(r_mac_pkg_cnt == 20)
        r_fifo_mac_rd_en <= 'd1;
    else 
        r_fifo_mac_rd_en <= r_fifo_mac_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_rst <= 'd1;
    else if(r_mac_pkg_cnt == 8 )
        r_crc_rst <= 'd0;
    else if(r_crc_out_cnt == 3)
        r_crc_rst <= 'd1;
    else 
        r_crc_rst <= r_crc_rst;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_en <= 'd0;
    else if(r_mac_data_cnt == w_fifo_len_dout + 1)
        r_crc_en <= 'd0;
    else if(r_mac_pkg_cnt == 8 )
        r_crc_en <= 'd1;
    else 
        r_crc_en <= r_crc_en;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_out_cnt <= 'd0;
    else if(r_crc_out_cnt == 3)   
        r_crc_out_cnt <= 'd0;
    else if((!r_mac_data_valid && r_mac_data_valid_1d) || r_crc_out_cnt)
        r_crc_out_cnt <= r_crc_out_cnt + 1;
    else 
        r_crc_out_cnt <= r_crc_out_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_GMII_data <= 'd0;
    else if(r_mac_data_valid)
        ro_GMII_data <= r_mac_data;
    else case(r_crc_out_cnt)
        0       :ro_GMII_data <= w_crc_result[7 : 0];
        1       :ro_GMII_data <= w_crc_result[15: 8];
        2       :ro_GMII_data <= w_crc_result[23:16];
        3       :ro_GMII_data <= w_crc_result[31:24];
        default :ro_GMII_data <= 'd0;
    endcase   
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_out_cnt_1d <= 'd0;
    else if(r_crc_out_cnt == 3)
        r_crc_out_cnt_1d <= 'd1;
    else 
        r_crc_out_cnt_1d <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_GMII_valid <= 'd0;
    else if(r_crc_out_cnt_1d)
        ro_GMII_valid <= 'd0;
    else if(r_mac_data_valid)
        ro_GMII_valid <= 'd1;
    else    
        ro_GMII_valid <= ro_GMII_valid;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_send_valid_1d    <= 'd0;
        r_mac_data_valid_1d <= 'd0;
    end else begin
        ri_send_valid_1d    <= ri_send_valid   ;
        r_mac_data_valid_1d <= r_mac_data_valid;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_udp_valid <= 'd0 ;
        ro_GMII_valid_1d <= 'd0;
    end else begin
        ri_udp_valid <= i_udp_valid;
        ro_GMII_valid_1d <= ro_GMII_valid;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_udp_ready <= 'd0;
    else if( r_mac_data_cnt == w_fifo_len_dout  - 2)
        ro_udp_ready <= 'd1;
    else if(i_udp_valid)
        ro_udp_ready <= 'd0;
    else 
        ro_udp_ready <= ro_udp_ready;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_gap_cnt <= 'd1;
    else if(ro_GMII_valid)
        r_gap_cnt <= 'd0;
    else if(r_gap_cnt == P_GAP)
        r_gap_cnt <= r_gap_cnt;
    else if((!ro_GMII_valid && ro_GMII_valid_1d) || r_gap_cnt)
        r_gap_cnt <= r_gap_cnt + 1;
    else 
        r_gap_cnt <= r_gap_cnt;
end

endmodule
