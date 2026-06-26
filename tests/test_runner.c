#include <stdio.h>

// Forward declarations
int run_chunk_tests(void);
int run_scanner_tests(void);
int run_integration_tests(void);

int main(void)
{
    int all_passed = 1;
    
    all_passed &= run_chunk_tests();
    printf("\n");
    all_passed &= run_scanner_tests();
    printf("\n");
    all_passed &= run_integration_tests();
    
    printf("\n===== Test Summary =====\n");
    if (all_passed)
    {
        printf("All test suites passed!\n");
        return 0;
    }
    else
    {
        printf("Some test suites failed!\n");
        return 1;
    }
}
