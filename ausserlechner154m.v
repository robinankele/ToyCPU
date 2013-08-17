////////////////////////////////////////////////////
//
//  Robin Ankele & Christoph Bauernhofer 
//      ausserlechner154m.v
//
//  Übung 4 - Toy CPU (Mixed)
//
////////////////////////////////////////////////////

`define NUM_STATE_BITS 6


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

`define INIT     16
`define IDLE     17
`define FETCH1   18
`define FETCH2   19
`define FETCH3   20
`define DECODE   21
`define MB       22
`define PC       23
`define MA       24
`define SEL      25
`define IR       26
`define PC_INC   27
`define SWITCH   28
`define ADDR     29

`define LD1      30
`define LD2      31
`define LD3      32
`define LD4      33
`define LD5      34
`define LDI1     35
`define LDI2     36
`define LDI3     37
`define LDI4     38
`define LDI5     39
`define ADDR_REG 40
`define REG_T    41
`define MA_1     42

`define ST1      43
`define ST2      44
`define ST3      45
`define STI1     46
`define STI2     47
`define STI3     48

`define BP1      49
`define BP2      50
`define BZ1      51
`define BZ2      52

`define JL1      53
`define JL2      54

`define R0       100
`define R1       101
`define R2       102
`define R3       103
`define R4       104
`define R5       105
`define R6       106
`define R7       107
`define R8       108
`define R9       109
`define RA       110
`define RB       111
`define RC       112
`define RD       113
`define RE       114
`define RF       115
`define MB_REG   116
`define ALU_OUT  117
`define PC_REG   118

////////////////////////////////////////////////////
module alu(opcode, s, t, dout);
  input opcode;
  input s;
  input t;
  output dout;
  
  wire [3:0] opcode;
  wire [15:0] s;
  wire [15:0] t;
  reg  [15:0] dout;

  always @(opcode or s or t)
  begin
    case(opcode) 
      `ADD: 
            dout = s + t;
      `SUB: 
            dout = s - t;
      `AND: 
            dout = s & t;
      `XOR: 
            dout = s ^ t;
      `SHL: 
            dout = s << t;
      `SHR: 
            dout = s >> t;
    endcase
  end
endmodule

/////////////////////////////////////////////////
module register16(clk, load, din, q);
  input clk, load;
  input [15:0] din;
  output [15:0] q;
  
  wire clk, load;
  wire [15:0] din;
  reg [15:0] q;
  
  always @(posedge clk)
    if(load == 1)
    begin
      q = din;
    end
endmodule


/////////////////////////////////////////////////
module register0(clk, load, din, q);
  input clk, load;
  input [15:0] din;
  output [15:0] q;
  
  wire clk, load;
  wire [15:0] din;
  reg [15:0] q;
  
  always @(posedge clk)
    q = 0;
endmodule

/////////////////////////////////////////////////
module register8(clk, load, init, inc, din, q);
  input clk, load, init, inc;
  input [7:0] din;
  output [7:0] q;
  
  wire clk, load, init, inc;
  wire [7:0] din;
  reg [7:0] q;
  
  always @(posedge clk)
    begin
      if(load == 1)
        begin
          if(init == 1)
            q = 'h0010;
          else if(inc == 1)
            q = q + 1;
          else
            q = din;
        end     
    end
endmodule

/////////////////////////////////////////////////
module register4(clk, load, din, q);
  input clk, load;
  input [3:0] din;
  output [3:0] q;
  
  wire clk, load;
  wire [3:0] din;
  reg [3:0] q;
  
  always @(posedge clk)
    if (load == 1)
      q = din;
endmodule

/////////////////////////////////////////////////
module register1(clk, load, q);
  input clk;
  input load;
  output q;
  
  wire clk, load;
  reg q;
  
  always @(posedge clk)
    if (load == 1)
      q = 1;
    else
      q = 0;
endmodule

/////////////////////////////////////////////////
module register_dout(clk, din, q);
  input clk;
  input [15:0] din;
  output [15:0] q;
  
  wire clk;
  wire [15:0] din;
  reg  [15:0] q;
  
  always @(posedge clk)
    q = din;
endmodule

/////////////////////////////////////////////////
module register_addr_out(clk, din, q);
  input clk;
  input [7:0] din;
  output [7:0] q;
  
  wire clk;
  wire [7:0] din;
  reg  [7:0] q;
  
  always @(posedge clk)
    q = din;  
endmodule

/////////////////////////////////////////////////
module mux8(pc, addr, t, sel, q);
  input [7:0] pc, addr, sel;
  input [15:0] t;
  output [7:0] q;
  
  wire [7:0] pc, addr, sel;
  wire [15:0] t;
  reg [7:0] q;
  
  always @(pc or addr or t or sel)
  begin
    case(sel) 
      `PC:    q = pc;
      `ADDR:  q = addr;
      `REG_T: q = t;
    endcase
  end
