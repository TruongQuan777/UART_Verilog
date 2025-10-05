`timescale 1ns/1ps

module uart_tb();

  // === Clock & I/O ===
  reg clk = 0;
  reg tx_start = 0;
  reg [7:0] tx_in = 8'h00;
  wire tx_out;
  wire tx_dv;
  wire tick;

  // === Clock generator (50 MHz) ===
  always #10 clk = ~clk;  // 20 ns period

  // === Instantiate UART transmitter ===
  transmitter #(.DATA_WIDTH(8)) uut_tx (
      .clk(clk),
      .tick(tick),
      .tx_start(tx_start),
      .tx_in(tx_in),
      .tx_out(tx_out),
      .tx_dv(tx_dv)
  );

  // === Baudrate generator (115200 baud, 16× oversample) ===
  baudrate_generator uut_baud (
      .clk(clk),
      .tick(tick)
  );

  // === Main test sequence ===
  initial begin
    // Print time-stamped events
    $display("\n=== UART TX MULTI-BYTE TEST START ===");
    $monitor("Time=%t ns | tx_start=%b | tx_in=%02h | tx_out=%b | tx_dv=%b",
              $time, tx_start, tx_in, tx_out, tx_dv);

    // Byte #1: 0xA5  (10100101)
    tx_in = 8'hA5;
    #200;
    tx_start = 1; #20; tx_start = 0;
    $display("[%t ns] Sending byte 1: 0xA5", $time);

    // Wait long enough for one full UART frame (~87 µs)
    #200_000;

    // Byte #2: 0xF0  (11110000)
    tx_in = 8'hF0;
    #200;
    tx_start = 1; #20; tx_start = 0;
    $display("[%t ns] Sending byte 2: 0xF0", $time);

    #200_000;

    // Byte #3: 0x3C  (00111100)
    tx_in = 8'h3C;
    #200;
    tx_start = 1; #20; tx_start = 0;
    $display("[%t ns] Sending byte 3: 0x3C", $time);

    // Wait enough time to finish third frame
    #2_000_000;

    $display("\n=== UART TX MULTI-BYTE TEST END ===");
    $stop;
  end

endmodule
