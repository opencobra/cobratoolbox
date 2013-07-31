% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function output = rBioNet_search(type, column, str, exact)
% Purpose:  Perform simple searches in rBioNet tables.
%
% INPUT:    Table or model
%           Column - number
%           String - search phrase
%           Exact match - true or false
%
% OUTPUT:   Array containing results.
%


if nargin < 3
    exact = 0;
end

output = [];
% type can be:
%   - string: 'rxn' or 'met'
%   - cell array containing a model
if isa(type,'cell')
   data = type;
elseif strcmp(type,'rxn') || strcmp(type,'met')
    %Search reactions or metabolite
    data = rBioNetSaveLoad('load',type);

else
    %Should never enter this part.
    msgbox('Variable type incorrect in rBioNet_search','Error','error');
    return;
end

A = false(1,size(data,1));
if exact == 1 %Exact match
    for i = 1:size(data,1)
        if isempty(data{i,column})
            continue;
        end
        if strcmp(str,data{i,column})
            A(i) = true;
        end
    end
    
else %Partial match
    for i = 1:size(data,1)
        if isempty(data{i,column})
            continue;
        else
            if ~isempty(regexpi(data{i,column},str)) || strcmp(str,data{i,column})
                A(i) = true;
            end
        end
    end
end
output = data(A,:);
end

