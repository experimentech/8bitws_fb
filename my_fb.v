`include "hvsync_generator.v"
`include "ram.v"
`include "voxel_engine.v"

/*
Top module integrating the hvsync_generator, RAM, and voxel_engine modules.
*/

module top_module(clk, reset, hsync, vsync, rgb);

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
  reg [RAM_DATA_WIDTH-1:0] ram_d; // Data to be written to RAM

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

  // Instantiate the voxel engine
  voxel_engine voxel_eng(
    .clk(clk),
    .reset(reset),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos),
    .we(we),
    .addr(addr),
    .ram_d(ram_d)
  );

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      rgb_reg <= 3'b000;
    end else begin
      if (display_on) begin
        rgb_reg <= data[2:0]; // Example RGB assignment
      end else begin
        rgb_reg <= 3'b000; // Black when display is off
      end
    end
  end

endmodule
