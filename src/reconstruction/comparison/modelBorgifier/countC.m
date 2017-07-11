function cNum = countC(nowFormula)
% Finds number of carbons in a formula, if any.
% Called by `reactionCompareGUI`.
%
% USAGE:
%
%    cNum = countC(nowFormula)
%
% INPUTS:
%    nowFormula:    Current chemical formula
%
% OUTPUTS:
%    cNum:          Integer with number of carbons
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

nowFormula = regexprep(nowFormula,'/|,*','') ; % Remove alternate formulas.

% Look for C's
cNum = regexp(nowFormula,'C\d*','match') ;
if isempty(cNum)
    cNum = 0 ;
else
    if length(cNum{1}) == 1
        cNum = 1 ;
    else
        cNum = str2double(cNum{1}(2:end)) ;
    end
end
