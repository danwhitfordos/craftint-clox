#include "common.h"
#include "chunk.h"
#include "debug.h"

int main(int argc, const char *argv[]) {
    Chunk chunk;
    initChunk(&chunk);

    int constantLoc = addConstant(&chunk, 123);
    writeChunk(&chunk, OP_CONSTANT, 1);
    writeChunk(&chunk, constantLoc, 1);

    constantLoc = addConstant(&chunk, 6.7);
    writeChunk(&chunk, OP_CONSTANT, 2);
    writeChunk(&chunk, constantLoc, 2);

    writeChunk(&chunk, OP_RETURN, 3);
    disassembleChunk(&chunk, "test chunk");
    
    freeChunk(&chunk);
    return 0;
}
