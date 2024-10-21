`default_nettype wire
module logics(
    input wire  SW1,
    input wire  SW2,
    input wire  SW3,
    input wire  SW4,
    output wire LED1,
    output wire LED2,
    output wire LED3,
    output wire LED4
);

    /* Logic for a 2 bit full adder */
    wire [1:0] a = {SW2, SW1};
    wire [1:0] b = {SW4, SW3};

    assign {LED4, LED3, LED2, LED1} = a + b;

endmodule
