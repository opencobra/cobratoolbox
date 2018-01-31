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
    %Biomodels specific conversions for Input of Biomodels 
    convertedstr = strrep(convertedstr,'-DASH-','-');
    convertedstr = strrep(convertedstr,'_DASH_','-');
    convertedstr = strrep(convertedstr,'_FSLASH_','/');
    convertedstr = strrep(convertedstr,'_BSLASH_','\');
    convertedstr = strrep(convertedstr,'_LPAREN_','(');
    convertedstr = strrep(convertedstr,'_LSQBKT_','[');
    convertedstr = strrep(convertedstr,'_RSQBKT_',']');
    convertedstr = strrep(convertedstr,'_RPAREN_',')');
    convertedstr = strrep(convertedstr,'_COMMA_',',');
    convertedstr = strrep(convertedstr,'_PERIOD_','.');
    convertedstr = strrep(convertedstr,'_APOS_','''');        
end

end

