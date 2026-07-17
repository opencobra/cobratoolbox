function [metabolite_structure, IDsAdded] = getSeed2Kegg(metabolite_structure)
% Add KEGG identifiers to the metabolite structure by mapping from the SEED id.
% The mapping parses the KBase file
% ftp://ftp.kbase.us/assets/KBase_Reference_Data/Biochemistry/compounds.xls
% (first column: seed ID, 5th column: KEGG ID), provided in /data/ as
% 'compounds.xlsx'.
%
% USAGE:
%
%    [metabolite_structure, IDsAdded] = getSeed2Kegg(metabolite_structure)
%
% INPUT:
%    metabolite_structure:    metabolite structure whose fields are VMH
%                             metabolite IDs, each holding a `seed` field
%
% OUTPUTS:
%    metabolite_structure:    metabolite structure updated with the matched
%                             KEGG identifiers
%    IDsAdded:                cell array logging the added identifiers, with the
%                             metabolite field name, the annotation type
%                             (`keggId`), and the assigned identifier per row
%
% .. Author: - Ines Thiele, 2020-2021

annotationSource = 'Seed mapping to Kegg';
annotationType = 'automatic';

Mets = fieldnames(metabolite_structure);
for i = 1 : length(Mets)
    SeedId{i,1} = Mets{i};
    SeedId{i,2} = metabolite_structure.(Mets{i}).seed;
end

a = 1;
IDsAdded = '';

[NUM,TXT,RAW]=xlsread('compounds.xlsx');
for i = 1 : size(SeedId,1)
    % no keggId exists
    if isempty(metabolite_structure.(SeedId{i,1}).keggId) || ~isempty(find(isnan(metabolite_structure.(SeedId{i,1}).keggId),1))
        match = strmatch(SeedId{i,2},RAW(:,1),'exact');
        if ~isempty(match)
            if contains(RAW(match,5),'|') % take only first kegg Id
                [RAW{match,5},rem]=strtok(RAW{match,5},'|');
            end
            if ~isempty(RAW{match,5})
                metabolite_structure.(SeedId{i,1}).keggId = RAW{match,5};
                metabolite_structure.(SeedId{i,1}).keggId_source =  [annotationSource,':',annotationType,':',datestr(now)];
                IDsAdded{a,1} = SeedId{i,1};
                IDsAdded{a,2} = 'keggId';
                IDsAdded{a,3} =  metabolite_structure.(SeedId{i,1}).keggId;
                a = a + 1;
            end
        end
    end
end
