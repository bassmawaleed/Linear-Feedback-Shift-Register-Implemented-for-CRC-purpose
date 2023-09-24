`timescale 1ns/1ns

module CRC_tb ();
  

parameter CLK_Period = 100 ;
parameter LFSR_WD_tb = 8;
parameter Test_Cases = 10;

reg    [LFSR_WD_tb-1:0]   Test_Data   [Test_Cases-1:0] ;
reg    [LFSR_WD_tb-1:0]   Expec_Outs   [Test_Cases-1:0] ;
reg    [LFSR_WD_tb-1:0]   Test;

/* Declaring Testbench Signals */
reg DATA_tb ;
reg ACTIVE_tb ;
reg CLK_tb , RST_tb;

wire CRC_tb ;
wire Valid_tb ;

integer Operation ;

/* DUT Instantiation */
CRC DUT (
.DATA(DATA_tb),
.ACTIVE(ACTIVE_tb),
.CLK(CLK_tb),
.RST(RST_tb),
.CRC(CRC_tb),
.Valid(Valid_tb)
);

/* Clock generation */
always #(CLK_Period/2) CLK_tb =~CLK_tb ;



/* Initial Block */
initial 
begin
  $dumpfile("CRC.vcd");
  $dumpvars ;
  
  $readmemh("DATA_h.txt" , Test_Data);
  $readmemh("Expec_Out_h.txt" , Expec_Outs);
  
  
  initialize();
  /* Time = 0*/
  
  reset();
  /* Time = 200ns*/
  
  /* Test Cases */
 for (Operation=0;Operation<Test_Cases;Operation=Operation+1)
  begin
   #(CLK_Period)
   do_oper(Test_Data[Operation]) ;                       // do_lfsr_operation
   check_out(Expec_Outs[Operation],Operation) ;           // check output response
  end
  
  
  #(10*CLK_Period)
  $stop ;
end

/* Initialize task */
task initialize;
  begin  
    ACTIVE_tb = 1'b0 ;
    CLK_tb = 1'b0;
    RST_tb = 1'b1;
  end
endtask


/*Reset task --> Store the SEED In LFSR before the entry of new data*/
task reset;
  begin
    RST_tb= 1'b1;
    #(CLK_Period)
    RST_tb = 1'b0 ;
    #(CLK_Period)
    RST_tb = 1'b1 ;
  end
endtask

/* CRC Operation */
task do_oper ;
input  [LFSR_WD_tb-1:0]     Test ;

 begin
   reset () ; /*Time = Time + 200 ns */
   ACTIVE_tb = 1'b1;
   
   /* Data is fed bit by bit every clock cycle */
   DATA_tb = Test[0];
   #(CLK_Period) 
   DATA_tb = Test[1];
   #(CLK_Period)
   DATA_tb = Test[2];
   #(CLK_Period)
   DATA_tb = Test[3];
   #(CLK_Period)
   DATA_tb = Test[4];
   #(CLK_Period)
   DATA_tb = Test[5];
   #(CLK_Period)
   DATA_tb = Test[6];
   #(CLK_Period)
   DATA_tb = Test[7];
   #(CLK_Period)
   ACTIVE_tb = 1'b0;   
 end
endtask


/* Checking Output and comparing with the expected one */

task check_out ;
 input  reg     [LFSR_WD_tb-1:0]     expec_out ;
 input  integer                      Oper_Num ; 

 integer i ;
 
 reg    [LFSR_WD_tb-1:0]     gener_out ;

 begin
  ACTIVE_tb = 1'b0;  
  @(posedge Valid_tb)
  for(i=0; i<8; i=i+1)
   begin
    #(CLK_Period) gener_out[i] = CRC_tb ;
   end
   #(CLK_Period/2)
   if(gener_out == expec_out) 
    begin
     $display("Test Case %d is succeeded",Oper_Num);
    end
   else
    begin
     $display("Test Case %d is failed", Oper_Num);
    end
 end
endtask


endmodule



