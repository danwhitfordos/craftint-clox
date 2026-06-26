#include "scanner.h"
#include "test.h"

static int test_scanner_empty(void)
{
    const char *input = "";
    initScanner(input);
    Token token = scanToken();
    
    ASSERT_EQ(token.type, TOKEN_EOF);
    return 1;
}

static int test_basic_arithmetic(void)
{
    ASSERT_EQ(2 + 2, 4);
    return 1;
}

// Public interface for test runner
int run_scanner_tests(void)
{
    int passed = 0;
    int total = 0;
    
    printf("===== Scanner Tests =====\n");
    RUN_TEST("test_scanner_empty", test_scanner_empty);
    RUN_TEST("test_basic_arithmetic", test_basic_arithmetic);
    
    printf("\n%d/%d scanner tests passed\n", passed, total);
    return (passed == total);
}
