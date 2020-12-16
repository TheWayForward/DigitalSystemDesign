module countdown(
	clk,
	rst,
	set_in,
	start,
	clr,
	segment_row,
	segment_col,
	cnt,
);
	
	//basic
	input clk,rst,clr,start;
	//set countdown period with switches
	input[6:0] set_in;
	
	//segment display
	output reg[1:0] segment_row = 2'b11;
	output reg[7:0] segment_col = 8'b0000_0000;
	output reg[6:0] cnt = 7'b011_1011;
	reg[6:0] set = 7'b000_0000;
	reg[2:0] overlap = 3'b00;
	reg[9:0] cnt_loop_1Hz = 10'b0;
	
	//divide parameters
	parameter dp_1Hz = 5000_0000;
	wire clkout_1Hz;
	divide #(
		//system clk 50MHz
		//generate 1Hz square when N is 50000000
		.WIDTH(26),
		.N(dp_1Hz)
		) divide_1Hz(
			.clk(clk),
			.rst_n(rst),
			.clkout(clkout_1Hz)
		);
	
	parameter dp_1000Hz = 5_0000;
	wire clkout_1000Hz;
	divide #(
		//system clk 50MHz
		//generate 1000Hz square when N is 50000
		.WIDTH(16),
		.N(dp_1000Hz)
		) divide_1000Hz(
			.clk(clk),
			.rst_n(rst),
			.clkout(clkout_1000Hz)
		);
	
	always@(posedge clkout_1000Hz)
		begin
			cnt_loop_1Hz <= cnt_loop_1Hz + 1;
			if(cnt_loop_1Hz == 10'b11_1110_1000)
				begin
					cnt <= cnt - 1;
					cnt_loop_1Hz <= 0;
					if(cnt == 0)
						begin
							//stay at 0
							cnt <= 0;
						end
				end
			if(clr)
				begin
					cnt <= set_in;
				end				
		end
	
	always@(clkout_1000Hz)
		begin
			case(clkout_1000Hz)
				0: segment_row = 2'b10;
				1:	segment_row = 2'b01;
			endcase
			case(segment_row)
				2'b01:
					case(cnt)
							7'b000_0000: segment_col = 8'b0000_0000;
							7'b000_0001: segment_col = 8'b0000_0000;
							7'b000_0010: segment_col = 8'b0000_0000;
							7'b000_0011: segment_col = 8'b0000_0000;
							7'b000_0100: segment_col = 8'b0000_0000;
							7'b000_0101: segment_col = 8'b0000_0000;
							7'b000_0110: segment_col = 8'b0000_0000;
							7'b000_0111: segment_col = 8'b0000_0000;
							7'b000_1000: segment_col = 8'b0000_0000;
							7'b000_1001: segment_col = 8'b0000_0000;
							//10-19
							7'b000_1010: segment_col = 8'b0110_0000;
							7'b000_1011: segment_col = 8'b0110_0000;
							7'b000_1100: segment_col = 8'b0110_0000;
							7'b000_1101: segment_col = 8'b0110_0000;
							7'b000_1110: segment_col = 8'b0110_0000;
							7'b000_1111: segment_col = 8'b0110_0000;
							7'b001_0000: segment_col = 8'b0110_0000;
							7'b001_0001: segment_col = 8'b0110_0000;
							7'b001_0010: segment_col = 8'b0110_0000;
							7'b001_0011: segment_col = 8'b0110_0000;
							//20-29
							7'b001_0100: segment_col = 8'b1101_1010;
							7'b001_0101: segment_col = 8'b1101_1010;
							7'b001_0110: segment_col = 8'b1101_1010;
							7'b001_0111: segment_col = 8'b1101_1010;
							7'b001_1000: segment_col = 8'b1101_1010;
							7'b001_1001: segment_col = 8'b1101_1010;
							7'b001_1010: segment_col = 8'b1101_1010;
							7'b001_1011: segment_col = 8'b1101_1010;
							7'b001_1100: segment_col = 8'b1101_1010;
							7'b001_1101: segment_col = 8'b1101_1010;
							//30-39
							7'b001_1110: segment_col = 8'b1111_0010;
							7'b001_1111: segment_col = 8'b1111_0010;
							7'b010_0000: segment_col = 8'b1111_0010;
							7'b010_0001: segment_col = 8'b1111_0010;
							7'b010_0010: segment_col = 8'b1111_0010;
							7'b010_0011: segment_col = 8'b1111_0010;
							7'b010_0100: segment_col = 8'b1111_0010;
							7'b010_0101: segment_col = 8'b1111_0010;
							7'b010_0110: segment_col = 8'b1111_0010;
							7'b010_0111: segment_col = 8'b1111_0010;
							//40-49
							7'b010_1000: segment_col = 8'b0110_0110;
							7'b010_1001: segment_col = 8'b0110_0110;
							7'b010_1010: segment_col = 8'b0110_0110;
							7'b010_1011: segment_col = 8'b0110_0110;
							7'b010_1100: segment_col = 8'b0110_0110;
							7'b010_1101: segment_col = 8'b0110_0110;
							7'b010_1110: segment_col = 8'b0110_0110;
							7'b010_1111: segment_col = 8'b0110_0110;
							7'b011_0000: segment_col = 8'b0110_0110;
							7'b011_0001: segment_col = 8'b0110_0110;
							//50-59
							7'b011_0010: segment_col = 8'b1011_0110;
							7'b011_0011: segment_col = 8'b1011_0110;
							7'b011_0100: segment_col = 8'b1011_0110;
							7'b011_0101: segment_col = 8'b1011_0110;
							7'b011_0110: segment_col = 8'b1011_0110;
							7'b011_0111: segment_col = 8'b1011_0110;
							7'b011_1000: segment_col = 8'b1011_0110;
							7'b011_1001: segment_col = 8'b1011_0110;
							7'b011_1010: segment_col = 8'b1011_0110;
							7'b011_1011: segment_col = 8'b1011_0110;
							//60-69
							7'b011_1100: segment_col = 8'b1011_1110;
							7'b011_1101: segment_col = 8'b1011_1110;
							7'b011_1110: segment_col = 8'b1011_1110;
							7'b011_1111: segment_col = 8'b1011_1110;
							7'b100_0000: segment_col = 8'b1011_1110;
							7'b100_0001: segment_col = 8'b1011_1110;
							7'b100_0010: segment_col = 8'b1011_1110;
							7'b100_0011: segment_col = 8'b1011_1110;
							7'b100_0100: segment_col = 8'b1011_1110;
							7'b100_0101: segment_col = 8'b1011_1110;
							//70-79
							7'b100_0110: segment_col = 8'b1110_0000;
							7'b100_0111: segment_col = 8'b1110_0000;
							7'b100_1000: segment_col = 8'b1110_0000;
							7'b100_1001: segment_col = 8'b1110_0000;
							7'b100_1010: segment_col = 8'b1110_0000;
							7'b100_1011: segment_col = 8'b1110_0000;
							7'b100_1100: segment_col = 8'b1110_0000;
							7'b100_1101: segment_col = 8'b1110_0000;
							7'b100_1110: segment_col = 8'b1110_0000;
							7'b100_1111: segment_col = 8'b1110_0000;
							//80-89
							7'b101_0000: segment_col = 8'b1111_1110;
							7'b101_0001: segment_col = 8'b1111_1110;
							7'b101_0010: segment_col = 8'b1111_1110;
							7'b101_0011: segment_col = 8'b1111_1110;
							7'b101_0100: segment_col = 8'b1111_1110;
							7'b101_0101: segment_col = 8'b1111_1110;
							7'b101_0110: segment_col = 8'b1111_1110;
							7'b101_0111: segment_col = 8'b1111_1110;
							7'b101_1000: segment_col = 8'b1111_1110;
							7'b101_1001: segment_col = 8'b1111_1110;
							//90-99
							7'b101_1010: segment_col = 8'b1111_0110;
							7'b101_1011: segment_col = 8'b1111_0110;
							7'b101_1100: segment_col = 8'b1111_0110;
							7'b101_1101: segment_col = 8'b1111_0110;
							7'b101_1110: segment_col = 8'b1111_0110;
							7'b101_1111: segment_col = 8'b1111_0110;
							7'b110_0000: segment_col = 8'b1111_0110;
							7'b110_0001: segment_col = 8'b1111_0110;
							7'b110_0010: segment_col = 8'b1111_0110;
							7'b110_0011: segment_col = 8'b1111_0110;
					endcase
				2'b10:
					case(cnt)
							//0-9
							7'b000_0000: segment_col = 8'b1111_1100;
							7'b000_0001: segment_col = 8'b0110_0000;
							7'b000_0010: segment_col = 8'b1101_1010;
							7'b000_0011: segment_col = 8'b1111_0010;
							7'b000_0100: segment_col = 8'b0110_0110;
							7'b000_0101: segment_col = 8'b1011_0110;
							7'b000_0110: segment_col = 8'b1011_1110;
							7'b000_0111: segment_col = 8'b1110_0000;
							7'b000_1000: segment_col = 8'b1111_1110;
							7'b000_1001: segment_col = 8'b1111_0110;
							//10-19
							7'b000_1010: segment_col = 8'b1111_1100;
							7'b000_1011: segment_col = 8'b0110_0000;
							7'b000_1100: segment_col = 8'b1101_1010;
							7'b000_1101: segment_col = 8'b1111_0010;
							7'b000_1110: segment_col = 8'b0110_0110;
							7'b000_1111: segment_col = 8'b1011_0110;
							7'b001_0000: segment_col = 8'b1011_1110;
							7'b001_0001: segment_col = 8'b1110_0000;
							7'b001_0010: segment_col = 8'b1111_1110;
							7'b001_0011: segment_col = 8'b1111_0110;
							//20-29
							7'b001_0100: segment_col = 8'b1111_1100;
							7'b001_0101: segment_col = 8'b0110_0000;
							7'b001_0110: segment_col = 8'b1101_1010;
							7'b001_0111: segment_col = 8'b1111_0010;
							7'b001_1000: segment_col = 8'b0110_0110;
							7'b001_1001: segment_col = 8'b1011_0110;
							7'b001_1010: segment_col = 8'b1011_1110;
							7'b001_1011: segment_col = 8'b1110_0000;
							7'b001_1100: segment_col = 8'b1111_1110;
							7'b001_1101: segment_col = 8'b1111_0110;
							//30-39
							7'b001_1110: segment_col = 8'b1111_1100;
							7'b001_1111: segment_col = 8'b0110_0000;
							7'b010_0000: segment_col = 8'b1101_1010;
							7'b010_0001: segment_col = 8'b1111_0010;
							7'b010_0010: segment_col = 8'b0110_0110;
							7'b010_0011: segment_col = 8'b1011_0110;
							7'b010_0100: segment_col = 8'b1011_1110;
							7'b010_0101: segment_col = 8'b1110_0000;
							7'b010_0110: segment_col = 8'b1111_1110;
							7'b010_0111: segment_col = 8'b1111_0110;
							//40-49
							7'b010_1000: segment_col = 8'b1111_1100;
							7'b010_1001: segment_col = 8'b0110_0000;
							7'b010_1010: segment_col = 8'b1101_1010;
							7'b010_1011: segment_col = 8'b1111_0010;
							7'b010_1100: segment_col = 8'b0110_0110;
							7'b010_1101: segment_col = 8'b1011_0110;
							7'b010_1110: segment_col = 8'b1011_1110;
							7'b010_1111: segment_col = 8'b1110_0000;
							7'b011_0000: segment_col = 8'b1111_1110;
							7'b011_0001: segment_col = 8'b1111_0110;
							//50-59
							7'b011_0010: segment_col = 8'b1111_1100;
							7'b011_0011: segment_col = 8'b0110_0000;
							7'b011_0100: segment_col = 8'b1101_1010;
							7'b011_0101: segment_col = 8'b1111_0010;
							7'b011_0110: segment_col = 8'b0110_0110;
							7'b011_0111: segment_col = 8'b1011_0110;
							7'b011_1000: segment_col = 8'b1011_1110;
							7'b011_1001: segment_col = 8'b1110_0000;
							7'b011_1010: segment_col = 8'b1111_1110;
							7'b011_1011: segment_col = 8'b1111_0110;
							//60-69
							7'b011_1100: segment_col = 8'b1111_1100;
							7'b011_1101: segment_col = 8'b0110_0000;
							7'b011_1110: segment_col = 8'b1101_1010;
							7'b011_1111: segment_col = 8'b1111_0010;
							7'b100_0000: segment_col = 8'b0110_0110;
							7'b100_0001: segment_col = 8'b1011_0110;
							7'b100_0010: segment_col = 8'b1011_1110;
							7'b100_0011: segment_col = 8'b1110_0000;
							7'b100_0100: segment_col = 8'b1111_1110;
							7'b100_0101: segment_col = 8'b1111_0110;
							//70-79
							7'b100_0110: segment_col = 8'b1111_1100;
							7'b100_0111: segment_col = 8'b0110_0000;
							7'b100_1000: segment_col = 8'b1101_1010;
							7'b100_1001: segment_col = 8'b1111_0010;
							7'b100_1010: segment_col = 8'b0110_0110;
							7'b100_1011: segment_col = 8'b1011_0110;
							7'b100_1100: segment_col = 8'b1011_1110;
							7'b100_1101: segment_col = 8'b1110_0000;
							7'b100_1110: segment_col = 8'b1111_1110;
							7'b100_1111: segment_col = 8'b1111_0110;
							//80-89
							7'b101_0000: segment_col = 8'b1111_1100;
							7'b101_0001: segment_col = 8'b0110_0000;
							7'b101_0010: segment_col = 8'b1101_1010;
							7'b101_0011: segment_col = 8'b1111_0010;
							7'b101_0100: segment_col = 8'b0110_0110;
							7'b101_0101: segment_col = 8'b1011_0110;
							7'b101_0110: segment_col = 8'b1011_1110;
							7'b101_0111: segment_col = 8'b1110_0000;
							7'b101_1000: segment_col = 8'b1111_1110;
							7'b101_1001: segment_col = 8'b1111_0110;
							//90-99
							7'b101_1010: segment_col = 8'b1111_1100;
							7'b101_1011: segment_col = 8'b0110_0000;
							7'b101_1100: segment_col = 8'b1101_1010;
							7'b101_1101: segment_col = 8'b1111_0010;
							7'b101_1110: segment_col = 8'b0110_0110;
							7'b101_1111: segment_col = 8'b1011_0110;
							7'b110_0000: segment_col = 8'b1011_1110;
							7'b110_0001: segment_col = 8'b1110_0000;
							7'b110_0010: segment_col = 8'b1111_1110;
							7'b110_0011: segment_col = 8'b1111_0110;
					endcase
			endcase
	end
	
endmodule
