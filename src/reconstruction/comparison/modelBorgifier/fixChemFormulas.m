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
function formulaList = fixChemFormulas(formulaList)
% fixChemFormulas formats chemical formulas such that they do not include a
% '1' after elements that only occur once in the molecule. Only operates on
% C, H, N, O, P, S
%
% USAGE:
%    formulaList = fixChemFormulas(formulaList)
%
% INPUTS:
%    formulaList:   Cell array of chemical formulas.
%
% OUTPUTS:
%    formulaList:   Same cell array, formated.
%
% CALLS:
%    None
%
% CALLED BY:      
%    verifyModel
%    addSEEDInfo
%

%% Find 1's and replace with nothing.
searchString = '(?<=(C|H|N|O|P|S))1(?!\d)' ;
formulaList = regexprep(formulaList,searchString,'') ;




