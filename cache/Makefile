.DEFAULT_GOAL := all

top := OneLineBuffer

ifeq ($(top), )
$(warning No top module specified.)
endif

SOURCE    := src
BUILD     := build
TEST      := test
UTIL      := $(TEST)/util
VERILATOR := /usr/share/verilator/include

# SystemVerilog / Verilator
SV             := verilator
SV_TOP_FILE    := $(SOURCE)/$(top).sv
SV_DIR_TREE    := $(shell find $(SOURCE) -type d)
SV_SOURCE_TREE := $(shell find $(SOURCE) -name "*.sv*")
SV_INCLUDE     := $(addprefix -I, . $(SV_DIR_TREE))
SV_PREFIX      := VTop
SV_PORTS	   := $(SOURCE)/$(top).top
SV_METAXML	   := $(BUILD)/$(top).xml
SV_METAINFO	   := $(BUILD)/$(top).meta.top
SV_WRAPPER	   := $(BUILD)/$(top)Top.sv
SV_TARGET      := $(BUILD)/$(SV_PREFIX).mk
SVFLAGS        := \
	-Wall -Wpedantic -cc \
	-Mdir $(BUILD) \
	--prefix $(SV_PREFIX) \
	$(SV_INCLUDE) -O2 --trace-fst --trace-structs

$(BUILD)/default.top:
	echo "# ports" > $@

$(SV_PORTS): $(BUILD)/default.top
	cp -n $< $@

$(SV_METAXML): $(SV_SOURCE_TREE) $(SV_TOP_FILE)
	$(SV) $(SVFLAGS) --xml-only --xml-output "$@" $(SV_TOP_FILE)

$(SV_METAINFO): $(SV_METAXML)
	python3 ./wrap.py dump $< > $@

$(SV_WRAPPER): $(SV_PORTS) $(SV_METAINFO)
	awk 1 $+ | python3 ./wrap.py parse --name="$(top)" > $@

$(SV_TARGET): $(SV_WRAPPER)
	$(SV) $(SVFLAGS) $(SV_WRAPPER)

# C++
CXX             := g++
CXX_INCLUDE     := $(addprefix -I, $(VERILATOR) $(UTIL) $(BUILD))
CXX_HEADERS     := $(shell find $(TEST) -name "*.h")
CXX_VERILATED   := $(VERILATOR)/verilated.cpp
CXX_TRACE_FST   := $(VERILATOR)/verilated_fst_c.cpp
CXX_TOP_HEADER  := $(BUILD)/$(SV_PREFIX).h
CXX_TOP_TARGET  := $(BUILD)/$(SV_PREFIX)__ALL.a
CXX_TEST_TARGET := $(BUILD)/$(top).o
CXXLIBS         := $(addprefix $(BUILD)/, main.o util.o verilated.o trace_fst.o)
CXXFLAGS        := \
	-Wall -Wextra -Wno-comment \
	-g -std=c++17 -fsanitize=undefined \
	-lz \
	$(CXX_INCLUDE)

$(CXX_TOP_HEADER): $(SV_TARGET)

$(CXX_TOP_TARGET): $(SV_TARGET)
	cd $(BUILD); make -f $(notdir $(SV_TARGET))

$(BUILD)/main.o: $(UTIL)/main.cpp $(CXX_HEADERS)
	$(CXX) $(CXXFLAGS) $< -c -o $@

$(BUILD)/util.o: $(UTIL)/util.cpp $(CXX_HEADERS)
	$(CXX) $(CXXFLAGS) $< -c -o $@

$(BUILD)/verilated.o: $(CXX_VERILATED)
	$(CXX) $(CXXFLAGS) $< -c -o $@

$(BUILD)/trace_fst.o: $(CXX_TRACE_FST)
	$(CXX) $(CXXFLAGS) $< -c -o $@

$(CXX_TEST_TARGET): $(TEST)/$(top).cpp $(CXX_HEADERS) $(CXX_TOP_HEADER)
	$(CXX) $(CXXFLAGS) $< -c -o $@

a.out: $(CXXLIBS) $(CXX_TEST_TARGET) $(CXX_TOP_TARGET)
	$(CXX) $(CXXFLAGS) $^ -o a.out

.PHONY: all run impl clean

all: a.out

run: a.out
	./a.out

impl: $(SV_TARGET)

clean:
	rm -rf build/[^.]*
