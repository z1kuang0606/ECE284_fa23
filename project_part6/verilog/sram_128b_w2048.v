// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sram_128b_w2048 (CLK, D, Q, CEN, WEN, A, sram_reset);

  input  CLK;
  input  WEN;
  input  CEN;
  input  [127:0] D;
  input  [10:0] A;
  output [127:0] Q;
  input  sram_reset;
  parameter num = 2048;

  reg [127:0] memory [num-1:0];
  reg [10:0] add_q;
  integer i;
  assign Q = memory[add_q];

  always @ (posedge CLK) begin
	if (sram_reset) begin
		for (i=0;i<36;i=i+1) begin
			memory[i] <= 128'b0; 
		end
		
		memory[1024] <= 128'b0;
	end
	else begin
		if (!CEN && WEN) // read 
			add_q <= A;
		if (!CEN && !WEN) // write
			memory[A] <= D; 
	end
  end

endmodule