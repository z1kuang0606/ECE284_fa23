// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;

reg [bw-1:0] a_q;
reg [bw-1:0] b_q;
reg [psum_bw-1:0] c_q;
wire [psum_bw-1:0] mac_out;
reg [1:0] inst_q;
reg load_ready_q;

assign out_e=a_q;
assign inst_e=inst_q;
assign out_s=mac_out;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 

always @(posedge clk)
begin
	if (reset==1'b1) 
	begin
		inst_q<=2'b00;
		load_ready_q<=1'b1;
		a_q    <= 0;
      b_q    <= 0;
      c_q    <= 0;
	end
	else 
	begin
		inst_q[1]<=inst_w[1];
		if (inst_w[0] && load_ready_q) begin
			b_q<=in_w;
			load_ready_q<=1'b0;
		end
		else if (load_ready_q==1'b0)
			inst_q[0]<=inst_w[0];

		if (inst_w[0] | inst_w[1])
			a_q<=in_w;
		if (inst_w[1])
			c_q<=in_n;


	end
end


endmodule
