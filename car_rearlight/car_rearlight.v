module car_rearlight(
	clk,
	rst,
	state_in,
	led_left,
	led_right,
	led_flow
);

	//basic
	input clk,rst;
	wire rst_n = ~rst;
	input[3:0] state_in;
	output reg[2:0] led_left;
	output reg[2:0] led_right;
	output reg[7:0] led_flow;
	
	//state parameters, as they were called
	localparam STOP = 4'b1111;
	localparam GO = 4'b1110;
	localparam LEFT = 4'b1101;
	localparam RIGHT = 4'b1011;
	localparam BACK = 4'b0111;
	localparam stop = 8'b0000_0000;
	localparam left = 8'b1111_0000;
	localparam right = 8'b0000_1111;
	localparam on = 3'b101;
	localparam off = 3'b111;
	
	//light states
	wire[2:0] blink;
	reg[7:0] go = 8'b0111_1111;
	reg[7:0] back = 8'b1111_1110;
	
	//state registers
	reg[3:0] current_state;
	reg[3:0] next_state;
	
	//divide parameters
	//system clk 50MHz
	//1Hz
	parameter dp_1Hz = 1200_0000;
	parameter dp_8Hz = 150_0000;
	wire clkout_1Hz;
	divide #(
		//system clk 50MHz
		//generate 1Hz square when N is 50000000
		.WIDTH(30),
		.N(dp_1Hz)
		) divide_1Hz(
			.clk(clk),
			.rst_n(rst_n),
			.clkout(clkout_1Hz)
		);
		
		
	//counter for led_flow, size must be specified
	reg[27:0] cnt_8Hz = 28'b0;
	always@(posedge clk)
		begin
			cnt_8Hz <= cnt_8Hz + 1;
			if(cnt_8Hz == dp_8Hz + 1)
				begin
					cnt_8Hz <= 0;
				end
		end
		
		
	//blink once per second
	assign blink = {1'b1,clkout_1Hz,1'b1};
	
	
	//go, leds arrays blinks forward
	always@(posedge clk)
		begin
			if(!rst)
				begin
					if(go == 8'b1111_1110 && cnt_8Hz == dp_8Hz)
						begin
							//max reached
							go <= 8'b0111_1111;
						end
					else if(cnt_8Hz == dp_8Hz)
						begin
							//roll forward
							go <= {go[0],go[7:1]};
						end
					else
						begin
							go <= go;
						end
				end
			else
				begin
					go <= 8'b0111_1111;
				end
		end
	
	//back, led array blinks backward
	always@(posedge clk)
		begin
			if(!rst)
				begin
					if(back == 8'b0111_1111 && cnt_8Hz == dp_8Hz)
						begin
							back <= 8'b1111_1110;
						end
					else if(cnt_8Hz == dp_8Hz)
						begin
							//roll backward
							back <= {back[6:0],back[7]};
						end
					else
						begin
							back <= back;
						end
				end
			else
				begin
					back <= 8'b1111_1110;
				end
		end
	
	always@(*)
		begin
			next_state <= state_in;
		end
	
	//set next state to current state, input state as next state
	always@(posedge clk or negedge rst)
		begin				
			if(!rst)
				begin
					current_state <= next_state;
				end
			else
				begin
					current_state <= STOP;
				end
		end
	
	//output to led_flow
	always@(current_state)
		begin
			if(!rst)
				begin
					case(current_state)
						STOP:
							begin
								led_left <= blink;
								led_right <= blink;
								led_flow <= stop;
							end
						GO:
							begin
								led_left <= on;
								led_right <= on;
								led_flow <= go;
							end
						LEFT:
							begin
								led_left <= blink;
								led_right <= off;
								led_flow <= left;
							end
						RIGHT:
							begin
								led_left <= off;
								led_right <= blink;
							   led_flow <= right; 
							end
						BACK:
							begin
								led_left <= off;
								led_right <= off;
								led_flow <= back;
							end
						default:
							begin
								led_left <= blink;
								led_right <= blink;
								led_flow <= stop;
							end
					endcase
				end
			else
				begin
					led_left <= blink;
					led_right <= blink;
					led_flow <= stop;
				end
		end
	
endmodule
