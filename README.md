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

The build process creates two executables in the `build/` directory:
- `clox` - The main Lox interpreter
- `test-runner` - The test suite (used by CTest)

## Running Tests

Run all tests using CTest:

```bash
ctest --output-on-failure --test-dir build
```

Or run the test executable directly:

```bash
./build/test-runner
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
