% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function outstr = mets2str(str)
%   Input is a structer of names, for example metabolites or reactions 
%   str = {'actp', 'acon-C','pep'}
%   outstr = 'act, acon-C, pep'
%   Purpose: create strings for message boxis
S = size(str);
if S(1) <= S(2)
    m = S(2);
else
    m = S(1);
end

outstr = [];

for i = 1:m
    if i == 1
        outstr = str{i};
    else
        outstr = [outstr ', ' str{i}];
    end
end

