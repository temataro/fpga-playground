`default_nettype wire
/*

          +---------------+
          |               | 
     -----| D           Q |----
          |               | 
          |               | 
          |\              | 
          | \             | 
          |  \            | 
     -----| c/          Q'|---- 
          | /             | 
          |/              | 
          |     rst_n     | 
          +------+--------+
                 | 
     ------------+ 


  Let's do some math to figure out which bit in a clock register
  would tick at 1 hertz. 
  FPGA clock speed = 25_000_000 Hz
  The LSB would tick every 40 ns, bit 1 would tick every 80 ns ...
  bit_n_tick_duration = 2 ^ (bit_n) * 40 ns
  --> bit_n ~ log_2(1e9 ns / 40 ns) = log_2(FPGA clock speed)
  Doing the math we see that bit 24 gives us 0.67 seconds of delay and
  bit 25 gives roughly 1.3 s.
*/

module ff(
  input wire D,
  input wire clk,
  input wire rst_n,
  output wire Q,
  output wire Q_bar,
  output wire clk_out
);

  localparam bits   = 32;
  localparam delay  = 25;

  reg [bits - 1 : 0] cntr = 0;
  wire clk_1hz = cntr[delay];
  
  reg r_Q = 0;
  reg r_clk_out = 0;
  assign Q = r_Q;  // Can't assign wires to values in always blocks.
  assign Q_bar = !Q;
  assign clk_out = r_clk_out;

  always @ (posedge clk) begin
    if (rst_n)  // It should be a conscious decision to do a synchronous reset other times...
    begin
      cntr <= 0;
    end

    else
    begin
      cntr <= cntr + 1;
    end
  end

  always @ (posedge clk_1hz) begin
    r_Q <= D;
    r_clk_out <= !r_clk_out;
  end

endmodule
