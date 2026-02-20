#include <stdio.h>
#include <assert.h>

#include "vm.h"
#include "test.h"
#include "chunk.h"

int main() {
    initVM();
    Chunk chunk;
    initChunk(&chunk);

    int constantLoc = addConstant(&chunk, NUMBER_VAL(123));
    writeChunk(&chunk, OP_CONSTANT, 1);
    writeChunk(&chunk, constantLoc, 1);

    constantLoc = addConstant(&chunk, NUMBER_VAL(6.7));
    writeChunk(&chunk, OP_CONSTANT, 2);
    writeChunk(&chunk, constantLoc, 2);

    writeChunk(&chunk, OP_RETURN, 3);
    InterpretResult res = interpret("123 + 67");
    assert(res == INTERPRET_OK);

    freeVM();
    freeChunk(&chunk);
}
