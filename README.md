# crypto
Classic Cryptography in the Lua language

A small collection of programs that are implementing several classic crypto routines. A useful library ccrypt.lua included, some nice utilities and if I find time, I will add some crypto breakers, too! The programs usually are working within the Linux/Unix/Shell pipeline and expect input from stdin, output to stdout.

* bin.lua - a small binary dumper
* block.lua - prints text in blocks, fist argument is the blocksize, the second the linelength
* caesar.lua - does a caesar code, argument is the shift
* ccrypt.lua - the "classic crypt" library with many useful functions
* count.lua - does a simple character or bi- trigram-count, argument is the length of the ngrams
* dec2bin.lua - single decimal number to binary converter (in UTF8 codes), you can determine the bitlength and codes, I also put that routine into ccrypt.lua
* engigma.lua - hopefully a complete implementation of the Enigma algorithm, as far as I could test it
* engigma_{}.txt - some Enigma encoded original texts for control purposes from second world war
* lower.lua - transfer to lowercase letters
* playfair.lua - implements the Playfair crypto algorithm
* shuffle.lua - shuffles a text in a random way, also part of ccrypt.lua
* skytale.lua - implements the Skytale algorithm, the argument determines the size of the rectangle, while it fills until dividable with random letters
* sz42.lua - implemtns the Lorenz machine chiffre, but still lacks the argument for setting the default of the rings
* trithemius.lua - implements the Trithemius algorithm, the predecessor of the Vigenére chiffre
* unrequire.lua - deletes a require from Lua symbol space, library function
* utf4.lua - transfers a text to nibble sized Unicode, while small letters are the stuff, that encodes with minimum size, usually the text is something like 60% of it's original size or less. Modern alternative for Baudot/Murray encoding and works fine to preserve bandwidth (no official UTF4 exists up to this time)
* vernam.lua - shows working of the Vernam chiffre with a pseudo random number stream
* vigenere.lua - implements the Vigenère chiffre
* the rest is just for fun

