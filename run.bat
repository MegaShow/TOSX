::compile
cd boot
"../bin/nasm" boot.asm -o "../bin/a.img"

::run
cd "../bin/"
"Bochs-2.6.8/bochs" -f tosx.bxrc

pause
