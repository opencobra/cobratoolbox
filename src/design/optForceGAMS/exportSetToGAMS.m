function exportSetToGAMS(set, fileName)
%% DESCRIPTION
% This function export the information in "set" to a .txt file which can be
% read by GAMS. "set" must be a cell array of strings.
%
%% INPUTS
% set(obligatory)           Type: cell array of strings
%                           Description: cell array containing identifiers
%                           for certain set of elements (reactions,
%                           metabolites, etc)
%
% fileName(obligatory)      Type: string
%                           Description: Name of the file in which the
%                           information will be stored. It is recomended to
%                           add the extension of the file.
%
%% OUTPUTS
% fileName                  Type: file
%                           Description: File of name "fileName" containing
%                           the set of elements, one for row.

%% CODE
%input handling
if nargin > 2
    error('All inputs for the function exportSetToGAMS must be specified');
end

%write file
n_set = length(set);
f = fopen(fileName, 'w');
fprintf(f, '/\n');
for i = 1:n_set
    fprintf(f, '''%s''\n', set{i});
end
fprintf(f, '/');
fclose(f);

end
