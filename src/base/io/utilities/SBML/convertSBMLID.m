function [ convertedstr ] = convertSBMLID( str, toSBML )
%CONVERTSBMLID converts the given str to a valid SBML ID 
% USAGE:
%
%       convertedstr = convertSBMLID(str,toSBML)
%
% INPUT:
%
%       str:        The String to convert
%
% OPTIONAL INPUT:
%       toSBML:     Whether to convert to SBML format (or undo a
%                   conversion) (default true, ie convert to SBML)
%
% OUTPUT:
%
%       convertedstr:   The converted String.
%    
% .. Authors:
%       - Thomas Pfau May 2017 

if ~exist('toSBML','var')
    toSBML = true;
end
if toSBML
    
    convertedstr = regexprep(str,'([^0-9_a-zA-Z])','__${num2str($1+0)}__');
else   
    convertedstr = regexprep(str,'__([0-9]+)__','${char(str2num($1))}');
end

end

