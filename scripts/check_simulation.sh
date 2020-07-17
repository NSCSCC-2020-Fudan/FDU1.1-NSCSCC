#!/bin/bash

echo $FLAG

grep $FLAG $LOG_PATH > /dev/null

if [ $? -eq 0 ]; then
    echo "Simulation ${SIMULATION} succeeded."
else
    echo "Simulation ${SIMULATION} failed. Please check log ${LOG_PATH} for more information."
    exit 1
fi
