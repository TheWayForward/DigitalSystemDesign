module divide(
	clk,
	rst_n,
	clkout,
);

	input clk,rst_n;
	//led displaying clock
	output clkout;
	reg clk_p,clk_n;
	
	//parameter for variables, or macro
	//counter max: 2 ^ width - 1
	//N = 12000000, WIDTH = 24, cycling 1s
	parameter WIDTH = 24;
	//division: N < 2 ^ width - 1
	parameter N = 1000000;
	
	//p for posedge, n for negedge
	reg[WIDTH - 1:0] cnt_p,cnt_n;
	
	
	//posedge triggered counter
	//do when clk posedge or rst_n negedge arrives
	always@(posedge clk)
		begin
		//counter counts unless N-1 reached
			if(!rst_n)
				begin
					if(cnt_p == (N - 1))
						cnt_p <= 0;
					else
						cnt_p <= cnt_p + 1;
				end
			else
				cnt_p <= 0;
		end
		
	//posedge triggered clk division
	always@(posedge clk)
		begin
			if(!rst_n)
				begin
					if(cnt_p < (N >> 1))
						clk_p <= 0;
					else
						clk_p <= 1;
				end
			else
				clk_p <= 0;
		end
	
	//negedge triggered counter
	always@(negedge clk)
		begin	
			if(!rst_n)
				begin
					if(cnt_n == (N - 1))
						cnt_n <= 0;
					else
						cnt_n <= cnt_n + 1;
				end
			else
				cnt_n <= 0;
		end
	
	//negedge triggered clk division
	always@(negedge clk)
		begin
			if(!rst_n)
				begin
					if(cnt_n < (N >> 1))
						clk_n <= 0;
					else
						clk_n <= 1;
				end
			else
				clk_n <= 0;
		end
		
	//judging
	//print clk when N == 1
	//print clk_p when N even, min bit is 0
	//print clk_p&clk_n when N odd, min bit is 1
	assign clkout = (N == 1) ? clk : (N[0]) ? (clk_p & clk_n) : clk_p;

endmodule
