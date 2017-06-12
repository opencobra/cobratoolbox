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
function letterpos = charpos(instr)
% Finds the letter characters (as opposed to numeric characters) in a string
% and returns a logical array.
% 
% USAGE:
%    letterpos = charpos(instr)
%
% INPUTS:
%    instr:         String input. 
%
% OUTPUTS:
%    letterpos:     Logical array with 1's where the letters are in input. 
%
% CALLS:
%    None
%
% CALLED BY:
%    cleanTModel
%

letterpos = false(size(instr)) ;
for i = 1:length(instr)
    letterpos(i) = isnan(str2double(instr(i))) ;
end
