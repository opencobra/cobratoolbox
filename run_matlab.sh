#!/bin/bash

echo "Current working directory: $(pwd)"
echo "Location of convert_files.m: $(pwd)/convert_files.m"

# Get command-line arguments
echo "MLX files: $1"

# Call MATLAB with the convert_files function and pass the mlx_files as input
"/home/aaron/Documents/Matlab/bin/matlab" -batch "addpath('.'); convert_files(strsplit('$1', ' '))"



