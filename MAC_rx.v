module MAC_rx#(
    parameter               P_TARGET_MAC    = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}  ,
                            P_SOURCE_MAC    = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}  ,
                            P_CRC_CHECK     = 1                                                           
)(
    input                   i_clk               ,
    input                   i_rst               ,

    input [47:0]            i_target_mac        ,
    input                   i_target_mac_valid  ,
    input [47:0]            i_source_mac        ,
    input                   i_source_mac_valid  ,

    output [15:0]           o_post_type         ,   // 1
    output [7 :0]           o_post_data         ,   // 1
    output                  o_post_last         ,   // 1
    output                  o_post_valid        ,   // 1

    output [47:0]           o_rec_src_mac       ,   // 1
    output                  o_rec_src_valid     ,   // 1
    output                  o_crc_error         ,   // 1
    output                  o_crc_valid         ,   // 1

    input [7:0]             i_GMII_data         ,
    input                   i_GMII_valid        
);

// isolation
reg [47:0]                  r_source_mac                    ;
reg [47:0]                  r_target_mac                    ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_source_mac <= P_SOURCE_MAC;
    else if (i_source_mac_valid)
        r_source_mac <= i_source_mac;
    else
        r_source_mac <= r_source_mac;
end           

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_target_mac <= P_TARGET_MAC;
    else if (i_target_mac_valid)
        r_target_mac <= i_target_mac;
    else
        r_target_mac <= r_target_mac;
end

reg [7:0]                   ri_GMII_data                    ;
reg                         ri_GMII_valid                   ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_GMII_data <= 'd0;
        ri_GMII_valid <= 'd0;
    end else begin
        ri_GMII_data <= i_GMII_data;
        ri_GMII_valid <= i_GMII_valid;
    end
end

// use a cnt to count how many input
reg [15:0]                  r_rec_cnt                       ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_rec_cnt <= 'd0;
    else if (ri_GMII_valid && r_rec_cnt == 6 && ri_GMII_data == 8'h55)
        r_rec_cnt <= r_rec_cnt;
    else if (ri_GMII_valid)
        r_rec_cnt <= r_rec_cnt + 1;
    else
        r_rec_cnt <= 'd0;
end

// use rec_cnt to check if we got the right forehead code
reg                         r_header_check                  ;
always@(*)
begin
    case(r_rec_cnt)
        0, 1, 2, 3, 4, 5    : r_header_check = ri_GMII_data == 8'h55    ? 'd1 : 'd0 ;
        6                   : r_header_check = ri_GMII_data == 8'h55 || ri_GMII_data == 8'hD5 ? 'd1 : 'd0 ;
        default             : r_header_check = 'd1                      ;
    endcase
end

reg                         r_header_access                 ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)      
        r_header_access <= 'd1;
    else if (!ri_GMII_valid)
        r_header_access <= 'd1;
    else if (ri_GMII_valid && r_rec_cnt >= 0 && r_rec_cnt <= 6 && !r_header_check)
        r_header_access <= 'd0;
    else
        r_header_access <= r_header_access;
end

// CTRL the out type
reg [15:0]                  ro_post_type                    ;
assign                      o_post_type = ro_post_type      ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_post_type <= 'd0;
    else if (r_rec_cnt >= 19 && r_rec_cnt <= 20 && ri_GMII_valid)
        ro_post_type <= {ro_post_type[7:0], ri_GMII_data};
    else 
        ro_post_type <= ro_post_type;
end

// ctrl the output o_rec_src_mac
reg [47:0]                  ro_rec_src_mac                  ;
assign                      o_rec_src_mac = ro_rec_src_mac  ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_rec_src_mac <= 'd0;
    else if (r_rec_cnt >= 13 && r_rec_cnt <= 18 && ri_GMII_valid)
        ro_rec_src_mac <= {ro_rec_src_mac[39:0], ri_GMII_data};
    else
        ro_rec_src_mac <= ro_rec_src_mac;
end

// ctrl o_rec_src_valid
reg                         ro_rec_src_valid                ;
assign                      o_rec_src_valid = ro_rec_src_valid;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_rec_src_valid <= 'd0;
    else if (r_rec_cnt == 19 && ri_GMII_valid)          // it meant to get the steady so delay one clk
        ro_rec_src_valid <= 'd1;
    else 
        ro_rec_src_valid <= ro_rec_src_valid;
end


