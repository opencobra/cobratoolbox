function group_def = getGroupVectorFromInchi(inchi, silent)
% Decompose an InChI into a group-contribution vector using the inchi2gv.py python script
%
% USAGE:
%
%    group_def = getGroupVectorFromInchi(inchi, silent)
%
% INPUT:
%    inchi:        InChI string of the metabolite to decompose
%
% OPTIONAL INPUT:
%    silent:       boolean, suppress python script warnings (default true)
%
% OUTPUT:
%    group_def:    row vector of group counts (the group-contribution vector),
%                  empty if the InChI cannot be decomposed
%
% NOTE:
%
%    Depends on the python script inchi2gv.py
 
 
if nargin < 2
    silent = true;
end

if isempty(inchi)
    group_def = [];
    return;
end

fullpath = which('getGroupVectorFromInchi.m');
fullpath = regexprep(fullpath,'getGroupVectorFromInchi.m','');

if silent
    cmd = ['python2 ' fullpath 'inchi2gv.py -s -i '];
else
    cmd = ['python2 ' fullpath 'inchi2gv.py -i '];
end

if ~ispc
    [rval, group_def] = system([cmd, '"', inchi, '"']);
else
    [rval, group_def] = system([cmd, inchi]);
end

if rval == 0 % && ~strcmp('Traceback', group_def(1:9))
    group_def = regexp(group_def,'(\d+,\s){162}\d+','match');
    if ~isempty(group_def)
        group_def = group_def{:};
        group_def = regexp(group_def, ',', 'split');
        group_def = group_def(~cellfun('isempty',group_def));
        group_def = str2double(group_def);
    else
        group_def = [];
    end
else
    fprintf('%s\n',['Warning: getGroupVectorFromInchi did not succeed for: ' inchi])
    group_def = [];
end

