function [metabolite_structure, IDsAdded] = generateInchiKeysSmilesFromInchiStrings(metabolite_structure)
% Generates missing InChI keys and SMILES strings from available InChI strings
%
% Searches the metabolite structure for entries where the InChI key or SMILES
% string is missing but the InChI string is available, and generates the
% InChI key/SMILES using Open Babel (obabel).
%
% USAGE:
%
%    [metabolite_structure, IDsAdded] = generateInchiKeysSmilesFromInchiStrings(metabolite_structure)
%
% INPUTS:
%    metabolite_structure:    Metabolite structure
%
% OUTPUTS:
%    metabolite_structure:    Updated metabolite structure
%    IDsAdded:                List of added InChI keys/SMILES strings
%
% .. Author: - Ines Thiele 01/2021

annotationSource = 'InchiString (metabolite_structure, obabel)';
annotationType = 'automatic';
verificationType = 'not verified';

Mets = fieldnames(metabolite_structure);
for i = 1 : length(Mets)
    VMHId{i,1} = Mets{i};
    if isfield(metabolite_structure.(Mets{i}),'VMHId')
        VMHId{i,2} = metabolite_structure.(Mets{i}).VMHId;
    else
        VMHId{i,2} = Mets{i};
        VMHId{i,2} =regexprep(  VMHId{i,2},'VMH_','');
        VMHId{i,2} =regexprep(  VMHId{i,2},'__','_');
    end
end
a = 1;
IDsAdded = ''; a =  1;

for i = 1 : length(Mets)
    i
    % inchiString exists for metabolite and inchiKey is missing
    if ~isempty(metabolite_structure.(Mets{i}).inchiString) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiString),1))
        if isempty(metabolite_structure.(Mets{i}).inchiKey) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1))
            format = 'inchiKey';
            [result] = convertInchiString2format(metabolite_structure.(Mets{i}).inchiString,format);
            if isempty(find(contains(result,'Error')))
                metabolite_structure.(Mets{i}).inchiKey = result;
                metabolite_structure.(Mets{i}).inchiKey_source = [annotationSource,':',annotationType,':', verificationType,':',datestr(now)];
                IDsAdded{a,1} = Mets{i};
                IDsAdded{a,2} = 'inchiKey';
                IDsAdded{a,3} = metabolite_structure.(Mets{i}).inchiKey;
                a = a + 1;
            end
        end
        if isempty(metabolite_structure.(Mets{i}).smile) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).smile),1))
            format = 'smiles';
            [result] = convertInchiString2format(metabolite_structure.(Mets{i}).inchiString,format);
            if isempty(find(contains(result,'Error')))
                metabolite_structure.(Mets{i}).smile = result;
                metabolite_structure.(Mets{i}).smile_source = [annotationSource,':',annotationType,':', verificationType,':',datestr(now)];
                IDsAdded{a,1} = Mets{i};
                IDsAdded{a,2} = 'smiles';
                IDsAdded{a,3} = metabolite_structure.(Mets{i}).smile;
                a = a + 1;
            end
        end
    end
end

[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure);
