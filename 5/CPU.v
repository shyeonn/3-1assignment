module Add_PC(IN, OUT); //IF Adder
input IN;
output OUT;

assign OUT = IN + 4;

endmodule

module MUX_Branch(Signal, IN_A, IN_B, OUT); //Branch의 조건 확인하는 MUX
input Signal;
input IN_A, IN_B;
output OUT;

assign OUT = Signal ? IN_B : IN_A;

endmodule

module Add_Branch(IN_A, IN_B, OUT);
input IN_A, IN_B;
output OUT;

assign OUT = IN_A + IN_B;

endmodule

module Shift_Branch(IN, OUT);
input IN;
output OUT;

assign OUT = IN << 1;

endmodule

module MUX_Reg(Signal, IN_A, IN_B, OUT);
input IN_A, IN_B;
input Signal;
output OUT;

assign OUT = Signal ? IN_B : IN_A;
endmodule

module Control(IN, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
input [6:0] IN;
output reg Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite;

always @(IN) begin

    case (IN)
    7'b0110011:begin //R-type Opcode
    Branch <= 'b0;
    MemRead <= 'b0;
    ALUOp <= 'b000; //R-type
    MemWrite <= 'b0;
    ALUSrc <= 'b0;
    RegWrite <= 'b1;
        
    end
    7'b0010011:begin //I-type Opcode (Exclude LW)
    Branch <= 'b0;
    MemRead <= 'b0;
    ALUOp <= 'b001; //I-type
    MemWrite <= 'b0;
    ALUSrc <= 'b1;
    RegWrite <= 'b1;
        
    end
    7'b0000011:begin //I-type Opcode (LW)
    Branch <= 'b0;
    MemRead <= 'b1;
    ALUOp <= 'b101; //LW
    MemWrite <= 'b0;
    ALUSrc <= 'b1;
    RegWrite <= 'b1;
        
    end
    7'b0100011:begin //S-type Opcode 아직안함
    Branch <= 'b0;
    MemRead <= 'b1;
    ALUOp <= 'b101; //S-type
    MemWrite <= 'b0;
    ALUSrc <= 'b1;
    RegWrite <= 'b1;
        
    end
    7'b1100011:begin //B-type Opcode
    Branch <= 'b1;
    MemRead <= 'b0;
    ALUOp <= 'b101; //B-type
    MemWrite <= 'b0;
    ALUSrc <= 'b0;
    RegWrite <= 'b0;
    end
    


    
endcase
    
end



endmodule


module ALU(Control_Signal, IN_A, IN_B, OUT, Zero, PNum);
input Control_Signal;
input IN_A, IN_B;
output OUT, Zero, PNum;

endmodule



