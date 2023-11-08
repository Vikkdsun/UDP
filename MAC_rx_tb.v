`timescale 1ns/1ps;

module MAC_rx_tb();

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

reg [7:0]       i_GMII_data    ;
reg             i_GMII_valid   ;

reg [47:0]  i_target_mac        ;
reg         i_target_mac_valid  ;
reg [47:0]  i_source_mac        ;
reg         i_source_mac_valid  ;

MAC_rx#(
    .P_TARGET_MAC    ( {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}  ),
    .P_SOURCE_MAC    ( {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}  ),
    .P_CRC_CHECK     ( 1                                                         )  
)
MAC_rx_u0
(
    .i_clk               (clk),
    .i_rst               (rst),

    .i_target_mac        (i_target_mac      ),
    .i_target_mac_valid  (i_target_mac_valid),
    .i_source_mac        (i_source_mac      ),
    .i_source_mac_valid  (i_source_mac_valid),

    .o_post_type         (),   // 1
    .o_post_data         (),   // 1
    .o_post_last         (),   // 1
    .o_post_valid        (),   // 1

    .o_rec_src_mac       (),   // 1
    .o_rec_src_valid     (),   // 1
    .o_crc_error         (),   // 1
    .o_crc_valid         (),   // 1

    .i_GMII_data         (i_GMII_data ),
    .i_GMII_valid        (i_GMII_valid)
);


initial
begin
    i_target_mac       = 'd0;
    i_target_mac_valid = 'd0;
    i_source_mac       = 'd0;
    i_source_mac_valid = 'd0;
end



initial
begin
    i_GMII_data  <= 'd0;
    i_GMII_valid <= 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    i_GMII_data  <= 8'h55;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h55;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h55;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h55;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h55;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h55;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h55;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'hd5;
    i_GMII_valid <= 'd1;
    // end foreahead
    @(posedge clk );
    i_GMII_data  <= 8'h00;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h00;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h00;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h00;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h00;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h00;
    i_GMII_valid <= 'd1;
    @(posedge clk );

    i_GMII_data  <= 8'h01;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h02;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h03;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h04;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h05;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h06;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h00;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'h00;
    i_GMII_valid <= 'd1;
    @(posedge clk );
        // data
    i_GMII_data  <= 8'd1;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'd1;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'd1;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'd1;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    // crc
    i_GMII_data  <= 8'd2;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'd2;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'd2;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 8'd2;
    i_GMII_valid <= 'd1;
    @(posedge clk );
    i_GMII_data  <= 'd0;
    i_GMII_valid <= 'd0;
    @(posedge clk );
end


endmodule
