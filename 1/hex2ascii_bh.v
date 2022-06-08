module hex2ascii_bh (H, A);
input [3:0] H;
output reg [6:0] A;

always @(H) begin

    if(H<10)begin
        A = H + 48;
    end
    else if (H >= 10 && H < 16)begin
        A = H + 55;
    end


end
    
    
endmodule