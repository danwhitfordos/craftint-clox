#include "chunk.h"
#include "test.h"

static int test_chunk_init(void)
{
    Chunk chunk;
    initChunk(&chunk);
    
    ASSERT_EQ(chunk.count, 0);
    ASSERT_EQ(chunk.capacity, 0);
    ASSERT_NULL(chunk.code);
    
    return 1;
}

static int test_chunk_expansion(void)
{
    Chunk chunk;
    initChunk(&chunk);
    
    for (uint8_t i = 0; i < 10; i++)
    {
        writeChunk(&chunk, i, i);
    }
    
    ASSERT_EQ(chunk.count, 10);
    ASSERT_EQ(chunk.capacity, 16);
    
    for (uint8_t i = 0; i < 10; i++)
    {
        ASSERT_EQ(chunk.code[i], i);
    }
    
    freeChunk(&chunk);
    return 1;
}

int main(void)
{
    int passed = 0;
    int total = 0;
    
    printf("===== Chunk Tests =====\n");
    RUN_TEST("test_chunk_init", test_chunk_init);
    RUN_TEST("test_chunk_expansion", test_chunk_expansion);
    
    printf("\n%d/%d chunk tests passed\n", passed, total);
    return (passed == total) ? 0 : 1;
}
