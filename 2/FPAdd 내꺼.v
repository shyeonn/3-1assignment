`timescale 1 ns / 100 ps

module Adder(A, B, S, C); //덧셈기 구현
    parameter N = 6;  //몇비트 계산할건지
    input [N-1:0] A, B; // 입력되는 두 수, 파라미터값으로 범위 지정
    output [N-1:0] S; // 덧셈 계산 결과, 파라미터로 범위 지정
    output C; // Carryout 출력

    assign{C,S} = A + B; //두비트 덧셈하여 MSB Cout으로, 하위비트는 Sum으로

endmodule


module seven2six_shifter(In, H, Out); //7비트를 6비트로 바꾸는 시프터로, H값만큼 시프팅 한다
    input [6:0] In; // 입력되는 7비트 시프터
    input [3:0] H;  // 입력되는 시프팅 비트수
    output [5:0] Out; // 시프팅 된 값중 히위 6비트 출력 

    assign Out = In>>H; //시프팅 연산자 이용하여 H값만큼 시프트
endmodule

module eight2six_shifter(In, H, Out); //8비트 시프터
    input [7:0] In; //입력되는 8비트
    input [3:0] H;  //출력되는 4비트
    output [5:0] Out; // 출력되는 상위 6비트
    assign Out = In>>H; //In을 H만큼 시프팅한다
endmodule

module FPAdd(A, B, S); //Floating Adder 모듈
    input [9:0] A, B; //10비트의 input
    output [9:0] S;//덧셈결과
    wire [9:0] Sum; //덧셈결과에서 OverFlow를 확인하기위한 중간 Wire 선언
    wire [3:0] A_Exp, B_Exp; //입력의 Exp부분 
    wire [5:0] A_Man, B_Man, //입력의 Mantissa부분
    Max_Man, Min_Man, //두개중 큰, 작은 Mantissa
    Shift_Man, //시프팅된 Mantissa
    Add_Man, Add_Man_Tmp, //덧셈된 Mantissa
    Add_Man_Tmp_Shift; //Carry가 있을때 Shifting된 Mantissa
    wire [6:0] Min_Man_MSB;//MSB에 1이 들어간(1.xx...형태로 나타내기위해) 작은 Mantissa
    wire [3:0] Exp_temp, Max_Exp, Add_Exp1; //Exp부분
    wire [1:0] two_bit;


    wire Cout; //덧셈후 Carry out
        assign A_Exp = A[9:6]; //Exp 및 Mantissa assign
        assign B_Exp = B[9:6];
        assign A_Man = A[5:0];
        assign B_Man = B[5:0];

        
        assign Exp_temp = (A_Exp >= B_Exp) ? A_Exp - B_Exp : B_Exp - A_Exp; // 지수 차이 assign
        assign Max_Exp = (A_Exp >= B_Exp) ? A_Exp : B_Exp; //둘중 큰 Exp assign 
        assign Min_Man = (A_Exp >= B_Exp) ? B_Man : A_Man; //둘중 작은 Mantissa min_Man에 assign
        assign Max_Man = (A_Exp < B_Exp) ? B_Man : A_Man; //둘중 큰 Mantissa Max_Man에 assign
        assign Min_Man_MSB = {1'b1, Min_Man}; //MSB에 1이 고려된 작은 Mantissa
        seven2six_shifter shift1(Min_Man_MSB, Exp_temp, Shift_Man); //지수 차이만큼 작은 mantissa shift          
        Adder Add1(Shift_Man, Max_Man, Add_Man_Tmp, Cout); //shifting후 덧셈
        assign Add_Exp1 = (Cout == 1'b1 || Exp_temp == 1'b0) ? 1+Max_Exp : Max_Exp; //최종 Exp에 Cout이 발생했을때 Exp 조정, 발생하지 않으면 그대로
        assign two_bit = (Cout == 1'b1 && Exp_temp == 1'b0) ? 2'b11 : 2'b10; //만약 지수가 같고 Cout발생했다면 11.xxx..와 같은 값 발생하므로 상위 2비트 경우에 따라 지정)
        eight2six_shifter shift2({two_bit, Add_Man_Tmp},4'd1,Add_Man_Tmp_Shift); //가장 앞 두비트에 10(exp가 다르고, Cout1) 또는 11(exp가 같고, Cout1)을 넣고 1만큼 shift
        assign Add_Man = (Cout == 1'b1 || Exp_temp == 1'b0) ?  Add_Man_Tmp_Shift : Add_Man_Tmp; //Cout이 있거나 Exp가 같을때는 Shitft된 값, 그렇지 않다면 그냥 덧셈값
        assign Sum = {Add_Exp1, Add_Man}; //오버플로우를 고려하지 않은 최종 10bit 출력값
        assign S = (A>B ? A : B) > Sum ? 10'b1111111111 : Sum; //오버플로우를 고려하기 위해서 두 값을 더한 값이 하나보다 작다면 오버플로우 발생이므로 그런 경우에 10'b1111111111 출력
        

endmodule 
