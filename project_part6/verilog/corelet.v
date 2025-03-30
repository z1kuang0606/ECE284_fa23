//corelet

module corelet (clk, reset, in_ctrl, in_d, /*ofifo_valid*/, sfp_out, psum_in, /*ofifo_out*/);
	parameter bw = 4;
   parameter psum_bw = 16;
   parameter col = 8;
   parameter row = 8;
	
	input clk, reset;
	input [11:0] in_ctrl;
	input [row*bw-1:0] in_d;
	//output ofifo_valid;//  
	output [col*psum_bw-1:0] sfp_out;
	input [col*psum_bw-1:0] psum_in; //one of the sfp input from psum memory
	//output [psum_bw*col-1:0] ofifo_out;//
	//output ofifo_o_valid_out;
	//input ofifo_rd_in;
	
	wire l0_wr, l0_rd, l0_o_full, l0_o_ready;
	wire [row*bw-1:0] l0_out;
	wire [1:0] mac_array_inst_w;
	wire [psum_bw*col-1:0] mac_array_in_n;
	wire [col-1:0] mac_array_valid;
	wire [psum_bw*col-1:0] mac_array_out_s;
	//wire [psum_bw*col-1:0] ofifo_out;
	wire sfp_acc;
	wire sfp_relu;
	wire ofifo_o_full, ofifo_o_ready, ofifo_o_valid;
	wire [psum_bw*col-1:0] ofifo_out;
	wire ofifo_rd;
	wire sfp_reset;
	wire sfp_sel;
	wire [col*psum_bw-1:0] sfp_in;
	
	
	assign l0_wr = in_ctrl[2];
	assign l0_rd = in_ctrl[3];
	assign mac_array_inst_w = in_ctrl[1:0];
	assign mac_array_in_n = 0;
	assign ofifo_valid=ofifo_o_valid;
	assign ofifo_rd=in_ctrl[6];
	assign sfp_acc=in_ctrl[7];
	assign sfp_relu=in_ctrl[8];
	assign sfp_reset=in_ctrl[10];
	assign sfp_sel=in_ctrl[11];
	
	assign sfp_in=(sfp_sel==0)? ofifo_out : psum_in;
	
	l0 #(.bw(bw), .row(row)) l0_instance (
		.clk(clk),
		.reset(reset),
		.wr(l0_wr),
		.rd(l0_rd),
		.in(in_d),
		.out(l0_out),
		.o_full(l0_o_full),
		.o_ready(l0_o_ready)
	);
	
	mac_array #(.bw(bw), .row(row), .psum_bw(psum_bw), .col(col)) mac_array_instance(
		.clk(clk),
		.reset(reset),
		.out_s(mac_array_out_s),
		.in_w(l0_out),
		.inst_w(mac_array_inst_w),
		.in_n(mac_array_in_n),
		.valid(mac_array_valid)
	);
	
	ofifo #(.bw(psum_bw), .col(col)) ofifo_instance(
		.clk(clk),
		.reset(reset),
		.wr(mac_array_valid),
		.rd(ofifo_rd),
		.in(mac_array_out_s),
		.out(ofifo_out),
		.o_full(ofifo_o_full),
		.o_ready(ofifo_o_ready),
		.o_valid(ofifo_o_valid)
	);
	
	genvar i;
	generate
	for (i=0;i<col;i=i+1) begin : col_num
		sfp #(.bw(psum_bw), .psum_bw(psum_bw)) sfp_instance(
			.clk(clk),
			.reset(sfp_reset),
			.acc(sfp_acc),
			.relu(sfp_relu),
			.in(sfp_in[psum_bw*(i+1)-1:psum_bw*i]),
			.thres(16'b0),
			.out(sfp_out[psum_bw*(i+1)-1:psum_bw*i])
		);
	end
	endgenerate

endmodule