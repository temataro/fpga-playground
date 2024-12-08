from time import sleep

lfsr = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
orig_lfsr = [0, 1, 0, 0, 0, 0, 0, 0, 0, 0]
while True:
    print(*lfsr, end='\r')
    lfsr[1:] = lfsr[0:-1]
    lfsr[0] = lfsr[-1] ^ lfsr[2]
    sleep(0.4)
    if lfsr == orig_lfsr:
        print("COMPLETED ONE CYCLE!\n", end='\r')
