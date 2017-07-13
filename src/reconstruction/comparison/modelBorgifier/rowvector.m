function [out] = rowvector(in)
% Transposes the input vector to a row vector if it is not
% already a row vector. Called by `verifyModel`.
%
% USAGE:
%
%    out = columnvector(in)
%
% INPUTS:
%    in:     Vector
%
% OUTPUTS:
%    out:    Column vector
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

dim = size(in) ;
if dim(1) > dim(2)
    out = in' ;
else
    out = in ;
end
