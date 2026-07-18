function [outputArg1, outputArg2] = example5()
% example5 computes a gene-deletion strategy for growth-coupled
% production of succinate (succ_e) in the iMM904 model, using TrimGdel.
%
% USAGE:
%
%    [outputArg1, outputArg2] = example5()
%
% OUTPUTS:
%    outputArg1:    unused; declared by the function signature but never
%                   assigned (placeholder from the function template)
%    outputArg2:    unused; declared by the function signature but never
%                   assigned (placeholder from the function template)
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

load('iMM904.mat');
model = iMM904;

[gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, 'succ_e', 10, 0.1, 0.1)

end

