`timescale 1ns/1ps

module uart_tb();

  // === Clock and signals ===
  reg clk = 0;
  wire tick;
  reg rx_in = 1;          // line idle high
  wire [7:0] rx_out;
  wire rx_dv;

  // === 50 MHz clock ===
  always #10 clk = ~clk;  // 20 ns period

  // === Baudrate generator (115200 baud, 16× oversample) ===
  baudrate_generator baud_inst (
      .clk(clk),
      .tick(tick)
  );

  // === Receiver under test ===
  receiver #(.DATA_WIDTH(8)) rx_inst (
      .clk(clk),
      .tick(tick),
      .rx_in(rx_in),
      .rx_out(rx_out),
      .rx_dv(rx_dv)
  );

  // === Print whenever RX finishes a byte ===
  always @(posedge rx_dv)
    $display("[%t ns] RX received byte = 0x%02h", $time, rx_out);

  // === Main test sequence ===
  initial begin
    $display("\n=== UART RX-only test start ===");
    // Send three bytes manually: 0x55, 0xF0, 0x3C
    send_uart_byte(8'h55);
    #100_000;
    send_uart_byte(8'hF0);
    #100_000;
    send_uart_byte(8'h3C);
    #200_000;

    $display("\n=== UART RX-only test end ===");
    $stop;
  end

  // === Task: send one UART frame at 115200 baud ===
  task automatic send_uart_byte(input [7:0] data);
    integer i;
    real bit_time;   // must be declared inside as 'automatic'
    begin
      bit_time = 8680.0;  // ns per bit at 115200 baud

      // Start bit
      rx_in = 0;
      #(bit_time);

      // 8 data bits, LSB first
      for (i = 0; i < 8; i = i + 1) begin
        rx_in = data[i];
        #(bit_time);
      end

      // Stop bit
      rx_in = 1;
      #(bit_time);

      $display("[%t ns] Sent UART frame for 0x%02h", $time, data);
    end
  endtask

endmodule
