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
function obj = optWeightExp(weight, highscoreVectors, lowscoreVectors, wnum, hitnum, missnum)
% optweightExp is a optimization weighting function used for weighting
% the scores comparing reactions. 
%
% USAGE:
%    obj = optWeightExp(weight, highscoreVectors, lowscoreVectors, wnum, hitnum, missnum)
%
% INPUTS:
%    weight:                Weights
%    highscoreVectors:      Logical array of hits
%    lowscoreVectors:       Loggical array of misses
%    wnum 
%    hitVec:                Number of hits. 
%    missVec:               Number of misses
%
% OUTPUTS:
%    obj:                   New weights
%
% CALLS:
%    None
%
% CALLED BY:
%    OptimalScore

obj = 1/(abs(mean((highscoreVectors.^repmat(weight(:, 2), 1, hitnum ))' * weight(:, 1)) - ...
             mean((lowscoreVectors.^repmat(weight(:, 2), 1, missnum))' * weight(:, 1))) + 1) ;
end