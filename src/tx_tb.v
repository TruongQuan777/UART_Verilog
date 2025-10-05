`timescale 1ns/1ps

module uart_tb();

  // ============================================
  // Clock & DUT I/O
  // ============================================
  reg clk = 0;
  reg tx_start = 0;
  reg [7:0] tx_in = 8'h00;
  wire tx_out;
  wire tx_dv;
  wire tick;

  // ============================================
  // 50 MHz clock generation
  // ============================================
  always #10 clk = ~clk;  // 20 ns period (50 MHz)

  // ============================================
  // Baudrate generator (115200 baud, 16× oversampling)
  // ============================================
  baudrate_generator baud_inst (
      .clk(clk),
      .tick(tick)
  );

  // ============================================
  // Transmitter under test
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
  // Simulation stimulus
  // ============================================
  initial begin
    $display("\n=== UART TX-Only Test Start ===");

    send_uart_tx(8'h55);
    #200_000;
    send_uart_tx(8'hF0);
    #200_000;
    send_uart_tx(8'h3C);

    #3_000_000;  // Wait for final frame
    $display("\n=== UART TX-Only Test End ===");
    $stop;
  end

  // ============================================
  // Task: trigger TX for a specific byte
  // ============================================
  task send_uart_tx(input [7:0] data);
    begin
      tx_in = data;
      #200;
      tx_start = 1; #20; tx_start = 0;
      $display("[%t ns] TX started for byte: 0x%02h", $time, data);
      monitor_uart_frame(data);
    end
  endtask

  // ============================================
  // UART frame monitor
  // Captures tx_out bit values and prints them
  // ============================================
  task automatic monitor_uart_frame(input [7:0] expected_data);
    integer bit_index;
    reg [9:0] frame_bits;    // start + 8 data + stop
    reg [7:0] received_byte; // reconstructed byte
    real bit_time;
    begin
      bit_time = 8680.0;  // ns per bit for 115200 baud

      // Wait for start bit (falling edge)
      wait (tx_out == 0);
      #(bit_time/2);  // sample in middle of bit

      // Sample 10 bits total
      for (bit_index = 0; bit_index < 10; bit_index = bit_index + 1) begin
        frame_bits[bit_index] = tx_out;
        #(bit_time);
      end

      // Decode data bits
      received_byte = frame_bits[8:1];

      // Display
      $display("[%t ns] UART Frame Captured: %b (start+data+stop)", $time, frame_bits);
      $display("             Data bits (LSB→MSB): %b%b%b%b%b%b%b%b",
                frame_bits[1], frame_bits[2], frame_bits[3], frame_bits[4],
                frame_bits[5], frame_bits[6], frame_bits[7], frame_bits[8]);

      if (received_byte === expected_data)
        $display("             ✅ TX Frame matches expected 0x%02h", received_byte);
      else
        $display("             ❌ TX Frame mismatch (got 0x%02h, expected 0x%02h)",
                  received_byte, expected_data);
    end
  endtask

endmodule
