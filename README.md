# Notes on Programming and Using the NANDLAND Go Board

Some notes on this FPGA and [dev board](https://nandland.com/the-go-board/).

  - Lattice ICE40 HX1K FPGA
  - 1280 Logic cells.

We will be using the opensource toolchain combination of Yosys, Icestorm and nextprnr-ice40.
Consult the oracle below:
https://eecs.blog/lattice-ice40-fpga-icestorm-tutorial/

Basic workflow will include fixed start costs like assigning your pcf file, setting up a Makefile to convert your Verilog into asc then bin files and then programming the 1MB flash memory with the bitstream.

Fixed Costs:
  - Ensure the FPGA memory is detected as a USB device:

  run `lsusb` and find:
  ```
  Bus 003 Device 002: ID 0403:6010 Future Technology Devices International, Ltd FT2232C/D/H Dual UART/FIFO ICB
```

## Programming the FPGA

### My first blinky
Apio is a great tool. Make a venv and pip install it.
It will geneate the pcf and other necessary things for your specific fpga, give you examples (`apio examples -l` to see a list).
Then you can run `apio upload` to the USB device.
In your upload folder, run `apio init --board go-board` to generate the `apio.ini` file it will use for the uploading.
Make sure to change the name of the top module it expects to find to the name of your Verilog module.

TODO: Try the more verbose approach of doing each step manually.
```shell
yosys -p "synth_ice40 -top blink -json hardware.json" -q blink.v
nextpnr-ice40 --hx1k --package vq100 --json hardware.json --asc hardware.asc --pcf blinky.pcf -q --pcf-allow-unconstrained
icepack hardware.asc hardware.bin
iceprog hardware.bin
```

We can Makefile away this procedure now with
`make prog TOP_MOD=<your_top_verilog_file>`

### Getting Started Yourself
Go to `./projects/` and make a project directory of your own. Then either run `apio init --board go-board`
so you can use `apio upload`, or copy the Makefile at the root of this repository to use `make prog`.

Also copy whatever pins you need to alias into your own pcf file or copy the go-board.pcf from the root directory.

## Testing
Use a combination of [iverilog](https://github.com/steveicarus/iverilog) and
[gtkwave](https://github.com/gtkwave/gtkwave).

To start writing testbenches, we'll have to start being aware of what our clock
is doing. For sims, the clock resolution we use really doesn't factor into what
the real FPGA clock is doing (at least for low performance designs (< 100 MHz
according to the author of the Nandland FPGA book) where we just want to see
whether our Verilog actually works.)

**The go-board has a 25 MHz clock. This means each clock cycle lasts 40 nanoseconds.**

As such, we'll start specfying a timescale for anything we do from now on.

The design file will not change but will be accompanied by a testbench,
`<module_name>_tb.v`. It will have an infinite loop of a clock pulse during
which all our input combinations can be tested.


Specifying default nettypes also seems to be best practice, so:

```verilog
`default_nettype wire`
`default_nettype none`
```

All in all, a test bench will have all these components:


```verilog
  timescale 1ns / 100ps
  /*
  * Writing a testbench essentially boils down to doing the following 5
  * things:
  *       1- Defining all your inputs/outputs to test + your clock.
  *           ( regs for input, wires for output).
  *
  *       2- Instantiating an instance (yes) of the unit under test (UUT).
  *
  *       3- Defining any helper variables you think would give you better
  *       insight into your design. (Turn individual bit lines into a larger N
  *       bit wire, etc...)
  *
  *       4- Toggle your clock faaast in an `always begin` block.
  *
  *       5- Write your permutations and output dumpfile/dumpvars specification
  *       in an `initial begin` block. Then $finish.
  */

  module logics_tb(); // NOTE: Don't forget the ()!

  // Define all your variables + clock here
  // Set inputs to be registers and outputs to be wires.
  reg clk;
  reg a, b, c, d;
  wire o1, o2, o3, o4;

  // <module name> <module instance name>(.<parameter name>(variable))
  logics logic_mod1(
      .SW1(a),
      .SW2(b),
      .SW3(c),
      .SW4(d),
      .LED1(o1),
      .LED2(o2),
      .LED3(o3),
      .LED4(o4) // LEAVE NO TRAILING COMMAS!
  );

  // Define helper variables here
  wire [1:0] input1 = {b, a};
  wire [1:0] input2 = {d, c};
  wire [3:0] out = {o4, o3, o2, o1};
  // *** *** === *** **

  // Toggle your clock signal at however many cycles you want below
  always begin
      #10  // This means 10 ns at a timescale of 1ns / 1ps
      clk = !clk;
  end

  // Main procedure
  initial begin
      $dumpfile("logics_tb.vcd"); // whatever file you wanna run your gtkwave from
      $dumpvars(0, logics_tb); // $dumpvars(0, <testbench module name>)

      $display("=== =================== ===");
      $display("*** Starting simulation ***");
      $display("=== =================== ===");
      // Initialize all your variables
      a   = 0;
      b   = 0;
      c   = 0;
      d   = 0;
      clk = 0;

      $display("\nTime=%0t		0'binput1 = %b (0'd%0d) | 0'binput2 = %b (0'd%0d) | out=%b (0'd%0d)",
                              $time, input1, input1,
                              input2, input2,
                              out, out);

      // Did you know you can also do for loops in here to ease writing all the
      // combinations?

      for  (integer i = 0; i < 4; i++) begin
          for  (integer j = 0; j < 4; j++) begin
              {b, a} = i[1:0];
              {d, c} = j[1:0];

              #10; // Don't forget to clock... with semicolon!
              $display("\nTime=%0t		0'binput1 = %b (0'd%0d) | 0'binput2 = %b (0'd%0d) | out=%b (0'd%0d)",
                                      $time, input1, input1,
                                      input2, input2,
                                      out, out);
          end
      end

      // Write any remaining test combinations below.
      // Display to CLI with  and $monitor, there is a $time variable you
      // can use for current # of clock cycles.

      // *** *** === *** ***
      $finish;
  end

  endmodule
`default_nettype wire
```
Testing will be done with iVerilog and GTKWave as such:

```shell
iverilog -o <output_file> <testbench> <main_verilog_file>
vvp <output_file>
gtkwave <whatever_dumpfile_you_specified_in_your_tb>
```

