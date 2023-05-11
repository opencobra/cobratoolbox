#!/bin/bash

echo "Current working directory: $(pwd)"
echo "Location of convert_files.m: $(pwd)/convert_files.m"

# Get command-line arguments
mlx_files=("$@")

# Call MATLAB with the convert_files function and pass the mlx_files as input
matlab -batch "addpath('.'); convert_files(${mlx_files})"



