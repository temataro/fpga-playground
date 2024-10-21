`default_nettype wire
module math(
  input rst_n,
  input clk,
  output is_prime
);
    localparam cntr_bits = 16;
    reg[cntr_bits-1:0] counter = 0;
    reg[cntr_bits-1:0] number  = 0;

    always @ (posedge clk or posedge rst_n) begin
        if (rst_n)
        begin
            counter <= counter + 1;
            if (counter[8])
                number <= number + 1;
            end

            integer i;
            for (i = 1; i < number; i++)
            begin
                if (number % i)
                    is_prime = 1;
                else
                    is_prime = 0;
                end
            end
        end else begin
            counter <= 0;
        end
    end
endmodule

