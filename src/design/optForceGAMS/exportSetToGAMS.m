function [] = exportSetToGAMS(set, fileName)
% This function exports the information in "set" to a .txt file which can be
% read by GAMS. "set" must be a cell array of strings. 
%
% USAGE: 
%
%         [] = exportSetToGAMS(set, fileName)
%
% INPUTS:
%    set:             Type: cell array of strings
%                     Description: cell array containing identifiers
%                     for certain set of elements (reactions,
%                     metabolites, etc)
% 
%    fileName:        Type: string
%                     Description: Name of the file in which the
%                     information will be stored. It is recomended to
%                     add the extension of the file. 
%
% OUTPUTS:
%    fileName.txt:    Type: file
%                     Description: File of name "fileName" containing 
%                     the set of elements, one for row.
%
% EXAMPLE: 
%
%    exportSetToGAMS(model.rxns, 'Reactions.txt') 
%    This, will export the list of elements in model.rxns to a file called
%    Reactions.txt
%
% .. Author: - Sebastian Mendoza, May 30th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl
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
