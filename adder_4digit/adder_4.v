module adder_4(
	add_1,
	add_2,
	carry_in,
	carry_out,
	sum
);

	input[3:0] add_1,add_2;
	input carry_in;
	output[3:0] sum;
	output carry_out;
	assign {carry_out,sum} = add_1 + add_2 + carry_in;
	
endmodule
