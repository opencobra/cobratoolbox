#!/bin/bash
echo "Current working directory: $(pwd)"
echo "Location of convert_files.m: $(pwd)/convert_files.m"
"/usr/local/MATLAB/R2020a/bin/matlab" -batch "addpath('.'); convert_files"



