`timescale 1ns / 100ps
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

module lfsr_tb(); // NOTE: Don't forget the ()!

// Define all your variables + clock here
// Set inputs to be registers and outputs to be wires.
reg clk;
reg a, b;
wire o1, o2, o3, o4;

// <module name> <module instance name>(.<parameter name>(variable))
lfsr lfsr1(
    .SW1(a),
    .SW2(b),
    .CLK(clk),
    .LED1(o1),
    .LED2(o2),
    .LED3(o3),
    .LED4(o4) // LEAVE NO TRAILING COMMAS!
);

// Define helper variables here
wire [1:0] input1 = {b, a};
wire [3:0] out = {o4, o3, o2, o1};
// *** *** === *** **

// Toggle your clock signal at however many cycles you want below
always begin
    #10  // This means 10 ns at a timescale of 1ns / 1ps
    clk = !clk;
end

// Main procedure
initial begin
    $dumpfile("lfsr_tb.vcd"); // whatever file you wanna run your gtkwave from
    $dumpvars(0, lfsr_tb); // $dumpvars(0, <testbench module name>)

    $display("=== =================== ===");
    $display("*** Starting simulation ***");
    $display("=== =================== ===");
    // Initialize all your variables
    a   = 0;
    b   = 0;
    clk = 0;

    $display("\nTime=%0t		0'binput1 = %b (0'd%0d)",
                            $time, input1, input1,
                            out, out);

    // Did you know you can also do for loops in here to ease writing all the
    // combinations?

    #10
    a = 1;
    b = 1;
    #10
    $display("\nTime=%0t		0'binput1 = %b (0'd%0d)",
                            $time, input1, input1,
                            out, out);
    #10
    $display("\nTime=%0t		0'binput1 = %b (0'd%0d)",
                            $time, input1, input1,
                            out, out);
    #10
    $display("\nTime=%0t		0'binput1 = %b (0'd%0d)",
                            $time, input1, input1,
                            out, out);
    #10
    $display("\nTime=%0t		0'binput1 = %b (0'd%0d)",
                            $time, input1, input1,
                            out, out);

    // Write any remaining test combinations below.
    // Display to CLI with  and $monitor, there is a $time variable you
    // can use for current # of clock cycles.

    // *** *** === *** ***
    $finish;
end

endmodule
`default_nettype wire
