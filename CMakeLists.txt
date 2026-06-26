cmake_minimum_required(VERSION 3.15)
project(craftint-clox C)

# Set C standard
set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Add POSIX features for fmemopen
add_compile_definitions(_POSIX_C_SOURCE=200809L)

# Include directories
include_directories(src)

# Source files for the main application (excluding test files)
set(CORE_SOURCES
    src/chunk.c
    src/compiler.c
    src/debug.c
    src/memory.c
    src/object.c
    src/scanner.c
    src/table.c
    src/value.c
    src/vm.c
)

# Main executable (clox)
add_executable(clox src/main.c ${CORE_SOURCES})

# Test executable
enable_testing()

set(TEST_SOURCES
    ${CORE_SOURCES}
    tests/test_runner.c
    tests/test_chunk.c
    tests/test_scanner.c
    tests/test_integration.c
)

add_executable(test-runner ${TEST_SOURCES})
target_include_directories(test-runner PRIVATE src tests)

# Register the test executable with CTest
add_test(NAME all_tests COMMAND test-runner)
# Set working directory for tests so relative paths work
set_tests_properties(all_tests PROPERTIES WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
