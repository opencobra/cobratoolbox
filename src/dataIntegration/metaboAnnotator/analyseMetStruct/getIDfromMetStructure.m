function [VMH2IDmappingAll, VMH2IDmappingPresent, VMH2IDmappingMissing] = getIDfromMetStructure(metabolite_structure, idName)
% Retrieves a specified identifier for all metabolites in a metabolite structure
%
% Retrieves the requested identifier (`idName`) for every metabolite in the
% metabolite structure and returns the VMH-to-identifier mappings, split into
% all metabolites, those with a present identifier, and those with a missing
% (NaN) identifier.
%
% USAGE:
%
%    [VMH2IDmappingAll, VMH2IDmappingPresent, VMH2IDmappingMissing] = getIDfromMetStructure(metabolite_structure, idName)
%
% INPUTS:
%    metabolite_structure:    metabolite structure containing metabolite-related
%                             information and identifiers
%    idName:                  name of the identifier, as used in the metabolite
%                             structure, to be retrieved (e.g. 'pubChemId')
%
% OUTPUTS:
%    VMH2IDmappingAll:        mapping of all VMH metabolites present in the
%                             metabolite structure (including NaNs)
%    VMH2IDmappingPresent:    mapping of all VMH metabolites present in the
%                             metabolite structure (excluding NaNs)
%    VMH2IDmappingMissing:    abbreviations of metabolites whose identifier is
%                             NaN in the metabolite structure
%
% .. Author: - Ines Thiele, Aug 2020


Mets = fieldnames(metabolite_structure);
a = 1;
b = 1;
c = 1;
VMH2IDmappingAll = '';
VMH2IDmappingPresent = '';
VMH2IDmappingMissing = '';
for i = 1 : length(Mets)
    if length(find(isnan(metabolite_structure.(Mets{i}).(idName)))) == 0
        VMH2IDmappingPresent{b,1} =Mets{i};
        if isstr(metabolite_structure.(Mets{i}).(idName))
            id = (metabolite_structure.(Mets{i}).(idName));
        else
            id = num2str(metabolite_structure.(Mets{i}).(idName));
        end
        VMH2IDmappingPresent{b,2} = id;
        VMH2IDmappingPresent{b,3} = metabolite_structure.(Mets{i}).VMHId;
        if isfield(metabolite_structure.(Mets{i}),'metNames')
            VMH2IDmappingPresent{b,4} = metabolite_structure.(Mets{i}).metNames;
        else
            VMH2IDmappingPresent{b,4} = metabolite_structure.(Mets{i}).rxnNames;
        end
        b = b + 1;
    elseif isnan(metabolite_structure.(Mets{i}).(idName))
        VMH2IDmappingMissing{c,1} =Mets{i};
        c = c + 1;
    end
    
    VMH2IDmappingAll{a,1} =Mets{i};
    if isstr(metabolite_structure.(Mets{i}).(idName))
        id = (metabolite_structure.(Mets{i}).(idName));
    else
        id = num2str(metabolite_structure.(Mets{i}).(idName));
    end
    VMH2IDmappingAll{a,2} = id;
    a = a + 1;
end
