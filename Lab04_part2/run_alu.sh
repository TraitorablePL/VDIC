#!/bin/bash

source /cad/env/cadence_path.XCELIUM1909

TESTS=(Lab04_part2);

FFILE="alu_tb.f"

function main(){
  xrun_compile
  xrun_elaborate
  xrun_run_all_tests
  if [[ "$RUN_IMC" != "" ]]; then
    run_imc
  fi
}

XCELIUM_CONFIG="/cad/env/cadence_path.XCELIUM1909";
INCA="INCA_libs"
GUI=""
QUIET=""
DEBUG=""
RUN_IMC="1"

#------------------------------------------------------------------------------
# init
rm -rf $INCA      # remove previous database
rm -rf cov_work   # remove previous coverage results
cols=`tput cols`
separator=`perl -e "print \"#\" x $cols"` >> /dev/null 2>&1
which xrun >> /dev/null 2>&1
if [[ "$?" != "0" ]]; then
  echo ERROR: xrun simulator not found. Execute the command:
  echo source $XCELIUM_CONFIG
  exit -1
fi
#------------------------------------------------------------------------------
# simulator arguments
COV_ARGS=""
if [[ "$RUN_IMC" != "" ]]; then
  COV_ARGS="-coverage all -covoverwrite -covfile xrun_covfile.txt" 
fi
XRUN_ARGS="\
  -F $FFILE \
  -v93 \
  $QUIET \
  $DEBUG \
  +nowarnDSEM2009 \
  +nowarnDSEMEL \
  +nowarnCGDEFN \
  -xmlibdirname $INCA \
  $GUI \
  +overwrite \
  -nocopyright \
  $COV_ARGS \
"
#------------------------------------------------------------------------------
# PROCEDURES
#------------------------------------------------------------------------------
function xrun_info() {
  echo $separator
  echo "$*"
  echo $separator
  return 0
}
#------------------------------------------------------------------------------
function xrun_check_status() {
  status=$1
  action=$2

  if [[ "$status" != "0" ]]; then
    echo "$action failed with status $status".
    exit -1
  fi
  echo "$action finished with status 0 (PASSED)."
  return 0
}
#------------------------------------------------------------------------------
function xrun_compile() {
  xrun_info "# Compiling. Log saved to xrun_compile.log"
  xrun -compile -l xrun_compile.log $XRUN_ARGS 
  xrun_check_status $? "Compilation"
}
#------------------------------------------------------------------------------
function xrun_elaborate() {
  xrun_info "# Elaborating. Log saved to xrun_elaborate.log"
  xrun -elaborate  -l xrun_elaborate.log $XRUN_ARGS
  xrun_check_status $? "Elaboration"
}
#------------------------------------------------------------------------------
function xrun_run_all_tests() {
  COV_TEST=""
  if [[ "$GUI" != "" ]] ; then
      if [[ "$RUN_IMC" != "" ]]; then
        COV_TEST="-covtest ${TESTS[0]}"
      fi
      xrun $XRUN_ARGS \
        $COV_TEST \
        -l xrun_gui.log
  else  
    TEST_LIST=""

    for TEST in ${TESTS[@]} ; do
      TEST_LIST="$TEST_LIST $TEST"
      xrun_info "# Running test: $TEST. Log saved to xrun_test_$TEST.log"
      if [[ "$RUN_IMC" != "" ]]; then
        COV_TEST="-covtest $TEST"
      fi
      xrun $XRUN_ARGS \
        $COV_TEST \
        -l xrun_test_$TEST.log
      xrun_check_status $? "Test $TEST"
    done

    echo "# End of tests."
  fi
}
#------------------------------------------------------------------------------
function run_imc {
  xrun_info "# Running imc."
  if [[ "$GUI" == "" ]] ; then
    imc -nocopyright -batch -initcmd \
      "load -run $TEST; merge -out merged_results $TEST_LIST; exit" |& tee xrun_cov.rpt
    xrun_check_status $? "IMC MERGE"

    imc -nocopyright -batch -initcmd \
      "load -run merged_results; report -summary; exit" |& tee -a xrun_cov.rpt
    xrun_check_status $? "IMC REPORT"

    xrun_info "\
 The coverage report was saved to xrun_cov.rpt file.
 To browse the results with gui use:
   imc -load merged_results"
  fi
}

main

