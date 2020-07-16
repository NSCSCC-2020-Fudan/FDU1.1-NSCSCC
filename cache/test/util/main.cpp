#include "verilated.h"
#include "util.h"

int main(int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);
    run_tests();
    return 0;
}