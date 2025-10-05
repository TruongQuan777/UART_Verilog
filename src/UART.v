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
