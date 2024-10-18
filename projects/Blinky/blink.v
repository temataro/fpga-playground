module blink (
input clk,
output LED1,
output LED2,
output LED3,
output LED4
);
  localparam bits = 4;
  localparam delay = 22;

  reg[bits + delay-1 : 0] counter = 0;
  reg[bits        -1 : 0]     out = 0;

  always @(posedge clk) begin
    counter <= counter + 1;
    out <= counter >> delay;
  end

  assign {LED1, LED2, LED3, LED4} = out;

endmodule

