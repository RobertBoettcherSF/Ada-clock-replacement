# Makefile for Ada Clock Replacement Algorithms
# Uses GNAT (GNU Ada Compiler)

# Compiler settings
GNAT := gnatmake
GPRBUILD := gprbuild
GPR_FILE := clock_variants.gpr

# Directories
SRC_DIR := .
OBJ_DIR := obj
BIN_DIR := bin

# Source files
SRC_FILES := clock_algorithms.ads clock_algorithms.adb

# Compiler flags
GNAT_FLAGS := -g -O2 -gnat12 -gnata -gnatwa

# Default target
all: library

# Build the library
library: $(SRC_FILES)
	@mkdir -p $(OBJ_DIR)
	$(GNAT) -P $(GPR_FILE) $(GNAT_FLAGS)

# Build and run a test program
test: test_clock.adb
	@mkdir -p $(BIN_DIR)
	$(GNAT) -P $(GPR_FILE) test_clock.adb $(GNAT_FLAGS)
	./test_clock

# Clean build artifacts
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) *.o *.ali *.exe

# Clean everything
clobber: clean
	rm -f test_clock main

# Show available targets
help:
	@echo "Available targets:"
	@echo "  all      - Build the library (default)"
	@echo "  library  - Build the library"
	@echo "  test     - Build and run test program"
	@echo "  clean    - Remove build artifacts"
	@echo "  clobber  - Remove all build files"
	@echo ""
	@echo "Note: 'make test' requires test_clock.adb to exist"

.PHONY: all library test clean clobber help
