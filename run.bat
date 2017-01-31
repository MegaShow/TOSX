::compile
cd boot
"../bin/nasm" boot.asm -o "../bin/boot.bin"

::package
"../bin/dd" if="../bin/boot.bin" of="../bin/a.img" bs=512 count=1 conv=notrunc

::run
cd "../bin/"
"Bochs-2.6.8/bochs" -f tosx.bxrc

pause
