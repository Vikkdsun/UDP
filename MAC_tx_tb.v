`timescale 1ns/1ps

module MAC_tx_tb();

reg clk, rst;

initial begin
    rst = 1;
    #100;
    @(posedge clk) rst = 0;
end

always begin
    clk = 0 ;
    #10;
    clk = 1;
    #10;
end

MAC_tx#(
    .P_TARTGET_MAC   ({8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}),
    .P_SOURCE_MAC    ({8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}),
    .P_CRC_CHECK     (1                                    ) 
)
MAC_tx_u0
(
    .i_clk                  (clk),
    .i_rst                  (rst),

    .i_target_mac           (i_target_mac      ),
    .i_target_mac_valid     (i_target_mac_valid),
    .i_source_mac           (i_source_mac      ),
    .i_source_mac_valid     (i_source_mac_valid),

    .i_udp_valid            (i_udp_valid),
    .o_udp_ready            (),
    .i_send_type            (i_send_type ),
    .i_send_len             (i_send_len  ),
    .i_send_data            (i_send_data ),
    .i_send_last            (i_send_last ),
    .i_send_valid           (i_send_valid),


    .o_GMII_data            (),
    .o_GMII_valid           ()
);

reg [47:0]  i_target_mac        ;
reg         i_target_mac_valid  ;
reg [47:0]  i_source_mac        ;
reg         i_source_mac_valid  ;

reg         i_udp_valid         ;

reg [15:0]  i_send_type         ;
reg [15:0]  i_send_len          ;
reg [7 :0]  i_send_data         ;
reg         i_send_last         ;
reg         i_send_valid        ;

initial
begin
    i_target_mac       = 'd0;
    i_target_mac_valid = 'd0;
    i_source_mac       = 'd0;
    i_source_mac_valid = 'd0;
    i_udp_valid        = 'd0;
end

initial 
begin
    i_send_type  <= 'd0;
    i_send_len   <= 'd0;
    i_send_data  <= 'd0;
    i_send_last  <= 'd0;
    i_send_valid <= 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    i_send_type  <= 'd1;
    i_send_len   <= 'd2;
    i_send_data  <= 'd1;
    i_send_last  <= 'd0;
    i_send_valid <= 'd1;
    @(posedge clk);
    i_send_type  <= 'd1;
    i_send_len   <= 'd2;
    i_send_data  <= 'd2;
    i_send_last  <= 'd1;
    i_send_valid <= 'd1;
    @(posedge clk);
    i_send_type  <= 'd0;
    i_send_len   <= 'd0;
    i_send_data  <= 'd0;
    i_send_last  <= 'd0;
    i_send_valid <= 'd0;
    @(posedge clk);
    i_send_type  <= 'd2;
    i_send_len   <= 'd2;
    i_send_data  <= 'd1;
    i_send_last  <= 'd0;
    i_send_valid <= 'd1;
    @(posedge clk);
    i_send_type  <= 'd2;
    i_send_len   <= 'd2;
    i_send_data  <= 'd2;
    i_send_last  <= 'd1;
    i_send_valid <= 'd1;
    @(posedge clk);
    i_send_type  <= 'd0;
    i_send_len   <= 'd0;
    i_send_data  <= 'd0;
    i_send_last  <= 'd0;
    i_send_valid <= 'd0;
    @(posedge clk);
end
















endmodule
