module voxel_engine(
  input clk,
  input reset,
  input display_on,
  input [8:0] hpos,
  input [8:0] vpos,
  output reg we,
  output reg [11:0] addr,
  output reg [7:0] ram_d
);

  // Voxel array (3D array of 1-bit voxels)
  reg [0:0] voxels[7:0][7:0][7:0];  // Explicitly declare 1-bit width

  // Initialize voxel array with a simple pattern
  integer x, y, z;  // Moved declaration outside of initial block

  initial begin
    for (x = 0; x < 8; x = x + 1) begin
      for (y = 0; y < 8; y = y + 1) begin
        for (z = 0; z < 8; z = z + 1) begin
          // Extract LSB to get a 1-bit result
          voxels[x][y][z] = (x + y + z) & 1'b1;
        end
      end
    end
  end

  // Simple projection algorithm
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      addr <= 0;
      we <= 0;
      x <= 0;
      y <= 0;
      z <= 0;
    end else if (display_on) begin
      if (voxels[x][y][z]) begin
        // Simple orthographic projection
        addr <= {y[3:0], x[3:0], 4'b0};  // Ensure addr is 12 bits
        we <= 1;
        ram_d <= 8'b11111111;  // White voxel
      end else begin
        we <= 0;
      end
      // Increment indices
      if (z < 7) begin
        z <= z + 1;
      end else begin
        z <= 0;
        if (y < 7) begin
          y <= y + 1;
        end else begin
          y <= 0;
          if (x < 7) begin
            x <= x + 1;
          end else begin
            x <= 0;
          end
        end
      end
    end else begin
      we <= 0;
    end
  end

endmodule