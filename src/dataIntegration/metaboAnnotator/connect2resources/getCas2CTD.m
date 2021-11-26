function [metabolite_structure,IDsAdded] = getCas2CTD(metabolite_structure)
%
%
% The input file was obtained from http://ctdbase.org/reports/CTD_chemicals.csv.gz
% 1st col: ctd id, 3rd col cas

% INPUT
% metabolite_structure  metabolite structure
%
% OUTPUT
% metabolite_structure  Updated metabolite structure
%
%
% Ines Thiele, 2020-2021


[NUM,TXT,RAW]=xlsread('CTD_chemicals.xlsx');
annotationSource = 'CTD_id mapping from CasRegistry';
annotationType = 'automatic';

Mets = fieldnames(metabolite_structure);
for i = 1 : length(Mets)
    Cas{i,1} = Mets{i};
    Cas{i,2} = num2str(metabolite_structure.(Mets{i}).casRegistry);
end

% listing starts at row 28
b =1;
for i = 28 : size(RAW,1)
    casRAW{b,1} = num2str(RAW{i,3});
    casRAWList{b,1} = RAW{i,2};
    b = b+1;
end
a = 1;
IDsAdded = '';

for i = 1 : size(Cas,1)

    % no keggId exists
    if ~isempty(metabolite_structure.(Cas{i,1}).casRegistry) && isempty(find(isnan(metabolite_structure.(Cas{i,1}).casRegistry),1))
        if isempty(metabolite_structure.(Cas{i,1}).ctd) || ~isempty(find(isnan(metabolite_structure.(Cas{i,1}).ctd),1))
            match = strmatch(Cas{i,2},casRAW,'exact');
            if ~isempty(match)
                metabolite_structure.(Cas{i,1}).ctd = casRAWList{match};
                metabolite_structure.(Cas{i,1}).ctd_source =  [annotationSource,':',annotationType,':',datestr(now)];
                IDsAdded{a,1} = Cas{i,1};
                IDsAdded{a,2} = 'ctd';
                IDsAdded{a,3} =  metabolite_structure.(Cas{i}).ctd;
                a = a + 1;
            end
        end
    end
end
[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure);
