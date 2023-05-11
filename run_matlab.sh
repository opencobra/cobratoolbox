#!/bin/bash

echo "Current working directory: $(pwd)"
echo "Location of convert_files.m: $(pwd)/convert_files.m"

# Start Xvfb on display :99
Xvfb :99 -screen 0 1024x768x24 &

# Set the DISPLAY environment variable
export DISPLAY=:99

# Call MATLAB with the convert_files function and pass the mlx_files as input
"/home/aaron/Documents/Matlab/bin/matlab" -batch "addpath('.'); convert_files(strsplit('$1', ' '))"



