function [outputArg1, outputArg2] = exampl4()
% example4 calculates the gene deletion strategy for growth coupling
% for pantothenate in iML1515.
%
% Feb. 6, 2025  Takeyuki TAMURA
%

load('iML1515.mat');
model = iML1515;

[gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, 'pnto__R_c', 10, 0.1, 0.1)

end

