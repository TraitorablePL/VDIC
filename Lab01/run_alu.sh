#!/bin/bash

source /cad/env/cadence_path.XCELIUM1909

xrun -f alu_tb.f \
-linedebug \
-debug
