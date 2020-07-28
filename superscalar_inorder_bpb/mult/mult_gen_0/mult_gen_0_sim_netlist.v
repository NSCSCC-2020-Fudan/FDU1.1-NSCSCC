// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Mon Jul 27 20:11:44 2020
// Host        : DESKTOP-TR4IRCO running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               D:/NCSSCC/Git/FDU1.1-MIPS/superscalar_inorder_bpb/mult/mult_gen_0/mult_gen_0_sim_netlist.v
// Design      : mult_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "mult_gen_0,mult_gen_v12_0_16,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_16,Vivado 2019.2" *) 
(* NotValidForBitStream *)
module mult_gen_0
   (CLK,
    A,
    B,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [31:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [31:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [63:0]P;

  wire [31:0]A;
  wire [31:0]B;
  wire CLK;
  wire [63:0]P;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "4" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "63" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  mult_gen_0_mult_gen_v12_0_16 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "1" *) (* C_A_WIDTH = "32" *) (* C_B_TYPE = "1" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "32" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "4" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "63" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "artix7" *) (* ORIG_REF_NAME = "mult_gen_v12_0_16" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module mult_gen_0_mult_gen_v12_0_16
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [31:0]A;
  input [31:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [63:0]P;
  output [47:0]PCASC;

  wire \<const0> ;
  wire [31:0]A;
  wire [31:0]B;
  wire CLK;
  wire [63:0]P;
  wire [47:0]PCASC;
  wire [1:0]NLW_i_mult_ZERO_DETECT_UNCONNECTED;

  assign ZERO_DETECT[1] = \<const0> ;
  assign ZERO_DETECT[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "4" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "63" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  mult_gen_0_mult_gen_v12_0_16_viv i_mult
       (.A(A),
        .B(B),
        .CE(1'b0),
        .CLK(CLK),
        .P(P),
        .PCASC(PCASC),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_i_mult_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2019.1"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
HPMPLvpmoX7LOmPj78BMT9X1rCnPz6PdhVGZQ307N9haGfAdMGVirvGR3e0Glyn2ieoWqXA6qOQL
t0xn28+h0g==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
Nxv/BnutRgdmHnLyK7kvDGjm7WGfFKW2mxQ6xUKF14zS4ziz5pSV0ueW4VqAzUyEPsErIAEuyV6F
m5KCqRBB197Q2NbZa7O7tdAqboX6tPAJzbB6u4U/MmNS1AQcSgtfj5srMbdBzDa5pR4V3HrI0MRj
0xhV1BWf725FYPP4av0=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
F5KGJgEDQsX2btdjtRUlSmNtuyodIhGXEa3/AXv1Y7qgSO8gknBfiqj5HcIaVA9b4npQpDnNcmq+
1ONAqLeLhdOm9TES+GsTAkh/lClvl89bzfqgOV33iqwQHYIHwSsWMRXT9JSUx+YWu+g6xKpT1Ycn
8BCPsq4QUJIqL6W16fheEHB/lkMgnespIWEYJJG6R6zvv2zG8GiU6cG8zHrRjdvAj8kOkhmiMvSd
YjGXJSMfjw7ojCPSUF+nb6WWhUEmoMA/6lgSVaXRm00YHSZ09k7rKTJWSXFSpTmkL2WOsQhNS0ek
jdTK2KF5K6z2YOK4zkfHgZ+fB0KJyANaLLJH/Q==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lFuQXeJ0hi7qnIKAR+37XCSOwp8bGLukonngcICceOVpL87+rxvhP5TyNJ/zXpAWDF0BaRYlGr7d
isPiUStrvUthNyOqCr4vFZyhCdY8n+Mrv3OCvLoLQSarxVXbaKbXb0tPsXJCUdXTrCt9mr5x0Nda
6DAI8FBPlFMAiqnFXnYMwlUiSlkNWUpInuNw7+1eD8kUdckEUV1PDwZ0yjpFqMokMH9oJjN6z0Yy
65D8Tqo288ZMfZQuIimjski+X6EK157XbpyuoZIuYLJ7j6oaATdintgfZpgGzVvhCZtMbx6/SJtR
efW5vLBGiGs7rPBPE2T8fosHGOvmeC9QBSj8Ww==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2019_02", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Q8VVvHzTNgU3tZr4+8ia7ylST+kbNPWskONHDOT1dTkB7cHZIAWyzXpQZPuEgk2wJq21PoqmVlG9
t08IYzkfC8vYQ2LRf2Co3SXc7p3gF2OFMC68J9Nf9D+/PXJCJy3QO4H8oO39l6bn8c56K2ARnK0R
mMIALbCWSBDGCWGQmXWZJ+xmDGs1KgTeiSW3bZRftWJ6K8l8BhMit8BLOY2Mi3jJ0WRhN8kKd6JT
D4NU1jTZT6jEtmI7Gnj/AXG6auTqDPHsVQzf+ZzBsLTfw83CFoO70xM997L5cZXlqz8fEDmxezkr
wWxPwJbJeVkRV3tUxlo2Bs2x1uVkXQeNVMI8jg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
oUeTLA0HA2uKORUHo1HidNC3lw54gxwlLUkv28qRPv1pz7AEVUbIJ7wsyu2Scju+EkC2Ivi8HbBn
jxkeqRDTAwAbAqIKnY3AdyfojN9Hb8SMLcLnpWLLCpb6E0vwA09r7uqKRZ8wYAgT9CPFvzpQ3zKt
9DTLgQ3rZtFxx2nfCug=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Fayrlym1l14Y48yZ195XboT9ZQmp/mAzUyHby3Y9qJTzDF+m6mRQ/ZbebObo8bu4VAm45JeETPx1
YI4UZNOK4IqKv0BZsAlzUfAYAmqmkmIJYbn2gWUCwXyKX5AoA4ONnlxEHxzZhqtsmEXvxwTEs25/
R7iLzeoMfmwwNHgPNQkteiR4zDlB76CYmgu6EOSUX5Nnitq1oh7qRuU8WqWN7lLfgIC6T7qNHwGD
RPze2yiP06fSG45jPrOn2fvBX9SRbUXjNtiFgmqim4anwJU46v7y3ubit/I6giZhz5PJMZfkDaFX
ag+uCMq4Q8ZEolqMBmjUjat86BdVd4Nmr0yUaA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kIpxh3qIIkWUg8aLJSPKvKhKTPFH7T8fisti5RtNaftS7xh3KDsGLYnF1lYhH2RVXgzbdaVqvtED
5QJazVo6wUFI91xgFeOR5jX+Ny5UBUX2MngsK+UZyZg5+EdtSiDtiJNtQqgjq1Rn+XQCGF3xP80n
7YvuVMbgRHCAfWrWw7ZJ7Y3raRzeIkx+koPFio7XnC+QdRJ0ItO1YtQgF4Sg1Ihr5TH8/RrNn903
kPa+anH9spo3SFCf2Ts11UXAGLdIBmOLMtEAKjjCUbtmjGSeSc0gn2q2I+xRTFcegLevlr/iuLTw
3lFndBAoW40xOiCDjWZ6Rz7J+jZhsRl3D0Bhwg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TTStJeZvQLWiHcOmUulVnzfARotq9XRms/FKZBho3eZWOofWZZVgR+YvF4rHt6gDh4uspDymt8Z6
rP1FhOEeC31tVfm2WjifP9JLpvJSzuwiWWk7+4pKT5DdvMsUP9GLajfJ36unAA7+jCDhpy4kmfYP
ghO1KjPY/FRN4L/iMtdShRy4WrPxaobzP3JbvXRPDRZo9/CFKsEta5uWMlV/+/SXBy1MNRoDwORk
oMIDd6f0We1tITbLB7NrlMZuOGOCAgVXCCBkEef1dxQ7PtoYPdAQfvTq231x834yoe6DTPxcCBW+
OD73kWN8WQdazL/2ckNaiA7kBhS9GO7gU5HLzA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qlpCf1SYROWV4EGfovZ6Z+VT3m7ZALSDCDzGRRKpXfjozJ+biXm2a7O37fWDC8X9s/9OGLqPtUY0
Nv+WawZZDGC2DE520lQN4sHyBn1PA97LTIp0IdRpnM8kTZK6Sgi9NaMBUslp0dXqztAG7uZH97PX
hqlOS7zmXmHj5aKj+AUtsPSPh7ekbsefBhQ3ySxPAA28/xejk5Hk/yqShJSrZ6wZ4IRu3i9fLYv5
orMmeCAbu45vuncB73WyicmfJJzKHgmqnipcnG3xXtgzPuNBYqaEEIiWLlITuNsSBdiqpBrSuYrE
vSRGHgjBo8IZkO46TbJT09UGnVQjkBpqxhyKqw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 42784)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
