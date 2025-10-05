module uart #(parameter DATA_WIDTH=8)(
    input clk,
    
    input wire rx_in,
    output wire [DATA_WIDTH-1:0] rx_out,
    output wire rx_dv,
    
    
    input tx_start,
    input wire [DATA_WIDTH-1:0] tx_in,
    output wire tx_dv,
    output wire tx_out
);
    
    wire tick;
    
    baudrate_generator baudrate(
        .clk(clk),
        .tick(tick)
    );
    
    receiver #(.DATA_WIDTH(DATA_WIDTH)) rx(
        .clk(clk),
        .tick(tick),
        .rx_in(rx_in),
        .rx_out(rx_out),
        .rx_dv(rx_dv)
    );
    
    transmitter #(.DATA_WIDTH(DATA_WIDTH)) tx(
        .clk(clk),
      	.tick(tick),
        .tx_start(tx_start),
        .tx_in(tx_in),
        .tx_dv(tx_dv),
        .tx_out(tx_out)
    );
    
endmodule

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

module transmitter #(parameter DATA_WIDTH=8,oversample_rate=16)(
    input clk,
    input tick,
    input tx_start,
    input [DATA_WIDTH-1:0] tx_in,
    output reg  tx_out,
    output tx_dv
);
  parameter iddle=2'b00,start=2'b01,data=2'b10,stop=2'b11;
  
  reg [1:0] state = iddle;
  reg [4:0] tick_counter = 0;
  reg [3:0] bit_counter = 0;
  reg tx_out = 1;

  
  always @(posedge clk)
    begin
      if (state == iddle) 
        begin
          if (tx_start) 
            begin
              tx_out <= 0; // start bit
              tick_counter <= 0;
              state <= start;
            end 
          else 
            begin
              tx_out <= 1;
              state <= iddle;
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
              if(tick_counter==oversample_rate-1)
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

module baudrate_generator(
    input clk,
    output tick
);
    parameter baud_rate=115200,
			  clk_rate=50000000,
			  oversample_rate=16,
			  max_counter=clk_rate/(baud_rate*oversample_rate),
  			  counter_width=$clog2(max_counter);
    
    reg [counter_width-1:0] counter=0; 
    
    always @(posedge clk)
        begin
          if(counter==max_counter-1) counter<=0;
          else counter<=counter+1;            
        end
    
  assign tick=(counter==max_counter-1);
endmodule


