module Vrprime_tbc ();
reg [3:0] Hex;
wire Asci;
reg [3:0] Num2;


Vrprimef UUT (.H(Hex), .A(Asci));

initial begin
    $dumpfile("test.vcd");
    $dumpvars(2, Vrprime_tbc);

    errors = 0;

    for (i =0; i<15; i = i+1)begin
        Hex = i; 
    end

end

endmodule