CC=gcc
CFLAGS=-Wall -Werror -g

main: chunk.o memory.o debug.o value.o

%_test : %_test.o %.o memory.o value.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

