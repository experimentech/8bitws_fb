`include "hvsync_generator.v"
`include "ram.v"
`include "voxel_engine.v"

/*
Top module integrating the hvsync_generator, RAM, and voxel_engine modules.
*/

module top_module(clk, reset, hsync, vsync, rgb);

  input clk, reset;     // Clock and reset signals (input)
  output hsync, vsync;  // H/V sync signals (output)
  output [2:0] rgb;     // RGB output (BGR order)

  wire display_on;      // Display on signal
  wire [8:0] hpos;      // 9-bit horizontal position
  wire [8:0] vpos;      // 9-bit vertical position

  // Instantiate the H-V Sync Generator module
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  // RAM module parameters
  parameter RAM_ADDR_WIDTH = 12; // Address width for the RAM
  parameter RAM_DATA_WIDTH = 8;  // Data width for the RAM

  wire we;  // Write enable signal from voxel_engine
  wire [RAM_ADDR_WIDTH-1:0] addr;    // Address from voxel_engine
  wire [RAM_DATA_WIDTH-1:0] ram_d;   // Data to write from voxel_engine
  wire [RAM_DATA_WIDTH-1:0] data;    // Bidirectional data line

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

  // Connect voxel_engine's ram_d to RAM's data line during write operations
  assign data = we ? ram_d : 8'bZ;

  // RGB output logic
  reg [2:0] rgb_reg;
  assign rgb = rgb_reg;

  // Read pixel data from RAM and output RGB signals
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      rgb_reg <= 3'b000;
    end else begin
      if (display_on && !we) begin
        // Read mode: display pixel data from RAM
        rgb_reg <= data[2:0];
      end else begin
        // Write mode or display off: output black
        rgb_reg <= 3'b000;
      end
    end
  end

endmodule
