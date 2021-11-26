function [metabolite_structure,IDsAdded] = removeSmilesInchiKey(metabolite_structure,removeInchiKey, removeSmiles, generateSmiles,generateInchiKey,generateMolFile)

% this function removes all smiles and InchiKeys from fields if InchiString
% exists. This is done to reduce cummulative errors. The next step will be
% to compute smiles and InchiKeys from InchiString - for this use
% [result] = convertInchiString2format(inchiString,format)


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