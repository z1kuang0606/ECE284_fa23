// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, out_acc_cnt);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [2*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading;  8 bits
output [2*bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
output out_acc_cnt;

reg [bw-1:0] a_q;
reg [bw-1:0] b_q;
//reg [psum_bw-1:0] c_q;
reg  [psum_bw-1:0] in_n_q;

wire [psum_bw-1:0] mac_out;
reg [1:0] inst_q;
reg load_ready_q;

reg [bw-1:0] b_q_0; //weights for ic 0 to 7;
reg [bw-1:0] b_q_1; //weights for ic 8 to 15;
reg [bw-1:0] a_q_0; //activations for ic 0 to 7;
reg [bw-1:0] a_q_1; //activations for ic 8 to 15;

reg [psum_bw-1:0] mac_out_q;

reg int_acc_cnt;
reg [psum_bw-1:0] c;

//assign a_q=(int_acc_cnt==0)? a_q_0 : a_q_1;
//assign b_q=(int_acc_cnt==0)? b_q_0 : b_q_1;
//assign c=(int_acc_cnt==0)? in_n_q : mac_out_q;

assign out_e={a_q_1,a_q_0};
assign inst_e=inst_q;
assign out_s=mac_out;
assign out_acc_cnt=int_acc_cnt;
//assign out_s=(int_acc_cnt==1)? mac_out : 0;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c),
	.out(mac_out)
); 

always @(posedge clk)
begin
	if (reset==1'b1) 
	begin
		inst_q<=2'b00;
		load_ready_q<=1'b1;
		a_q_0    <= 0;
		a_q_1    <= 0;
      b_q_0    <= 0;
		b_q_1    <= 0;
		a_q<=0;
		c<=0;
      //c_q    <= 0;
		int_acc_cnt  <=0;
		//in_n_q   <= 0;
		//mac_out_q<= 0;
	end
	else 
	begin
		inst_q[1]<=inst_w[1];
		if (inst_w[0] && load_ready_q) begin
			b_q_0<=in_w[3:0];
			b_q_1<=in_w[7:4];
			load_ready_q<=1'b0;
		end
		else if (load_ready_q==1'b0)
			inst_q[0]<=inst_w[0];

		if (inst_w[0] | inst_w[1]) begin
			a_q_0<=in_w[3:0];
			a_q_1<=in_w[7:4];
		end
		if (inst_w[1]) begin
			
			//c_q<=c;
			if (int_acc_cnt==0) begin
				c<=in_n;
				a_q<=in_w[3:0];
				b_q<=b_q_0;
				int_acc_cnt<=1;
				//out_s<=0;
			end
			else begin
				c<=mac_out;
				a_q<=in_w[7:4];
				b_q<=b_q_1;
				int_acc_cnt<=0;
				//out_s<=mac_out;
			end
			/*in_n_q <= in_n;
			mac_out_q <= mac_out;
			int_acc_cnt<=~int_acc_cnt;*/
			//if (int_acc_cnt==1)
			
		end
	end
end


endmodule
