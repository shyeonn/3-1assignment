`timescale 1 ns / 100 ps   

module HGameTb();

    reg CLK, RST, A, B, C; //입력

    wire A_DISP, B_DISP, C_DISP; //출력
    wire [2:0] Winner_DISP;


    HGame UUT1(CLK, RST, A, B, C, Winner_DISP, A_DISP, B_DISP, C_DISP); 
    Display UUT2(CLK, RST, Winner_DISP, A_DISP, B_DISP, C_DISP);


    initial begin //클락신호 초기화
        
        CLK = 1;
    end

    always begin //클락신호 생성
        #1
        CLK = ~CLK;
        
    end

    initial begin       
        $dumpfile("test.vcd"); //test파일 생성
        $dumpvars(0, HGameTb); 
        RST = 1; //초기화를 위해 신호 1로
        #2
        RST = 0; //초기화 신호 다시 0으로 
        A = 1; B = 1; C= 1; //DRAW
        #2

        #2


        A = 0; B = 1; C= 1; //Awin
        #2

        #2

        A = 1; B = 0; C= 1; //Bwin
        #2

        #2


        A = 1; B = 1; C= 0; //Cwin
        #2

        #2

        A = 1; B = 0; C= 0; 
        #2
        A = 0; B = 1; C= 1; // Awin

        #2

        #2        

        A = 0; B = 1; C = 0 ; 
        #2
        A = 1; B = 0; C = 1; // Bwin

        #2

        #2 

        A = 0; B = 0; C= 1; 
        #2
        A = 1; B = 1; C= 0; // Cwin

        #2

        #2                 

        A = 1; B = 0; C= 0; 
        #2
        A = 0; B = 1; C= 0; // ABwin

        #2

        #2

        A = 1; B = 0; C= 0; 
        #2
        A = 0; B = 0; C= 1; // ACwin

        #2

        #2

        A = 0; B = 1; C= 0; 
        #2
        A = 0; B = 0; C= 1;// BCwin
        #2

        #2

        A = 0; B = 0; C= 0; 
        #2
        A = 0; B = 0; C= 0;
        #2
        A = 0; B = 0; C= 0;
        #2
        A = 1; B = 1; C= 1;
        #2 

        #2
        $finish;
    end
    

endmodule
