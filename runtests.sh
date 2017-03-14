#!/bin/sh
/mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < test/testAll.m
CODE=$?
exit $CODE
