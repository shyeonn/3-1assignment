`timescale 1 ns / 100 ps // #1을 1ns로 설정한다. /뒤는 해상도

module hex2ascii_tb(); 
    reg [3:0]Hex_St=4'b0000; //St모델에 입력될 16진수값을 0으로 초기화시킨다. 이하동일
    reg [3:0]Hex_Df=4'b0000;
    reg [3:0]Hex_Bh=4'b0000;
    wire [6:0]Ascii_St,Ascii_Df,Ascii_Bh; //각각의 모델에 출력으로 나오게되는 Wire 선언
    integer i; //반복문을 위한 정수형 변수 선언

    hex2ascii_struct struct(.H(Hex_St), .A(Ascii_St)); //각각의 모델을 불러오게된다. 
    hex2ascii_df dataflow(.H(Hex_Df), .A(Ascii_Df));
    hex2ascii_bh behavior(.H(Hex_Bh), .A(Ascii_Bh));

    initial begin
        $dumpfile("test.vcd"); //파형생성을 위한 명령어
        $dumpvars; 
        
        $display("\n<Struct Model>");     //터미널창에 출력시키는 함수 St모델의 모듈에 대한 입출력부터 테스트한다. 이하 동일 
        for (i=0; i<16; i = i + 1 )begin //0~16까지의 입력을 주기위해 1씩 더하며 반복한다
             #1 //0초 기준으로는 입력에 대한 출력이 존재하지 않으므로 먼저 10ns의 시간지연을 준다.
            
            
            if (i>=0 && i<10)begin //예측값을 위한 조건문, 해당 알고리즘은 Bh모델에서 구현한것과 동일. 이하동일
                $display("[%2d] < %H >   < 0b%b >   < 0b%b >", $time, Hex_St, Ascii_St, Hex_St +7'b0110000); //현재 시간, 입력값, 출력값, 예측값을 터미널창에 표시. 이하 동일
            end
            else if (i >= 10 && i < 16) begin
                $display("[%2d] < %H >   < 0b%b >   < 0b%b >", $time, Hex_St , Ascii_St, Hex_St + 7'b0110111);
            end
            
            Hex_St++; //입력에 들어가게 될 값을 1 올려준다.

            
        end

        $display("\n<Dataflow Model>");    
        for (i=0; i<16; i = i + 1 )begin
            #1
            if (i>=0 && i<10)begin
                $display("[%2d] < %H >   < 0b%b >   < 0b%b >", $time, Hex_Df, Ascii_Df, Hex_Df+7'b0110000);

            end
            else if (i >= 10 && i < 16) begin
                $display("[%2d] < %H >   < 0b%b >   < 0b%b >", $time, Hex_Df , Ascii_Df, Hex_Df + 7'b0110111);
            end
            Hex_Df++;
        end
        
        $display("\n<Behavior Model>");    
        for (i=0; i<16; i = i + 1 )begin
            #1
            if (i>=0 && i<10)begin
                $display("[%2d] < %H >   < 0b%b >   < 0b%b >", $time, Hex_Bh, Ascii_Bh, Hex_Bh+7'b0110000);
            end
            else if (i >= 10 && i < 16) begin
                $display("[%2d] < %H >   < 0b%b >   < 0b%b >", $time, Hex_Bh , Ascii_Bh, Hex_Bh + 7'b0110111);
            end
            Hex_Bh++;
        end
        
    end

endmodule
