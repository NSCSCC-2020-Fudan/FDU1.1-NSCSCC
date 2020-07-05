`timescale 1ns/1ps

typedef struct packed {
    logic [8:0] zero_0; // [31:23], always 0
    logic Bev; // [22], always 1
    logic [5:0] zero_1; // [21:16], always 0
    logic IM7, IM6, IM5, IM4, IM3, IM2, IM1, IM0; // [15:8]
    logic [5:0] zero_2; // [7:2]
    logic EXL; // [1]
    logic IE; // [0]
} CP0_STATUS; // CP0 register 12, select 0

typedef struct packed {
    logic BD; // [31]
    logic TI; // [30]
    logic [14:0]zero_0; // [29:16], always 0
    logic [7:0]IP; // [15:8]
    logic zero_1; // [7]
    logic [4:0]ExcCode; // [6:2]
    logic zero_2; // [1:0]
} CP0_CAUSE;

typedef struct packed {
    logic [31:0] EPC; // 14
    CP0_CAUSE Cause; // 13
    CP0_STATUS Status; // 12
    logic [31:0] Compare; // 11
    logic [31:0] Count, BadVAddr; // 9, 8
} CP0_REG;


typedef struct packed {
    logic valid;
    logic [31:0]pc;
    logic [3:0]mode;
    logic [31:0]va;
    logic isbranch;
} Exception;


`def EXMODE_INT = 0
`def EXMODE_ADEL = 4
`def EXMODE_ADES = 5
`def EXMODE_OV = 4'hc
`def EXMODE_SYS = 8
`def EXMODE_BP = 9
`def EXMODE_RI = 10