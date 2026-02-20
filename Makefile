CC=gcc
CFLAGS += -Wall -Werror -Wpedantic -Wextra -g -MMD

OBJS = chunk.o memory.o debug.o value.o vm.o compiler.o scanner.o
RM = rm -f

main: $(OBJS)

%_test : %_test.o %.o test.h $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

.PHONY: clean
clean:
	$(RM) *.o
	$(RM) *.d
	$(RM) main
	$(RM) *_test

-include $(OBJS:.o=.d)
