function [outputArg1, outputArg2] = example5()
% example5 calculates the gene deletion strategy for growth coupling
% for succinate in iMM904.
% 
% USAGE:
%
%     function [] = example5()
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

load('iMM904.mat');
model = iMM904;

[gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, 'succ_e', 10, 0.1, 0.1)

end

