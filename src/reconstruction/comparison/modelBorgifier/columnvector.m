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
function out = columnvector(in)
% Columnvector transposes the input vector to a column vector if it is not
% already a column vector.
%
% USAGE:
%    out = columnvector(in)
%
% INPUTS:
%    in:     Vector
%
% OUTPUTS:
%    out:    Column vector
%
% CALLS:
%    None
%
% CALLED BY:
%    None

dim = size(in) ;
if dim(1) < dim(2)
    out = in' ;
else
    out = in ;
end
