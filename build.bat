set PREFIX=arm-none-eabi-
set CFLAGS=-Wall --std=c99 -O2 -fdata-sections -ffunction-sections

"%PREFIX%as" -o build\start.o start.S
"%PREFIX%as" -o build\gpio.o gpio.S
"%PREFIX%as" -o build\mail.o mail.S
"%PREFIX%as" -o build\memory.o memory.S
"%PREFIX%as" -o build\fb.o fb.S
"%PREFIX%as" -o build\led.o led.S
"%PREFIX%as" -o build\interrupts.o interrupts.S

"%PREFIX%ld" -T memmap -o build\kernel.elf build\interrupts.o build\start.o build\gpio.o build\mail.o build\memory.o build\fb.o build\led.o 
"%PREFIX%strip" -s -x -X build\kernel.elf
"%PREFIX%objcopy" --output-target binary build\kernel.elf build\kernel.img

copy /Y build\kernel.img K:\