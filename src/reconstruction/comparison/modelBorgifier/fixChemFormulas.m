function formulaList = fixChemFormulas(formulaList)
% Formats chemical formulas such that they do not include a
% '1' after elements that only occur once in the molecule. Only operates on
% C, H, N, O, P, S. Called by `verifyModel`, `addSEEDInfo`.
%
% USAGE:
%
%    formulaList = fixChemFormulas(formulaList)
%
% INPUTS:
%    formulaList:    Cell array of chemical formulas.
%
% OUTPUTS:
%    formulaList:    Same cell array, formated.
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

searchString = '(?<=(C|H|N|O|P|S))1(?!\d)' ; % Find 1's and replace with nothing.
formulaList = regexprep(formulaList,searchString,'') ;
