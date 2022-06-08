
module Display(CLK, RST, Winner_DISP, A_DISP, B_DISP, C_DISP);
    input CLK, RST;
    input [2:0] Winner_DISP;
    input A_DISP, B_DISP, C_DISP;

    reg[5:0] Clock; //클락신호 카운트하는 변수

    

    always @ (posedge CLK) begin //상승엣지일때
        
        if(RST == 0)begin
            if(Winner_DISP == 3'b000)begin //승부가결정 안되었을 때
                $display("[#%d] A : %b B : %b  C : %b\n\n", Clock,A_DISP,B_DISP,C_DISP); 
            end
            else begin //승부가 결정되었을 때
                case(Winner_DISP) //승부에 따라서 출력
                3'b001 : $display("[#%d] Result : Winner is C\n\n", Clock);
                3'b010 : $display("[#%d] Result : Winner is B\n\n", Clock);
                3'b011 : $display("[#%d] Result : Winner is B and C\n\n", Clock);
                3'b100 : $display("[#%d] Result : Winner is A\n\n", Clock,);
                3'b101 : $display("[#%d] Result : Winner is A and C\n\n", Clock);
                3'b110 : $display("[#%d] Result : Winner is A and B\n\n", Clock);
                3'b111 : $display("[#%d] Result : DRAW\n\n", Clock);
                endcase
                
            end
        Clock++; //카운트 +1 (0초는 초기화상태일때)
        end
        else begin
            Clock = 0; //RST이 1일때 카운트 초기화
        end
        
    end    
endmodule
