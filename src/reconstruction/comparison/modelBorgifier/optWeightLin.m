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
function obj = optWeightLin(weight, highscoreVectors, lowscoreVectors)
% This is the objective function for the linear optimization of the weighting of 
% the individual scores. It maximizes the difference between the weighted sum of 
% scores of the correctly assigned reactions and the incorrect matches in the 
% training data set.
% USAGE:
%    obj = optWeightLin(weight, highscoreVectors, lowscoreVectors)
%
% INPUTS:
%    weight:                Weights
%    highscoreVectors:      Logical array of hits
%    lowscoreVectors:       Loggical array of misses
%
% OUTPUTS:
%    obj:                   New weights
%
% CALLS:
%    None
%
% CALLED BY:
%    OptimalScore

obj = 1/(abs(mean(highscoreVectors'*weight) - ...
             mean(lowscoreVectors'*weight))+1) ;
end
