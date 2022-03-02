function parsave(fname, data)
% Saves a data variable (e.g., model) from a parfor loop - might not work in R2105b
%
% USAGE:
%
%    parsave(fname, data)
%
% INPUTS:
%   fname:   name of file
%   data:    name of variable
%

% need to use v7.3 switch for very large variables
if isstruct(data)
    if isfield(data,'rxns')
        if length(data.rxns) < 300000
            save(fname, 'data')
        else
            save(fname, 'data','-v7.3')
        end
    end
else
    save(fname, 'data')
end

end
