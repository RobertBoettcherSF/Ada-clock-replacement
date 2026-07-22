# Ada Clock Replacement Algorithms

Ada implementation of various Clock page replacement algorithms for operating systems and memory management research.

## Algorithms Implemented

1. **Standard Clock (Second-Chance)** - Basic clock algorithm with reference bits
2. **GCLOCK (Generalized Clock)** - Uses counters instead of boolean reference bits
3. **WSClock (Working Set Clock)** - Adds virtual time and aging parameter (Tau)
4. **CAR (Clock with Adaptive Replacement)** - Uses two lists and two history caches
5. **Clock-Pro** - Maintains Hot, Cold, and Test page categories

## Project Structure

```
Ada-clock-replacement/
├── clock_algorithms.ads    # Algorithm specifications
├── clock_algorithms.adb    # Algorithm implementations
├── clock_variants.gpr       # GNAT project file
├── Makefile                 # Build system
├── run_tests.adb            # Main test runner
├── test_clock.adb           # Simple test program
├── tests/
│   ├── clock_tests.ads      # Test framework specification
│   └── clock_tests.adb      # Test implementations (15 tests)
├── obj/                     # Object files directory
├── bin/                     # Binary files directory
└── README.md
```

## Quick Start

### Prerequisites

- GNAT (GNU Ada Compiler) - Install with:
  - Ubuntu/Debian: `sudo apt-get install gnat`
  - Fedora: `sudo dnf install gnat`
  - macOS: `brew install gnat`

### Building

```bash
# Build the library
make

# Build and run all tests (15 comprehensive tests)
make tests

# Build and run simple test
make test

# Clean build artifacts
make clean

# Full clean (including executables)
make clobber
```

### Running Tests

The test suite includes **15 comprehensive tests** that verify:

#### Standard Clock Tests (5 tests)
1. **Clock_Empty_Access** - Empty access sequence should have 0 faults
2. **Clock_Single_Page** - Repeated access to same page should have 1 fault
3. **Clock_Page_Faults** - Standard reference string should have 7 faults
4. **Clock_Hit_Rate** - All pages in cache should have high hit rate
5. **Clock_Circular_Replacement** - Clock should replace pages in circular fashion

#### GCLOCK Tests (5 tests)
6. **GCLOCK_Empty_Access** - Empty access sequence should have 0 faults
7. **GCLOCK_Single_Page** - Repeated access to same page should have 1 fault
8. **GCLOCK_Page_Faults** - GCLOCK should have different fault count than Clock
9. **GCLOCK_Counter_Decrement** - Accessing a page should reset its counter
10. **GCLOCK_Higher_Count_Survival** - Pages with higher Max_Count should survive longer

#### WSClock Tests (3 tests)
11. **WSClock_Empty_Access** - Empty access sequence should have 0 faults
12. **WSClock_Recent_Access_Protection** - Recently accessed pages should not be evicted
13. **WSClock_Tau_Expiration** - Pages older than Tau should be evictable

#### Comparison Tests (2 tests)
14. **Clock_vs_GCLOCK** - Clock and GCLOCK should have different fault counts
15. **All_Algorithms_Same_Input** - All algorithms should produce different results for same input

## Test Assumptions Being Verified

### Assumptions About Clock Algorithm
1. **A1**: Clock algorithm correctly counts page faults
   - *Test*: Clock_Page_Faults verifies exact fault count for known sequence
   - *Could be proven false*: If fault count doesn't match expected value

2. **A2**: Clock algorithm implements circular replacement
   - *Test*: Clock_Circular_Replacement verifies all accesses are faults with overflow sequence
   - *Could be proven false*: If replacement isn't circular

3. **A3**: Clock algorithm correctly calculates hit rate
   - *Test*: Clock_Hit_Rate verifies hit rate calculation
   - *Could be proven false*: If hit rate doesn't match expected percentage

### Assumptions About GCLOCK Algorithm
4. **A4**: GCLOCK with higher Max_Count gives pages more chances
   - *Test*: GCLOCK_Higher_Count_Survival verifies pages survive longer
   - *Could be proven false*: If pages are evicted too early

5. **A5**: GCLOCK counter decrements on each pass
   - *Test*: GCLOCK_Counter_Decrement verifies counter behavior
   - *Could be proven false*: If counter doesn't decrement correctly

