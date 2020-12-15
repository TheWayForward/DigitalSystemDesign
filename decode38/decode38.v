module decode38(
	sw,
	led
);
	input[2:0] sw;
	output[7:0] led;
	//this reg var for assignment in always
	reg[7:0] led;
	
	//always: run when sw changes
	always @(sw)
	begin
		case(sw)
			3'b000:
			led = 8'b0111_1111;
			3'b001:
			led = 8'b1011_1111;
			3'b010:
			led = 8'b1101_1111;
			3'b011:
			led = 8'b1110_1111;
			3'b100:
			led = 8'b1111_0111;
			3'b101:
			led = 8'b1111_1011;
			3'b110:
			led = 8'b1111_1101;
			3'b111:
			led = 8'b1111_1110;
			default:;
		endcase
	end
endmodule
