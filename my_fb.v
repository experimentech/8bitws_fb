`include "hvsync_generator.v"
`include "ram.v"

/*
A simple test pattern using the hvsync_generator module and RAM_async_tristate for simulated RAM access.
*/

module test_hvsync_top(clk, reset, hsync, vsync, rgb);

  input clk, reset;   // clock and reset signals (input)
  output hsync, vsync;  // H/V sync signals (output)
  output [2:0] rgb;  // RGB output (BGR order)

  wire display_on;  // display_on signal
  wire [8:0] hpos;  // 9-bit horizontal position
  wire [8:0] vpos;  // 9-bit vertical position

  // Include the H-V Sync Generator module and
  // wire it to inputs, outputs, and wires.
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  // RAM module instantiation
  parameter RAM_ADDR_WIDTH = 12; // Address width for the RAM
  parameter RAM_DATA_WIDTH = 8;  // Data width for the RAM

  reg we;  // Write enable signal
  reg [RAM_ADDR_WIDTH-1:0] addr;  // Address signal for RAM
  wire [RAM_DATA_WIDTH-1:0] data; // Data signal for RAM

  // Instantiate the RAM module
  RAM_async_tristate #(
    .A(RAM_ADDR_WIDTH),
    .D(RAM_DATA_WIDTH)
  ) ram (
    .clk(clk),
    .we(we),
    .addr(addr),
    .data(data)
  );

  // RGB output logic
  reg [2:0] rgb_reg;
  assign rgb = rgb_reg;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset logic
      addr <= 0;
      we <= 0;
      rgb_reg <= 3'b000;
    end else begin
      // Test pattern generation logic
      if (display_on) begin
        addr <= {vpos[7:0], hpos[7:0]}[RAM_ADDR_WIDTH-1:0]; // Truncate to 12 bits
        we <= 0; // Read mode
        rgb_reg <= data[2:0]; // Example RGB assignment
      end else begin
        rgb_reg <= 3'b000; // Black when display is off
      end
    end
  end

  // Example initialization of RAM with a test pattern
  initial begin
    integer i;
    for (i = 0; i < (1 << RAM_ADDR_WIDTH); i = i + 1) begin
      ram.mem[i] = i[RAM_DATA_WIDTH-1:0]; // Example pattern
    end
  end

endmodule
