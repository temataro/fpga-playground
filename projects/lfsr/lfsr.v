module lfsr(
    input wire SW1,
    input wire CLK,
    input wire SW2,
    output wire LED1,
    output wire LED2,
    output wire LED3,
    output wire LED4
);
    localparam SIZE = 4;  // LFSR Size
    reg[SIZE - 1: 0] r_bits = 4'b0000;

    assign r_bits = {LED4, LED3, LED2, LED1};

    // Tap the second and fourth bits to xor and feedback
    assign w_tap_output = r_bits[1] ^ r_bits[3];

    always @(posedge CLK)
    begin
        if (!SW1) begin
            r_bits[SIZE - 1: 1] <= r_bits[SIZE - 2: 0];
            r_bits[0] <= w_tap_output;
        end
            r_bits[SIZE - 1: 1] <= r_bits[SIZE - 2: 0];
            r_bits[0] <= SW2;
    end
endmodule
