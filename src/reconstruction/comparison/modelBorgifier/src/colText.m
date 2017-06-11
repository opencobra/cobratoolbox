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
function outHtml = colText(inText, inColor)
% return a HTML string with colored font. Used for GUIs.
%
% USAGE:
%    outHtml = colText(inText, inColor)
%
% INPUTS:
%    inText:      String
%    inColor      Color to make string. 
%
% OUTPUTS:
%    outHtml:     Text with formatting
%
% CALLS:
%    None
%
% CALLED BY:
%    metCompareGUI
%    reactionCompareGUI
%

outHtml = ['<html><font color="', ...
    inColor, ...
    '">', ...
    inText, ...
    '</font></html>'];