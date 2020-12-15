//divide testbench
`timescale 1ns/100ps

module divide_tb();

reg clk,rst_n;
wire clkout;

initial
	begin
		clk = 0;
		rst_n = 0;
		//delay 25 clock intervals
		#25
		//25ns low, then high
		rst_n = 1;
	end
	
	//invert clk every 10 ns, generating a clk cycling 20ns, freq as 50M
	always #10 clk = ~clk;
	
	//constructor and assignment
	divide #(.WIDTH(4),.N(12)) u1(
		.clk(clk),
		.rst_n(rst_n),
		.clkout(clkout)
	);

endmodule
