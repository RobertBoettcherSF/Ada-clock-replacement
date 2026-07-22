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

# Test files (optional)
TEST_FILES := test_clock.adb

# Main executable (if you create one)
MAIN_FILE := main.adb

# Compiler flags
GNAT_FLAGS := -g -O2 -gnat12 -gnata -gnatwa

# Default target
all: library

# Build the library
library: $(GPR_FILE) $(SRC_FILES)
	@mkdir -p $(OBJ_DIR)
	$(GNAT) -P $(GPR_FILE) $(GNAT_FLAGS)

# Build and run a test program
test: $(MAIN_FILE)
	@mkdir -p $(BIN_DIR)
	$(GNAT) -P $(GPR_FILE) $(MAIN_FILE) $(GNAT_FLAGS)
	./$(MAIN_FILE:.adb=)

# Clean build artifacts
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) *.o *.ali *.exe

# Clean everything
clobber: clean
	rm -f main test_clock

# Show available targets
help:
	@echo "Available targets:"
	@echo "  all      - Build the library (default)"
	@echo "  library  - Build the library"
	@echo "  test     - Build and run test program"
	@echo "  clean    - Remove build artifacts"
	@echo "  clobber  - Remove all build files"
	@echo ""
	@echo "To create a test program, create main.adb or test_clock.adb"

.PHONY: all library test clean clobber help
