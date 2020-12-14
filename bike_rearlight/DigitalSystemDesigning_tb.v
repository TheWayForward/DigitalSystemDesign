`timescale 1ns/1ps

module DigitalSystemDesigning_tb();

	reg clk = 1'b0;
	reg rst,sw;
	reg[3:0] state_in;
	reg[7:0] row = 8'b0000_0000;
	reg[7:0] col_r = 8'b0000_0000;
	reg[7:0] col_g = 8'b0000_0000;
	reg[7:0] seg_row = 8'b0000_0000;
	reg[7:0] seg_col = 8'b0000_0000;
	
	initial 
		begin
			#5 clk = 1'b0;
			#5 rst = 1'b0;
			#5 sw = 1'b1;
			#5 state_in = 4'b0000;
			#5 forever #20 clk = ~clk;
			#1_0000 state_in = 4'b0001;
			#1_0000 state_in = 4'b0010;
			#1_0000 state_in = 4'b0100;
			#1_0000 sw = 1'b0;
		end
	
	DigitalSystemDesigning DSD(
		.clk(clk),
		.rst(rst),
		.sw(sw),
		.state_in(state_in),
		.row(row),
		.col_r(col_r),
		.col_g(col_g),
		.seg_row(seg_row),
		.seg_col(seg_col)
	);
	
endmodule