endmodule

/////////////////////////////////////////////////
module muxsel(ld_d, ld_mb, ld_alu, ld_addr_reg, ld_pc_reg, d, out_sel);
  input ld_d, ld_mb, ld_alu, ld_addr_reg, ld_pc_reg;
  input [3:0] d;
  output [15:0] out_sel;
  
  wire ld_d, ld_mb, ld_alu, ld_addr_reg, ld_pc_reg;
  wire [3:0] d;
  reg [15:0] out_sel;
  
  always @(ld_d or ld_mb or ld_alu or ld_pc_reg)
  begin
    if(ld_d == 1)
      case(d) 
        'h0:  out_sel = `R0;
        'h1:  out_sel = `R1;
        'h2:  out_sel = `R2;
        'h3:  out_sel = `R3;
        'h4:  out_sel = `R4;
        'h5:  out_sel = `R5;
        'h6:  out_sel = `R6;
        'h7:  out_sel = `R7;
        'h8:  out_sel = `R8;
        'h9:  out_sel = `R9;
        'hA:  out_sel = `RA;
        'hB:  out_sel = `RB;
        'hC:  out_sel = `RC;
        'hD:  out_sel = `RD;
        'hE:  out_sel = `RE;
        'hF:  out_sel = `RF;
      endcase
    if(ld_mb == 1)
      out_sel = `MB_REG;
    if(ld_alu == 1)
      out_sel = `ALU_OUT;
    if(ld_addr_reg == 1)
      out_sel = `ADDR_REG;
    if(ld_pc_reg == 1)
      out_sel = `PC_REG;
  end
endmodule

