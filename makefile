program: graph_io.o findPattern.o
	gcc -o program graph_io.o findPattern.o -m32
graph_io.o: graph_io.c
	gcc -c -m32 -fpack-struct graph_io.c -o graph_io.o
findPattern.o: findPattern.asm
	nasm -f elf32 -o findPattern.o findPattern.asm
