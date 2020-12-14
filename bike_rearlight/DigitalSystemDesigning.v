module DigitalSystemDesigning(
	clk,
	rst,
	sw,
	state_in,
	row,
	col_r,
	col_g,
	seg_row,
	seg_col
);
	//I/O s
	//sw is master switch
	input clk,rst,sw;
	output reg[7:0] row = 8'b1111_1111;
	output reg[7:0] col_r = 8'b0000_0000;
	output reg[7:0] col_g = 8'b0000_0000;
	output reg[7:0] seg_row = 8'b1111_1111;
	output reg[7:0] seg_col = 8'b0000_0000;
	
	//state input from buttons
	input[3:0] state_in;
	
	//next and now and past and an identifier
	reg[3:0] next_state = 4'b0000;
	reg[3:0] current_state = 4'b0000;
	reg[3:0] previous_state = 4'b0000;
	reg[1:0] is_pending = 2'b00;
	reg[6:0] second_cnt = 7'b000_0000;
	reg[6:0] second_cnt_ext = 7'b000_0000;
	
	//4 lighting states
	//state normal
	localparam GO = 4'b0000;
	//state left
	localparam LEFT = 4'b0001;
	//state right
	localparam RIGHT = 4'b0010;
	//state brake
	localparam STOP = 4'b0100;
	//state off
	localparam OFF = 4'b1111;
	
	//counters and flag for breathing light
	reg[31:0] cnt_breathing_1 = 0;
	reg[31:0] cnt_breathing_2 = 0;
	reg flag = 1'b0;
	localparam cnt_breathing_loop = 7500;
	
	//counters for display
	reg[2:0] cnt_decimalHz = 3'b000;
	reg[2:0] cnt_1Hz = 3'b000;
	reg[2:0] cnt_8Hz = 3'b000;
	reg[2:0] cnt_60Hz = 3'b000;
	reg[2:0] cnt_1000Hz = 3'b000;
	reg[2:0] cnt_2000Hz = 3'b000;
	reg[2:0] cnt_ultimate = 3'b000;
	
	//counters for delay
	reg[2:0] cnt_5s = 3'b000;
	reg[3:0] cnt_10s_l = 4'b0000;
	reg[3:0] cnt_10s_r = 4'b0000;
	
	//devide parameters
	parameter dp_decimalHz = 5_0000_0000;
	parameter dp_1Hz = 5000_0000;
	parameter dp_8Hz = 625_0000;
	parameter dp_60Hz = 83_3333;
	parameter dp_1000Hz = 5_0000;
	parameter dp_2000Hz = 2_5000;
	
	//clkouts
	wire clkout_decimalHz;
	wire clkout_1Hz;
	wire clkout_8Hz;
	wire clkout_60Hz;
	wire clkout_1000Hz; //2nd fastest refreshing rate
	wire clkout_2000Hz;
	
	divide #(
		//system clk 50MHz
		//generate .1Hz square when N is 5000000
		.WIDTH(32),
		.N(dp_decimalHz)
		) divide_decimalHz(
			.clk(clk),
			.rst_n(rst),
			.clkout(clkout_decimalHz)
		);
	
	divide #(
		//system clk 50MHz
		//generate 1Hz square when N is 50000000
		.WIDTH(28),
		.N(dp_1Hz)
		) divide_1Hz(
			.clk(clk),
			.rst_n(rst),
			.clkout(clkout_1Hz)
		);
	
	divide #(
		//system clk 50MHz
		//generate 8Hz square when N is 6250000
		.WIDTH(28),
		.N(dp_8Hz)
		) divide_8Hz(
			.clk(clk),
			.rst_n(rst),
			.clkout(clkout_8Hz)
		);
	
	divide #(
		//system clk 50MHz
		//generate 60Hz square when N is 833333
		.WIDTH(26),
		.N(dp_60Hz)
		) divide_60Hz(
			.clk(clk),
			.rst_n(rst),
			.clkout(clkout_60Hz)
		);
	
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
	
	divide #(
		//system clk 50MHz
		//generate 2000Hz square when N is 25000
		.WIDTH(15),
		.N(dp_2000Hz)
		) divide_2000Hz(
			.clk(clk),
			.rst_n(rst),
			.clkout(clkout_2000Hz)
		);
	
	//switch all
	always@(clk)
		begin
			if(!sw)
				begin
					next_state = OFF;
				end
			else
				begin
					next_state = state_in;
				end
		end
	
	//segment second counter
	always@(posedge clkout_1Hz)
		if(!sw)
			second_cnt <= 0;
		else
			if(!rst)
				begin
					second_cnt <= second_cnt + 1;
					if(second_cnt == 99)
						second_cnt <= 0;
				end
			else
				second_cnt <= 0;
				
	always@(posedge clkout_1Hz)
		if(!sw)
			second_cnt_ext <= 0;
		else
			if(!rst)
				begin
					if(is_pending == 2'b11)
						begin
							second_cnt_ext <= second_cnt_ext + 1;
						end
					else if(is_pending == 2'b00)
						begin
							second_cnt_ext <= 0;
						end
				end

	//breathing counter
	always@(posedge clk)
		begin
			if(cnt_breathing_1 >= cnt_breathing_loop)
				begin
					cnt_breathing_1 <= 0;
				end
			else
				begin
					cnt_breathing_1 <= cnt_breathing_1 + 1;
				end
		end
	
	always@(posedge clk)
		begin
			if(cnt_breathing_1 == cnt_breathing_loop)
				begin
					if(flag == 1'b0)
						begin
							if(cnt_breathing_2 >= cnt_breathing_loop - 1)
								begin
									flag <= 1'b1;
								end
							else
								begin
									cnt_breathing_2 <= cnt_breathing_2 + 1'b1;
								end
						end
					else
						begin
							if(cnt_breathing_2 <= 0)
								begin
									flag <= 1'b0;
								end
							else
								begin
									cnt_breathing_2 <= cnt_breathing_2 - 1'b1;
								end
						end
				end
			else
				begin
					cnt_breathing_2 <= cnt_breathing_2;
				end
		end
				
	//counter increment and loop
	always@(posedge clkout_decimalHz)
		if(!rst)
			begin
				cnt_decimalHz <= cnt_decimalHz + 1;
			end
		else
			cnt_decimalHz <= 0;
	
	always@(posedge clkout_1Hz)
		if(!rst)
			begin
				cnt_1Hz <= cnt_1Hz + 1;
			end
		else
			cnt_1Hz <= 0;
			
	always@(posedge clkout_1Hz)
		if(!rst)
			begin
				if(previous_state == LEFT)
					begin
						cnt_10s_l <= cnt_10s_l + 1;
						if(cnt_10s_l == 10)
							begin
								cnt_10s_l <= 0;
							end
					end
				if(is_pending == 2'b00)
					begin
						cnt_10s_l <= 0;
					end
			end
	
	always@(posedge clkout_1Hz)
		if(!rst)
			begin
				if(previous_state == RIGHT)
					begin
						cnt_10s_r <= cnt_10s_r + 1;
						if(cnt_10s_r == 10)
							begin
								cnt_10s_r <= 0;
							end
					end
				if(is_pending == 2'b00)
					begin
						cnt_10s_r <= 0;
					end
			end
	
	always@(posedge clkout_1Hz)
		if(!rst)
			begin
				if(previous_state == STOP)
					begin
						cnt_5s <= cnt_5s + 1;
						if(cnt_5s == 5)
							begin
								cnt_5s <= 0;
							end
					end
				if(is_pending == 2'b00)
					begin
						cnt_5s <= 0;
					end
			end
	
	always@(posedge clkout_8Hz)
		if(!rst)
			begin
				cnt_8Hz <= cnt_8Hz + 1;
			end
		else
			cnt_8Hz <= 0;
	
	always@(posedge clkout_60Hz)
		if(!rst)
			begin
				cnt_60Hz <= cnt_60Hz + 1;
			end
		else
			cnt_60Hz <= 0;
	
	always@(posedge clkout_1000Hz)
		if(!rst)
			begin
				cnt_1000Hz <= cnt_1000Hz + 1;
			end
		else
			cnt_1000Hz <= 0;
			
	
	always@(posedge clkout_2000Hz)
		if(!rst)
			begin
				cnt_2000Hz <= cnt_2000Hz + 1;
			end
		else
			cnt_2000Hz <= 0;
	
	always@(posedge clk)
		if(!rst)
			begin
				cnt_ultimate <= cnt_ultimate + 1;
			end
		else
			cnt_ultimate <= 0;
	
	//keypress and state change
	always@(clk)
		begin
			case(next_state)
				LEFT:
					begin
						previous_state <= LEFT;
						is_pending <= 2'b11;
					end
				RIGHT:
					begin
						previous_state <= RIGHT;
						is_pending <= 2'b11;
					end
				STOP:
					begin
						previous_state <= STOP;
						is_pending <= 2'b11;
					end
			endcase
			case(next_state)
				GO:
					begin
						case(previous_state)
							LEFT:
								begin
									if(is_pending == 2'b11 && cnt_10s_l != 10)
										current_state <= LEFT;
										previous_state <= LEFT;
									if(cnt_10s_l == 10 || is_pending == 2'b00)
										begin
											is_pending <= 2'b00;
											current_state <= GO;
										end
								end
							RIGHT:
								begin
									if(is_pending == 2'b11 && cnt_10s_r != 10)
										current_state <= RIGHT;
										previous_state <= RIGHT;
									if(cnt_10s_r == 10 || is_pending == 2'b00)
										begin
											is_pending <= 2'b00;
											current_state <= GO;
										end
								end
							STOP:
								begin
									if(is_pending == 2'b11 && cnt_5s != 5)
										current_state <= STOP;
										previous_state <= STOP;
									if(cnt_5s == 5 || is_pending == 2'b00)
										begin
											is_pending <= 2'b00;
											current_state <= GO;
										end
								end
							default:
								begin
									current_state <= GO;
								end
						endcase
					end
				LEFT:
					begin
						current_state <= LEFT;
					end
				RIGHT:
					begin
						current_state <= RIGHT;
					end
				STOP:
					begin
						current_state <= STOP;
						previous_state <= STOP;
					end
				OFF:
				   begin
						current_state <= OFF;
					end
			endcase
		end
		

	// of corresponded state
	always@(posedge clk)
		begin
				case(current_state)
				GO:
					begin
						case(cnt_ultimate[2:0])
							default:
								col_r <= 8'b0000_0000;
						endcase
						if(cnt_breathing_1 > cnt_breathing_2)
							begin
								case(cnt_2000Hz[2:0])
									3'b000: row <= 8'b1111_1110;
									3'b001: row <= 8'b1111_1101;
									3'b010: row <= 8'b1111_1011;
									3'b011: row <= 8'b1111_0111;
									3'b100: row <= 8'b1110_1111;
									3'b101: row <= 8'b1101_1111;
									3'b110: row <= 8'b1011_1111;
									3'b111: row <= 8'b0111_1111;
								endcase
							case(cnt_8Hz[2:0])
								3'b000:
									case(row)
										8'b1111_1110: col_g <= 8'b1100_0011;
										8'b1111_1101: col_g <= 8'b0110_0110;
										8'b1111_1011: col_g <= 8'b0011_1100;
										8'b1111_0111: col_g <= 8'b0001_1000;
										8'b1110_1111: col_g <= 8'b1100_0011;
										8'b1101_1111: col_g <= 8'b0110_0110;
										8'b1011_1111: col_g <= 8'b0011_1100;
										8'b0111_1111: col_g <= 8'b0001_1000;
									endcase
								3'b001:
									case(row)
										8'b1111_1110: col_g <= 8'b0001_1000;
										8'b1111_1101: col_g <= 8'b1100_0011;
										8'b1111_1011: col_g <= 8'b0110_0110;
										8'b1111_0111: col_g <= 8'b0011_1100;
										8'b1110_1111: col_g <= 8'b0001_1000;
										8'b1101_1111: col_g <= 8'b1100_0011;
										8'b1011_1111: col_g <= 8'b0110_0110;
										8'b0111_1111: col_g <= 8'b0011_1100;
									endcase
								3'b010:
									case(row)
										8'b1111_1110: col_g <= 8'b0011_1100;
										8'b1111_1101: col_g <= 8'b0001_1000;
										8'b1111_1011: col_g <= 8'b1100_0011;
										8'b1111_0111: col_g <= 8'b0110_0110;
										8'b1110_1111: col_g <= 8'b0011_1100;
										8'b1101_1111: col_g <= 8'b0001_1000;
										8'b1011_1111: col_g <= 8'b1100_0011;
										8'b0111_1111: col_g <= 8'b0110_0110;
									endcase
								3'b011:
									case(row)
										8'b1111_1110: col_g <= 8'b0110_0110;
										8'b1111_1101: col_g <= 8'b0011_1100;
										8'b1111_1011: col_g <= 8'b0001_1000;
										8'b1111_0111: col_g <= 8'b1100_0011;
										8'b1110_1111: col_g <= 8'b0110_0110;
										8'b1101_1111: col_g <= 8'b0011_1100;
										8'b1011_1111: col_g <= 8'b0001_1000;
										8'b0111_1111: col_g <= 8'b1100_0011;
									endcase
								3'b100:
									case(row)
										8'b1111_1110: col_g <= 8'b1100_0011;
										8'b1111_1101: col_g <= 8'b0110_0110;
										8'b1111_1011: col_g <= 8'b0011_1100;
										8'b1111_0111: col_g <= 8'b0001_1000;
										8'b1110_1111: col_g <= 8'b1100_0011;
										8'b1101_1111: col_g <= 8'b0110_0110;
										8'b1011_1111: col_g <= 8'b0011_1100;
										8'b0111_1111: col_g <= 8'b0001_1000;
									endcase
								3'b101:
									case(row)
										8'b1111_1110: col_g <= 8'b0001_1000;
										8'b1111_1101: col_g <= 8'b1100_0011;
										8'b1111_1011: col_g <= 8'b0110_0110;
										8'b1111_0111: col_g <= 8'b0011_1100;
										8'b1110_1111: col_g <= 8'b0001_1000;
										8'b1101_1111: col_g <= 8'b1100_0011;
										8'b1011_1111: col_g <= 8'b0110_0110;
										8'b0111_1111: col_g <= 8'b0011_1100;
									endcase
								3'b110:
									case(row)
										8'b1111_1110: col_g <= 8'b0011_1100;
										8'b1111_1101: col_g <= 8'b0001_1000;
										8'b1111_1011: col_g <= 8'b1100_0011;
										8'b1111_0111: col_g <= 8'b0110_0110;
										8'b1110_1111: col_g <= 8'b0011_1100;
										8'b1101_1111: col_g <= 8'b0001_1000;
										8'b1011_1111: col_g <= 8'b1100_0011;
										8'b0111_1111: col_g <= 8'b0110_0110;
									endcase
								3'b111:
									case(row)
										8'b1111_1110: col_g <= 8'b0110_0110;
										8'b1111_1101: col_g <= 8'b0011_1100;
										8'b1111_1011: col_g <= 8'b0001_1000;
										8'b1111_0111: col_g <= 8'b1100_0011;
										8'b1110_1111: col_g <= 8'b0110_0110;
										8'b1101_1111: col_g <= 8'b0011_1100;
										8'b1011_1111: col_g <= 8'b0001_1000;
										8'b0111_1111: col_g <= 8'b1100_0011;
									endcase
							endcase
						end
					else
						begin
							case(cnt_2000Hz[2:0])
								3'b000: row <= 8'b1111_1110;
								3'b001: row <= 8'b1111_1101;
								3'b010: row <= 8'b1111_1011;
								3'b011: row <= 8'b1111_0111;
								3'b100: row <= 8'b1110_1111;
								3'b101: row <= 8'b1101_1111;
								3'b110: row <= 8'b1011_1111;
								3'b111: row <= 8'b0111_1111;
							endcase
							case(row)
								default: col_g <= 8'b0000_0000;
							endcase
						end
				end
			LEFT:
				begin
					case(cnt_1000Hz[2:0])
						default:
							col_r <= 8'b0000_0000;
					endcase
					case(cnt_1000Hz[2:0])
						3'b000: row <= 8'b1111_1110;
						3'b001: row <= 8'b1111_1101;
						3'b010: row <= 8'b1111_1011;
						3'b011: row <= 8'b1111_0111;
						3'b100: row <= 8'b1110_1111;
						3'b101: row <= 8'b1101_1111;
						3'b110: row <= 8'b1011_1111;
						3'b111: row <= 8'b0111_1111;
					endcase
					case(cnt_8Hz[2:0])
						3'b000:
							case(row)
								8'b1111_1110: col_g <= 8'b0000_1000;
								8'b1111_1101: col_g <= 8'b0000_1100;
								8'b1111_1011: col_g <= 8'b0000_0110;
								8'b1111_0111: col_g <= 8'b0111_1111;
								8'b1110_1111: col_g <= 8'b0111_1111;
								8'b1101_1111: col_g <= 8'b0000_0110;
								8'b1011_1111: col_g <= 8'b0000_1100;
								8'b0111_1111: col_g <= 8'b0000_1000;
							endcase
						3'b001:
							case(row)
								8'b1111_1110: col_g <= 8'b0000_0100;
								8'b1111_1101: col_g <= 8'b0000_0110;
								8'b1111_1011: col_g <= 8'b0000_0011;
								8'b1111_0111: col_g <= 8'b1011_1111;
								8'b1110_1111: col_g <= 8'b1011_1111;
								8'b1101_1111: col_g <= 8'b0000_0011;
								8'b1011_1111: col_g <= 8'b0000_0110;
								8'b0111_1111: col_g <= 8'b0000_0100;
							endcase
						3'b010:
							case(row)
								8'b1111_1110: col_g <= 8'b0000_0010;
								8'b1111_1101: col_g <= 8'b0000_0011;
								8'b1111_1011: col_g <= 8'b1000_0001;
								8'b1111_0111: col_g <= 8'b1101_1111;
								8'b1110_1111: col_g <= 8'b1101_1111;
								8'b1101_1111: col_g <= 8'b1000_0001;
								8'b1011_1111: col_g <= 8'b0000_0011;
								8'b0111_1111: col_g <= 8'b0000_0010;
							endcase
						3'b011:
							case(row)
								8'b1111_1110: col_g <= 8'b0000_0001;
								8'b1111_1101: col_g <= 8'b1000_0001;
								8'b1111_1011: col_g <= 8'b1100_0000;
								8'b1111_0111: col_g <= 8'b1110_1111;
								8'b1110_1111: col_g <= 8'b1110_1111;
								8'b1101_1111: col_g <= 8'b1100_0000;
								8'b1011_1111: col_g <= 8'b1000_0001;
								8'b0111_1111: col_g <= 8'b0000_0001;
							endcase
						3'b100:
							case(row)
								8'b1111_1110: col_g <= 8'b1000_0000;
								8'b1111_1101: col_g <= 8'b1100_0000;
								8'b1111_1011: col_g <= 8'b0110_0000;
								8'b1111_0111: col_g <= 8'b1111_0111;
								8'b1110_1111: col_g <= 8'b1111_0111;
								8'b1101_1111: col_g <= 8'b0110_0000;
								8'b1011_1111: col_g <= 8'b1100_0000;
								8'b0111_1111: col_g <= 8'b1000_0000;
							endcase
						3'b101:
							case(row)
								8'b1111_1110: col_g <= 8'b0100_0000;
								8'b1111_1101: col_g <= 8'b0110_0000;
								8'b1111_1011: col_g <= 8'b0011_0000;
								8'b1111_0111: col_g <= 8'b1111_1011;
								8'b1110_1111: col_g <= 8'b1111_1011;
								8'b1101_1111: col_g <= 8'b0011_0000;
								8'b1011_1111: col_g <= 8'b0110_0000;
								8'b0111_1111: col_g <= 8'b0100_0000;
							endcase
						3'b110:
							case(row)
								8'b1111_1110: col_g <= 8'b0010_0000;
								8'b1111_1101: col_g <= 8'b0011_0000;
								8'b1111_1011: col_g <= 8'b0001_1000;
								8'b1111_0111: col_g <= 8'b1111_1101;
								8'b1110_1111: col_g <= 8'b1111_1101;
								8'b1101_1111: col_g <= 8'b0001_1000;
								8'b1011_1111: col_g <= 8'b0011_0000;
								8'b0111_1111: col_g <= 8'b0010_0000;
							endcase
						3'b111:
							case(row)
								8'b1111_1110: col_g <= 8'b0001_0000;
								8'b1111_1101: col_g <= 8'b0001_1000;
								8'b1111_1011: col_g <= 8'b0000_1100;
								8'b1111_0111: col_g <= 8'b1111_1110;
								8'b1110_1111: col_g <= 8'b1111_1110;
								8'b1101_1111: col_g <= 8'b0000_1100;
								8'b1011_1111: col_g <= 8'b0001_1000;
								8'b0111_1111: col_g <= 8'b0001_0000;
							endcase
					endcase
				end
			RIGHT:
				begin
					case(cnt_1000Hz[2:0])
						default:
							col_r <= 8'b0000_0000;
					endcase
					case(cnt_1000Hz[2:0])
						3'b000: row <= 8'b1111_1110;
						3'b001: row <= 8'b1111_1101;
						3'b010: row <= 8'b1111_1011;
						3'b011: row <= 8'b1111_0111;
						3'b100: row <= 8'b1110_1111;
						3'b101: row <= 8'b1101_1111;
						3'b110: row <= 8'b1011_1111;
						3'b111: row <= 8'b0111_1111;
					endcase
					case(cnt_8Hz[2:0])
						3'b000:
							case(row)
								8'b1111_1110: col_g <= 8'b0001_0000;
								8'b1111_1101: col_g <= 8'b0011_0000;
								8'b1111_1011: col_g <= 8'b0110_0000;
								8'b1111_0111: col_g <= 8'b1111_1110;
								8'b1110_1111: col_g <= 8'b1111_1110;
								8'b1101_1111: col_g <= 8'b0110_0000;
								8'b1011_1111: col_g <= 8'b0011_0000;
								8'b0111_1111: col_g <= 8'b0001_0000;
							endcase
						3'b001:
							case(row)
								8'b1111_1110: col_g <= 8'b0010_0000;
								8'b1111_1101: col_g <= 8'b0110_0000;
								8'b1111_1011: col_g <= 8'b1100_0000;
								8'b1111_0111: col_g <= 8'b1111_1101;
								8'b1110_1111: col_g <= 8'b1111_1101;
								8'b1101_1111: col_g <= 8'b1100_0000;
								8'b1011_1111: col_g <= 8'b0110_0000;
								8'b0111_1111: col_g <= 8'b0010_0000;
							endcase
						3'b010:
							case(row)
								8'b1111_1110: col_g <= 8'b0100_0000;
								8'b1111_1101: col_g <= 8'b1100_0000;
								8'b1111_1011: col_g <= 8'b1000_0001;
								8'b1111_0111: col_g <= 8'b1111_1011;
								8'b1110_1111: col_g <= 8'b1111_1011;
								8'b1101_1111: col_g <= 8'b1000_0001;
								8'b1011_1111: col_g <= 8'b1100_0000;
								8'b0111_1111: col_g <= 8'b0100_0000;
							endcase
						3'b011:
							case(row)
								8'b1111_1110: col_g <= 8'b1000_0000;
								8'b1111_1101: col_g <= 8'b1000_0001;
								8'b1111_1011: col_g <= 8'b0000_0011;
								8'b1111_0111: col_g <= 8'b1111_0111;
								8'b1110_1111: col_g <= 8'b1111_0111;
								8'b1101_1111: col_g <= 8'b0000_0011;
								8'b1011_1111: col_g <= 8'b1000_0001;
								8'b0111_1111: col_g <= 8'b1000_0000;
							endcase
						3'b100:
							case(row)
								8'b1111_1110: col_g <= 8'b0000_0001;
								8'b1111_1101: col_g <= 8'b0000_0011;
								8'b1111_1011: col_g <= 8'b0000_0110;
								8'b1111_0111: col_g <= 8'b1110_1111;
								8'b1110_1111: col_g <= 8'b1110_1111;
								8'b1101_1111: col_g <= 8'b0000_0110;
								8'b1011_1111: col_g <= 8'b0000_0011;
								8'b0111_1111: col_g <= 8'b0000_0001;
							endcase
						3'b101:
							case(row)
								8'b1111_1110: col_g <= 8'b0000_0010;
								8'b1111_1101: col_g <= 8'b0000_0110;
								8'b1111_1011: col_g <= 8'b0000_1100;
								8'b1111_0111: col_g <= 8'b1101_1111;
								8'b1110_1111: col_g <= 8'b1101_1111;
								8'b1101_1111: col_g <= 8'b0000_1100;
								8'b1011_1111: col_g <= 8'b0000_0110;
								8'b0111_1111: col_g <= 8'b0000_0010;
							endcase
						3'b110:
							case(row)
								8'b1111_1110: col_g <= 8'b0000_0100;
								8'b1111_1101: col_g <= 8'b0000_1100;
								8'b1111_1011: col_g <= 8'b0001_1000;
								8'b1111_0111: col_g <= 8'b1011_1111;
								8'b1110_1111: col_g <= 8'b1011_1111;
								8'b1101_1111: col_g <= 8'b0001_1000;
								8'b1011_1111: col_g <= 8'b0000_1100;
								8'b0111_1111: col_g <= 8'b0000_0100;
							endcase
						3'b111:
							case(row)
								8'b1111_1110: col_g <= 8'b0000_1000;
								8'b1111_1101: col_g <= 8'b0001_1000;
								8'b1111_1011: col_g <= 8'b0011_0000;
								8'b1111_0111: col_g <= 8'b0111_1111;
								8'b1110_1111: col_g <= 8'b0111_1111;
								8'b1101_1111: col_g <= 8'b0011_0000;
								8'b1011_1111: col_g <= 8'b0001_1000;
								8'b0111_1111: col_g <= 8'b0000_1000;
							endcase
					endcase
				end
			STOP:
				begin
					case(cnt_1000Hz[2:0])
						3'b000: row <= 8'b1111_1110;
						3'b001: row <= 8'b1111_1101;
						3'b010: row <= 8'b1111_1011;
						3'b011: row <= 8'b1111_0111;
						3'b100: row <= 8'b1110_1111;
						3'b101: row <= 8'b1101_1111;
						3'b110: row <= 8'b1011_1111;
						3'b111: row <= 8'b0111_1111;
					endcase
					case(row)
						8'b1111_1110: col_r <= 8'b1000_0001;
						8'b1111_1101: col_r <= 8'b0100_0010;
						8'b1111_1011: col_r <= 8'b0010_0100;
						8'b1111_0111: col_r <= 8'b0001_1000;
						8'b1110_1111: col_r <= 8'b0001_1000;
						8'b1101_1111: col_r <= 8'b0010_0100;
						8'b1011_1111: col_r <= 8'b0100_0010;
						8'b0111_1111: col_r <= 8'b1000_0001;
					endcase
					//clear screen
					case(row)
						8'b1111_1110: col_g <= 8'b0000_0000;
						8'b1111_1101: col_g <= 8'b0000_0000;
						8'b1111_1011: col_g <= 8'b0000_0000;
						8'b1111_0111: col_g <= 8'b0000_0000;
						8'b1110_1111: col_g <= 8'b0000_0000;
						8'b1101_1111: col_g <= 8'b0000_0000;
						8'b1011_1111: col_g <= 8'b0000_0000;
						8'b0111_1111: col_g <= 8'b0000_0000;
					endcase
				end
			OFF:
				begin
					case(cnt_1000Hz[2:0])
						3'b000: row <= 8'b1111_1110;
						3'b001: row <= 8'b1111_1101;
						3'b010: row <= 8'b1111_1011;
						3'b011: row <= 8'b1111_0111;
						3'b100: row <= 8'b1110_1111;
						3'b101: row <= 8'b1101_1111;
						3'b110: row <= 8'b1011_1111;
						3'b111: row <= 8'b0111_1111;
					endcase
					case(row)
						8'b1111_1110: col_r <= 8'b0000_0000;
						8'b1111_1101: col_r <= 8'b0000_0000;
						8'b1111_1011: col_r <= 8'b0000_0000;
						8'b1111_0111: col_r <= 8'b0000_0000;
						8'b1110_1111: col_r <= 8'b0000_0000;
						8'b1101_1111: col_r <= 8'b0000_0000;
						8'b1011_1111: col_r <= 8'b0000_0000;
						8'b0111_1111: col_r <= 8'b0000_0000;
					endcase
					//clear screen
					case(row)
						8'b1111_1110: col_g <= 8'b0000_0000;
						8'b1111_1101: col_g <= 8'b0000_0000;
						8'b1111_1011: col_g <= 8'b0000_0000;
						8'b1111_0111: col_g <= 8'b0000_0000;
						8'b1110_1111: col_g <= 8'b0000_0000;
						8'b1101_1111: col_g <= 8'b0000_0000;
						8'b1011_1111: col_g <= 8'b0000_0000;
						8'b0111_1111: col_g <= 8'b0000_0000;
					endcase
				end
			endcase
		end
	
	always@(cnt_1000Hz)
		if(!sw)
			begin
				//segments are off
				seg_row <= 8'b1111_1111;
				seg_col <= 8'b0000_0000;
			end
		else
			//segments are on
			begin
				case(clkout_1000Hz)
					0:
						seg_row = 8'b1101_1111;
					1:
						seg_row = 8'b1110_1111;
				endcase
				case(seg_row)
					8'b1101_1111:
						case(second_cnt_ext)
							//0-9
							7'b000_0000: seg_col = 8'b1111_1100;
							7'b000_0001: seg_col = 8'b1111_1100;
							7'b000_0010: seg_col = 8'b1111_1100;
							7'b000_0011: seg_col = 8'b1111_1100;
							7'b000_0100: seg_col = 8'b1111_1100;
							7'b000_0101: seg_col = 8'b1111_1100;
							7'b000_0110: seg_col = 8'b1111_1100;
							7'b000_0111: seg_col = 8'b1111_1100;
							7'b000_1000: seg_col = 8'b1111_1100;
							7'b000_1001: seg_col = 8'b1111_1100;
						endcase
					8'b1110_1111:
						case(second_cnt_ext)
							//0-9
							7'b000_0000: seg_col = 8'b1111_1100;
							7'b000_0001: seg_col = 8'b0110_0000;
							7'b000_0010: seg_col = 8'b1101_1010;
							7'b000_0011: seg_col = 8'b1111_0010;
							7'b000_0100: seg_col = 8'b0110_0110;
							7'b000_0101: seg_col = 8'b1011_0110;
							7'b000_0110: seg_col = 8'b1011_1110;
							7'b000_0111: seg_col = 8'b1110_0000;
							7'b000_1000: seg_col = 8'b1111_1110;
							7'b000_1001: seg_col = 8'b1111_0110;
						endcase
				endcase
				case(clkout_1000Hz)
					0:
					//10
						seg_row = 8'b0111_1111;
					1: 
					//1
						seg_row = 8'b1011_1111;
				endcase
				case(seg_row)
					8'b0111_1111:
					//10
						case(second_cnt)
							//0-9
							7'b000_0000: seg_col = 8'b0000_0000;
							7'b000_0001: seg_col = 8'b0000_0000;
							7'b000_0010: seg_col = 8'b0000_0000;
							7'b000_0011: seg_col = 8'b0000_0000;
							7'b000_0100: seg_col = 8'b0000_0000;
							7'b000_0101: seg_col = 8'b0000_0000;
							7'b000_0110: seg_col = 8'b0000_0000;
							7'b000_0111: seg_col = 8'b0000_0000;
							7'b000_1000: seg_col = 8'b0000_0000;
							7'b000_1001: seg_col = 8'b0000_0000;
							//10-19
							7'b000_1010: seg_col = 8'b0110_0000;
							7'b000_1011: seg_col = 8'b0110_0000;
							7'b000_1100: seg_col = 8'b0110_0000;
							7'b000_1101: seg_col = 8'b0110_0000;
							7'b000_1110: seg_col = 8'b0110_0000;
							7'b000_1111: seg_col = 8'b0110_0000;
							7'b001_0000: seg_col = 8'b0110_0000;
							7'b001_0001: seg_col = 8'b0110_0000;
							7'b001_0010: seg_col = 8'b0110_0000;
							7'b001_0011: seg_col = 8'b0110_0000;
							//20-29
							7'b001_0100: seg_col = 8'b1101_1010;
							7'b001_0101: seg_col = 8'b1101_1010;
							7'b001_0110: seg_col = 8'b1101_1010;
							7'b001_0111: seg_col = 8'b1101_1010;
							7'b001_1000: seg_col = 8'b1101_1010;
							7'b001_1001: seg_col = 8'b1101_1010;
							7'b001_1010: seg_col = 8'b1101_1010;
							7'b001_1011: seg_col = 8'b1101_1010;
							7'b001_1100: seg_col = 8'b1101_1010;
							7'b001_1101: seg_col = 8'b1101_1010;
							//30-39
							7'b001_1110: seg_col = 8'b1111_0010;
							7'b001_1111: seg_col = 8'b1111_0010;
							7'b010_0000: seg_col = 8'b1111_0010;
							7'b010_0001: seg_col = 8'b1111_0010;
							7'b010_0010: seg_col = 8'b1111_0010;
							7'b010_0011: seg_col = 8'b1111_0010;
							7'b010_0100: seg_col = 8'b1111_0010;
							7'b010_0101: seg_col = 8'b1111_0010;
							7'b010_0110: seg_col = 8'b1111_0010;
							7'b010_0111: seg_col = 8'b1111_0010;
							//40-49
							7'b010_1000: seg_col = 8'b0110_0110;
							7'b010_1001: seg_col = 8'b0110_0110;
							7'b010_1010: seg_col = 8'b0110_0110;
							7'b010_1011: seg_col = 8'b0110_0110;
							7'b010_1100: seg_col = 8'b0110_0110;
							7'b010_1101: seg_col = 8'b0110_0110;
							7'b010_1110: seg_col = 8'b0110_0110;
							7'b010_1111: seg_col = 8'b0110_0110;
							7'b011_0000: seg_col = 8'b0110_0110;
							7'b011_0001: seg_col = 8'b0110_0110;
							//50-59
							7'b011_0010: seg_col = 8'b1011_0110;
							7'b011_0011: seg_col = 8'b1011_0110;
							7'b011_0100: seg_col = 8'b1011_0110;
							7'b011_0101: seg_col = 8'b1011_0110;
							7'b011_0110: seg_col = 8'b1011_0110;
							7'b011_0111: seg_col = 8'b1011_0110;
							7'b011_1000: seg_col = 8'b1011_0110;
							7'b011_1001: seg_col = 8'b1011_0110;
							7'b011_1010: seg_col = 8'b1011_0110;
							7'b011_1011: seg_col = 8'b1011_0110;
							//60-69
							7'b011_1100: seg_col = 8'b1011_1110;
							7'b011_1101: seg_col = 8'b1011_1110;
							7'b011_1110: seg_col = 8'b1011_1110;
							7'b011_1111: seg_col = 8'b1011_1110;
							7'b100_0000: seg_col = 8'b1011_1110;
							7'b100_0001: seg_col = 8'b1011_1110;
							7'b100_0010: seg_col = 8'b1011_1110;
							7'b100_0011: seg_col = 8'b1011_1110;
							7'b100_0100: seg_col = 8'b1011_1110;
							7'b100_0101: seg_col = 8'b1011_1110;
							//70-79
							7'b100_0110: seg_col = 8'b1110_0000;
							7'b100_0111: seg_col = 8'b1110_0000;
							7'b100_1000: seg_col = 8'b1110_0000;
							7'b100_1001: seg_col = 8'b1110_0000;
							7'b100_1010: seg_col = 8'b1110_0000;
							7'b100_1011: seg_col = 8'b1110_0000;
							7'b100_1100: seg_col = 8'b1110_0000;
							7'b100_1101: seg_col = 8'b1110_0000;
							7'b100_1110: seg_col = 8'b1110_0000;
							7'b100_1111: seg_col = 8'b1110_0000;
							//80-89
							7'b101_0000: seg_col = 8'b1111_1110;
							7'b101_0001: seg_col = 8'b1111_1110;
							7'b101_0010: seg_col = 8'b1111_1110;
							7'b101_0011: seg_col = 8'b1111_1110;
							7'b101_0100: seg_col = 8'b1111_1110;
							7'b101_0101: seg_col = 8'b1111_1110;
							7'b101_0110: seg_col = 8'b1111_1110;
							7'b101_0111: seg_col = 8'b1111_1110;
							7'b101_1000: seg_col = 8'b1111_1110;
							7'b101_1001: seg_col = 8'b1111_1110;
							//90-99
							7'b101_1010: seg_col = 8'b1111_0110;
							7'b101_1011: seg_col = 8'b1111_0110;
							7'b101_1100: seg_col = 8'b1111_0110;
							7'b101_1101: seg_col = 8'b1111_0110;
							7'b101_1110: seg_col = 8'b1111_0110;
							7'b101_1111: seg_col = 8'b1111_0110;
							7'b110_0000: seg_col = 8'b1111_0110;
							7'b110_0001: seg_col = 8'b1111_0110;
							7'b110_0010: seg_col = 8'b1111_0110;
							7'b110_0011: seg_col = 8'b1111_0110;	
						endcase
					8'b1011_1111:
					//1
						case(second_cnt)
							//0-9
							7'b000_0000: seg_col = 8'b1111_1100;
							7'b000_0001: seg_col = 8'b0110_0000;
							7'b000_0010: seg_col = 8'b1101_1010;
							7'b000_0011: seg_col = 8'b1111_0010;
							7'b000_0100: seg_col = 8'b0110_0110;
							7'b000_0101: seg_col = 8'b1011_0110;
							7'b000_0110: seg_col = 8'b1011_1110;
							7'b000_0111: seg_col = 8'b1110_0000;
							7'b000_1000: seg_col = 8'b1111_1110;
							7'b000_1001: seg_col = 8'b1111_0110;
							//10-19
							7'b000_1010: seg_col = 8'b1111_1100;
							7'b000_1011: seg_col = 8'b0110_0000;
							7'b000_1100: seg_col = 8'b1101_1010;
							7'b000_1101: seg_col = 8'b1111_0010;
							7'b000_1110: seg_col = 8'b0110_0110;
							7'b000_1111: seg_col = 8'b1011_0110;
							7'b001_0000: seg_col = 8'b1011_1110;
							7'b001_0001: seg_col = 8'b1110_0000;
							7'b001_0010: seg_col = 8'b1111_1110;
							7'b001_0011: seg_col = 8'b1111_0110;
							//20-29
							7'b001_0100: seg_col = 8'b1111_1100;
							7'b001_0101: seg_col = 8'b0110_0000;
							7'b001_0110: seg_col = 8'b1101_1010;
							7'b001_0111: seg_col = 8'b1111_0010;
							7'b001_1000: seg_col = 8'b0110_0110;
							7'b001_1001: seg_col = 8'b1011_0110;
							7'b001_1010: seg_col = 8'b1011_1110;
							7'b001_1011: seg_col = 8'b1110_0000;
							7'b001_1100: seg_col = 8'b1111_1110;
							7'b001_1101: seg_col = 8'b1111_0110;
							//30-39
							7'b001_1110: seg_col = 8'b1111_1100;
							7'b001_1111: seg_col = 8'b0110_0000;
							7'b010_0000: seg_col = 8'b1101_1010;
							7'b010_0001: seg_col = 8'b1111_0010;
							7'b010_0010: seg_col = 8'b0110_0110;
							7'b010_0011: seg_col = 8'b1011_0110;
							7'b010_0100: seg_col = 8'b1011_1110;
							7'b010_0101: seg_col = 8'b1110_0000;
							7'b010_0110: seg_col = 8'b1111_1110;
							7'b010_0111: seg_col = 8'b1111_0110;
							//40-49
							7'b010_1000: seg_col = 8'b1111_1100;
							7'b010_1001: seg_col = 8'b0110_0000;
							7'b010_1010: seg_col = 8'b1101_1010;
							7'b010_1011: seg_col = 8'b1111_0010;
							7'b010_1100: seg_col = 8'b0110_0110;
							7'b010_1101: seg_col = 8'b1011_0110;
							7'b010_1110: seg_col = 8'b1011_1110;
							7'b010_1111: seg_col = 8'b1110_0000;
							7'b011_0000: seg_col = 8'b1111_1110;
							7'b011_0001: seg_col = 8'b1111_0110;
							//50-59
							7'b011_0010: seg_col = 8'b1111_1100;
							7'b011_0011: seg_col = 8'b0110_0000;
							7'b011_0100: seg_col = 8'b1101_1010;
							7'b011_0101: seg_col = 8'b1111_0010;
							7'b011_0110: seg_col = 8'b0110_0110;
							7'b011_0111: seg_col = 8'b1011_0110;
							7'b011_1000: seg_col = 8'b1011_1110;
							7'b011_1001: seg_col = 8'b1110_0000;
							7'b011_1010: seg_col = 8'b1111_1110;
							7'b011_1011: seg_col = 8'b1111_0110;
							//60-69
							7'b011_1100: seg_col = 8'b1111_1100;
							7'b011_1101: seg_col = 8'b0110_0000;
							7'b011_1110: seg_col = 8'b1101_1010;
							7'b011_1111: seg_col = 8'b1111_0010;
							7'b100_0000: seg_col = 8'b0110_0110;
							7'b100_0001: seg_col = 8'b1011_0110;
							7'b100_0010: seg_col = 8'b1011_1110;
							7'b100_0011: seg_col = 8'b1110_0000;
							7'b100_0100: seg_col = 8'b1111_1110;
							7'b100_0101: seg_col = 8'b1111_0110;
							//70-79
							7'b100_0110: seg_col = 8'b1111_1100;
							7'b100_0111: seg_col = 8'b0110_0000;
							7'b100_1000: seg_col = 8'b1101_1010;
							7'b100_1001: seg_col = 8'b1111_0010;
							7'b100_1010: seg_col = 8'b0110_0110;
							7'b100_1011: seg_col = 8'b1011_0110;
							7'b100_1100: seg_col = 8'b1011_1110;
							7'b100_1101: seg_col = 8'b1110_0000;
							7'b100_1110: seg_col = 8'b1111_1110;
							7'b100_1111: seg_col = 8'b1111_0110;
							//80-89
							7'b101_0000: seg_col = 8'b1111_1100;
							7'b101_0001: seg_col = 8'b0110_0000;
							7'b101_0010: seg_col = 8'b1101_1010;
							7'b101_0011: seg_col = 8'b1111_0010;
							7'b101_0100: seg_col = 8'b0110_0110;
							7'b101_0101: seg_col = 8'b1011_0110;
							7'b101_0110: seg_col = 8'b1011_1110;
							7'b101_0111: seg_col = 8'b1110_0000;
							7'b101_1000: seg_col = 8'b1111_1110;
							7'b101_1001: seg_col = 8'b1111_0110;
							//90-99
							7'b101_1010: seg_col = 8'b1111_1100;
							7'b101_1011: seg_col = 8'b0110_0000;
							7'b101_1100: seg_col = 8'b1101_1010;
							7'b101_1101: seg_col = 8'b1111_0010;
							7'b101_1110: seg_col = 8'b0110_0110;
							7'b101_1111: seg_col = 8'b1011_0110;
							7'b110_0000: seg_col = 8'b1011_1110;
							7'b110_0001: seg_col = 8'b1110_0000;
							7'b110_0010: seg_col = 8'b1111_1110;
							7'b110_0011: seg_col = 8'b1111_0110;
						endcase
				endcase
			end
		
endmodule
