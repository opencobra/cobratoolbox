function [outputArg1, outputArg2] = example3()
% example3 calculates the gene deletion strategy for growth coupling
% for riboflavin in iML1515.
% 
% USAGE:
%
%     function [] = example3()
% 
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

load('iML1515.mat');
model = iML1515;

[gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, 'ribflv_c', 10, 0.1, 0.1)

end

