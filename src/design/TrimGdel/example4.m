function [outputArg1, outputArg2] = exampl4()
% example4 computes a gene-deletion strategy for growth-coupled
% production of pantothenate (pnto__R_c) in the iML1515 model, using TrimGdel.
%
% USAGE:
%
%    [outputArg1, outputArg2] = exampl4()
%
% OUTPUTS:
%    outputArg1:    unused; declared by the function signature but never
%                   assigned (placeholder from the function template)
%    outputArg2:    unused; declared by the function signature but never
%                   assigned (placeholder from the function template)
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

load('iML1515.mat');
model = iML1515;

[gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, 'pnto__R_c', 10, 0.1, 0.1)

end

