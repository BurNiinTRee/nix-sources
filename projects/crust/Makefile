.PHONY: run clean

build: hello
	

run: hello
	./hello

clean:
	rm ./hello ./hello.o


hello.o: hello.s
	as hello.s -o hello.o

hello: hello.o
	ld hello.o -o hello
