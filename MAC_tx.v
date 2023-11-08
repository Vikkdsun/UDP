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

// isolation
reg [15:0]                  ri_send_type            ;
reg [7 :0]                  ri_send_data            ;
reg                         ri_send_valid           ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_send_type  <= 'd0;
        ri_send_data  <= 'd0;
        ri_send_valid <= 'd0;
    end else begin
        ri_send_type  <= i_send_type ;
        ri_send_data  <= i_send_data ;
        ri_send_valid <= i_send_valid;
    end
end

// save the src_mac and trg_mac
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

// use FIFO to save input_data and input_len and input_type
reg                         r_fifo_data_rden        ;
wire [7:0]                  w_fifo_data_out         ;
wire                        w_fifo_data_full        ;
wire                        w_fifo_data_empty       ;
FIFO_MAC_8X64 FIFO_MAC_8X1024_U0 (
  .clk              (i_clk              ),      // input wire clk
  .din              (ri_send_data       ),      // input wire [7 : 0] din
  .wr_en            (ri_send_valid      ),  // input wire wr_en
  .rd_en            (r_fifo_data_rden   ),  // input wire rd_en
  .dout             (w_fifo_data_out    ),    // output wire [7 : 0] dout
  .full             (w_fifo_data_full   ),    // output wire full
  .empty            (w_fifo_data_empty  )  // output wire empty
);

// wren of FIFO_LEN should just one clk
wire                        w_fifo_len_wren         ;
assign                      w_fifo_len_wren = i_send_valid & !ri_send_valid; 
wire [15:0]                 w_fifo_len_dout         ;
wire                        w_fifo_len_full         ;
wire                        w_fifo_len_empty        ;

FIFO_16X64 FIFO_16X64_LEN (
  .clk              (i_clk              ),      
  .din              (i_send_len),      
  .wr_en            (w_fifo_len_wren), 
  .rd_en            (), 
  .dout             (w_fifo_len_dout    ),   
  .full             (w_fifo_len_full    ),
  .empty            (w_fifo_len_empty   ) 
);

FIFO_16X64 FIFO_16X64_LEN (
  .clk              (i_clk              ),      
  .din              (i_send_len),      
  .wr_en            (w_fifo_len_wren), 
  .rd_en            (), 
  .dout             (w_fifo_len_dout    ),   
  .full             (w_fifo_len_full    ),
  .empty            (w_fifo_len_empty   ) 
);

























endmodule
