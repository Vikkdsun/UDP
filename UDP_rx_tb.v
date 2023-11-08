`timescale 1ns/1ps

module UDP_rx_tb();

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

UDP_rx#(
    .P_TARGET_PORT   (16'h8080) ,
    .P_SOURCE_PORT   (16'h8080)
)
UDP_rx_u0
(
    .i_clk                   (clk),
    .i_rst                   (rst),

    .i_target_port           (i_target_port      ),
    .i_target_port_valid     (i_target_port_valid),   
    .i_source_port           (i_source_port      ),
    .i_source_port_valid     (i_source_port_valid),

    .i_ip_data               (i_ip_data ),
    .i_ip_len                (i_ip_len  ),
    .i_ip_last               (i_ip_last ),
    .i_ip_valid              (i_ip_valid),

    .o_udp_data              (),
    .o_udp_len               (),
    .o_udp_last              (),
    .o_udp_valid             ()
);

reg [15:0]        i_target_port         ;
reg               i_target_port_valid   ;
reg [15:0]        i_source_port         ;
reg               i_source_port_valid   ;
initial
begin
    i_target_port        = 'd0;
    i_target_port_valid  = 'd0;
    i_source_port        = 'd0;
    i_source_port_valid  = 'd0;
end

reg [7:0]         i_ip_data             ;
reg [15:0]        i_ip_len              ;
reg               i_ip_last             ;
reg               i_ip_valid            ;
initial
begin
    i_ip_data  <= 'd0;
    i_ip_len   <= 'd0;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    /*  12¸ö  */
    i_ip_data  <= 'd128;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd128;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd128;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd128;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd5;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd6;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd7;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd8;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd9;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd10;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd11;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd42;
    i_ip_len   <= 'd12;
    i_ip_last  <= 'd1;
    i_ip_valid <= 'd1;
    @(posedge clk);

    i_ip_data  <= 'd0;
    i_ip_len   <= 'd0;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd0;
    @(posedge clk);
    /*---- #2 9ge -----*/
    i_ip_data  <= 'd128;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd128;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd128;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd128;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd1;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd2;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd3;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd4;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd1;
    @(posedge clk);
    i_ip_data  <= 'd5;
    i_ip_len   <= 'd9;
    i_ip_last  <= 'd1;
    i_ip_valid <= 'd1;
    @(posedge clk);
    

    // final
    i_ip_data  <= 'd0;
    i_ip_len   <= 'd0;
    i_ip_last  <= 'd0;
    i_ip_valid <= 'd0;
    @(posedge clk);

end

endmodule
