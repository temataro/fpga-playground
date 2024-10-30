TOP_MOD   :=blink
DEVICE    :=hx1k
PKG       :=vq100
DEV_VIDPID:=i:0x0403:0x6010:0

prog: hardware.asc
	icepack hardware.asc hardware.bin
	iceprog -d $(DEV_VIDPID) hardware.bin

hardware.asc: hardware.json
	nextpnr-ice40 --$(DEVICE) --package $(PKG) --json $< --asc $@ --pcf $(TOP_MOD).pcf -q --pcf-allow-unconstrained

hardware.json:
	yosys -p "synth_ice40 -top $(TOP_MOD) -json hardware.json" -q $(TOP_MOD).v

sim:
	iverilog -o $(TOP_MOD) $(TOP_MOD)_tb.v $(TOP_MOD).v
	vvp $(TOP_MOD)
	gtkwave $(TOP_MOD)_tb.vcd

clean:
	rm *.asc *.bin *.json $(TOP_MOD)

init:
	@echo "This only copies the base files at the base directory of this repo\
	to a project folder <project_name> inside ./projects/<project_name>"
	cp ../../go-board.pcf ../Verilogging/logics_tb.v .

.PRECIOUS: %.bin %.asc %.vcd
.PHONY: prog clean sim init
