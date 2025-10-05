`timescale 1ns/1ps

module uart_tb();

  // ============================================
  // Clock & I/O signals
  // ============================================
  reg clk = 0;
  reg tx_start = 0;
  reg [7:0] tx_in = 8'h00;

  wire tx_out;
  wire tx_dv;
  wire tick;

  wire [7:0] rx_out;
  wire rx_dv;

  // ============================================
  // 50 MHz clock generation
  // ============================================
  always #10 clk = ~clk; // 20 ns period = 50 MHz

  // ============================================
  // Baudrate generator (115200 baud, 16× oversample)
  // ============================================
  baudrate_generator baud_inst (
      .clk(clk),
      .tick(tick)
  );

  // ============================================
  // UART transmitter
  // ============================================
  transmitter #(.DATA_WIDTH(8)) tx_inst (
      .clk(clk),
      .tick(tick),
      .tx_start(tx_start),
      .tx_in(tx_in),
      .tx_out(tx_out),
      .tx_dv(tx_dv)
  );

  // ============================================
  // UART receiver (loopback from tx_out)
  // ============================================
  receiver #(.DATA_WIDTH(8)) rx_inst (
      .clk(clk),
      .tick(tick),
      .rx_in(tx_out),   // 🌀 loopback connection
      .rx_out(rx_out),
      .rx_dv(rx_dv)
  );

  // ============================================
  // Stimulus
  // ============================================
  initial begin
    $display("\n=== UART LOOPBACK TEST START ===");
    #200;

    send_uart_byte(8'h55);
    #200_000;
    send_uart_byte(8'hF0);
    #200_000;
    send_uart_byte(8'h3C);
    #3_000_000;

    $display("\n=== UART LOOPBACK TEST END ===");
    $stop;
  end

  // ============================================
  // Task: transmit one byte
  // ============================================
  task send_uart_byte(input [7:0] data);
    begin
      tx_in = data;
      tx_start = 1;
      #20; // one clk cycle
      tx_start = 0;
      $display("[%t ns] Sent TX byte: 0x%02h", $time, data);
    end
  endtask

  // ============================================
  // Monitor: show when RX receives a byte
  // ============================================
  always @(posedge rx_dv) begin
    $display("[%t ns] RX received byte: 0x%02h", $time, rx_out);
  end

endmodule
