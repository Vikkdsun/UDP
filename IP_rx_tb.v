`timescale 1ns/1ps

module IP_rx_tb();

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

IP_rx#(
    .P_ST_TARGET_IP ({8'd192,8'd168,8'd1,8'd0}),
    .P_ST_SOURCE_IP ({8'd192,8'd168,8'd1,8'd1})
)
IP_rx_u0
(
    .i_clk               (clk           ),
    .i_rst               (rst           ),

    .i_target_ip         (i_target_ip   ),
    .i_target_valid      (i_target_valid),
    .i_source_ip         (i_source_ip   ),
    .i_source_valid      (i_source_valid),

    .o_udp_data          (),
    .o_udp_len           (),
    .o_udp_last          (),
    .o_udp_valid         (),
    .o_icmp_data         (),
    .o_icmp_len          (),
    .o_icmp_last         (),
    .o_icmp_valid        (),

    .i_mac_data          (i_mac_data    ),
    .i_mac_last          (i_mac_last    ),
    .i_mac_valid         (i_mac_valid   )
);

reg [31:0]        i_target_ip    ;
reg               i_target_valid ;
reg [31:0]        i_source_ip    ;
reg               i_source_valid ;

initial
begin
    i_target_ip     = 'd0;
    i_target_valid  = 'd0;
    i_source_ip     = 'd0;
    i_source_valid  = 'd0;
end

reg [7:0]         i_mac_data        ;
reg               i_mac_last        ;
reg               i_mac_valid       ;

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
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 'd24;
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
    i_mac_data  <= 'd17;
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

    i_mac_data  <= 8'd192;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd168;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 8'd192;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd168;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 8'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd2;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd3;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd4;
    i_mac_last  <= 'd1;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd0;
    @(posedge clk);



    /*--- #2 ---*/
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
    i_mac_data  <= 'd21;
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

    i_mac_data  <= 8'd192;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd168;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 8'd192;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd168;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);
    i_mac_data  <= 8'd1;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 8'd1;
    i_mac_last  <= 'd1;
    i_mac_valid <= 'd1;
    @(posedge clk);

    i_mac_data  <= 'd0;
    i_mac_last  <= 'd0;
    i_mac_valid <= 'd0;
    @(posedge clk);
    
    // i_mac_data  <= 8'd2;
    // i_mac_last  <= 'd0;
    // i_mac_valid <= 'd1;
    // @(posedge clk);
    // i_mac_data  <= 8'd3;
    // i_mac_last  <= 'd0;
    // i_mac_valid <= 'd1;
    // @(posedge clk);
    // i_mac_data  <= 8'd4;
    // i_mac_last  <= 'd1;
    // i_mac_valid <= 'd1;
    // @(posedge clk);

    // i_mac_data  <= 'd0;
    // i_mac_last  <= 'd0;
    // i_mac_valid <= 'd0;
    // @(posedge clk);
end


endmodule
