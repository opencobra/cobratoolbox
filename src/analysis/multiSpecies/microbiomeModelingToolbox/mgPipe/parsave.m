function parsave(fname, microbiota_model)
% Saves a model from a parfor loop - might not work in R2105b
%
% USAGE:
%
%    parsave(fname, microbiota_model)
%
% INPUTS:
%   fname:               name of file
%   microbiota_model:    name of variable
%

    save(fname, 'microbiota_model')
end
