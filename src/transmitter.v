module transmitter #(parameter DATA_WIDTH=8,oversample_rate=16)(
    input clk,
    input tick,
    input tx_start,
    input [DATA_WIDTH-1:0] tx_in,
    output reg  tx_out,
    output tx_dv
);
  parameter iddle=2'b00,start=2'b01,data=2'b10,stop=2'b11;
  
  reg [1:0] state;
  reg [4:0] tick_counter;
  reg [3:0] bit_counter;
  
  always @(posedge clk)
    begin
      if(state==iddle)
        begin
          if(tx_start)
            begin
              tx_out<=1;
              state<=iddle;
            end
          else
            begin
              tx_out<=0;
              tick_counter<=0;
              state<=start;
            end
        end
      else if(state==start)
        begin
          if(tick)
            begin
              if(tick_counter==oversample_rate-1)
                begin
                  bit_counter<=0;
                  tick_counter<=0;
                  state<=data;
                end
              else
                begin
                  tick_counter<=tick_counter+1;
                  state<=start;
                end
            end
          else
            begin
              state<=start;
            end
        end
      else if(state==data)
        begin
          if(tick)
            begin
              if(tick_counter==15)
                begin
                  tick_counter<=0;
                  tx_out<=tx_in[bit_counter];
                  if(bit_counter==DATA_WIDTH-1)
                    begin
                      tx_out<=1;
                      state<=stop;
                    end
                  else
                    begin
                      bit_counter<=bit_counter+1;
                      state<=data;
                    end
                end
              else
                begin
                  tick_counter<=tick_counter+1;
                  state<=data;
                end
            end
          else state<=data;

        end
      else
        begin
          if(tick)
            begin
              if(tick_counter==oversample_rate-1)
                begin
                  tick_counter<=0;
                  tx_out<=1;
                  state<=iddle;
                end
              else
                begin
                  tick_counter<=tick_counter+1;
                  state<=stop;
                end
            end
          else state<=stop;
        end
    end
  
  assign tx_dv=(state==iddle);
    
endmodule

