module hex2ascii_df(H, A); //모듈선언
input [3:0] H; //입력부4비트
output [6:0] A;  //출력부7비트

assign A[6] = H[3] & H[2] | H[3] & H[1] ; //MSB 
assign A[5] = ~H[3] | ~H[2] & ~H[1];
assign A[4] = ~H[3] | ~H[2] & ~H[1];
assign A[3] = H[3] & ~H[2] & ~H[1];
assign A[2] = ~H[3] & H[2] | H[2] & H[0] | H[2] & H[1];
assign A[1] = ~H[3] & H[1] | H[1] & H[0] | H[3] & H[2] & ~H[1] & ~H[0];
assign A[0] = ~H[3] & H[0] | ~H[2] & ~H[1] & H[0] | H[3] & H[1] & ~H[0] | H[3] & H[2] & ~H[0]; //LSB
// 해당 기능을 수행하는 진리표를 그린뒤 카르노맵을 통해 논리식을 간소화하여서 각 비트에 대해 얻은 결과를 비트연산자를 이용해 계산

endmodule


module hex2ascii_struct (H, A);
input [3:0] H;
output [6:0] A;
wire A6_A, A6_B, A5, A4, A3, A2_A, A2_B, A2_C, A1_A, A1_B, A1_C, A0_A, A0_B, A0_C, A0_D; //게이트 사이에 연결되는 Wire 선언
wire NH0, NH1, NH2, NH3; //NOT Gate에 출력으로 나오게 되는 Wire 선언

not(NH0, H[0]);
not(NH1, H[1]);
not(NH2, H[2]);
not(NH3, H[3]);
//각각의 입력에 대한 반전된 출력

and (A6_A, H[3], H[2]);
and (A6_B, H[3], H[1]);
or (A[6], A6_A, A6_B); //MSB를 출력하는 식을 이용해 Gate 구현, 이하동일

and (A5, NH2, NH1);
or(A[5], NH3, A5);

and (A4, NH2, NH1);
or(A[4], NH3, A4);

and (A[3], H[3], NH2, NH1);

and(A2_A, NH3, H[2]);
and(A2_B, H[2], H[0]);
and(A2_C, H[2], H[1]);
or(A[2], A2_A, A2_B, A2_C);

and(A1_A, NH3, H[1]);
and(A1_B, H[1], H[0]);
and(A1_C, H[3], H[2], NH1, NH0);
or(A[1], A1_A, A1_B, A1_C);

and(A0_A, NH3, H[0]); //LSB
and(A0_B, NH2, NH1, H[0]);
and(A0_C, H[3], H[1], NH0);
and(A0_D, H[3], H[2], NH0);
or(A[0], A0_A, A0_B, A0_C, A0_D);
// 해당 기능을 수행하는 진리표를 그린뒤 카르노맵을 통해 논리식을 간소화하여서 각 비트에 대해 얻은 결과를 게이트를 통해 구현하였다.
    
endmodule


module hex2ascii_bh (H, A);
input [3:0] H;
output reg [6:0] A; //값을 대입하게 되므로 Reg 선언

always @(H) begin //H의 값에 변화가 생기면 실행하게 된다

    if(H >= 0 && H<10)begin //만약 입력된 16비트가 10보다 작거나 같다면, 0 기준으로 아스키코드 48부터 하나씩 올라가게 되므로 48값에 더해주게 된다
        A = H + 48;
    end
    else if (H >= 10 && H < 16)begin// 만약 입력된 16비트가 10보다 크다면, A 기준으로 아스키코드 55부터 하나씩 올라가게 되므로 55값에 더해주게 된다
        A = H + 55;
    end


end
    
    
endmodule