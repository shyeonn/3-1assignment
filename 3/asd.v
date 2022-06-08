module asd(clock_50m, pb, fnd_s, fnd_d);
	
	// input output.
	input clock_50m; //클락신호
	input [15:0] pb; //입력신호
	output reg [5:0] fnd_s; //몇번째에 출력할건지
	output reg [7:0] fnd_d; //어떤숫자 출력할건지
	
	// clock.
	reg [15:0] npb; 
	reg [31:0] init_counter;
	reg sw_clk; 
	reg fnd_clk;
	reg [2:0] fnd_cnt; //카운트 3비트 -> 8자리 표현 
	
	// 7-segment.
	reg [4:0] set_no1; //입력된 숫자
	reg [4:0] set_no2;
	reg [4:0] set_no3;
	reg [4:0] set_no4;
	reg [4:0] set_no5;
	reg [4:0] set_no6;
	reg [6:0] seg_100000; //위치에 해당하는값
	reg [6:0] seg_10000;
	reg [6:0] seg_1000;
	reg [6:0] seg_100;
	reg [6:0] seg_10;
	reg [6:0] seg_1;
	

	
	// switch(keypad) control.
	reg [15:0] pb_1st; //첫번째입력
	reg [15:0] pb_2nd; //두번째입력
	reg sw_toggle; //토글상태
	
	// sw_status.
	reg [3:0] sw_status; //현재상태
	parameter sw_idle = 0;  //완전히 초기상태
	parameter sw_start = 1; // =을 눌러서 숫자를 입력받을 수 있는 상태로 한다. 
	parameter sw_s1 = 2; //이후 숫자를 누를때마다 하나씩 증가 
	parameter sw_s2 = 3;
	parameter sw_s3 = 4;
	parameter sw_s4 = 5;
	parameter sw_s5 = 6;
	parameter sw_s6 = 7;
	parameter sw_result = 8; // 숫자와 연산자 입력이 된 후 =을 눌렀을때 최종값 출력 상태 

	
	//calculate
	integer cal_temp; //입력받은값
	reg notinit; //0이면 연산자 첫번째입력, 1이면 연산자 첫번째입력이 아님
	reg [2:0] op_temp; //연산자 저장 0은 연산자입력 없을떄, 1은 +, 2는 -, 3은 * 4는 / 5는 % 6은 제곱
	reg [1:0] count; //0일때가 일반적상태, 1일때가 나머지연산 두번누를때 ,2일때가 곱하기 두번눌러 제곱 (연산자 두번입력시에 예외를 두기 위함)


	// initial.
	initial begin
		sw_status <= sw_idle; //초기상태
		sw_toggle <= 0; 
		npb <= 'h0000;
		pb_1st <= 'h0000;
		pb_2nd <= 'h0000;
		set_no1 <= 22; //StArt 
		set_no2 <= 10;
		set_no3 <= 12;
		set_no4 <= 17;
		set_no5 <= 10;
		set_no6 <= 20;
		cal_temp <= 0; //입력값 초기 0
		op_temp <= 0; //연산기호 초기 0
		notinit <= 0;
		count <= 0;
	end
	
	// input. clock divider.
	always begin
		npb <= ~pb;						// input
		sw_clk <= init_counter[20];		// clock for keypad(switch)
		fnd_clk <= init_counter[16];	// clock for 7-segment
	end
	
	// clock_50m. clock counter.
	always @(posedge clock_50m) begin
		init_counter <= init_counter + 1;
	end
	
	// sw_clk. get two consecutive inputs to correct switch(keypad) error.
	always @(posedge sw_clk) begin
		pb_2nd <= pb_1st; //클락이 한번 돌때마다 이전 입력값을 다음 입력값으로 보낸다.
		pb_1st <= npb; //현재 입력된 값을 넣어준다
		
		if (pb_2nd == 'h0000 && pb_1st != pb_2nd) begin  //이전 입력값이 0 이고 현재 입력값과 이전입력값이 다를때, 즉 아무것도 눌리지 않은 상태에서 어떤 수가 눌렸을때
			sw_toggle <= 1; //1로 바꾼다
		end
		
		if (sw_toggle == 1 && pb_1st == pb_2nd) begin//입력이 있고, 아무것도 눌리지 않은 상태가 되었을 때
			sw_toggle <= 0; //0으로 바꾸고 입력에 해당하는 케이스문을 실행한다. 
			if(sw_status == sw_start)begin //만약 start status라면 숫자를 입력받기위해 ------ 상태로 segment를 표시한다.
				set_no1 <= 18;
				set_no2 <= 18;
				set_no3 <= 18;
				set_no4 <= 18;
				set_no5 <= 18;
				set_no6 <= 18;
				
			end

			
			case (pb_1st) //현재 입력된 값에 의한 케이스문
					'h0001: begin //1입력 되었을때
						case (sw_status)
							sw_idle: begin //초기상태에서 입력되면 에러 
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
							end
							sw_start: begin //status가 start라면
								sw_status <= sw_s1; //가장왼쪽자리에 1표시
								set_no1 <= 1;
							end
							sw_s1: begin //status가 s1이라면
								sw_status <= sw_s2; //두번째자리에 1표시 
								set_no2 <= 1;
								
							end
							sw_s2: begin//status가 s2이라면
								sw_status <= sw_s3; //세번째자리에 1표시
								set_no3 <= 1;
							end
							sw_s3: begin//status가 s3이라면
								sw_status <= sw_s4; //네번째자리에 1표시
								set_no4 <= 1;
								
							end
							sw_s4: begin//status가 s4이라면
								sw_status <= sw_s5; //다섯번째자리에 1표시
								set_no5 <= 1;
								
							end
							sw_s5: begin//status가 s5이라면
								sw_status <= sw_s6;
								set_no6 <= 1;
								
							end
							sw_s6: begin//status가 s6으로 숫자를 모두 입력받은 상태라면
								sw_status <= sw_idle; //에러 출력
								set_no1 <= 16; //e
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							
						endcase
					end
					'h0002: begin //2입력 위와동일
						case (sw_status)
							sw_idle: begin
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
							end
							sw_start: begin
								sw_status <= sw_s1;
								set_no1 <= 2;
							end
							sw_s1: begin
								sw_status <= sw_s2;
								set_no2 <= 2;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 2;
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 2;
								
							end
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 2;
								
							end
							sw_s5: begin
								sw_status <= sw_s6;
								set_no6 <= 2;
								
							end
							sw_s6: begin
								sw_status <= sw_idle;
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							
						endcase
					end
					'h0004: begin //3입력 위와동일
						case (sw_status)
							sw_idle: begin
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
							end
							sw_start: begin
								sw_status <= sw_s1;
								set_no1 <= 3;
							end
							sw_s1: begin
								sw_status <= sw_s2;
								set_no2 <= 3;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 3;
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 3;
								
							end
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 3;
								
							end
							sw_s5: begin
								sw_status <= sw_s6;
								set_no6 <= 3;
								
							end
							sw_s6: begin
								sw_status <= sw_idle;
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							
						endcase
					end
					'h0008: begin // +입력
						case (sw_status)
							sw_idle: begin //idle상태에서 입력시 err표시
								set_no1 <= 16; //e
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;

							end
							sw_start: begin //start 상태에서 입력시 err표시
								set_no1 <= 16; //e
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;

							end
							sw_s1: begin // '+' add , 1의자리수에서의 계산
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0; //+입력은 두번입력이 불가하므로 0상태로 한다
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 12;//A
								set_no5 <= 15;//d
								set_no6 <= 15;//d
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <= 1; //더이상 첫입력이 아니다라는 신호
									cal_temp <= set_no1; //temp에 현재입력값 대입
									op_temp <= 1; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + set_no1;
									end
									2:begin
										cal_temp <= cal_temp - set_no1;
									end
									3:begin
										cal_temp <= cal_temp * set_no1;
									end
									4:begin
										cal_temp <= cal_temp / set_no1;
									end
									5:begin
									   cal_temp <= cal_temp % set_no1;
									end
									6:begin
									   cal_temp <= cal_temp * cal_temp;
									end
									endcase
						
									op_temp <= 1; //+연산자가 입력되었다는걸 저장해둔다.
								end
							end
							sw_s2: begin // '+' add ,10의자리수에서의 계산
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
                        		count <= 0; //+입력은 두번입력이 불가하므로 0상태로 한다
								set_no1 <= 20; 
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 12;//A
								set_no5 <= 15;//d
								set_no6 <= 15;//d
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*10 + set_no2; //temp에 현재입력값 대입
									op_temp <= 1; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10 + set_no2);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10 + set_no2);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10 + set_no2);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10 + set_no2);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10 + set_no2);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 1; //+연산자가 입력되었다는걸 저장해둔다.
								end
							end
							sw_s3: begin // '+' add , 100의자리수에서의 계산
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0; //+입력은 두번입력이 불가하므로 0상태로 한다
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 12;//A
								set_no5 <= 15;//d
								set_no6 <= 15;//d
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*100 + set_no2*10 + set_no3; //temp에 현재입력값 대입
									op_temp <= 1; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100 + set_no2*10 + set_no3);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100 + set_no2*10 + set_no3);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100 + set_no2*10 + set_no3);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100 + set_no2*10 + set_no3);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100 + set_no2*10 + set_no3);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 1;	 //+연산자가 입력되었다는걸 저장해둔다.
								end
							end
							sw_s4: begin // '+' add, 1000의 자리수에서의 계산
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0;  //+입력은 두번입력이 불가하므로 0상태로 한다
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
                        		set_no4 <= 12;
								set_no5 <= 15;
								set_no6 <= 15;
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*1000 + set_no2*100 + set_no3*10 + set_no4; //temp에 현재입력값 대입
									op_temp <= 1; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 1; //+연산자가 입력되었다는걸 저장해둔다.
								end
							end

							sw_s5: begin // '+' add , 10000의자리수에서의 계산
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0; //+입력은 두번입력이 불가하므로 0상태로 한다
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
                        		set_no4 <= 12;//A
								set_no5 <= 15;//d
								set_no6 <= 15;//d
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5; //temp에 현재입력값 대입
									op_temp <= 1; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 1; //+연산자가 입력되었다는걸 저장해둔다.
								end
							end
							sw_s6: begin // '+' add 100000의자리수에서의 계산
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0; //+입력은 두번입력이 불가하므로 0상태로 한다
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
                        		set_no4 <= 12;//A
								set_no5 <= 15;//d
								set_no6 <= 15;//d
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6; //temp에 현재입력값 대입
									op_temp <= 1; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									6:begin
									   cal_temp <= cal_temp * cal_temp;
									end
									endcase
									op_temp <= 1; //+연산자가 입력되었다는걸 저장해둔다.
									
								end
							end

						endcase
					end
					'h0010: begin //4입력일때 위와 동일
						case (sw_status)
							sw_idle: begin
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							sw_start: begin
								sw_status <= sw_s1;
								set_no1 <= 4;
								
							end
							sw_s1: begin
								sw_status <= sw_s2;
								set_no2 <= 4;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 4;
								
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 4;
								
							end
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 4;
								
							end
							sw_s5: begin
								sw_status <= sw_s5;
								set_no6 <= 4;
								
							end
							sw_s6: begin
								sw_status <= sw_idle;
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
						endcase
					end
					'h0020: begin //5입력일때 위와 동일
						case (sw_status)
							sw_idle: begin
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							sw_start: begin
								sw_status <= sw_s1;
								set_no1 <= 5;
								
							end
							sw_s1: begin
								sw_status <= sw_s2;
								set_no2 <= 5;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 5;
								
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 5;
								
							end
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 5;
								
							end
							sw_s5: begin
								sw_status <= sw_s6;
								set_no6 <= 5;
								
							end
							sw_s6: begin
								sw_status <= sw_idle;
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
							end
						endcase
					end
					'h0040: begin //6입력일때 위와 동일
						case (sw_status)
							sw_idle: begin
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							sw_start: begin
								sw_status <= sw_s1;
								set_no1 <= 6;
								
							end
							sw_s1: begin
								sw_status <= sw_s2;
								set_no2 <= 6;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 6;
								
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 6;
								
							end
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 6;			
							end
							sw_s5: begin
								sw_status <= sw_s6;
								set_no6 <= 6;
								
							end
							sw_s6: begin
								sw_status <= sw_idle;
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
						endcase
					end
					'h0080: begin   //'-', substract 빼기 입력일떄
						case (sw_status)
							sw_idle: begin //idle 상태라면 초기이므로 Err표시를 한다.
								set_no1 <= 16; //E
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;

							end
							sw_start: begin //start 상태라면 숫자를 입력받아야 하므로 Err표시를 한다.
								sw_status <= sw_idle; //초기상태로 보낸다
								set_no1 <= 16; //E
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;

							end
							sw_s1: begin //'-' sub
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
                      
								count <= 0; //-입력에서는 두번 연산자가 입력될일 없으므로 0상태로 한다.
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 5; //s
								set_no5 <= 11;//u
								set_no6 <= 13;//b
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <= 1; //더이상 첫입력이 아니다라는 신호
									cal_temp <= set_no1; //temp에 현재입력값 대입
									op_temp <= 2; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + set_no1;
									end
									2:begin
										cal_temp <= cal_temp - set_no1;
									end
									3:begin
										cal_temp <= cal_temp * set_no1;
									end
									4:begin
										cal_temp <= cal_temp / set_no1;
									end
									5:begin
									   cal_temp <= cal_temp % set_no1;
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
						
									op_temp <= 2; //-연산자가 입력되었다는걸 저장해둔다.
								end
							end
							sw_s2: begin //'-' sub
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
                    			count <= 0; //-입력에서는 두번 연산자가 입력될일 없으므로 0상태로 한다.
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 5; //s
								set_no5 <= 11;//u
								set_no6 <= 13;//b
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*10 + set_no2; //temp에 현재입력값 대입
									op_temp <= 2; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10 + set_no2);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10 + set_no2);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10 + set_no2);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10 + set_no2);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10 + set_no2);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 2; //-연산자가 입력되었다는걸 저장해둔다.
								end
							end
							sw_s3: begin //'-' sub
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 5; //s
								set_no5 <= 11;//u
								set_no6 <= 13;//b
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*100 + set_no2*10 + set_no3; //temp에 현재입력값 대입
									op_temp <= 2; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100 + set_no2*10 + set_no3);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100 + set_no2*10 + set_no3);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100 + set_no2*10 + set_no3);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100 + set_no2*10 + set_no3);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100 + set_no2*10 + set_no3);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 2;	//-연산자가 입력되었다는걸 저장해둔다.
								end
							end
							sw_s4: begin //'-' sub
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 5; //s
								set_no5 <= 11;//u
								set_no6 <= 13;//b

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*1000 + set_no2*100 + set_no3*10 + set_no4; //temp에 현재입력값 대입
									op_temp <= 2; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 2; //-연산자가 입력되었다는걸 저장해둔다.
								end
							end

							sw_s5: begin //'-' sub
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 5; //s
								set_no5 <= 11;//u
								set_no6 <= 13;//b

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5; //temp에 현재입력값 대입
									op_temp <= 2; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 2; //-연산자가 입력되었다는걸 저장해둔다.
								end
							end
							sw_s6: begin //'-' sub
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 0;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 5; //s
								set_no5 <= 11;//u
								set_no6 <= 13;//b

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6; //temp에 현재입력값 대입
									op_temp <= 2; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 2; //-연산자가 입력되었다는걸 저장해둔다.
									
								end
							end

						endcase
					end
					'h0100: begin //7이 입력되었을때 위와 동일
						case (sw_status)
							sw_idle: begin
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							sw_start: begin
								sw_status <= sw_s1;
								set_no1 <= 7;
								
							end
							sw_s1: begin
								sw_status <= sw_s2;
								set_no2 <= 7;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 7;
								
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 7;
							end	
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 7;
								
						   end
							sw_s5: begin
								sw_status <= sw_s6;
								set_no6 <= 7;
							end	
							
							sw_s6: begin
								sw_status <= sw_idle;
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
						endcase
					end
					'h0200: begin //8이 입력되었을때 위와 동일
						case (sw_status)
							sw_idle: begin
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							sw_start: begin
								sw_status <= sw_s1;
								set_no1 <= 8;
								
							end
							sw_s1: begin
								sw_status <= sw_s2;
								set_no2 <= 8;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 8;
								
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 8;
							end	
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 8;
								
						   end
							sw_s5: begin
								sw_status <= sw_s6;
								set_no6 <= 8;
							end	
							
							sw_s6: begin
								sw_status <= sw_idle;
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
						endcase
					end
					'h0400: begin //9가 입력되었을때 위와 동일
						case (sw_status)
							sw_idle: begin
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
							sw_start: begin
								sw_status <= sw_s1;
								set_no1 <= 9;
								
							end
							sw_s1: begin
								sw_status <= sw_s2;
								set_no2 <= 9;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 9;
								
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 9;
							end	
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 9;
								
						   end
							sw_s5: begin
								sw_status <= sw_s6;
								set_no6 <= 9;
							end	
							
							sw_s6: begin
								sw_status <= sw_idle;
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end
						endcase
					end
					'h0800: begin //'*', '^2' 곱셈 연산및 제곱 연산을 하기위한 버튼을 눌렀을때
						case (sw_status)
							sw_idle: begin //idle상태라면 초기상태이므로 Err표시
								set_no1 <= 16; //E
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;

							end
							sw_start: begin //초기상태일때
							if(count != 2)begin //만약 이전에 곱셈버튼이 눌린 상태가 아니라면 첫입력이 연산자이므로 Err
								set_no1 <= 16; //E
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
							 end
							else if(count == 2)begin // 만약 이전에 곱셈버튼이 눌렸다면 제곱연산 명령이므로 
								sw_status <= sw_s6; //연산자를입력받기위함, 숫자입력들어오면 에러
								count <= 0;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 5; //s
								set_no5 <= 17;//r
								set_no6 <= 15;//d

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <= 1; //더이상 첫입력이 아니다라는 신호
									op_temp <= 6; //연산자 저장 시킨다 
								end

								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									op_temp <= 6;
								end
							 
							end
							end
							sw_s1: begin // s1상태에서 눌렸다면 곱셈연산
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
                      
								count <= 2;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 10; //t
								set_no5 <= 1;  //i
								set_no6 <= 5;  //s
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <= 1; //더이상 첫입력이 아니다라는 신호
									cal_temp <= set_no1; //temp에 현재입력값 대입
									op_temp <= 3; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + set_no1;
									end
									2:begin
										cal_temp <= cal_temp - set_no1;
									end
									3:begin
										cal_temp <= cal_temp * set_no1;
									end
									4:begin
										cal_temp <= cal_temp / set_no1;
									end
									5:begin
									   cal_temp <= cal_temp % set_no1;
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end	
									endcase
						
									op_temp <= 3; //연산자를 저장한다.
								end
							end
							sw_s2: begin // '*'(times)
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
                        		count <= 2;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 10; //t
								set_no5 <= 1;  //i
								set_no6 <= 5;  //s
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*10 + set_no2; //temp에 현재입력값 대입
									op_temp <= 3; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10 + set_no2);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10 + set_no2);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10 + set_no2);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10 + set_no2);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10 + set_no2);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 3; //연산자를 저장한다
								end
							end
							sw_s3: begin // '*'(times)
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 2;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 10; //t
								set_no5 <= 1;  //i
								set_no6 <= 5;  //s
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*100 + set_no2*10 + set_no3; //temp에 현재입력값 대입
									op_temp <= 3; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100 + set_no2*10 + set_no3);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100 + set_no2*10 + set_no3);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100 + set_no2*10 + set_no3);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100 + set_no2*10 + set_no3);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100 + set_no2*10 + set_no3);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 3;	//연산자를 저장한다
								end
							end
							sw_s4: begin // '*'(times)
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 2;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 10; //t
								set_no5 <= 1;  //i
								set_no6 <= 5;  //s

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*1000 + set_no2*100 + set_no3*10 + set_no4; //temp에 현재입력값 대입
									op_temp <= 3; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 3; //연산자를 저장한다.
								end
							end

							sw_s5: begin // '*'(times)
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 2;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 10; //t
								set_no5 <= 1;  //i
								set_no6 <= 5;  //s

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5; //temp에 현재입력값 대입
									op_temp <= 3; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 3;
								end
							end
							sw_s6: begin // '*'(times)
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 2;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 10; //t
								set_no5 <= 1;  //i
								set_no6 <= 5;  //s

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6; //temp에 현재입력값 대입
									op_temp <= 3; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 3;
									
								end
							end

						endcase
					end
					'h1000: begin // =입력
						case (sw_status)
							sw_idle: begin //초기상태라면
								sw_status <= sw_start; //숫자를 입력받을 수 있는 상태로하고
								set_no1 <= 18; // 화면에 ------을 표시한다
								set_no2 <= 18;
								set_no3 <= 18;
								set_no4 <= 18;
								set_no5 <= 18;
								set_no6 <= 18;
								cal_temp <= 0; //입력값 초기 0
		                  op_temp <= 0; //연산기호 초기 0
		                  notinit <= 0; //가장 첫번째 입력받는 상태로 한다.
							end
							sw_start: begin //숫자를 입력받을 수 있는 상태에서
								if(notinit ==0)begin //연산자 입력이 없다면
								sw_status <= sw_idle; //초기상태로 보내고 에러표시
								set_no1 <= 16; //E
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp) //해당부분은 이전에 0이 입력되었을때 상태가 start로 돌아가게 되는데 그 상태에서 엔터를 눌렀을때 계산을 하기 위함입니다.
									1:begin 
										cal_temp <= cal_temp + set_no1;
									end
									2:begin
										cal_temp <= cal_temp - set_no1;
									end
									3:begin
										cal_temp <= cal_temp * set_no1;
									end
									endcase
									op_temp <= 0; //연산자 입력 없는 상태로
									sw_status <= sw_result; // 결과 상태로 이동
									end
							end
							sw_s1: begin 
								if(notinit == 0)begin //연산자가 첫입력이라면
									set_no1 <= 16;
									set_no2 <= 17;
									set_no3 <= 17;
									set_no4 <= 20;
									set_no4 <= 20;
									set_no4 <= 20;
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + set_no1;
									end
									2:begin
										cal_temp <= cal_temp - set_no1;
									end
									3:begin
										cal_temp <= cal_temp * set_no1;
									end
									4:begin
										cal_temp <= cal_temp / set_no1;
									end
									5:begin
									   cal_temp <= cal_temp % set_no1;
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 0;
									sw_status <= sw_result; //결과 상태로 이동
									
								
								end
							end
							sw_s2: begin 
								 //다시 숫자를 입력받을 수 있는 상태로 만든다.

								if(notinit == 0)begin //연산자가 첫입력이라면
									sw_status <= sw_idle;
									set_no1 <= 16;
									set_no2 <= 17;
									set_no3 <= 17;
									set_no4 <= 20;
									set_no5 <= 20;
									set_no6 <= 20;
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10 + set_no2);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10 + set_no2);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10 + set_no2);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10 + set_no2);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10 + set_no2);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 0;
									sw_status <= sw_result; //결과 상태로 이동
								end
							end
							sw_s3: begin 
								 //다시 숫자를 입력받을 수 있는 상태로 만든다.

								if(notinit == 0)begin //연산자가 첫입력이라면
									sw_status <= sw_idle;
									set_no1 <= 16;
									set_no2 <= 17;
									set_no3 <= 17;
									set_no4 <= 20;
									set_no5 <= 20;
									set_no6 <= 20;
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100 + set_no2*10 + set_no3);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100 + set_no2*10 + set_no3);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100 + set_no2*10 + set_no3);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100 + set_no2*10 + set_no3);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100 + set_no2*10 + set_no3);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 0;
									sw_status <= sw_result; //결과 상태로 이동
								end
							end
							sw_s4: begin 
								 //다시 숫자를 입력받을 수 있는 상태로 만든다.

								if(notinit == 0)begin
									sw_status <= sw_idle;
									set_no1 <= 16;
									set_no2 <= 17;
									set_no3 <= 17;
									set_no4 <= 20;
									set_no5 <= 20;
									set_no6 <= 20;
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 0;
									sw_status <= sw_result; //결과 상태로 이동
								end
							end

							sw_s5: begin 
								 //다시 숫자를 입력받을 수 있는 상태로 만든다.

								if(notinit == 0)begin //연산자가 첫입력이라면
									sw_status <= sw_idle;
									set_no1 <= 16;
									set_no2 <= 17;
									set_no3 <= 17;
									set_no4 <= 20;
									set_no5 <= 20;
									set_no6 <= 20;
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 0; 
								   sw_status <= sw_result; //결과 상태로 이동
								end
							end
							sw_s6: begin 
								 //다시 숫자를 입력받을 수 있는 상태로 만든다.

								if(notinit == 0)begin //연산자가 첫입력이라면
									sw_status <= sw_idle;
									set_no1 <= 16;
									set_no2 <= 17;
									set_no3 <= 17;
									set_no4 <= 20;
									set_no4 <= 20;
									set_no4 <= 20;
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 0;
									sw_status <= sw_result; //결과 상태로 이동
								end
							end
							sw_result: begin //계산 완료후 엔터가 한번 더 눌렸을 때
								if(cal_temp > 999999)begin //만약 계산결과 값이 양수일 때 6자리 이상이라면 오버플로우 출력
									set_no1 <= 0; //O
                  					set_no2 <= 21; //F
                  					set_no3 <= 20;
                  					set_no4 <= 20;
                  					set_no5 <= 20;
                  					set_no6 <= 20;
									sw_status <= sw_idle;
									
								end
								else if(cal_temp < -99999)begin //만약 계산 결과값이 음수일때 5자리 이상이라면 언더플로우 출력
									set_no1 <= 11; //U
                  					set_no2 <= 21; //F
                  					set_no3 <= 20;
                  					set_no4 <= 20;
                  					set_no5 <= 20;
                  					set_no6 <= 20;
									sw_status <= sw_idle;
									
								end
								else begin
									if(cal_temp >= 0)begin //양수값일때 자리수에 맞춰 결과값을 변환하여 각 자리에 출력한다.
										set_no1 <= (cal_temp / 100000);
										set_no2 <= ((cal_temp % 100000) / 10000); 
										set_no3 <= ((cal_temp % 10000) / 1000); 
										set_no4 <= ((cal_temp % 1000) / 100); 
										set_no5 <= ((cal_temp % 100) / 10); 
										set_no6 <= ((cal_temp) % 10);
										sw_status <= sw_idle; //초기상태로 보낸다.
										
									end
									else begin //음수값일때 가장 앞에는 -를 표시하고 나머지 자리에 자리수에 맞춰 결과값을 변환하여 각 자리에 출력한다. 
										set_no1 <= 18; //-
										set_no2 <= (((-1*cal_temp) % 100000) / 10000); 
										set_no3 <= (((-1*cal_temp)% 10000) / 1000); 
										set_no4 <= (((-1*cal_temp)% 1000) / 100); 
										set_no5 <= (((-1*cal_temp)% 100) / 10); 
										set_no6 <= ((-1*cal_temp) % 10);
										sw_status <= sw_idle; //초기상태로 보낸다
										
									end
								end
							end
						endcase
					end
					'h2000: begin //0입력
						case (sw_status)
							sw_idle: begin //초기상태일때 입력되면 err
							   set_no1 <= 16; //E
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								
							end	
							
							sw_start: begin //숫자입력시작상태일때 
								if(op_temp !=5 && op_temp !=4)begin // 이전의 연산자가 /, %가 아니라면 
								sw_status <= sw_start;  // 다시 현재 상태로 되돌아가 0을 입력하여도 다음자리로 넘어가지 않게 한다. 
								set_no1 <= 0; //첫번째자리에 0은 표시를 한다
								end
								else begin //이전의 연산자가 /, %라면 0으로 연산이 불가하므로
								sw_status <= sw_idle; //초기상태로 보내고 Err를 출력한다.
								set_no1 <= 16; //E
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
								end
								
								
							end
							sw_s1: begin //이후 자리에 0입력이 있다면 해당 자리에 0을 출력하고 다음자리로 넘어간다. 
								sw_status <= sw_s2;
								set_no2 <= 0;
								
							end
							sw_s2: begin
								sw_status <= sw_s3;
								set_no3 <= 0;
								
							end
							sw_s3: begin
								sw_status <= sw_s4;
								set_no4 <= 0;
								
							end
							sw_s4: begin
								sw_status <= sw_s5;
								set_no5 <= 0;
								
							end
							sw_s5: begin
								sw_status <= sw_s6;
								set_no6 <= 0;
								
							end
							sw_s6: begin //6자리가 입력된 상태에서 0이 입력되면 Err를 표시한다. 
								sw_status <= sw_idle; //초기상태로 돌아간다.
								set_no1 <= 16; //E
								set_no2 <= 17; //r
								set_no3 <= 17; //r
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
							end
						endcase
					end
					'h4000: begin //AC(초기화)버튼 
						
					sw_status <= sw_idle; //초기상태 값들을 다시 대입해준다.
		            sw_toggle <= 0; 
		            pb_1st <= 'h0000;
		        	pb_2nd <= 'h0000;
		            set_no1 <= 22; //StArt 
						set_no2 <= 10;
						set_no3 <= 12;
						set_no4 <= 17;
						set_no5 <= 10;
						set_no6 <= 20;
		            cal_temp <= 0; //입력값 초기 0
		            op_temp <= 0; //연산기호 초기 0
		            notinit <= 0;
					count <=0;
								
					end
					'h8000: begin // 나눗셈 및 나머지 연산을 하는 버튼
						case (sw_status) 
							sw_idle: begin //초기상태일때 눌린다면 에러
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;

							end
							sw_start: begin //숫자 입력 상태에서 눌렸을때
							 if(count != 1)begin //이전의 입력이 현재 버튼 입력이 아닐때 에러 (현재 버튼 입력 두번받기 위함)
								set_no1 <= 16;
								set_no2 <= 17;
								set_no3 <= 17;
								set_no4 <= 20;
								set_no5 <= 20;
								set_no6 <= 20;
							 end
							else if(count == 1)begin //이전의 입력에 현재버튼 입력이였을때 나눗셈 연산 한다(두번눌렸을 때)
							sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
                     		count <= 0;
							set_no1 <= 20;
							set_no2 <= 20;
							set_no3 <= 20;
							set_no4 <= 17; //r
							set_no5 <= 16; //E
							set_no6 <= 19; //n
							   if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <= 1; //더이상 첫입력이 아니다라는 신호
									op_temp <= 5; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									
									op_temp <= 5; //연산자 저장 시킨다.
								end
							 end
							end
							sw_s1: begin // '/' division operator
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
                        		set_no4 <= 15; //d
								set_no5 <= 1;  //i
								set_no6 <= 15; //d
								count <= 1;
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <= 1; //더이상 첫입력이 아니다라는 신호
									cal_temp <= set_no1; //temp에 현재입력값 대입
									op_temp <= 4; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + set_no1;
									end
									2:begin
										cal_temp <= cal_temp - set_no1;
									end
									3:begin
										cal_temp <= cal_temp * set_no1;
									end
									4:begin
										cal_temp <= cal_temp / set_no1;
									end
									5:begin
									   cal_temp <= cal_temp % set_no1;
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
						
									op_temp <= 4; //나눗셈 연산자 저장
								end
							end
							sw_s2: begin // '/' division operator
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
                        		count <= 1;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 15; //d
								set_no5 <= 1;  //i
								set_no6 <= 15; //d
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*10 + set_no2; //temp에 현재입력값 대입
									op_temp <= 4; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10 + set_no2);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10 + set_no2);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10 + set_no2);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10 + set_no2);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10 + set_no2);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 4; //나눗셈 연산자 저장
								end
							end
							sw_s3: begin // '/' division operator
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 1;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 15; //d
								set_no5 <= 1;  //i
								set_no6 <= 15; //d
								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*100 + set_no2*10 + set_no3; //temp에 현재입력값 대입
									op_temp <= 4; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100 + set_no2*10 + set_no3);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100 + set_no2*10 + set_no3);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100 + set_no2*10 + set_no3);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100 + set_no2*10 + set_no3);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100 + set_no2*10 + set_no3);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 4;	 //나눗셈 연산자 저장
								end
							end
							sw_s4: begin // '/' division operator
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 1;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 15; //d
								set_no5 <= 1;  //i
								set_no6 <= 15; //d

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*1000 + set_no2*100 + set_no3*10 + set_no4; //temp에 현재입력값 대입
									op_temp <= 4; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*1000 + set_no2*100 + set_no3*10 + set_no4);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 4; //나눗셈 연산자 저장
								end
							end

							sw_s5: begin // '/' division operator
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 1;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 15; //d
								set_no5 <= 1;  //i
								set_no6 <= 15; //d

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5; //temp에 현재입력값 대입
									op_temp <= 4; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*10000 + set_no2*1000 + set_no3*100 + set_no4*10 + set_no5);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 4; //나눗셈 연산자 저장
								end
							end
							sw_s6: begin // '/' division operator
								sw_status <= sw_start; //다시 숫자를 입력받을 수 있는 상태로 만든다.
								count <= 1;
								set_no1 <= 20;
								set_no2 <= 20;
								set_no3 <= 20;
								set_no4 <= 15; //d
								set_no5 <= 1;  //i
								set_no6 <= 15; //d

								if(notinit == 0)begin //연산자가 첫입력이라면
									notinit <=1; //첫입력이 아니다라는 신호
									cal_temp <= set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6; //temp에 현재입력값 대입
									op_temp <= 4; //연산자 저장 시킨다 
								end
								else if(notinit == 1)begin //연산자가 첫입력이 아니라면, 앞의 값들(저장숫자와 연산자) 계산한다.
									case(op_temp)
									1:begin
										cal_temp <= cal_temp + (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									2:begin
										cal_temp <= cal_temp - (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									3:begin
										cal_temp <= cal_temp * (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									4:begin
										cal_temp <= cal_temp / (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									5:begin
									   cal_temp <= cal_temp % (set_no1*100000 + set_no2*10000 + set_no3*1000 + set_no4*100 + set_no5*10 + set_no6);
									end
									6:begin
									   cal_temp <= cal_temp*cal_temp;
									end
									endcase
									op_temp <= 4; //나눗셈 연산자 저장
									
								end
							end

						endcase
					end
					endcase
					end
					end
	
	
	
	
	
	// 7-segment.
	always @(set_no1) begin //해당 숫자값을 세그먼트에 해당하는 이진수값으로 변환시켜준다.
		case (set_no1)
			0: seg_100000 <= 'b0011_1111; //0
			1: seg_100000 <= 'b0000_0110; //1
			2: seg_100000 <= 'b0101_1011; //2
			3: seg_100000 <= 'b0100_1111; //3
			4: seg_100000 <= 'b0110_0110; //4
			5: seg_100000 <= 'b0110_1101; //5
			6: seg_100000 <= 'b0111_1101; //6
			7: seg_100000 <= 'b0000_0111; //7
			8: seg_100000 <= 'b0111_1111; //8
			9: seg_100000 <= 'b0110_0111; //9
			10: seg_100000 <= 'b0111_1000; //t
			11: seg_100000 <= 'b0011_1110; //u
			12: seg_100000 <= 'b0111_0111; //A
			13: seg_100000 <= 'b0111_1100; //b
			14: seg_100000 <= 'b0011_1001; //c
			15: seg_100000 <= 'b0101_1110; //d
			16: seg_100000 <= 'b0111_1001; //E
			17: seg_100000 <= 'b0101_0000; //r
			18: seg_100000 <= 'b0100_0000; //-
			19: seg_100000 <= 'b0101_0100; //n
			21: seg_100000 <= 'b0111_0001; //F 
			22: seg_100000 <= 'b0110_1101; //S 
			23: seg_100000 <= 'b0101_0000; //r 
			default: seg_100000 <= 'b0000_0000; //Null
		endcase
	end
	always @(set_no2) begin
		case (set_no2)
			0: seg_10000 <= 'b0011_1111; //0
			1: seg_10000 <= 'b0000_0110; //1
			2: seg_10000 <= 'b0101_1011; //2
			3: seg_10000 <= 'b0100_1111; //3
			4: seg_10000 <= 'b0110_0110; //4 
			5: seg_10000 <= 'b0110_1101; //5 
			6: seg_10000 <= 'b0111_1101; //6
			7: seg_10000 <= 'b0000_0111; //7
			8: seg_10000 <= 'b0111_1111; //8
			9: seg_10000 <= 'b0110_0111; //9
			10: seg_10000 <= 'b0111_1000; //t
			11: seg_10000 <= 'b0011_1110; //u
			12: seg_10000 <= 'b0111_0111; //A
			13: seg_10000 <= 'b0111_1100; //b
			14: seg_10000 <= 'b0011_1001; //c
			15: seg_10000 <= 'b0101_1110; //d
			16: seg_10000 <= 'b0111_1001; //E
			17: seg_10000 <= 'b0101_0000; //r
			18: seg_10000 <= 'b0100_0000; //-
			19: seg_10000 <= 'b0101_0100; //n
			21: seg_10000 <= 'b0111_0001; //F 
			22: seg_10000 <= 'b0110_1101; //S 
			23: seg_10000 <= 'b0101_0000; //r 
			default: seg_10000 <= 'b0000_0000; //Null
		endcase
	end
	always @(set_no3) begin
		case (set_no3)
			0: seg_1000 <= 'b0011_1111; //0
			1: seg_1000 <= 'b0000_0110; //1
			2: seg_1000 <= 'b0101_1011; //2
			3: seg_1000 <= 'b0100_1111; //3
			4: seg_1000 <= 'b0110_0110; //4 
			5: seg_1000 <= 'b0110_1101; //5 
			6: seg_1000 <= 'b0111_1101; //6
			7: seg_1000 <= 'b0000_0111; //7
			8: seg_1000 <= 'b0111_1111; //8
			9: seg_1000 <= 'b0110_0111; //9
			10: seg_1000 <= 'b0111_1000; //t
			11: seg_1000 <= 'b0011_1110; //u
			12: seg_1000 <= 'b0111_0111; //A
			13: seg_1000 <= 'b0111_1100; //b
			14: seg_1000 <= 'b0011_1001; //c
			15: seg_1000 <= 'b0101_1110; //d
			16: seg_1000 <= 'b0111_1001; //E
			17: seg_1000 <= 'b0101_0000; //r
			18: seg_1000 <= 'b0100_0000; //-
			19: seg_1000 <= 'b0101_0100; //n
			21: seg_1000 <= 'b0111_0001; //F 
			22: seg_1000 <= 'b0110_1101; //S 
			23: seg_1000 <= 'b0101_0000; //r 
			default: seg_1000 <= 'b0000_0000; //Null
		endcase
	end
	always @(set_no4) begin
		case (set_no4)
			0: seg_100 <= 'b0011_1111; //0
			1: seg_100 <= 'b0000_0110; //1
			2: seg_100 <= 'b0101_1011; //2
			3: seg_100 <= 'b0100_1111; //3
			4: seg_100 <= 'b0110_0110; //4 
			5: seg_100 <= 'b0110_1101; //5 
			6: seg_100 <= 'b0111_1101; //6
			7: seg_100 <= 'b0000_0111; //7
			8: seg_100 <= 'b0111_1111; //8
			9: seg_100 <= 'b0110_0111; //9
			10: seg_100 <= 'b0111_1000; //t
			11: seg_100 <= 'b0011_1110; //u
			12: seg_100 <= 'b0111_0111; //A
			13: seg_100 <= 'b0111_1100; //b
			14: seg_100 <= 'b0011_1001; //c
			15: seg_100 <= 'b0101_1110; //d
			16: seg_100 <= 'b0111_1001; //E
			17: seg_100 <= 'b0101_0000; //r
			18: seg_100 <= 'b0100_0000; //-
			19: seg_100 <= 'b0101_0100; //n
			21: seg_100 <= 'b0111_0001; //F 
			22: seg_100 <= 'b0110_1101; //S 
			23: seg_100 <= 'b0101_0000; //r 
			default: seg_100 <= 'b0000_0000; //Null
		endcase
	end
	always @(set_no5) begin
		case (set_no5)
			0: seg_10 <= 'b0011_1111; //0
			1: seg_10 <= 'b0000_0110; //1
			2: seg_10 <= 'b0101_1011; //2
			3: seg_10 <= 'b0100_1111; //3
			4: seg_10 <= 'b0110_0110; //4 
			5: seg_10 <= 'b0110_1101; //5 
			6: seg_10 <= 'b0111_1101; //6
			7: seg_10 <= 'b0000_0111; //7
			8: seg_10 <= 'b0111_1111; //8
			9: seg_10 <= 'b0110_0111; //9
			10: seg_10 <= 'b0111_1000; //t
			11: seg_10 <= 'b0011_1110; //u
			12: seg_10 <= 'b0111_0111; //A
			13: seg_10 <= 'b0111_1100; //b
			14: seg_10 <= 'b0011_1001; //c
			15: seg_10 <= 'b0101_1110; //d
			16: seg_10 <= 'b0111_1001; //E
			17: seg_10 <= 'b0101_0000; //r
			18: seg_10 <= 'b0100_0000; //-
			19: seg_10 <= 'b0101_0100; //n
			21: seg_10 <= 'b0111_0001; //F 
			22: seg_10 <= 'b0110_1101; //S  
			23: seg_10 <= 'b0101_0000; //r 
			default: seg_10 <= 'b0000_0000; //Null
		endcase
	end
	always @(set_no6) begin
		case (set_no6)
			0: seg_1 <= 'b0011_1111; //0
			1: seg_1 <= 'b0000_0110; //1
			2: seg_1 <= 'b0101_1011; //2
			3: seg_1 <= 'b0100_1111; //3
			4: seg_1 <= 'b0110_0110; //4 
			5: seg_1 <= 'b0110_1101; //5 
			6: seg_1 <= 'b0111_1101; //6
			7: seg_1 <= 'b0000_0111; //7
			8: seg_1 <= 'b0111_1111; //8
			9: seg_1 <= 'b0110_0111; //9
			10: seg_1 <= 'b0111_1000; //t
			11: seg_1 <= 'b0011_1110; //u
			12: seg_1 <= 'b0111_0111; //A
			13: seg_1 <= 'b0111_1100; //b
			14: seg_1 <= 'b0011_1001; //c
			15: seg_1 <= 'b0101_1110; //d
			16: seg_1 <= 'b0111_1001; //E
			17: seg_1 <= 'b0101_0000; //r
			18: seg_1 <= 'b0100_0000; //-
			19: seg_1 <= 'b0101_0100; //n
			21: seg_1 <= 'b0111_0001; //F 
			22: seg_1 <= 'b0110_1101; //S 
			23: seg_1 <= 'b0101_0000; //r 
			default: seg_1 <= 'b0000_0000; //Null
		endcase
	end
	
	// fnd_clk. output.
	always @(posedge fnd_clk) begin //클락신호가 돌면서 세그먼트를 순서대로 하나씩 켠다.
		fnd_cnt <= fnd_cnt + 1; 
		case (fnd_cnt)
			5: begin 
				fnd_d <= seg_100000;//6번째자리 세그먼트에 값을 준다
				fnd_s <= 'b011111; //6번째자리 세그먼트를 켠다.
			end
			4: begin
				fnd_d <= seg_10000; //5번째자리 세그먼트에 값을 준다
				fnd_s <= 'b101111; //5번째자리 세그먼트를 켠다.
			end
			3: begin
				fnd_d <= seg_1000; //4번째자리 세그먼트에 값을 준다
				fnd_s <= 'b110111; //4번째자리 세그먼트를 켠다.
			end
			2: begin
				fnd_d <= seg_100; //3번째자리 세그먼트에 값을 준다
				fnd_s <= 'b111011; //3번째자리 세그먼트를 켠다.
			end
			1: begin
				fnd_d <= seg_10; //2번째자리 세그먼트에 값을 준다
				fnd_s <= 'b111101; //2번째자리 세그먼트를 켠다.
			end
			0: begin
				fnd_d <= seg_1; //1번째자리 세그먼트에 값을 준다
				fnd_s <= 'b111110; //1번째자리 세그먼트를 켠다.
			end
		endcase
	end
	
endmodule
