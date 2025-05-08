function [] = example1()
% example1 calculates the gene deletion strategy for growth coupling
% for succinate in e_coli_core.
%
% USAGE:
%
%     function [] = example1()
%
% .. Author:    - Takeyuki Tamura, Mar 05, 2025
%


load('e_coli_core.mat');
model = e_coli_core;

[gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, 'succ_e', 10, 0.1, 0.1)

end

