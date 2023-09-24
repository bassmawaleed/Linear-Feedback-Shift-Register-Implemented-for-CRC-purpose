module CRC (
  input wire DATA,
  input wire ACTIVE,
  input wire CLK,
  input wire RST,
  output reg CRC,
  output reg Valid
  );

/*Parameters*/
parameter SEED_LENGTH = 8 ;
parameter [SEED_LENGTH - 1:0] SEED = 8'hD8;
parameter TAPS =8'b10001000;


reg [7:0] LFSR;
reg feedback;

/*Loop Counters*/
integer N ;
integer K ;

/*Counter for counting the output bits*/
reg [2:0] counter ;



always@(posedge CLK or negedge RST)
begin
  if ( !RST )
    begin
      CRC <= 1'b0;
      Valid <= 1'b0;
      counter <= 0;
      
      /*Initializing the LFSR with the Seed*/
      for(N=0 ; N < SEED_LENGTH ; N = N+1)
      begin
        LFSR[N] <= SEED[N] ;
      end
      
    end
    
  else if (ACTIVE)
    begin
      LFSR[7] <= feedback ;
      for(K = 7 ; K > 0 ; K = K - 1)
      begin
        if(TAPS[K])
          LFSR[K - 1] <= LFSR[K] ^ feedback;
        else
          LFSR[K - 1] <= LFSR[K];
      end
      
      /*
      LFSR[7] <= feedback ;
      LFSR[6] <= LFSR[7] ^ feedback;
      LFSR[5] <= LFSR[6] ;
      LFSR[4] <= LFSR[5] ;
      LFSR[3] <= LFSR[4] ;
      LFSR[2] <= LFSR[3] ^ feedback;
      LFSR[1] <= LFSR[2] ;
      LFSR[0] <= LFSR[1] ;
      */
      
      CRC <= 1'b0;
      Valid <= 1'b0;
      
    end
    
    else if( counter < 8 )
    begin
      /*Shift the CRC bits*/
      Valid <= 1'b1;
      CRC <= LFSR[0] ;
      LFSR[0] <= LFSR[1] ;
      LFSR[1] <= LFSR[2] ;
      LFSR[2] <= LFSR[3] ;
      LFSR[3] <= LFSR[4] ;
      LFSR[4] <= LFSR[5] ;
      LFSR[5] <= LFSR[6] ;
      LFSR[6] <= LFSR[7] ;
      if(counter == 7)
        begin
          /*Now , All the CRC bits are out */
          Valid <= 1'b0;
          counter <= 0;
        end
      else
        begin
          counter <= counter + 1;
          Valid <= 1'b1;
        end
      end
      
    else
      begin
        CRC <= 1'b0;
        Valid <= 1'b0;
        counter <= 0; 
      end
      
end

always @ (*)
begin
   feedback = LFSR[0] ^ DATA ;
end



endmodule