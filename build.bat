set PREFIX=arm-none-eabi-
set CFLAGS=-Wall --std=c99 -O2 -fdata-sections -ffunction-sections

"%PREFIX%as" -o start.o start.S
"%PREFIX%as" -o gpio.o gpio.S
"%PREFIX%as" -o mail.o mail.S

"%PREFIX%ld" -e entry --gc-sections -o kernel.elf start.o gpio.o mail.o
"%PREFIX%strip" -s -x -X kernel.elf
"%PREFIX%objcopy" --output-target binary kernel.elf kernel.img
