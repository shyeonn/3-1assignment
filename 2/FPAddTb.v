`timescale 1 ns / 100 ps   

module FPAddTb();
    integer file,h; //파일 입력을 위한 변수
    reg [9:0] A,B; //입력
    wire [9:0] S; //출력
    wire Cout;
    
    integer i,n; //반복횟수를 결정하기 위한 변수 
    real A_dec,B_dec, S_dec;//실수값 저장
    
    FPAdd UUT(A, B, S, Cout); //모듈 불러오기
    
    initial begin       
        $dumpfile("test.vcd"); //test파일 생성
        $dumpvars(0, FPAddTb); 

        file = $fopenr("input.txt");   //txt파일을 받아오기 위해 $fopenr 함수 이용
        h = $fscanf(file,"%d\n",n); // $fscanf 함수 이용하여 첫번째줄의 값을 n 변수에 저장

        for(i=1;i<n+1;i++)begin //n회만큼 반복
            h = $fscanf(file,"%b %b\n",A,B); //다음줄의 값 두개를 각각 A, B변수에 저장
            #1 
            A_dec= ((2**0)+(A[5]*0.5)+(A[4]*0.25)+(A[3]*0.125)+
                    (A[2]*0.0625)+(A[1]*0.03125)+(A[0]*0.015625))*2**(A[9:6]); //A,B,S의 이진수값을 10진수로 변환하여 저장한다. 이하동일
            B_dec= ((2**0)+(B[5]*0.5)+(B[4]*0.25)+(B[3]*0.125)+
                    (B[2]*0.0625)+(B[1]*0.03125)+(B[0]*0.015625))*2**(B[9:6]); 
            S_dec= ((2**0)+(S[5]*0.5)+(S[4]*0.25)+(S[3]*0.125)+
                    (S[2]*0.0625)+(S[1]*0.03125)+(S[0]*0.015625))*2**(S[9:6]);
            $display("[#%2d] A=0b%b,%4f B=0b%b,%4f C=0b%b,%4f",i,A,A_dec,B,B_dec,S,S_dec); //A,B,S의 이진수와 십진수값을 출력한다 
        end

        
    end

endmodule