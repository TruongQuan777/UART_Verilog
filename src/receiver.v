module receiver #(parameter DATA_WIDTH=8,oversample_rate=16)(
    input clk,
    input tick,
    input rx_in,
    output reg [DATA_WIDTH-1:0] rx_out=0,
    output rx_dv
);
  parameter iddle=2'b00,start=2'b01,data=2'b10,stop=2'b11;
  
  reg [1:0] state = iddle;
  reg [4:0] tick_counter = 0;
  reg [3:0] bit_counter = 0;

  
  always @(posedge clk)
    begin
      if(state==iddle)
        begin
          if(rx_in==0)
            begin
              tick_counter<=0;
              state<=start;
            end
          else state<=iddle;
        end
      
      else if (state==start)
        begin
          if(tick)
            begin
              if(tick_counter==(oversample_rate/2)-1)
                begin
                  tick_counter<=0;
                  bit_counter<=0;
                  state<=data;
                end
              else 
                begin
                  tick_counter<=tick_counter+1;
                  state<=start;
                end
            end
          else state<=start;
        end
      
      else if (state==data)
        begin
          if(tick)
            begin
              if(tick_counter==oversample_rate-1)
                begin
                  tick_counter<=0;
                  rx_out[bit_counter]<=rx_in;
                  if(bit_counter==DATA_WIDTH-1)
                    begin
                      bit_counter<=0;
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
          else
            begin
              state<=data;
            end
        end
      
      else 
        begin
          if(tick)
            begin
              if(tick_counter==oversample_rate-1) state<=iddle;
              else
                begin
                  tick_counter<=tick_counter+1;
                  state<=stop;
                end
            end
          else state<=stop;
        end
    end
  assign rx_dv=(state==iddle);

endmodule