6. **A6**: GCLOCK behaves differently from standard Clock
   - *Test*: Clock_vs_GCLOCK verifies different fault counts
   - *Could be proven false*: If both produce same results

### Assumptions About WSClock Algorithm
7. **A7**: WSClock protects recently accessed pages
   - *Test*: WSClock_Recent_Access_Protection verifies page protection
   - *Could be proven false*: If recently accessed pages are evicted

8. **A8**: WSClock respects Tau parameter
   - *Test*: WSClock_Tau_Expiration verifies Tau-based expiration
   - *Could be proven false*: If pages aren't evicted when older than Tau

### Cross-Algorithm Assumptions
9. **A9**: All algorithms handle empty access correctly
   - *Test*: All *Empty_Access tests verify 0 faults for no accesses
   - *Could be proven false*: If any algorithm reports faults with no accesses

10. **A10**: All algorithms handle single page correctly
    - *Test*: All *Single_Page tests verify 1 fault for repeated single page
    - *Could be proven false*: If any algorithm doesn't report exactly 1 fault

11. **A11**: All algorithms produce different results for same input
    - *Test*: All_Algorithms_Same_Input verifies different behaviors
    - *Could be proven false*: If all algorithms produce identical results

## Usage Examples

### Simple Usage

```ada
with Clock_Algorithms; use Clock_Algorithms;
with Ada.Text_IO; use Ada.Text_IO;

procedure Example is
   Algo : Clock_Algo := Init_Clock(3);
   Pages : array(1..10) of Page_ID := (1, 2, 3, 4, 1, 2, 5, 1, 2, 3);
begin
   for P of Pages loop
      Access_Page(Algo, P);
   end loop;

   Put_Line("Page Faults: " & Natural'Image(Get_Page_Faults(Algo)));
   Put_Line("Hit Rate: " & Float'Image(Get_Hit_Rate(Algo)));
end Example;
```

### Comparing Algorithms

```ada
with Clock_Algorithms; use Clock_Algorithms;
with Ada.Text_IO; use Ada.Text_IO;

procedure Compare is
   Clock_Algo1 : Clock_Algo := Init_Clock(100);
   GCLOCK_Algo1 : GCLOCK_Algo := Init_GCLOCK(100, 2);
   WSClock_Algo1 : WSClock_Algo := Init_WSClock(100, 10);
   
   Pages : array(1..1000) of Page_ID := (others => 1); -- Your page sequence
begin
   for P of Pages loop
      Access_Page(Clock_Algo1, P);
      Access_Page(GCLOCK_Algo1, P);
      Access_Page(WSClock_Algo1, P);
   end loop;

   Put_Line("Clock faults: " & Natural'Image(Get_Page_Faults(Clock_Algo1)));
   Put_Line("GCLOCK faults: " & Natural'Image(Get_Page_Faults(GCLOCK_Algo1)));
   Put_Line("WSClock faults: " & Natural'Image(Get_Page_Faults(WSClock_Algo1)));
end Compare;
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make` or `make all` | Build the library |
| `make library` | Build the library only |
| `make tests` | Build and run all 15 tests |
| `make test` | Build and run simple test program |
| `make testlib` | Build test library only |
| `make clean` | Remove build artifacts (obj/, bin/, *.o, *.ali, *.exe) |
| `make clobber` | Full clean (clean + remove executables) |
| `make help` | Show available targets |

## Technical Details

### Array Implementation

The algorithms use fixed-size arrays with a maximum capacity of 1000 pages (`Max_Pages` constant). Each algorithm tracks its actual capacity separately in the `Capacity` field. This approach avoids Ada's restrictions on anonymous array types in discriminated records.

### Algorithm Parameters

- **Clock**: No additional parameters
- **GCLOCK**: `Max_Count` parameter (default: 2) - number of chances before eviction
- **WSClock**: `Tau` parameter (default: 10) - aging threshold in time units
- **CAR**: No additional parameters (adaptive)
- **Clock-Pro**: No additional parameters

## License

MIT License - See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## Acknowledgments

- Inspired by classic operating system page replacement algorithms
- Implemented in Ada 2012 for type safety and reliability
