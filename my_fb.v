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
  reg [RAM_DATA_WIDTH-1:0] ram_d;  // Data to be written to RAM
  wire [RAM_DATA_WIDTH-1:0] ram_q;  // Data read from RAM
  wire [RAM_ADDR_WIDTH-1:0] ram_addr = {vpos[6:0], hpos[4:0]}; // Combine vpos and hpos for 12-bit address

  // RAM instance
  RAM_async_tristate #(
    .A(RAM_ADDR_WIDTH),
    .D(RAM_DATA_WIDTH)
  ) ram (
    .clk(clk),
    .addr(ram_addr),
    .data(ram_q),
    .we(we)
  );

  // Write operation
  always @(posedge clk) begin
    if (we) begin
      ram.mem[ram_addr] <= ram_d;
    end
  end

  // Read operation
  assign ram_q = ram.mem[ram_addr];

/*  
    // Initialize RAM with a test pattern
  integer i;
  initial begin
    we = 1'b1;
    for (i = 0; i < (1 << RAM_ADDR_WIDTH); i = i + 1) begin
      if (i[3:0] == 4'b0000) // Example pattern: set every 16th byte
        ram_d = 8'hFF;       // White pixel
      else if (i[3:0] == 4'b1000)
        ram_d = 8'h00;       // Black pixel
      else
        ram_d = 8'hAA;       // Alternate pattern
      @(posedge clk);  // Ensure synchronization with the clock
    end
    we = 1'b0;
  end
*/
  // Initialize RAM with a test pattern
  integer i;  // Declaration of integer i should be outside procedural block
  initial begin
    we = 1'b1;
    for (i = 0; i < (1 << RAM_ADDR_WIDTH); i = i + 1) begin
      ram_d = i[7:0];  // Just an example, storing i's lower byte
    end
    we = 1'b0;
  end

  // Generate the RGB output based on RAM data
  wire r = display_on & ram_q[0];
  wire g = display_on & ram_q[1];
  wire b = display_on & ram_q[2];

  // Concatenation operator merges the red, green, and blue signals
  // into a single 3-bit vector, which is assigned to the 'rgb'
  // output. The IDE expects this value in BGR order.
  assign rgb = {b, g, r};

endmodule
