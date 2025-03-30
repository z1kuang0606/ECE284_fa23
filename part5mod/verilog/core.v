//core
module core (clk, reset, inst, /*ofifo_valid*/, D_xmem, result/*sfp_out*//*, psum_in1, psum_in2*/);
	parameter bw = 4;
   //parameter psum_bw = 16;
   parameter col = 8;
   parameter row = 8;
	
	input clk, reset;
	input [53:0] inst;
	input [2*bw*row-1:0] D_xmem;
	//output ofifo_valid;
	//output [127:0] sfp_out;
	//input [127:0] psum_in1;
	//input [127:0] psum_in2;
	output reg [127:0] result;

	wire WEN_xmem;
	wire CEN_xmem;
	wire [10:0] A_xmem;
	wire [2*bw*row-1:0] Q_xmem;
	wire [127:0] psum_in2;
	wire [127:0] psum_in1;
	wire [127:0] psum_in;
	wire [127:0] sfp_out_core;
	wire [127:0] sfp_out1;
	wire [127:0] sfp_out2;
	

	//wire [16*col-1:0] ofifo_out;
	wire WEN_pmem;
	wire CEN_pmem;
	wire [10:0] A_pmem;
	//wire [5:0] A_pmem;
	wire WEN_pmem2;
	wire CEN_pmem2;
	wire [10:0] A_pmem2;
	//wire [5:0] A_pmem2;
	wire out_en;
	
	wire chip_sel;
	wire sram_reset;
	
	assign WEN_xmem=inst[18];
	assign CEN_xmem=inst[19];
	assign A_xmem=inst[17:7];
	assign CEN_pmem=inst[32];
	assign WEN_pmem=inst[31];
	assign A_pmem=inst[30:20];
	assign chip_sel=inst[38];
	assign A_pmem2=inst[49:39];
	assign CEN_pmem2=inst[51];
	assign WEN_pmem2=inst[50];
	assign out_en=inst[52];
	assign sram_reset=inst[53];
	
	assign psum_in=(chip_sel==0)?psum_in1:psum_in2;
	assign sfp_out1=(chip_sel==1)?sfp_out_core:0;
	assign sfp_out2=(chip_sel==0)?sfp_out_core:0;
	
	sram_64b_w2048 #(.num(2048)) activation_weight_SRAM(
		.CLK(clk),
		.WEN(WEN_xmem),
		.CEN(CEN_xmem),
		.D(D_xmem),
		.A(A_xmem),
		.Q(Q_xmem)
	);
	
	corelet #(.bw(bw), .row(row), .psum_bw(16), .col(col)) corelet_instance(
		.clk(clk),
		.reset(reset),
		.in_ctrl({inst[37:33],inst[6:0]}),
		.in_d(Q_xmem),
		//.ofifo_valid(ofifo_valid),
		.sfp_out(sfp_out_core), 
		.psum_in(psum_in)
		//.ofifo_out(ofifo_out)
	);
	
	sram_128b_w2048 #(.num(2048)) psum_SRAM1(
		.CLK(clk),
		.WEN(WEN_pmem),
		.CEN(CEN_pmem),
		.D(sfp_out1),
		.A(A_pmem),
		.Q(psum_in1),
		.sram_reset(sram_reset)
	);
	
	sram_128b_w2048 #(.num(2048)) psum_SRAM2(
		.CLK(clk),
		.WEN(WEN_pmem2),
		.CEN(CEN_pmem2),
		.D(sfp_out2),
		.A(A_pmem2),
		.Q(psum_in2),
		.sram_reset(sram_reset)
	);
	
	always @(posedge clk) begin
		if (reset==1)
			result<=0;
		else begin
			if (out_en==1) begin
				if (chip_sel==0)
					result<=psum_in1;
				else
					result<=psum_in2;
			end
		end
	end
	
endmodule