#!/bin/bash
# runChain.sh <label> <cobraSrc> <modelMat>   -- each stage in its own capped process
L=$1; SRC=$2; MODEL=$3; D=$(dirname $0)/$L; mkdir -p $D; R=$D/results.csv; : > $R
prev=$MODEL
run() { stage=$1; out=$2
  systemd-run --user --scope -q -p MemoryMax=24G -p MemorySwapMax=0 timeout ${STAGE_TIMEOUT:-7200} \
    matlab -sd $(dirname $(readlink -f $0)) -batch "stageRun('$stage','$SRC','$prev','$out','$R')" > $D/$stage.log 2>&1
  rc=$?; [ -f "$out" ] && prev=$out || echo "$stage,$SRC,NA,NA,NA,NA,FAILED rc=$rc" >> $R; }
run trivialDupS $D/s1.mat
run dupFR $D/s2.mat
run fluxConsistent $D/s3.mat
run leaks ""
run stoich $D/s4.mat
run feasibility ""
