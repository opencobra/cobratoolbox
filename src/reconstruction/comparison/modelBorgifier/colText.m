function outHtml = colText(inText, inColor)
% Returns a HTML string with colored font. Used for GUIs.
% Called by `metCompareGUI`, `reactionCompareGUI`.
%
% USAGE:
%
%    outHtml = colText(inText, inColor)
%
% INPUTS:
%    inText:      String
%    inColor      Color to make string.
%
% OUTPUTS:
%    outHtml:     Text with formatting
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

outHtml = ['<html><font color="', ...
    inColor, ...
    '">', ...
    inText, ...
    '</font></html>'];
