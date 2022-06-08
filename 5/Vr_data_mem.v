module Vr_data_mem(CLK, ADDR, RW, WD, RD);
   input CLK;
   input [31:0] ADDR; //address(32bit)
   input 	RW; /* 0: Read, 1: Write */
   input [31:0] WD;  //write data
   output [31:0] RD; //read data

   wire [9:0] 	 word_addr; 

   reg [31:0] 	 mem_cell [0:1023];

   assign word_addr = ADDR[11:2];

   /*
    This block is for debugging purpose.
    Do not use initial block for initilization in your production code
    */
   initial
     begin
	/* Put your initial data */
	mem_cell[0] = 1;
	mem_cell[1] = 9;
	mem_cell[2] = 2;
	mem_cell[3] = 3;
	mem_cell[4] = 5;
	mem_cell[5] = 10;
	mem_cell[6] = 7;
	mem_cell[7] = 6;
	mem_cell[8] = 4;
	mem_cell[9] = 8;
     end // initial begin

   // Dumpvars does not dump array entries
   // To detour(우회) the limitation, assign each register entry to a temporal wire.
   generate
      genvar 		 idx;
      for (idx = 0; idx < 1024; idx = idx+1) begin: datamem
	 wire [31:0] tmp;
	 assign tmp = mem_cell[idx];
      end
   endgenerate

   /* write */
   always @ (posedge CLK)
     begin
	if (ADDR <1024)
	  if (RW)
            mem_cell[$unsigned(word_addr)] = WD;
     end

   /* read */
   assign RD = RW ? 32'hz : mem_cell[$unsigned(word_addr)];

endmodule
