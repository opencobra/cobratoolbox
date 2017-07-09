% This file is published under Creative Commons BY-NC-SA.
%
% Please cite:
% Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale 
% metabolic reconstructions with modelBorgifier. Bioinformatics 
% (Oxford, England), 30(7), 1036?8. http://doi.org/10.1093/bioinformatics/btt747
%
% Correspondance:
% johntsauls@gmail.com
%
% Developed at:
% BRAIN Aktiengesellschaft
% Microbial Production Technologies Unit
% Quantitative Biology and Sequencing Platform
% Darmstaeter Str. 34-36
% 64673 Zwingenberg, Germany
% www.brain-biotech.de
%
function out = removeProblematicCharacters(in, varargin)
% Replaces all problematic characters in input string in with substitute. 
%
% USAGE:
%    out = removeProblematicCharacters(in, varargin)    
%
% INPUTS:
%    in:     String.
%    sub:    Character which to subtitute with. Default is '_'
%
% OUTPUTS:
%    out:    Newly formateed string
%
% CALLS:
%    None
%
% CALLED BY:
%    cleanTmodel
%

if isempty(in)
    out = in ;
    return
end
if isempty(varargin)
    sub = '_' ;
else
    sub = varargin{1} ;
end

probpos =  [strfind(in,' ') ...
            strfind(in,'@') ...
            strfind(in,'"') ...
            strfind(in,'�') ...
            strfind(in,'%') ...
            strfind(in,'&') ...
            strfind(in,'/') ...
            strfind(in,'(') ...
            strfind(in,')') ...
            strfind(in,'=') ...
            strfind(in,'?') ...
            strfind(in,'�') ...
            strfind(in,'!') ...
            strfind(in,'#') ...
            strfind(in,'*') ...
            strfind(in,'+') ...
            strfind(in,'-') ...
            strfind(in,'~') ...
            strfind(in,'"') ...
            strfind(in,'<') ...
            strfind(in,'>') ...
            strfind(in,',') ...
            strfind(in,';') ...
            strfind(in,'.') ...
            strfind(in,':') ...
            strfind(in,'\') ] ;
out = in ;
if isempty(sub)
    out(probpos) = [] ;
else
    if length(sub) == 1
        out(probpos) = sub ;
    else
        error('RemoveProblematicCharacters: substitute string too long')
    end
end

probpos = [strfind(out, '�') strfind(out, '�')] ;
if ~isempty(probpos) ; out = [out(1:probpos - 1) 'oe' out(probpos + 1:end)] ; end
probpos = [strfind(out, '�') strfind(out, '�')] ;
if ~isempty(probpos) ; out = [out(1:probpos - 1) 'ue' out(probpos + 1:end)] ; end
probpos = [strfind(out, '�') strfind(out, '�')] ;
if ~isempty(probpos) ; out = [out(1:probpos - 1) 'ae' out(probpos + 1:end)] ; end
probpos = strfind(out, '�') ;
if ~isempty(probpos) ; out = [out(1:probpos - 1) 'ss' out(probpos + 1:end)] ; end
probpos = strfind(out, '�') ;
if ~isempty(probpos) ; out = [out(1:probpos - 1) 'mu' out(probpos + 1:end)] ; end



