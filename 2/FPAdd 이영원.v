
module Shift( A, B, A_shift, B_shift);
    input [9:0] A,B;
    output reg [10:0] A_shift, B_shift;
    reg [6:0] mantissa_A;
    reg [6:0] mantissa_B;
    reg [3:0] exponent_A;
    reg [3:0] exponent_B;
    integer exp,i;


    always @(*) begin
        mantissa_A = 7'b1000000;
        mantissa_B = 7'b1000000;
        exponent_A=A[9:6];
        exponent_B=B[9:6];
        mantissa_A[5:0] =A[5:0];
        mantissa_B[5:0] =B[5:0];

        if (A[9:6]>B[9:6])begin ///exponent가 A가 더 클 경우
            exp=A[9:6]-B[9:6];
            mantissa_B = mantissa_B >> exp;
            for (i=0;i<exp;i++)begin
                exponent_B = exponent_B + 1'b1;
            end

            A_shift = {exponent_A, mantissa_A};
            B_shift = {exponent_B, mantissa_B};
            //$display("before shift A B %b, %b",A,B);
            //$display("after  shift A B %b, %b",A_shift,B_shift);
        end
        else if (A[9:6]<B[9:6])begin///exponent가 B가 더 클 경우
            exp=B[9:6]-A[9:6];
            //$display("exp  %d",exp);
            mantissa_A = mantissa_A >> exp;
            //$display("manti A exp A<B일때  %b",mantissa_A);
            for (i=0;i<exp;i++)begin
                exponent_A = exponent_A + 1'b1;
                //$display("exp A %b,  i= %d",exponent_A, i);
            end
            A_shift = {exponent_A, mantissa_A};
            B_shift = {exponent_B, mantissa_B};
            //$display("before shift A B %b, %b",A,B);
            //$display("after  shift A B %b, %b",A_shift,B_shift);
        end
        else begin          
            A_shift={exponent_A, mantissa_A};
            B_shift={exponent_B, mantissa_B};
            //$display("before shift A B %b, %b",A,B);
            //$display("after  shift A B %b, %b",A_shift,B_shift);
        end
        //$display("----------shifter finish");
    end

endmodule

module Adder(a, b, R);
    input [10:0] a,b;
    output reg [9:0] R;
    reg [7:0] mantissa_S;
    reg [7:0] mantissa_A;
    reg [7:0] mantissa_B;
    reg [3:0] exponent_A;
    reg [3:0] exponent_B;

    always @(*) begin
        mantissa_A=8'b00000000;
        mantissa_B=8'b00000000;
        exponent_A=a[10:7];
        exponent_B=b[10:7];
        
        mantissa_A[6:0]= a[6:0];
        mantissa_B[6:0]= b[6:0];

        //$display("---------adder----------");
        //$display("mantissa A %b",mantissa_A);
        //$display("mantissa B %b",mantissa_B);
        mantissa_S=mantissa_A+mantissa_B;
        //$display("sum of mantissa %b",mantissa_S);

        if ( 15==a[10:7] && 15==b[10:7] && mantissa_S[7]==1 )begin           
            R=10'b1111111111;
        end
        else begin        
            if (mantissa_S[7]==1)begin
                //$display("exp A %b",exponent_A);
                exponent_A = a[10:7]+1'b1;
                //$display("exp A %b   1비트 더한거",exponent_A);
                //$display("shift 전 %b",mantissa_S);
                mantissa_S= mantissa_S >> 1;
                //$display("shift 후 %b",mantissa_S);
                R = {exponent_A, mantissa_S[5:0]};
                //$display(" result %b",R);
            end
            else begin
                R = {exponent_A, mantissa_S[5:0]};
                //$display(" result %b",R);
            end 
        end
        //$display("----------adder finish");
    end

endmodule


module FPAdd( A, B, S);
    input [9:0] A,B;
    output [9:0] S;
    wire [10:0] A_shift,B_shift;

    Shift S1(.A(A),.B(B),.A_shift(A_shift),.B_shift(B_shift));
    Adder A1(.a(A_shift),.b(B_shift),.R(S));

    
endmodule

