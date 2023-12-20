CFLAGS=-Itr/traceroute/ -Itr/libsupp
all: test
	./test
test: tr/traceroute/extension.o traceroute_test.o
	gcc -o test tr/traceroute/extension.o traceroute_test.o
clean:
	rm -f test tr/traceroute/extension.o traceroute_test.o