/////////////////////////////////////////////////
module mux16(in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, mb, alu, addr, pc, sel, q);
  input [15:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, mb, alu, sel;
  input [7:0] addr, pc;
  output [15:0] q;
  
  wire [15:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, mb, alu, sel;
  wire [7:0] addr, pc;
  reg  [15:0] q;
  
  always @(in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 or in8 or in9 or in10 or in11 or in12 or in13 or in14 or in15 or mb or alu or addr or pc or sel)
  begin
    case(sel) 
      `R0:  q = in0;
      `R1:  q = in1;
      `R2:  q = in2;
      `R3:  q = in3;
      `R4:  q = in4;
      `R5:  q = in5;
      `R6:  q = in6;
      `R7:  q = in7;
      `R8:  q = in8;
      `R9:  q = in9;
      `RA:  q = in10;
      `RB:  q = in11;
      `RC:  q = in12;
      `RD:  q = in13;
      `RE:  q = in14;
      `RF:  q = in15;
      `MB_REG:   q = mb;
      `ALU_OUT:  q = alu;
      `ADDR_REG: q = addr;
      `PC_REG:   q = pc;
    endcase
  end
endmodule


/////////////////////////////////////////////////
module muxs_t(clk, s, t, r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,rA,rB,rC,rD,rE,rF, out1, out2); //out1 = s, out2 = t
  input clk;
  input [3:0] s, t;
  input [15:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,rA,rB,rC,rD,rE,rF;
  output [15:0] out1, out2;
  
  wire clk;
  wire [3:0] s, t;
  wire [15:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,rA,rB,rC,rD,rE,rF;
  reg [15:0] out1, out2;
  
  always @(clk)
  begin
    case(s) 
      'h0:  out1 = r0;
      'h1:  out1 = r1;
      'h2:  out1 = r2;
      'h3:  out1 = r3;
      'h4:  out1 = r4;
      'h5:  out1 = r5;
      'h6:  out1 = r6;
      'h7:  out1 = r7;
      'h8:  out1 = r8;
      'h9:  out1 = r9;
      'hA:  out1 = rA;
      'hB:  out1 = rB;
      'hC:  out1 = rC;
      'hD:  out1 = rD;
      'hE:  out1 = rE;
      'hF:  out1 = rF;
    endcase
    
    case(t) 
      'h0:  out2 = r0;
      'h1:  out2 = r1;
      'h2:  out2 = r2;
      'h3:  out2 = r3;
      'h4:  out2 = r4;
      'h5:  out2 = r5;
      'h6:  out2 = r6;
      'h7:  out2 = r7;
      'h8:  out2 = r8;
      'h9:  out2 = r9;
      'hA:  out2 = rA;
      'hB:  out2 = rB;
      'hC:  out2 = rC;
      'hD:  out2 = rD;
      'hE:  out2 = rE;
      'hF:  out2 = rF;
    endcase 
  end
endmodule


/////////////////////////////////////////////////
module muxd(d, ld_d_reg, ld0,ld1,ld2,ld3,ld4,ld5,ld6,ld7,ld8,ld9,ldA,ldB,ldC,ldD,ldE,ldF);
  input [3:0] d;
  input ld_d_reg;
  output ld0,ld1,ld2,ld3,ld4,ld5,ld6,ld7,ld8,ld9,ldA,ldB,ldC,ldD,ldE,ldF;
  
  wire [3:0] d;
  wire ld_d_reg;
  reg  ld0,ld1,ld2,ld3,ld4,ld5,ld6,ld7,ld8,ld9,ldA,ldB,ldC,ldD,ldE,ldF;
  
  always @(d or ld_d_reg)
    begin
      if(ld_d_reg)
        begin
          case(d) 
            'h0:  ld0 = 1;
            'h1:  ld1 = 1;
            'h2:  ld2 = 1;
            'h3:  ld3 = 1;
            'h4:  ld4 = 1;
            'h5:  ld5 = 1;
            'h6:  ld6 = 1;
            'h7:  ld7 = 1;
            'h8:  ld8 = 1;
            'h9:  ld9 = 1;
            'hA:  ldA = 1;
            'hB:  ldB = 1;
            'hC:  ldC = 1;
            'hD:  ldD = 1;
            'hE:  ldE = 1;
            'hF:  ldF = 1;
          endcase
        end
      else
        begin
          ld0 = 0;
          ld1 = 0;
          ld2 = 0;
          ld3 = 0;
          ld4 = 0;
          ld5 = 0;
          ld6 = 0;
          ld7 = 0;
          ld8 = 0;
          ld9 = 0;
          ldA = 0;
          ldB = 0;
          ldC = 0;
          ldD = 0;
          ldE = 0;
          ldF = 0;
        end
    end
endmodule

/////////////////////////////////////////////////
module mux2to1_16(din, regD, ld_d, q);
  input [15:0] din, regD;
  input ld_d;
  output [15:0] q;
  
  wire [15:0] din, regD;
  wire ld_d;
  reg [15:0] q;
  
  always @(din or regD or ld_d)
  begin   
    if(ld_d === 1)
    begin
      q = regD;
    end
    else
      q = din;
  end
endmodule


/////////////////////////////////////////////////
module mux2to1_8(addr, regD, sel, q);
  input [7:0] addr, sel;
  input [15:0] regD;
  output [7:0] q;
  
  wire [7:0] addr, sel;
  wire [15:0] regD;
  reg [7:0] q;
  
  always @(addr or regD or sel)
  begin
    case(sel)
      1: q = addr;
      2: q = regD;
    endcase
  end
endmodule

////////////////////////////////////////////////////
module  toy_cpu_datapath(clk, sel, sel_pc, ld_mb, ld_ma, ld_pc, init_pc, inc_pc, ld_ir, ld_opc, ld_d, ld_s, ld_t, ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg, din, addr_out, dout);
  input  clk, ld_mb, ld_ma, ld_pc, init_pc, inc_pc, ld_ir, ld_opc, ld_d, ld_s, ld_t, ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg;
  input  [7:0] sel, sel_pc;
  input  [15:0] din;
  output [7:0] addr_out;  
  output [15:0] dout;
  
  wire clk, halt, ld_mb, ld_ma, ld_pc, init_pc, inc_pc, ld_ir, ld_opc, ld_d, ld_s, ld_t, ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg;
  wire [15:0] din;
  
  wire [15:0] mb, ir, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, rA, rB, rC, rD, rE, rF, data16, alu_out, mux_out1, mux_out2, sel_reg, mux2_1_out;
  wire [7:0] pc, sel, sel_pc, data8, ma, addr, mux_addr_regD;
  wire [3:0] op, d, s, t;
  wire [15:0] dout;
  wire [7:0] addr_out;
  
  register_dout r_dout(clk, mb, dout);
  register_addr_out r_addr_out(clk, ma, addr_out);
  
  register16 r_mb(clk, ld_mb, mux2_1_out, mb);
  register16 r_ir(clk, ld_ir, mb , ir);
  
  register8 r_pc(clk, ld_pc, init_pc, inc_pc, mux_addr_regD, pc);
  register8 r_ma(clk, ld_ma, , , data8, ma);
  register8 r_addr(clk, ld_addr, , , {ir[7],ir[6],ir[5],ir[4],ir[3],ir[2],ir[1],ir[0]}, addr);
  
  register4 r_op(clk, ld_opc, {ir[15],ir[14],ir[13],ir[12]}, op);
  register4 r_d (clk, ld_d  , {ir[11],ir[10],ir[9] ,ir[8]} , d);
  register4 r_s (clk, ld_s  , {ir[7] ,ir[6] ,ir[5] ,ir[4]} , s);
  register4 r_t (clk, ld_t  , {ir[3] ,ir[2] ,ir[1] ,ir[0]} , t);
  
  register0  r_0(clk, ld_0, data16, r0);
  register16 r_1(clk, ld_1, data16, r1);
  register16 r_2(clk, ld_2, data16, r2);
  register16 r_3(clk, ld_3, data16, r3);
  register16 r_4(clk, ld_4, data16, r4);
  register16 r_5(clk, ld_5, data16, r5);
  register16 r_6(clk, ld_6, data16, r6);
  register16 r_7(clk, ld_7, data16, r7);
  
  register16 r_8(clk, ld_8, data16, r8);
  register16 r_9(clk, ld_9, data16, r9);
  register16 r_A(clk, ld_A, data16, rA);
  register16 r_B(clk, ld_B, data16, rB);
  register16 r_C(clk, ld_C, data16, rC);
  register16 r_D(clk, ld_D, data16, rD);
  register16 r_E(clk, ld_E, data16, rE);
  register16 r_F(clk, ld_F, data16, rF);
  
  alu alu1(op, mux_out1, mux_out2, alu_out);
    
  mux2to1_16 m_din_regD(din, data16, ld_d_reg, mux2_1_out);
  mux2to1_8 m_addr_regD(addr, data16, sel_pc, mux_addr_regD);
  mux8 m8(pc, addr, mux_out2, sel, data8);
  mux16 m16(r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,rA,rB,rC,rD,rE,rF, mb, alu_out, addr, pc, sel_reg, data16);
  muxs_t mst(clk, s, t, r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,rA,rB,rC,rD,rE,rF, mux_out1, mux_out2);
  muxd md(d,ld_d_reg, ld_0,ld_1,ld_2,ld_3,ld_4,ld_5,ld_6,ld_7,ld_8,ld_9,ld_A,ld_B,ld_C,ld_D,ld_E,ld_F);
  muxsel msel(ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg, d, sel_reg);
 
endmodule

////////////////////////////////////////////////////
module  toy_cpu_controller(clk, cont, din, sel, sel_pc, ld_mb, ld_ma, ld_pc, init_pc, inc_pc, ld_ir, ld_opc, ld_d, ld_s, ld_t, ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg, read, write);
  input  clk, cont;
  input  [15:0] din;
  output ld_mb, ld_ma, ld_pc, init_pc, inc_pc, ld_ir, ld_opc, ld_d, ld_s, ld_t, ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg, read, write;
  output [7:0] sel, sel_pc;
  
  wire clk, cont;
  wire [15:0] din;
  reg  halt, ld_mb, ld_ma, ld_pc, init_pc, inc_pc, ld_ir, ld_opc, ld_d, ld_s, ld_t, ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg, read, write;
  
  reg [7:0] sel, sel_pc;
  reg [`NUM_STATE_BITS-1:0] present_state;
  
  
  
  always
    begin
      @(posedge clk) enter_new_state(`MB);
      ld_mb = 1;
      @(posedge clk)enter_new_state(`PC);
      ld_pc = 1;
      init_pc = 1;
      inc_pc = 0;
      halt = 1;
      while (1)   
        begin
          @(posedge clk) enter_new_state(`SEL);
            sel = `PC;
            @(posedge clk) enter_new_state(`MA);// sel wird pc
            ld_ma = 1;
            @(posedge clk) enter_new_state(`MA_1); // MA uebernehmen
            if (halt)
              begin
                while (~cont)
                  begin
                    @(posedge clk) enter_new_state(`IDLE);
                    halt = 0;
                  end
              end
            else
              begin
                @(posedge clk) enter_new_state(`MB);
                ld_mb = 1;
                @(posedge clk) enter_new_state(`IR);
                ld_ir = 1;
                @(posedge clk) enter_new_state(`PC_INC);
                ld_pc = 1;
                inc_pc = 1;

                ld_opc = 1;
                ld_d = 1;
                ld_s = 1;
                ld_t = 1;
                ld_addr = 1;
                
                @(posedge clk) enter_new_state(`SWITCH);
                
                case(din[15:12]) //op code
                    `HLT: 
                      begin
                        @(posedge clk) enter_new_state(`HLT);
                        halt = 1;
                      end
                    `ADD: 
                      begin
                        @(posedge clk) enter_new_state(`ADD);
                        ld_d_reg = 1;
                        ld_alu = 1;
                      end
                    `SUB: 
                      begin
                        @(posedge clk) enter_new_state(`SUB);
                        ld_d_reg = 1;
                        ld_alu = 1;
                      end
                    `AND: 
                      begin
                        @(posedge clk) enter_new_state(`AND);
                        ld_d_reg = 1;
                        ld_alu = 1;
                      end
                    `XOR: 
                      begin
                        @(posedge clk) enter_new_state(`XOR);
                        ld_d_reg = 1;
                        ld_alu = 1;
                      end
                    `SHL: 
                      begin
                        @(posedge clk) enter_new_state(`SHL);
                        ld_d_reg = 1;
                        ld_alu = 1;
                      end
                    `SHR: 
                      begin
                        @(posedge clk) enter_new_state(`SHR);
                        ld_d_reg = 1;
                        ld_alu = 1;
                      end   
                    `LDA: 
                      begin
                        @(posedge clk) enter_new_state(`LDA);
                        ld_mb = 1;
                        ld_addr_reg = 1;
                        ld_d_reg = 1;
                      end 
                    `LD: 
                      begin
                        @(posedge clk) enter_new_state(`LD1);
                        sel = `ADDR;
                        @(posedge clk) enter_new_state(`LD2);
                        ld_ma = 1;
                        @(posedge clk) enter_new_state(`LD3);
                        read = 1;
                        @(posedge clk) enter_new_state(`LD4);
                        ld_mb = 1;
                        @(posedge clk) enter_new_state(`LD5);
                        ld_d_reg = 1;
                        ld_mb_reg = 1;
                      end
                    `LDI: 
                      begin
                        @(posedge clk) enter_new_state(`LDI1);
                        sel = `REG_T;
                        @(posedge clk) enter_new_state(`LDI2);
                        ld_ma = 1;
                        @(posedge clk) enter_new_state(`LDI3);
                        read = 1;
                        @(posedge clk) enter_new_state(`LDI4);
                        ld_mb = 1;
                        @(posedge clk) enter_new_state(`LDI5);
                        ld_d_reg = 1;
                        ld_mb_reg = 1;
                      end
                    `ST: 
                      begin
                        @(posedge clk) enter_new_state(`ST1);
                        ld_d_reg = 1;
                        ld_mb = 1;
                        sel = `ADDR;
                        ld_ma = 1;
                        @(posedge clk) enter_new_state(`ST2);
                        @(posedge clk) enter_new_state(`ST3);
                        write = 1;
                      end
                    `STI: 
                      begin
                        @(posedge clk) enter_new_state(`STI1);
                        ld_d_reg = 1;
                        ld_mb = 1;
                        sel = `REG_T;
                        ld_ma = 1;
                        @(posedge clk) enter_new_state(`STI2);
                        @(posedge clk) enter_new_state(`STI3);
                        write = 1;
                      end
                    `BZ: 
                      begin
                        @(posedge clk) enter_new_state(`BZ1);
                        ld_d_reg = 1;
                        ld_mb = 1;
                        @(posedge clk)
                        @(posedge clk) enter_new_state(`BZ2);
                        if(din == 0)
                          begin
                            sel_pc = 1; //pc = addr
                            ld_pc = 1;
                          end
                      end
                    `BP: 
                      begin
                        @(posedge clk) enter_new_state(`BP1);
                        ld_d_reg = 1;
                        ld_mb = 1;
                        @(posedge clk)
                        @(posedge clk) enter_new_state(`BP2);
                        if(din > 0)
                          begin
                            sel_pc = 1; //pc = addr
                            ld_pc = 1;
                          end
                      end
                    `JR: 
                      begin
                        @(posedge clk) enter_new_state(`JR);
                          ld_d_reg = 1;
                          sel_pc = 2; //pc = reg[d]
                          ld_pc = 1;
                      end
                    `JL: 
                      begin
                        @(posedge clk) enter_new_state(`JL1);
                        ld_pc_reg = 1;
                        ld_d_reg = 1;
                        @(posedge clk) enter_new_state(`JL2);
                        sel_pc = 1; //pc = addr
                        ld_pc = 1;
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
      init_pc = 1;
      inc_pc = 0;
      {ld_mb, ld_pc, init_pc, inc_pc, 
      ld_ma, ld_ir,
      ld_d_reg, ld_alu, ld_mb_reg, ld_addr_reg, ld_pc_reg,
      sel, write} = 0;
    end
  endtask
 
endmodule

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
      $write("\n");
      $write("----------------Printing std_in----------------\n");
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
    begin
      std_in_pointer = std_in_pointer + 1;
    end

  always @(posedge clk)
    if (write == 1)
      begin
        // write to file whenever the cpu writes to address 0xFF:
        $fdisplay(std_out_handle, "%h", data_in);
      end

endmodule

////////////////////////////////////////////////////
module  toy(clk, cont);
  input clk;
  input cont;
  
  wire clk;
  wire cont;
  
  wire ld_mb;
  wire ld_ma;
  wire ld_pc;
  wire init_pc;
  wire inc_pc;
  wire ld_ir, ld_opc, ld_d, ld_s, ld_t, ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg;
  wire [7:0] sel, sel_pc;
  wire [3:0] op;
  
  wire [7:0] addr; 
  wire [15:0] toy_dout;

  wire [15:0] toy_din;
  wire write, read;
  
  wire write_io, write_mem, read_io;
  wire [15:0] mem_dout, io_dout;

  // instantiation of cpu:
  toy_cpu_datapath tcd  (clk, sel, sel_pc, ld_mb, ld_ma, ld_pc, init_pc, inc_pc, ld_ir, ld_opc, ld_d, ld_s, ld_t, 
                         ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg, 
                         toy_din, addr, toy_dout);
                       
  toy_cpu_controller tcc(clk, cont, toy_dout, sel, sel_pc, ld_mb, ld_ma, ld_pc, init_pc, inc_pc, ld_ir, ld_opc, ld_d, ld_s, ld_t, 
                         ld_addr, ld_d_reg, ld_mb_reg, ld_alu, ld_addr_reg, ld_pc_reg, 
                         read, write);
  

  // decoding control wires for memory access or for
  // input-output access:
  assign write_io  = write & (addr == 16'hFF);
  assign write_mem = write & (addr != 16'hFF);
  assign read_io   = read  & (addr == 16'hFF);

  assign toy_din = (addr == 16'hFF) ? io_dout : mem_dout;

  mem memory(clk, write_mem, addr, toy_dout, mem_dout);

  io in_out(clk, read_io, write_io, toy_dout, io_dout);   
endmodule



////////////////////////////////////////////////////
module top;
  reg clk;
  reg cont;
  
  integer i, j;
  
//----clock ---------------   
  initial 
    clk = 0;
  
  always #50
    clk = ~clk;

//----Device Under Test (DUT)-----------   
  toy toy_i(clk, cont);

  initial
    begin
      #300
      cont = 0;
      #200
      cont = 1;
    end

//----Bootloader -----------   
  initial
    begin
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
      #1000000
      j = 0;
      //print results
      
      $write("\n");
      $write("----------------Printing Registers----------------\n");
       
      $display("register[0]=%h", toy_i.tcd.r0);
      $display("register[1]=%h", toy_i.tcd.r1);
      $display("register[2]=%h", toy_i.tcd.r2);
      $display("register[3]=%h", toy_i.tcd.r3);
      $display("register[4]=%h", toy_i.tcd.r4);
      $display("register[5]=%h", toy_i.tcd.r5);
      $display("register[6]=%h", toy_i.tcd.r6);
      $display("register[7]=%h", toy_i.tcd.r7);
      $display("register[8]=%h", toy_i.tcd.r8);
      $display("register[9]=%h", toy_i.tcd.r9);
      $display("register[A]=%h", toy_i.tcd.rA);
      $display("register[B]=%h", toy_i.tcd.rB);
      $display("register[C]=%h", toy_i.tcd.rC);
      $display("register[D]=%h", toy_i.tcd.rD);
      $display("register[E]=%h", toy_i.tcd.rE);
      $display("register[F]=%h", toy_i.tcd.rF);

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





