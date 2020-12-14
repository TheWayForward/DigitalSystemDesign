//2-digit locker with validation, alert and pwd change
module locker(
	input clk,
	input[3:0] switch,
	input rst_n,
	input confirm,
	input digit_dec_0,
	input digit_dec_1,
	output reg[7:0] led,
	output reg[8:0] seg_led1,
	output reg[8:0] seg_led2
);

	//default pwd: 11
	parameter M = 4'd1;
	parameter N = 4'd1;
	
	//debounce module
	debounce#(.N(3))u1(
		.clk(clk),
		.rst(rst_n),
		.key({confirm,digit_dec_0,digit_dec_1}),
		.key_pulse({confirm_d,digit_dec_0_d,digit_dec_1_d})
	);
	
	//confirm buttons: confirm all, confirm dec_0, confirm dec_1
	wire confirm_d;
	wire digit_dec_0_d;
	wire digit_dec_1_d;
	
	//err counter
	reg[1:0] error_cnt;
	
	//pwd numbers, digit 0 and 1
	reg[3:0] code_digit_0;
	reg[3:0] code_digit_1;
	//change pwd
	reg flag;
	//new pwd holder
	reg[3:0] N_new;
	reg[3:0] M_new;
	
	//segment display
	always@(*)
		begin
			case(code_digit_0)
			//0 to 9
				4'd0: seg_led1 = 9'b00_0111111;
				4'd1: seg_led1 = 9'b00_0000110;
				4'd2: seg_led1 = 9'b00_1011011;
				4'd3: seg_led1 = 9'b00_1001111;
				4'd4: seg_led1 = 9'b00_1100110;
				4'd5: seg_led1 = 9'b00_1101101;
				4'd6: seg_led1 = 9'b00_1111101;
				4'd7: seg_led1 = 9'b00_0000111;
				4'd8: seg_led1 = 9'b00_1111111;
				4'd9: seg_led1 = 9'b00_1101111;
			default:
			//0
				seg_led1 = 9'b10_0111111;
			endcase
			case(code_digit_1)
			//0 to 9
				4'd0: seg_led2 = 9'b00_0111111;
				4'd1: seg_led2 = 9'b00_0000110;
				4'd2: seg_led2 = 9'b00_1011011;
				4'd3: seg_led2 = 9'b00_1001111;
				4'd4: seg_led2 = 9'b00_1100110;
				4'd5: seg_led2 = 9'b00_1101101;
				4'd6: seg_led2 = 9'b00_1111101;
				4'd7: seg_led2 = 9'b00_0000111;
				4'd8: seg_led2 = 9'b00_1111111;
				4'd9: seg_led2 = 9'b00_1101111;
			default:
			//0
				seg_led2 = 9'b10_0111111;
			endcase
		end
		
	//pwd validation
	always@(posedge clk)
		begin
		//checking possible conditions
			if(!rst_n)
				begin
					error_cnt <= 2'b00;
					code_digit_0 <= 4'b0000;
					code_digit_1 <= 4'b0000;
					led <= 8'b11111111;
				end
			//input pwd digit 0
			else if(digit_dec_0_d)
				begin
					code_digit_0 <= switch;
				end
			//input pwd digit 1
			else if(digit_dec_1_d)
				begin
					code_digit_1 <= switch;
				end
			//confirm
			else if(confirm_d)
				begin
					//&lt; erroneous input limit
					if(error_cnt != 2'd3)
						begin
							if((code_digit_0 == N && code_digit_1 == M) || (code_digit_0 == N_new && code_digit_1 == M_new))
								begin
									//unlocked successfully
									led <= 8'b01111111;
									//err counter cleared
									error_cnt <= 2'd0;
								end
							else
								begin
									//wrong pwd
									led <= 8'b10111111;
									//err counter increment
									error_cnt <= error_cnt + 1;
								end
				end
				else led <= 8'b00000000;
		end
	end
		
	//change pwd	
	always@(posedge clk)
		begin
			if(!rst_n)
				flag <= 0;
			else if(led <= 8'b01111111)
				flag <= 1;
			if(flag == 1 && digit_dec_1_d)
				begin
					M_new <= switch;
				end
				else if(flag == 1 && digit_dec_0_d)
				begin
					N_new <= switch;
				end
		end
endmodule
