clear; close all; clc;

confmat = magic(3); % sample data
% plotting
plotConfMat(confmat, {'Dog', 'Cat', 'Horse'});