#include "verilated.h"
#include "util.h"

int main(int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    run_tests();
    return 0;
}