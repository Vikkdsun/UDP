`timescale 1ns/1ps

module ARP_rx_tb();

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

ARP_rx#(
    .P_TARGET_IP  ({8'd192,8'd168,8'd1,8'd1}            )    ,
    .P_SOURCE_MAC ({8'h00,8'h00,8'h00,8'h00,8'h00,8'h00})    ,
    .P_SOURCE_IP  ({8'd192,8'd168,8'd1,8'd2}            )    
)
ARP_rx_u0
(
    .i_clk               (clk),
    .i_rst               (rst),

    .i_source_ip         (i_source_ip ),
    .i_s_ip_valid        (i_s_ip_valid),

    .i_mac_data          (i_mac_data ),
    .i_mac_last          (i_mac_last ),
    .i_mac_valid         (i_mac_valid),

    .o_target_mac        (),
    .o_target_ip         (),
    .o_target_valid      (),

    .o_tirg_reply        ()
);

reg [31:0]    i_source_ip ;
reg           i_s_ip_valid;
initial
begin
    i_source_ip  <= 'd0;
    i_s_ip_valid <= 'd0;
end

reg [7 :0]    i_mac_data    ;
reg           i_mac_last    ;
reg           i_mac_valid   ;

initial
begin
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd8;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd6;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd4;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;

    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk); 
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd1;
    i_mac_valid <= 'd1;
    @(posedge clk);

    /*----------fin--------*/
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd0;
    @(posedge clk);

    /*---------- #2 -----------*/
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd8;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd6;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd4;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;

    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk); 
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd1;
    i_mac_valid <= 'd1;
    @(posedge clk);

    /*----------fin--------*/
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd0;
    @(posedge clk);
end


endmodule