// ctrl and calculate the CRC
// to get the end flag of the input MAC data part(because we dont get the len of data part)
// to calculate the CRC so we take delay of the input 
// to make the end of the after-delayed data part to equal to the input valid_neg (negedge)
// we do lot of delays
reg [7:0]                   ri_GMII_data_1d                 ;
reg                         ri_GMII_valid_1d                ;
reg [7:0]                   ri_GMII_data_2d                 ;
reg                         ri_GMII_valid_2d                ;
reg [7:0]                   ri_GMII_data_3d                 ;
reg                         ri_GMII_valid_3d                ;
reg [7:0]                   ri_GMII_data_4d                 ;
reg                         ri_GMII_valid_4d                ;
reg [7:0]                   ri_GMII_data_5d                 ;       // here we got the final one data of 5d is have the same clk with i_GMII_data's crc part delay 1 clk.
reg                         ri_GMII_valid_5d                ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_GMII_data_1d  <= 'd0;
        ri_GMII_valid_1d <= 'd0;
        ri_GMII_data_2d  <= 'd0;
        ri_GMII_valid_2d <= 'd0;
        ri_GMII_data_3d  <= 'd0;
        ri_GMII_valid_3d <= 'd0;
        ri_GMII_data_4d  <= 'd0;
        ri_GMII_valid_4d <= 'd0;
        ri_GMII_data_5d  <= 'd0;
        ri_GMII_valid_5d <= 'd0;
    end else begin
        ri_GMII_data_1d  <= ri_GMII_data ;
        ri_GMII_valid_1d <= ri_GMII_valid;
        ri_GMII_data_2d  <= ri_GMII_data_1d ;
        ri_GMII_valid_2d <= ri_GMII_valid_1d;
        ri_GMII_data_3d  <= ri_GMII_data_2d ;
        ri_GMII_valid_3d <= ri_GMII_valid_2d;
        ri_GMII_data_4d  <= ri_GMII_data_3d ;
        ri_GMII_valid_4d <= ri_GMII_valid_3d;
        ri_GMII_data_5d  <= ri_GMII_data_4d ;
        ri_GMII_valid_5d <= ri_GMII_valid_4d;
    end
end

// the CRC_Calcu module
reg                         r_crc_en                        ;
reg                         r_crc_rst                       ;
wire [31:0]                 w_crc_result                    ;
CRC32_D8 CRC32_D8_u0(
  .i_clk        (i_clk              )      ,
  .i_rst        (r_crc_rst          )      ,
  .i_en         (r_crc_en           )      ,
  .i_data       (ri_GMII_data_5d    )      ,
  .o_crc        (w_crc_result       )         
);

// to get when to begin to enable the CRC_Calcu module we use a cnt to cnt the 5d
reg [15:0]                  r_5d_cnt                        ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_5d_cnt <= 'd0;
    else if (ri_GMII_valid_5d && r_5d_cnt == 6 && ri_GMII_data_5d == 8'h55)
        r_5d_cnt <= r_5d_cnt;
    else if (ri_GMII_valid_5d)
        r_5d_cnt <= r_5d_cnt + 1;
    else
        r_5d_cnt <= 'd0;
end

// get the negedge of i_GMII_valid and the negedge of crc_en
wire                        w_GMII_valid_neg = ri_GMII_valid_1d & !ri_GMII_valid;
reg                         r_crc_en_1d                                     ;
wire                        w_crc_en_neg = r_crc_en_1d & !r_crc_en          ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_en_1d <= 'd0;
    else 
        r_crc_en_1d <= r_crc_en;
end

// r_crc_en
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_en <= 'd0;
    else if (w_GMII_valid_neg)
        r_crc_en <= 'd0;
    else if (r_5d_cnt == 6 && ri_GMII_valid_5d)
        r_crc_en <= 'd1;
    else
        r_crc_en <= r_crc_en;
end

// r_crc_rst
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_rst <= 'd1;
    else if (w_crc_en_neg)
        r_crc_rst <= 'd1;
    else if (r_5d_cnt == 6 && ri_GMII_valid_5d)
        r_crc_rst <= 'd0;
    else
        r_crc_rst <= r_crc_rst;
end

// get the real CRC
reg [31:0]                  r_crc_result                    ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_crc_result <= 'd0;
    else if (ri_GMII_valid)
        r_crc_result <= {ri_GMII_data, r_crc_result[31:8]};
    else 
        r_crc_result <= r_crc_result;
end

// check if the CRC is right
reg                         ro_crc_error                    ;
assign                      o_crc_error = ro_crc_error      ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_crc_error <= 'd0;
    else if (!P_CRC_CHECK)
        ro_crc_error <= 'd0;
    else if (w_crc_en_neg && r_crc_result != w_crc_result)
        ro_crc_error <= 'd1;
    else
        ro_crc_error <= 'd0;
end

// ctrl o_crc_valid
reg                         ro_crc_valid                    ;
assign                      o_crc_valid = ro_crc_valid      ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_crc_valid <= 'd0;
    else if (w_crc_en_neg)
        ro_crc_valid <= 'd1;
    else 
        ro_crc_valid <= 'd0;
end

// ctrl o_post_data
assign                      o_post_data = ri_GMII_data_5d   ;
assign                      o_post_last = !ri_GMII_valid & ri_GMII_valid_1d & r_header_access;
reg                         ro_post_valid                   ;
assign                      o_post_valid = ro_post_valid    ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)      
        ro_post_valid <= 'd0;
    else if (!ri_GMII_valid & ri_GMII_valid_1d)
        ro_post_valid <= 'd0;
    else if (r_5d_cnt == 20 && r_header_access)
        ro_post_valid <= 'd1;
    else
        ro_post_valid <= ro_post_valid;
end





endmodule
