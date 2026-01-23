#include <assert.h>
#include <stdio.h>
#include "chunk.h"

void test_init() {
    Chunk chunk;
    initChunk(&chunk);
    assert(chunk.count == 0);
    assert(chunk.capacity == 0);
    assert(chunk.code == NULL);

    freeChunk(&chunk);
}

void test_expansion() {
    Chunk chunk;
    initChunk(&chunk);
    for (uint8_t i = 0; i < 10; i++) {
        writeChunk(&chunk, i);
    }
    assert(chunk.count == 10);
    assert(chunk.capacity == 16);

    for (uint8_t i = 0; i < 10; i++) {
        assert(chunk.code[i] == i);
    }

    freeChunk(&chunk);
}

int main(void) {
    test_init();
    test_expansion();

    printf("Test OK\n");
}
