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
