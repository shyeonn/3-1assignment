`timescale 1 ns / 100 ps

module hex2ascii_tb1();
    reg [3:0]hex,hex1,hex2 ;
    wire [6:0]ascii,ascii1,ascii2;
    integer i;
    reg [3:0] j=4'b0000;

    hex2ascii_struct struct(.H(hex), .A(ascii));
    hex2ascii_df dataflow(.H(hex1), .A(ascii1));
    hex2ascii_bh behavior(.H(hex2), .A(ascii2));

    initial begin
        $dumpfile("test.vcd");
        $dumpvars; 
        
        $display("\n<struct Model>");    
        for (i=0; i<16; i = i + 1 )begin
            hex=j;
            j=j+4'b0001;

            #10
            if (i<10)begin
                $display("[%3d] < %h >   < %c >   < %c >", $time, hex, ascii, hex+7'b0110000);
                $display("%b",hex);
                $display("%b",ascii);
            end
            else if (i>=10) begin
                $display("[%3d] < %h >   < %c >   < %c >", $time, hex , ascii, hex + 7'b0110111);
                $display("%b",hex);
                $display("%b",ascii);
            end
        end

        $display("\n<Dataflow Model>");    
        for (i=0; i<16; i = i + 1 )begin
            hex1=j;
            j=j+4'b0001;

            #10
            if (i<10)begin
                $display("[%3d] < %h >   < %c >   < %c >", $time, hex1, ascii1, hex1+7'b0110000);
                $display("%b",hex1);
                $display("%b",ascii1);
            end
            else if (i>=10) begin
                $display("[%3d] < %h >   < %c >   < %c >", $time, hex1 , ascii1, hex1 + 7'b0110111);
                $display("%b",hex1);
                $display("%b",ascii1);
            end

            
        end
        
        $display("\n<Behavior Model>");    
        for (i=0; i<16; i = i + 1 )begin
            hex2=j;
            j=j+4'b0001;

            #10
            if (i<10)begin
                $display("[%3d] < %h >   < %c >   < %c >", $time, hex2, ascii2, hex2+7'b0110000);
                $display("%b",hex2);
                $display("%b",ascii2);
            end
            else if (i>=10) begin
                $display("[%3d] < %h >   < %c >   < %c >", $time, hex2 , ascii2, hex2 + 7'b0110111);
                $display("%b",hex2);
                $display("%b",ascii2);
            end

            
        end
        
    end

endmodule
