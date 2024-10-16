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
  Bus 003 Device 002: ID 0403:6010 Future Technology Devices International, Ltd FT2232C/D/H Dual UART/FIFO IC
B
```

## Programming the FPGA

### My first blinky
Apio is a great tool. Make a venv and pip install it.
It will geneate the pcf and other necessary things for your specific fpga, give you examples (`apio examples -l` to see a list).
Then you can run `apio upload` to the USB device.
In your upload folder, run `apio init --board go-board` to generate the `apio.ini` file it will use for the uploading.
Make sure to change the name of the top module it expects to find to the name of your Verilog module.

TODO: Try the more verbose approach of doing each step manually.
```
yosys -p "synth_ice40 -top blink -json hardware.json" -q blink.v
nextpnr-ice40 --hx1k --package vq100 --json hardware.json --asc hardware.asc --pcf blinky.pcf -q --pcf-allow-unconstrained
icepack hardware.asc hardware.bin
iceprog hardware.bin
```
