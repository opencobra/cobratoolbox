function [outputArg1, outputArg2] = example1()
% example1 calculates the gene deletion strategy for growth coupling
% for succinate in e_coli_core.
%
% Feb. 6, 2025  Takeyuki TAMURA
%

load('e_coli_core.mat');
model = e_coli_core;

[gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, 'succ_e', 10, 0.1, 0.1)

end

