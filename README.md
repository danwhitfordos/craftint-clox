# Craftint Clox

A C-based implementation of the Lox programming language interpreter with a bytecode VM.

## Prerequisites

- CMake 3.15 or higher
- C compiler (gcc, clang, etc.) supporting C23
- Make

## Building

```bash
cmake -B build
cmake --build build
```

The build process creates these executables in the `build/` directory:
- `clox` - The main Lox interpreter
- `test_chunk` - Chunk unit tests
- `test_scanner` - Scanner unit tests
- `test_integration` - Integration tests

## Running Tests

Run all tests using CTest:

```bash
ctest --output-on-failure --test-dir build
```

Or run an individual test executable directly:

```bash
./build/test_chunk
./build/test_scanner
./build/test_integration
```

## Running the Interpreter

### Interactive REPL

```bash
./build/clox
```

### Run a Lox script

```bash
./build/clox examples/hello_world.lox
./build/clox examples/fib.lox
```

## Cleaning

Remove build artifacts:

```bash
rm -rf build
```

Or use CMake's clean target:

```bash
cmake --build build --target clean
```
