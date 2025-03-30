// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_row (clk, out_s, in_w, in_n, valid, inst_w, reset);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;
  input  [2*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;

  wire  [(col+1)*2*bw-1:0] temp;
  wire  [(col+1)*2-1:0] temp_inst;
  wire  [col-1:0]  temp_acc_cnt;

  assign temp[2*bw-1:0]   = in_w;
  assign temp_inst[1:0] = inst_w;
  

  genvar i;
  generate
  for (i=1; i < col+1 ; i=i+1) begin : col_num
      mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
         .clk(clk),
         .reset(reset),
	 .in_w( temp[2*bw*i-1:2*bw*(i-1)]),
	 .out_e(temp[2*bw*(i+1)-1:2*bw*i]),
	 .inst_w(temp_inst[2*i-1:2*(i-1)]),
	 .inst_e(temp_inst[2*(i+1)-1:2*i]),
	 .in_n(in_n[i*psum_bw-1:(i-1)*psum_bw]),
	 .out_s(out_s[i*psum_bw-1:(i-1)*psum_bw]),
	 .out_acc_cnt(temp_acc_cnt[i-1]));
  end
  endgenerate
  
  genvar j;
  
  generate
  
  for (j=0;j<col;j=j+1) begin : valid_assign
	assign valid[j]=temp_inst[2*(j+1)+1] & (~temp_acc_cnt[j]);
  end
  
  endgenerate
endmodule
