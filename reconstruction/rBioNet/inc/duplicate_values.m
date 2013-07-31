% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function result = duplicate_values(vector)
% result = duplicate_values(vector)
% Enter a cell vector of strings and get back a cell vector of duplicate values. 
%
% INPUT: vector - cell vector of strings (column- or row-vector)
% 
% OUTPUT: result - cell columnVector with duplicate entries.
%                - if no duplicate entries then results is empty
% 
% Stefan Gretar Thorleifsson Nov 2011. 

vector = columnVector(vector);
res = false(size(vector));
for i = 1:size(vector,1)
    if sum(strcmp(vector{i},vector)) > 1
        res(i) = true;
    end
end
result = unique(vector(res));