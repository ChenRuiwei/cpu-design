#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/media/gamedisk/Xilinx/SDK/2018.3/bin:/media/gamedisk/Xilinx/Vivado/2018.3/ids_lite/ISE/bin/lin64:/media/gamedisk/Xilinx/Vivado/2018.3/bin
else
  PATH=/media/gamedisk/Xilinx/SDK/2018.3/bin:/media/gamedisk/Xilinx/Vivado/2018.3/ids_lite/ISE/bin/lin64:/media/gamedisk/Xilinx/Vivado/2018.3/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/media/gamedisk/Xilinx/Vivado/2018.3/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/media/gamedisk/Xilinx/Vivado/2018.3/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/crw/Code/cpu/lab2-single-cycle-cpu/proj_single_cycle/proj_single_cycle.runs/DRAM_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log DRAM.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source DRAM.tcl
