function [metabolite_structure, IDsAdded] = removeSmilesInchiKey(metabolite_structure, removeInchiKey, removeSmiles, generateSmiles, generateInchiKey, generateMolFile)
% Removes (and optionally regenerates) smiles and inchiKeys in a metabolite structure
%
% Removes all smiles and inchiKeys from fields where an inchiString exists, to
% reduce cumulative errors. Optionally, smiles and inchiKeys are recomputed
% from the inchiString using `convertInchiString2format`.
%
% USAGE:
%
%    [metabolite_structure, IDsAdded] = removeSmilesInchiKey(metabolite_structure, removeInchiKey, removeSmiles, generateSmiles, generateInchiKey, generateMolFile)
%
% INPUTS:
%    metabolite_structure:    metabolite structure
%    removeInchiKey:          if true, remove the inchiKey where an inchiString
%                             exists
%    removeSmiles:            if true, remove the smiles where an inchiString
%                             exists
%    generateSmiles:          if true, recompute the smiles from the inchiString
%    generateInchiKey:        if true, recompute the inchiKey from the
%                             inchiString
%    generateMolFile:         flag intended to generate a mol file for the
%                             metabolite (declared but not used in the current
%                             implementation)
%
% OUTPUTS:
%    metabolite_structure:    updated metabolite structure
%    IDsAdded:                list of smiles and inchiKeys that were added
%
% .. Author: - Ines Thiele


Mets = fieldnames(metabolite_structure);
a = 1;
IDsAdded = '';
for i = 1 : length(Mets)
    % if inchiString is not empty and not NaN
    if ~isempty(metabolite_structure.(Mets{i}).inchiString) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiString),1))
        % remove inchiKey and smiles
        if removeInchiKey
            metabolite_structure.(Mets{i}).inchiKey = NaN;
        end
        if removeSmiles
            metabolite_structure.(Mets{i}).smile = NaN;
        end
        if generateSmiles
            format = 'smiles';
            [result] = convertInchiString2format(metabolite_structure.(Mets{i}).inchiString,format);
            metabolite_structure.(Mets{i}).smile = result;
            IDsAdded{a,1} = Mets{i};
            IDsAdded{a,2} = metabolite_structure.(Mets{i}).inchiString;
            IDsAdded{a,3} = 'smile';
            IDsAdded{a,4} = metabolite_structure.(Mets{i}).smile;
            a = a + 1;
        end
        if generateInchiKey
            format = 'inchiKey';
            [result] = convertInchiString2format(metabolite_structure.(Mets{i}).inchiString,format);
            metabolite_structure.(Mets{i}).inchiKey = result;
            IDsAdded{a,1} = Mets{i};
            IDsAdded{a,2} = metabolite_structure.(Mets{i}).inchiString;
            IDsAdded{a,3} = 'inchiKey';
            IDsAdded{a,4} = metabolite_structure.(Mets{i}).inchiKey;
            a = a + 1;
        end
    end
end