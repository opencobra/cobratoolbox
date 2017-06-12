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
function out = ismatlab
% ismatlab simply tests if Matlab is being used (as opposed to Octave). 
%
% USAGE:
%    out = ismatlab
%
% INPUTS:
%    None
%
% OUTPUTS:
%    out:       Boolean is true if this is Matlab. 
%
% CALLS:
%    None
%
% CALLED BY:
%    readCbTmodel

out = false ;
if ~isempty(strfind(version,'R20'))
    out = true ;
end