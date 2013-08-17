////////////////////////////////////////////////////
//
//  Robin Ankele & Christoph Bauernhofer 
//      ausserlechner154f.v
//
//  Übung 4 - Toy CPU (Functional)
//
////////////////////////////////////////////////////

`define NUM_STATE_BITS 6

`define INIT     16
`define IDLE     17
`define FETCH1   18
`define FETCH2   19
`define FETCH3   20
`define DECODE   21

`define HLT      0
`define ADD      1
`define SUB      2
`define AND      3
`define XOR      4
`define SHL      5
`define SHR      6
`define LDA      7
`define LD       8
`define ST       9
`define LDI      10
`define STI      11
`define BZ       12
`define BP       13
`define JR       14
`define JL       15

////////////////////////////////////////////////////
//  .toy_cpu.
// 
//   clk   clock input
//   read  is set to 1 if an external value input
//            at din is stored in register mb
//   write is set to 1 if a value should be written
//            to address addr
//   addr  defines the 8-bit address; in this example here
//            it is constantly set to 0xFF
//   din   16-bit data input
//   dout  16-bit data output
//   
////////////////////////////////////////////////////   
module  toy_cpu(clk, cont, read, write, addr, din, dout);
  input  clk;
  input  cont;
  output read;
  output write;
  output [7:0]  addr;
  input  [15:0] din;
  output [15:0] dout;
  
  wire clk;
  reg  read;
  reg  write;
  wire [15:0] din;
  wire [15:0] dout;
  
  reg  [7:0]  ma;
  reg  [7:0]  addr_;
  reg  [15:0] mb;

  reg  [15:0] register [15:0];
  
  reg  [15:0] ir;
  reg  [3:0]  opcode;
  reg  [3:0]  d;
  reg  [3:0]  s;
  reg  [3:0]  t;
  reg  [7:0]  imm;

  reg [7:0] pc;
  reg halt;

  assign addr = ma;
  assign dout = mb;
  
  reg [`NUM_STATE_BITS-1:0] present_state;


  always
    begin
      @(posedge clk) enter_new_state(`INIT);
      pc <= @(posedge clk) 8'h10;
      halt <= @(posedge clk) 1;
      while (1)   
        begin
          @(posedge clk) enter_new_state(`FETCH1);
            ma <= @(posedge clk) pc;
            if (halt)
              begin
                while (~cont)
                  begin
                    @(posedge clk) enter_new_state(`IDLE);
                    halt <= @(posedge clk) 0;
                  end
              end
            else
              begin
                @(posedge clk) enter_new_state(`FETCH2);
                mb <= @(posedge clk) din;
                @(posedge clk) enter_new_state(`FETCH3);
                ir <= @(posedge clk) mb;
                @(posedge clk) enter_new_state(`DECODE);
             	pc <= @(posedge clk) pc + 1;

                opcode <= @(posedge clk) ir[15:12];
                d <= @(posedge clk)      ir[11:8];
                s <= @(posedge clk)      ir[7:4];
                t <= @(posedge clk)      ir[3:0];
                addr_ <= @(posedge clk)  ir[7:0];
                
				@(posedge clk)
                case(opcode)
                    `HLT: 
                      begin
                        @(posedge clk) enter_new_state(`HLT);
                        halt <= @(posedge clk) 1;
                      end
                    `ADD: 
                      begin
                        @(posedge clk) enter_new_state(`ADD);
                        register[d] <= @(posedge clk) register[s] + register[t];
                      end
                    `SUB: 
                      begin
                        @(posedge clk) enter_new_state(`SUB);
                        register[d] <= @(posedge clk) register[s] - register[t];
                      end
                    `AND: 
                      begin
                        @(posedge clk) enter_new_state(`AND);
                        register[d] <= @(posedge clk) register[s] & register[t];
                      end
                    `XOR: 
                      begin
                        @(posedge clk) enter_new_state(`XOR);
                        register[d] <= @(posedge clk) register[s] ^ register[t];
                      end
                    `SHL: 
                      begin
                        @(posedge clk) enter_new_state(`SHL);
                        register[d] <= @(posedge clk) register[s] << register[t];
                      end
                    `SHR: 
                      begin
                        @(posedge clk) enter_new_state(`SHR);
                        register[d] <= @(posedge clk) register[s] >> register[t];
                      end  
                    `LDA: 
                      begin
                        @(posedge clk) enter_new_state(`LDA);
                        register[d] <= @(posedge clk) addr_;
                      end
                    `LD: 
                      begin
                        @(posedge clk) enter_new_state(`LD);
                        ma <= @(posedge clk) addr_;
                        @(posedge clk)
                        read = 1;
                        @(posedge clk)
                        mb <= @(posedge clk) din;
                        @(posedge clk)
                        register[d] <= @(posedge clk) mb;
                      end
                    `ST: 
                      begin
                        @(posedge clk) enter_new_state(`ST);
                        mb <= @(posedge clk) register[d];
                        ma <= @(posedge clk) addr_;
                        @(posedge clk)
                        write = 1;
                      end
                    `LDI: 
                      begin
                        @(posedge clk) enter_new_state(`LDI);
                        ma <= @(posedge clk) register[t];
                        @(posedge clk)
                        read = 1;
                        @(posedge clk)
                        mb <= @(posedge clk) din;
                        @(posedge clk)
                        register[d] <= @(posedge clk) mb;
                      end
                    `STI: 
                      begin
                        @(posedge clk) enter_new_state(`STI);
                        mb <= @(posedge clk) register[d];
                        ma <= @(posedge clk) register[t];
                        @(posedge clk)
                        write = 1;
                      end
                    `BZ: 
                      begin
                        @(posedge clk) enter_new_state(`BZ);
                        if(register[d] == 0)
                          pc <= @(posedge clk) addr_;
                      end
                    `BP: 
                      begin
                        @(posedge clk) enter_new_state(`BP);
                        if(register[d] > 0)
                          pc <= @(posedge clk) addr_;
                      end
                    `JR: 
                      begin
                        @(posedge clk) enter_new_state(`JR);
                          pc <= @(posedge clk) register[d];
                      end
                    `JL: 
                      begin
                        @(posedge clk) enter_new_state(`JL);
                          register[d] <= @(posedge clk) pc;
                          @(posedge clk)
                          pc <= @(posedge clk) addr_;
                      end
                endcase
              end
        end
    end

  task enter_new_state;
      input [`NUM_STATE_BITS-1:0] this_state;
      begin
         present_state = this_state;
         #1;
         write = 0;
         read = 0;
         register[0] = 0;
      end
   endtask
endmodule


//////////////////////////////////////////////
//  .mem.
//
//   clk          clock input
//   write        if input write is 1, then the value
//                    at data_in is stored at address write_addr.
//   addr         8-bit address input
//   data_in      16-bit data input
//   data_out     16-bit data output
//
//////////////////////////////////////////////
module mem(clk, write, addr, data_in, data_out);
  input  clk;
  input  write;
  input  addr; 
  input  data_in;
  output data_out;
  
  wire clk;
  wire write;
  wire [7:0] addr;
  wire [15:0] data_in;
  reg  [15:0] data_out;
  
  reg [15:0] m[0:'hFF];

  always @(addr)
  begin
    data_out = m[addr];
  end

  always @(posedge clk)
    if (write == 1)
        begin
          m[addr] = data_in;
          data_out = data_in;
        end
endmodule

/////////////////////////////////////////////////////
//  .io. 
//
//   clk       clock input
//   read      control input. If read is set to 1,
//               the next 16-bit value from the
//               input file is output at data_out.
//   write     control input. If write is set to 1,
//               the 16-bit value at input data_in
//               is appended to the file "std_out.dat"
//   data_in   16-bit data input
//   data_out  16-bit data output
//   
/////////////////////////////////////////////////////
module io(clk, read, write, data_in, data_out);
  input  clk, read, data_in, write;
  output data_out;

  wire clk, read;
  wire [15:0] data_in;
  wire write;
  
  wire [15:0] data_out;

  reg[8:0] i,j;
  integer std_out_handle; // file handle
  
  reg [15:0] std_in[0:1023];
  reg [9:0] std_in_pointer;
  
  reg read_delayed;
  reg write_delayed;
  wire read_strobe;

  assign data_out = std_in[std_in_pointer];
  
  initial
    begin
      $readmemh("D:\\Telematik\\2.Semester\\Rechnerorganisation\\Assignments\\Assignment 4\\Toy CPU Functional\\std_in.dat", std_in);
	  
      std_in_pointer = 0;
   
      // for convenience: print the values
      // just read from the input file "std_in.dat"
	  j = 0;
      for (i=0; i<256; i = i+1)
	  begin 
          $write("st_din[%h]=%h  ", i, std_in[i]);
		  j = j + 1;
		  if(j==4)
		  begin
			  $write("\n");
			  j = 0;
		  end
	  end
       
      std_out_handle = $fopen("D:\\Telematik\\2.Semester\\Rechnerorganisation\\Assignments\\Assignment 4\\Toy CPU Functional\\std_out.dat");
   
	  
   
    end
    
  always @(posedge clk)
    read_delayed = read;
  
  assign read_strobe = (read == 0) && (read_delayed == 1);
  
  always @(posedge clk)
    if (read_strobe == 1)
      std_in_pointer = std_in_pointer + 1;

  always @(posedge clk)
    if (write == 1)
      begin
        // write to file whenever the cpu writes to address 0xFF:
        $fdisplay(std_out_handle, "%h", data_in);
      end

endmodule

/////////////////////////////////////////////////////
//  .toy.
//
//   clk        clock input
//   continue   not needed here. But you will need
//                  it later for your real TOY.
//                  With continue you will start
//                  execution of your TOY.
//
/////////////////////////////////////////////////////
module  toy(clk, continue);
         
  input clk, continue;
  
  wire clk, continue;

  wire [7:0] addr; 
  wire [15:0] toy_dout;

  wire [15:0] toy_din;
  wire write, read;
  
  wire write_io, write_mem, read_io;
  wire [15:0] mem_dout, io_dout;

  // instantiation of cpu:
  toy_cpu cpu(clk, continue, read, write, addr, toy_din, toy_dout);

  // decoding control wires for memory access or for
  // input-output access:
  assign write_io  = write & (addr == 16'hFF);
  assign write_mem = write & (addr != 16'hFF);
  assign read_io   = read  & (addr == 16'hFF);
  
  // multiplexer for TOY's data input: data input
  // is taken either from input-output or from memory:
  assign toy_din = (addr == 16'hFF) ? io_dout : mem_dout;

  // The memory is not needed in this tiny example.
  // But I kept the line here so that students can
  // use it later, when developing their TOY.
  mem memory(clk, write_mem, addr, toy_dout, mem_dout);

  // instantiation of io-module:
  io in_out(clk, read_io, write_io, toy_dout, io_dout);

 endmodule

////////////////////////////////////////////////////
// Testbench top:
//
//   starts a clock generator,
//   creates an instance of the module toy,
//   stops simulation after 15000 clock cycles,
//   prints a debug message for each clock cycle.
//   
////////////////////////////////////////////////////
module top;
  reg clk, continue;

  reg[8:0] i,j;
  
  initial   clk = 0;
  always  #50 clk = ~clk;

  toy toy_i(clk, continue);

  initial   
    begin   
      continue = 0;
      #300      
      #200 continue = 1;
      #100 continue = 0;


      toy_i.memory.m['h0000] = 'hCAFE; // A     DW   0xCAFE

      toy_i.memory.m['h0010] = 'hFFE0; //       jl  RF, start

      toy_i.memory.m['h00E0] = 'h7101; // start lda R1, 0x1     // load constant 1
      toy_i.memory.m['h00E1] = 'h8200; //       ld  R2, A       // load CAFE
      toy_i.memory.m['h00E2] = 'h83FF; //       ld  R3, 0xFF    // read
      toy_i.memory.m['h00E3] = 'h2332; //       sub R3, R3, R2  // check for CAFE
      toy_i.memory.m['h00E4] = 'hC3E6; //       bz  R3, go
      toy_i.memory.m['h00E5] = 'h0000; //       hlt             // halt
      
      toy_i.memory.m['h00E6] = 'h84FF; // go    ld  R4, 0xFF    // start addr in R4
      toy_i.memory.m['h00E7] = 'h1540; //       add R5, R4, R0  // temp copy of start addr
      toy_i.memory.m['h00E8] = 'h86FF; //       ld  R6, 0xFF    // amount of words
      toy_i.memory.m['h00E9] = 'hC6EF; // loop  bz  R6, exit    // goto exit if finished
      toy_i.memory.m['h00EA] = 'h2661; //       sub R6, R6, R1  // decrement R6
      toy_i.memory.m['h00EB] = 'h87FF; //       ld  R7, 0xFF    // read a word
      toy_i.memory.m['h00EC] = 'hB705; //       st  R7, R5
      toy_i.memory.m['h00ED] = 'h1551; //       add R5, R5, R1  // increment code address
      toy_i.memory.m['h00EE] = 'hFFE9; //       jl  RF, loop
      toy_i.memory.m['h00EF] = 'hE400; // exit  jr  R4          // jump to program's start addr
      toy_i.memory.m['h00F0] = 'h0000; //       hlt             // this line should not be reached

    end  

  initial   
    begin
      #2000000
      j = 0;
      //print results
	  $write("----------------Printing Register----------------\n");
      for (i=0; i<16; i=i+1)
	  begin
        $write("reg[%h]=%h  ", i, toy_i.cpu.register[i]);
		j = j + 1;
		if(j==4)
		begin
		  $write("\n");
		  j = 0;
		end
      end
	  
	   $write("\n");
	   $write("----------------Printing Memory----------------\n");
	   
      for (i=0; i<256; i = i+1)
	  begin
        $write("mem[%h]=%h  ", i, toy_i.memory.m[i]);
		j = j + 1;
		if(j==8)
		begin
		  $write("\n");
		  j = 0;
		end
      end
        
      $fclose(toy_i.in_out.std_out_handle);
      $finish;
  end
endmodule 


