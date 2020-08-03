#!/bin/bash

function help_function()
{
   echo ""
   echo "Usage: $0 (--frq=FRQ) (--vivado=VIVADO_PATH) (--prj=PRJ_PATH)"
   echo -e "\t--frq Description of what is FRQ"
   echo -e "\t--vivado Description of what is VIVADO_PATH"
   echo -e "\t--prj Description of what is PRJ_PATH"
   exit 1 # Exit script after printing help
}

while [ $# -gt 0 ]; do
  case "$1" in
    --frq=*)
      FRQ="${1#*=}"
      ;;
    --vivado=*)
      VIVADO_PATH="${1#*=}"
      ;;
    --prj=*)
      PRJ_PATH="${1#*=}"
      ;;
    *)
      help_function
  esac
  shift
done

BEFORE_FRQ=${BEFORE_FRQ:=50}
FRQ=${FRQ:=100}
VIVADO_PATH=${VIVADO_PATH:=vivado}
PRJ_PATH=${PRJ_PATH:="../nscscc2020_group_v0.01/perf_test_v0.01/soc_axi_perf/run_vivado/mycpu_prj1"}
THRESHOLD=${THRESHOLD:=0.5}
LOG_PATH="$PRJ_PATH/mycpu.runs/impl_1/runme.log"
XPR_PATH="$PRJ_PATH/mycpu.xpr"

function run_iterations {
    DIVIDE=$(echo "scale=2; 900/$FRQ" | bc)
    tmpfile=$(mktemp)
    echo "[DYNAMIC] Alter clk freq to $FRQ"
    echo "[DYNAMIC] Using temp file as tcl source: $tmpfile"
    echo "set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {$FRQ} CONFIG.MMCM_CLKOUT0_DIVIDE_F {$DIVIDE}] [get_ips clk_pll]"
    echo "exit" >> $tmpfile
    $VIVADO_PATH -mode tcl -source $tmpfile $XPR_PATH
    echo "[DYNAMIC] generate all IP"
    $VIVADO_PATH -mode tcl -source scripts/generate_all_ips.tcl $XPR_PATH
    echo "[DYNAMIC] run implementation"
    $VIVADO_PATH -mode tcl -source scripts/run_implementation.tcl $XPR_PATH | tee "$FRQ.log"
}

while :
do
    run_iterations
    WNS=${grep -oP 'Post Routing Timing Summary \| WNS=\K[^ ]+' "$FRQ.log"}
    echo "frequency:$FRQ WNS: $WNS" >> freq.log
    if  [$FRQ -lt `expr $THRESHOLD + $BEFORE_FRQ`]
    then
        break
    fi
    BEFORE_FRQ=$FRQ
    FRQ=$(echo "scale=2; 1000 / ((1000 / $FRQ) - $WNS)" | bc)
done