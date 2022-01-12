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

% need to use v7.3 switch for very large models
if length(microbiota_model.rxns) < 300000
    save(fname, 'microbiota_model')
else
    save(fname, 'microbiota_model','-v7.3')
end

end
