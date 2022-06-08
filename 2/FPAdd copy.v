`timescale 1 ns / 100 ps

module Subtraction(A, B, S, C); //덧셈기 구현
    parameter N =10;  //몇비트 계산할건지
    input [N-1:0] A, B; // 입력되는 두 수, 파라미터값으로 범위 지정
    output [N-1:0] S; // 덧셈 계산 결과, 파라미터로 범위 지정
    output C; // Carryout 출력

    assign{C,S} = A - B; //두비트 덧셈하여 MSB Cout으로, 하위비트는 Sum으로

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
    reg [9:0] Max, Min;
    wire C;

    

    Subtraction sub(Max, Min, S, C);

    always @(*) begin
        if(A>B)begin
            Max = A;
            Min = B;
        end 
        
    end
    

endmodule 
