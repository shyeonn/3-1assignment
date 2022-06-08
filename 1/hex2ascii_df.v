module hex2ascii_df (H, A);
input [3:0] H;
output reg [6:0] A;

always @(H) begin
    case (H)
    4'h0 : A = 7'b0110000;
    4'h1 : A = 7'b0110001;
    4'h2 : A = 7'b0110010;
    4'h3 : A = 7'b0110011;
    4'h4 : A = 7'b0110100;
    4'h5 : A = 7'b0110101;
    4'h6 : A = 7'b0110110;
    4'h7 : A = 7'b0110111;
    4'h8 : A = 7'b0111000;
    4'h9 : A = 7'b0110001;
    4'ha : A = 7'b1000001;
    4'hb : A = 7'b1000001;
    4'hc : A = 7'b1000010;
    4'hd : A = 7'b1000011;
    4'he : A = 7'b1000100;
    4'hf : A = 7'b1000101;
    endcase

end
    
endmodule