function group_def = getGroupVectorFromInchi(inchi, printLevel)
% USAGE:
%
%    group_def = getGroupVectorFromInchi(inchi, silent, debug)
%
% INPUTS:
%    inchi:
%    silent:
%    debug:     0: No verbose output,
%               1: Progress information only (no warnings),
%               2: Progress and warnings
%
% OUTPUT:
%    group_def:

if nargin ==1 
    printLevel = 0;
end

if isempty(inchi)
    group_def = [];
    return;
end

fullpath = which('getGroupVectorFromInchi.m');
fullpath = regexprep(fullpath,'getGroupVectorFromInchi.m','');

if 1
    inchi2gv = 'inchi2gv';
else
    inchi2gv = 'compound_groups';
end


if printLevel<=1
    cmd = ['python2 ' fullpath  inchi2gv '.py -s -i '];
else
    cmd = ['python2 ' fullpath inchi2gv '.py -i '];
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
    if printLevel>1
        fprintf('%s\n',['getGroupVectorFromInchi did not decompose: ' inchi])
    end
    group_def = [];
end
