cmake_minimum_required(VERSION 3.15)
project(craftint-clox C)

# Set C standard
set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Add POSIX features for fmemopen
add_compile_definitions(_POSIX_C_SOURCE=200809L)

# Error
if(MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Werror)
endif()

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

# Optional add definition for DEBUG_PRINT_CODE
option(DEBUG_PRINT_CODE "Enable debug printing of bytecode" OFF)
if(DEBUG_PRINT_CODE)
    target_compile_definitions(clox PRIVATE DEBUG_PRINT_CODE)
endif()

option(DEBUG_TRACE_EXECUTION "Enable debug tracing of execution" OFF)
if(DEBUG_TRACE_EXECUTION)
    target_compile_definitions(clox PRIVATE DEBUG_TRACE_EXECUTION)
endif()

option(DEBUG_STRESS_GC "Enable stress testing of garbage collector" OFF)
if(DEBUG_STRESS_GC)
    target_compile_definitions(clox PRIVATE DEBUG_STRESS_GC)
endif()

option(DEBUG_LOG_GC "Enable logging of garbage collector" OFF)
if(DEBUG_LOG_GC)
    target_compile_definitions(clox PRIVATE DEBUG_LOG_GC)
endif()

# Print these options for debugging
message(STATUS "DEBUG_PRINT_CODE: ${DEBUG_PRINT_CODE}")
message(STATUS "DEBUG_TRACE_EXECUTION: ${DEBUG_TRACE_EXECUTION}")
message(STATUS "DEBUG_STRESS_GC: ${DEBUG_STRESS_GC}")
message(STATUS "DEBUG_LOG_GC: ${DEBUG_LOG_GC}")

# Test executable
enable_testing()

add_executable(test_chunk
    ${CORE_SOURCES}
    tests/test_chunk.c
)
target_include_directories(test_chunk PRIVATE src tests)

add_executable(test_scanner
    ${CORE_SOURCES}
    tests/test_scanner.c
)
target_include_directories(test_scanner PRIVATE src tests)

add_executable(test_integration
    ${CORE_SOURCES}
    tests/test_integration.c
)
target_include_directories(test_integration PRIVATE src tests)

# Register each test executable with CTest
add_test(NAME test_chunk COMMAND test_chunk)
add_test(NAME test_scanner COMMAND test_scanner)
add_test(NAME test_integration COMMAND test_integration)

# Set working directory for tests so relative paths work
set_tests_properties(test_chunk test_scanner test_integration
    PROPERTIES WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
