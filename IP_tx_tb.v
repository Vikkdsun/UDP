`timescale 1ns/1ps

module IP_tx_tb();

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

IP_tx#(
    .P_ST_TARGET_IP ({8'd192,8'd168,8'd1,8'd0}),
    .P_ST_SOURCE_IP ({8'd192,8'd168,8'd1,8'd1})
)
IP_tx_u0
(
    .i_clk       (clk),
    .i_rst       (rst),

    /*--------info port --------*/
    .i_target_ip         (i_target_ip   ),
    .i_target_valid      (i_target_valid),
    .i_source_ip         (i_source_ip   ),
    .i_source_valid      (i_source_valid),

    /*--------data port--------*/
    .i_send_type         (i_send_type ),
    .i_send_len          (i_send_len  ),
    .i_send_data         (i_send_data ),
    .i_send_last         (i_send_last ),
    .i_send_valid        (i_send_valid),

    .o_arp_seek_ip       (),
    .o_arp_seek_valid    (),

    /*--------mac port--------*/
    .o_mac_type          (),
    .o_mac_len           (),
    .o_mac_data          (),
    .o_mac_last          (),
    .o_mac_valid         ()

);

reg [31:0]   i_target_ip    ;
reg          i_target_valid ;
reg [31:0]   i_source_ip    ;
reg          i_source_valid ;
initial
begin
    i_target_ip    <= 'd0;
    i_target_valid <= 'd0;
    i_source_ip    <= 'd0;
    i_source_valid <= 'd0;
end

reg [7 :0]   i_send_type    ;
reg [15:0]   i_send_len     ;
reg [7 :0]   i_send_data    ;
reg          i_send_last    ;
reg          i_send_valid   ;

initial
begin
    i_send_type  <= 'd0;
    i_send_len   <= 'd0;
    i_send_data  <= 'd0;
    i_send_last  <= 'd0;
    i_send_valid <= 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    i_send_type  <= 8'd6;
    i_send_len   <= 'd2;
    i_send_data  <= 'd1;
    i_send_last  <= 'd0;
    i_send_valid <= 'd1;
    @(posedge clk);
    i_send_type  <= 8'd6;
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

    // i_send_type  <= 8'd6;
    // i_send_len   <= 'd3;
    // i_send_data  <= 'd1;
    // i_send_last  <= 'd0;
    // i_send_valid <= 'd1;
    // @(posedge clk);
    // i_send_type  <= 8'd6;
    // i_send_len   <= 'd3;
    // i_send_data  <= 'd2;
    // i_send_last  <= 'd0;
    // i_send_valid <= 'd1;
    // @(posedge clk);
    // i_send_type  <= 8'd6;
    // i_send_len   <= 'd3;
    // i_send_data  <= 'd3;
    // i_send_last  <= 'd1;
    // i_send_valid <= 'd1;
    // @(posedge clk);

    // i_send_type  <= 'd0;
    // i_send_len   <= 'd0;
    // i_send_data  <= 'd0;
    // i_send_last  <= 'd0;
    // i_send_valid <= 'd0;
    // @(posedge clk);

end

endmodule
