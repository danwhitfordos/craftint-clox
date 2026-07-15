#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "test.h"
#include "vm.h"

static char *readFile(const char *path) {
    FILE *file = fopen(path, "rb");
    if (file == NULL) {
        fprintf(stderr, "Could not open file \"%s\".\n", path);
        return NULL;
    }

    fseek(file, 0L, SEEK_END);
    size_t fileSize = ftell(file);
    rewind(file);

    char *buffer = (char *)malloc(fileSize + 1);
    if (buffer == NULL) {
        fprintf(stderr, "Not enough memory to read \"%s\".\n", path);
        fclose(file);
        return NULL;
    }

    size_t bytesRead = fread(buffer, sizeof(char), fileSize, file);
    if (bytesRead < fileSize) {
        fprintf(stderr, "Could not read file \"%s\".\n", path);
        fclose(file);
        free(buffer);
        return NULL;
    }

    buffer[bytesRead] = '\0';
    fclose(file);
    return buffer;
}

static int testFile(const char *fname, const char *expected_output) {
    // Initialize VM fresh for each test
    initVM();

    char *source = readFile(fname);
    if (source == NULL) {
        freeVM();
        return 0;
    }

    // Allocate buffer for output
    size_t buf_size = strlen(expected_output) + 64;
    char  *buf      = (char *)malloc(buf_size);
    if (buf == NULL) {
        freeVM();
        free(source);
        return 0;
    }
    memset(buf, 0, buf_size);

    // Set output to buffer
    setAllOutputToBuf(buf, buf_size);

    // Run the file
    InterpretResult result = interpret(source);

    // Flush output to ensure it's in the buffer
    if (vm.outfile != stdout && vm.outfile != stderr)
        fflush(vm.outfile);
    if (vm.errfile != vm.outfile && vm.errfile != stdout && vm.errfile != stderr)
        fflush(vm.errfile);

    // Check if output matches
    int success = (result == INTERPRET_OK && strcmp(buf, expected_output) == 0);

    if (!success) {
        printf("  Expected: %s\n", expected_output);
        printf("  Got:      %s\n", buf);
    }

    free(buf);
    free(source);
    freeVM();
    return success;
}

// Integration test definitions
static int test_hello_world(void) {
    return testFile("examples/hello_world.lox", "Hello, world!\n");
}

static int test_locals(void) { return testFile("examples/locals.lox", "10\n50\n"); }

static int test_jumping(void) {
    return testFile("examples/jumping.lox", "two plus two is four\n"
                                            "ok\n"
                                            "ok\n"
                                            "ok\n"
                                            "ok\n"
                                            "while i\n"
                                            "0\n"
                                            "while i\n"
                                            "1\n"
                                            "while i\n"
                                            "2\n"
                                            "while i\n"
                                            "3\n"
                                            "while i\n"
                                            "4\n"
                                            "for j\n"
                                            "0\n"
                                            "for j\n"
                                            "1\n"
                                            "for j\n"
                                            "2\n");
}

static int test_functions(void) {
    return testFile("examples/functions.lox", "<fn, areWeHavingItYet>\n"
                                              "Yes we are!\n"
                                              "22\n");
}

static int test_fib(void) { return testFile("examples/fib.lox", "55\n"); }

static int test_closure(void) { return testFile("examples/closures.lox", "outer\n"); }

static int test_closure_perverse(void) {
    return testFile("examples/closuresperverse.lox", "return from outer\n"
                                                     "create inner closure\n"
                                                     "value\n");
}

static int test_class_simps(void) {
    return testFile("examples/class_simps.lox", "Brioche\n"
                                                "Brioche instance\n"
                                                "3\n");
}

int main(void) {
    int passed = 0;
    int total  = 0;

    printf("===== Integration Tests =====\n");
    RUN_TEST(test_hello_world);
    RUN_TEST(test_locals);
    RUN_TEST(test_jumping);
    RUN_TEST(test_functions);
    RUN_TEST(test_fib);
    RUN_TEST(test_closure);
    RUN_TEST(test_closure_perverse);
    RUN_TEST(test_class_simps);

    printf("\n%d/%d integration tests passed\n", passed, total);
    return (passed == total) ? 0 : 1;
}
