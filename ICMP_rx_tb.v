`timescale 1ns/1ps

module ICMP_rx_tb();

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

ICMP_rx ICMP_rx_u0(
    .i_clk           (clk),
    .i_rst           (rst),

    .i_icmp_data     (i_icmp_data ),
    .i_icmp_len      (i_icmp_len  ),
    .i_icmp_last     (i_icmp_last ),
    .i_icmp_valid    (i_icmp_valid),

    .o_trig_seq      (),
    .o_trig_reply    ()
);

reg [7:0]       i_icmp_data     ;
reg [15:0]      i_icmp_len      ;
reg             i_icmp_last     ;
reg             i_icmp_valid    ;

initial
begin
    i_icmp_data  <= 'd0;
    i_icmp_len   <= 'd0;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd1;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);

    i_icmp_data  <= 'd2;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd3;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);

    i_icmp_data  <= 'd1;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd1;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);

    i_icmp_data  <= 'd6;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd6;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);

    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd1;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    // final
    i_icmp_data  <= 'd0;
    i_icmp_len   <= 'd0;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd0;
    @(posedge clk);

    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd1;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);

    i_icmp_data  <= 'd2;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd3;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);

    i_icmp_data  <= 'd1;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd1;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);

    i_icmp_data  <= 'd6;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd6;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);

    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    i_icmp_data  <= 'd8;
    i_icmp_len   <= 'd12;
    i_icmp_last  <= 'd1;
    i_icmp_valid <= 'd1;
    @(posedge clk);
    // final
    i_icmp_data  <= 'd0;
    i_icmp_len   <= 'd0;
    i_icmp_last  <= 'd0;
    i_icmp_valid <= 'd0;
    @(posedge clk);
end

endmodule
