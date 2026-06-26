#ifndef clox_test_h
#define clox_test_h

#include <stdio.h>
#include <string.h>

// Test assertion macros
#define ASSERT_EQ(actual, expected) \
    do { \
        if ((actual) != (expected)) { \
            printf("  Assertion failed: expected %d, got %d\n", expected, actual); \
            return 0; \
        } \
    } while (0)

#define ASSERT_NULL(ptr) \
    do { \
        if ((ptr) != NULL) { \
            printf("  Assertion failed: expected NULL, got %p\n", (void*)(ptr)); \
            return 0; \
        } \
    } while (0)

#define ASSERT_NOT_NULL(ptr) \
    do { \
        if ((ptr) == NULL) { \
            printf("  Assertion failed: expected non-NULL\n"); \
            return 0; \
        } \
    } while (0)

#define ASSERT_STREQ(actual, expected) \
    do { \
        if (strcmp((actual), (expected)) != 0) { \
            printf("  Assertion failed: expected '%s', got '%s'\n", expected, actual); \
            return 0; \
        } \
    } while (0)

#define ASSERT_TRUE(condition) \
    do { \
        if (!(condition)) { \
            printf("  Assertion failed: condition is false\n"); \
            return 0; \
        } \
    } while (0)

#define ASSERT_FALSE(condition) \
    do { \
        if ((condition)) { \
            printf("  Assertion failed: condition is true\n"); \
            return 0; \
        } \
    } while (0)

// Test runner helper
#define RUN_TEST(name, fn) \
    do { \
        if ((fn)()) { \
            printf("PASS: %s\n", name); \
            passed++; \
        } else { \
            printf("FAIL: %s\n", name); \
        } \
        total++; \
    } while (0)

#endif