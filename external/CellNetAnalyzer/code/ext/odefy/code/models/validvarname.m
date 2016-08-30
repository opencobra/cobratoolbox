% VALIDVARNAME  Check whether a file name is a valid MATLAB variable name
% and return a corrected version of the variable.
%
%   [NEWNAME,ISVALID]=VALIDVARNAME(VARNAME) checks whether VARNAME is a
%   valid MATLAB variable name. NEWNAME contains a corrected variant of the
%   original name and ISVALID is a Boolean value stating whether the
%   variable name is valid.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function [varname isvalid]=validvarname(varname)

isvalid=1;

% insert x if the first column is non-letter.
if numel(regexp(varname,'^\s*+([^A-Za-z])'))
    varname = regexprep(varname,'^\s*+([^A-Za-z])','x$1', 'once');
    isvalid=0;
end

% replace invalid chars by underscore
illegalChars = unique(varname(regexp(varname,'[^A-Za-z_0-9]')));

for i=1:numel(illegalChars)
     varname = strrep(varname, illegalChars(i), '_');
end

if numel(illegalChars)
    isvalid=0;
end