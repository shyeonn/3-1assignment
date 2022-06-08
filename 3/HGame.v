module HGame ( CLK, RST, A, B, C, Winner_DISP, A_DISP, B_DISP, C_DISP);
input CLK, RST, A,B,C;
output reg [2:0] Winner_DISP;
output reg A_DISP, B_DISP, C_DISP;


	reg [3:0] status; // state값을 저장하는 변수 선언
	parameter S_INIT = 0;  //state를 파라미터로 선언
	parameter S_AS = 1; 
  parameter S_BS = 2;
  parameter S_CS = 3;
  parameter S_AW = 4;
  parameter S_BW = 5;
  parameter S_CW = 6;
  parameter S_ABW = 7;
  parameter S_ACW= 8;
  parameter S_BCW = 9;
  parameter S_DRAW = 10;



    always @(posedge CLK) begin  
      if(RST == 1) begin  //RST이 1일때 초기화
        status <= S_INIT; //status 설정
        {A_DISP, B_DISP, C_DISP} <= 3'b000; //DISP값 초기화
        Winner_DISP <= 3'b000; //승부 결정 변수 초기화
      end

      case (status) //status에 따라서 case 실행
        S_INIT : begin //INIT 일때
          Winner_DISP <= 3'b000; 

          case ({A, B, C}) //입력값에 따라서 case 실행, DISP 값을 넣어주고 status를 바꾼다
          3'b000 : status <= S_INIT;
          3'b001 : begin 
            status <= S_CS;
            A_DISP <= 0;
            B_DISP <= 0;
            C_DISP <= 1;
          end
          3'b010 : begin 
            status <= S_BS;
            A_DISP <= 0;
            B_DISP <= 1;
            C_DISP <= 0;
          end
          3'b011 : begin 
            status <= S_AW;
            A_DISP <= 0;
            B_DISP <= 1;
            C_DISP <= 1;
          end
          3'b100 : begin 
            status <= S_AS;
            A_DISP <= 1;
            B_DISP <= 0;
            C_DISP <= 0;
          end
          3'b101 : begin 
            status <= S_BW;
            A_DISP <= 1;
            B_DISP <= 0;
            C_DISP <= 1;
          end
          3'b110 : begin 
            status <= S_CW;
            A_DISP <= 1;
            B_DISP <= 1;
            C_DISP <= 0;
          end
          3'b111 : begin 
            status <= S_DRAW;
            A_DISP <= 1;
            B_DISP <= 1;
            C_DISP <= 1;
          end
          endcase 
        end


        S_AS : begin //A가 일어선 상태이며, 아직 승부가 결정 안된 경우
          case ({A, B, C}) 
          3'b000 : status <= S_AS;
          3'b001 : begin 
            status <= S_ACW;
            A_DISP <= 0;
            B_DISP <= 0;
            C_DISP <= 1;
          end
          3'b010 : begin 
            status <= S_ABW;
            A_DISP <= 0;
            B_DISP <= 1;
            C_DISP <= 0;
          end
          3'b011 : begin 
            status <= S_AW;
            A_DISP <= 0;
            B_DISP <= 1;
            C_DISP <= 1;
          end
          3'b100 : begin 
            status <= S_AS;
            A_DISP <= 1;
            B_DISP <= 0;
            C_DISP <= 0;
          end
          3'b101 : begin 
            status <= S_ACW;
            A_DISP <= 1;
            B_DISP <= 0;
            C_DISP <= 1;
          end
          3'b110 : begin 
            status <= S_ABW;
            A_DISP <= 1;
            B_DISP <= 1;
            C_DISP <= 0;
          end
          3'b111 : begin 
            status <= S_AW;
            A_DISP <= 1;
            B_DISP <= 1;
            C_DISP <= 1;
          end
          endcase 
        end

        S_BS : begin //B가 일어선 상태이며, 아직 승부가 결정 안된 경우
          case ({A, B, C}) 
          3'b000 : status <= S_BS;
          3'b001 : begin 
            status <= S_BCW;
            A_DISP <= 0;
            B_DISP <= 0;
            C_DISP <= 1;
          end
          3'b010 : begin 
            status <= S_BS;
            A_DISP <= 0;
            B_DISP <= 1;
            C_DISP <= 0;
          end
          3'b011 : begin 
            status <= S_BCW;
            A_DISP <= 0;
            B_DISP <= 1;
            C_DISP <= 1;
          end
          3'b100 : begin 
            status <= S_ABW;
            A_DISP <= 1;
            B_DISP <= 0;
            C_DISP <= 0;
          end
          3'b101 : begin 
            status <= S_BW;
            A_DISP <= 1;
            B_DISP <= 0;
            C_DISP <= 1;
          end
          3'b110 : begin 
            status <= S_ABW;
            A_DISP <= 1;
            B_DISP <= 1;
            C_DISP <= 0;
          end
          3'b111 : begin 
            status <= S_BW;
            A_DISP <= 1;
            B_DISP <= 1;
            C_DISP <= 1;
          end
          endcase 
        end

        S_CS : begin //C가 일어선 상태이며, 아직 승부가 결정 안된 경우
          case ({A, B, C}) 
          3'b000 : status <= S_CS;
          3'b001 : begin 
            status <= S_CS;
            A_DISP <= 0;
            B_DISP <= 0;
            C_DISP <= 1;
          end
          3'b010 : begin 
            status <= S_BCW;
            A_DISP <= 0;
            B_DISP <= 1;
            C_DISP <= 0;
          end
          3'b011 : begin 
            status <= S_BCW;
            A_DISP <= 0;
            B_DISP <= 1;
            C_DISP <= 1;
          end
          3'b100 : begin 
            status <= S_ACW;
            A_DISP <= 1;
            B_DISP <= 0;
            C_DISP <= 0;
          end
          3'b101 : begin 
            status <= S_ACW;
            A_DISP <= 1;
            B_DISP <= 0;
            C_DISP <= 1;
          end
          3'b110 : begin 
            status <= S_CW;
            A_DISP <= 1;
            B_DISP <= 1;
            C_DISP <= 0;
          end
          3'b111 : begin 
            status <= S_CW;
            A_DISP <= 1;
            B_DISP <= 1;
            C_DISP <= 1;
          end
          endcase 
        end

        S_AW : begin //A가 이겼을 때, 이하 동일 
          Winner_DISP <= 3'b100;
          status <= S_INIT;
          {A_DISP, B_DISP, C_DISP} <= 3'b000; 
        end
        S_BW : begin 
          Winner_DISP <= 3'b010;
          status <= S_INIT;
          {A_DISP, B_DISP, C_DISP} <= 3'b000;
        end
        S_CW : begin
          Winner_DISP <= 3'b001;
          status <= S_INIT;
          {A_DISP, B_DISP, C_DISP} <= 3'b000;
        end
        S_ABW : begin
          Winner_DISP <= 3'b110;
          status <= S_INIT;
          {A_DISP, B_DISP, C_DISP} <= 3'b000;
        end
        S_BCW : begin
          Winner_DISP <= 3'b011;
          status <= S_INIT;
          {A_DISP, B_DISP, C_DISP} <= 3'b000;
        end
        S_ACW : begin
          Winner_DISP <= 3'b101;
          status <= S_INIT;
          {A_DISP, B_DISP, C_DISP} <= 3'b000;
        end
        S_DRAW : begin
          Winner_DISP <= 3'b111;
          status <= S_INIT;
          {A_DISP, B_DISP, C_DISP} <= 3'b000;
        end

      endcase

      
    end
  
endmodule
