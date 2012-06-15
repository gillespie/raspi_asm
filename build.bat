set PREFIX=arm-none-eabi-
set CFLAGS=-Wall --std=c99 -O2 -fdata-sections -ffunction-sections

"%PREFIX%as" -o build\start.o start.S
"%PREFIX%as" -o build\gpio.o gpio.S
"%PREFIX%as" -o build\mail.o mail.S
"%PREFIX%as" -o build\memory.o memory.S

"%PREFIX%ld" -e entry --gc-sections -o build\kernel.elf build\start.o build\gpio.o build\mail.o build\memory.o
"%PREFIX%strip" -s -x -X build\kernel.elf
"%PREFIX%objcopy" --output-target binary build\kernel.elf build\kernel.img

copy /Y build\kernel.img K:\