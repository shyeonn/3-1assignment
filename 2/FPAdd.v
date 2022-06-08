module FPAdd(
input [9:0] A,
input [9:0] B,
output [9:0] Out,
output Cout
);
wire [5:0] MA; //A의 마티사 부분
wire [5:0] MB; //B의 마티사 부분
wire [5:0] MO; //덧셈결과 마티사부분
wire [5:0] MB1; //쉬푸트 돌리고 덧셈로 들어갈 마티사 B

wire [3:0] EA; //A의 지수부분
wire [3:0] EB; //B의 지수부분
wire [3:0] EO; //덧셈결과 지수부분
wire [3:0] E1; 


wire [9:0] FA; //쉬프트 결과 값 저장
wire [9:0] FB; //쉬프트 결과 값 저장 

wire [9:0] FO; //쉬프트 결과 할 값 저장

assign MA[5:0] = A[5:0]; //알맞게 그 값을 대입 시켜준다
assign MB[5:0] = B[5:0];

assign EA = A[9:6]; //지수 부분도 그와 맞게 대입시켜준다.
assign EB = B[9:6];
assign EO = 4'b1001;
assign MB1 = FB[5:0];

wire [3:0] num1,num5; // 쉬프트 값을 대입해줄 변수설정

assign num1 = EA - EB; //지수부분 A-B에서 빼준 값을 넣어준다.
myshifter Bshi(B, num1,FB);

//num1만큼 쉬프트 해준다.

adder abadder(MA,MB1,MO,Cout);

assign num5 = ((Cout) ? 4'b0001 : 4'b0000); //num5에 캐리아웃이 1이면 1값 아니면 0값을 저장시켜준다.
//참이라면 1을 더해주고 1을 쉬프트할것이며 아니면 0을 더해줄것이다.
assign E1 = EO + num5;
assign FO = {E1,MO};
//이제 Out값을 쉬프트 해준다.
myshifter Oshi(FO,num5,Out); 
endmodule

module myshifter(Din, num ,Dout);
input [9:0] Din; // 데이터 인풋값
input [3:0] num; //쉬프트 amount
output [9:0] Dout; //쉬프트 값 출력

reg[9:0] Dout,x1,x2,x3,x4,x5,x6,x7,x8,x9;

always @ (Din or num) begin
if( num == 1) x1 = {1'b0 , Din[9:1]}; else x1=Din;
if( num == 2) x2 = {2'b00 , Din[9:2]}; else x2=x1;
if( num == 3) x3 = {3'b000 , Din[9:3]}; else x3=x2;
if( num == 4) x4 = {4'b0000 , Din[9:4]}; else x4=x3;
if( num == 5) x5 = {5'b00000 , Din[9:5]}; else x5=x4;
if( num == 6) x6 = {6'b000000 , Din[9:6]}; else x6=x5;
if( num == 7) x7 = {7'b0000000 , Din[9:7]}; else x7=x6;
if( num == 8) x8 = {8'b00000000 , Din[9:8]}; else x8=x7;
if( num == 9) x9 = {9'b000000000 , Din[9]}; else x9=x8;
if( num >= 10 && num < 15 ) Dout = {10'b0000000000}; else Dout = x9;
//10과 15사이의 쉬프트값은 모두 어차피 0이므로 설정해주며,
//1~9사이 일 경우의 쉬프트 값들 모듈 완성해준다.
end
endmodule 

module adder(A,B,C,Cout); //덧셈기 구현한다.
parameter num = 6;//마티사는 6비트이므로

input [num-1:0] A,B;

output [num-1:0] C; // 덧셈 결과 값 저장
output Cout; //캐리아웃으로 발생 확인

assign { Cout, C} = A + B; // 덧셈하여 MSB는 캐리아웃값으로 지정한다.

endmodule







