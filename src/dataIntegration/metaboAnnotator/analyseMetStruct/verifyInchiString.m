function [metabolite_structure,IDsSuggested] = verifyInchiString(metabolite_structure)
%% function [metabolite_structure] = verifyInchiString(metabolite_structure)
% This function verifies whether the inchiString and the formula/charge
% match for the entries in the metabolite_structure. If the inchiString is
% neutral but the chargedFormula is not neutral, only a note to the
% inchiString_source will be added. If the inchiString does not match or
% represents a different charge (not neutral and not overlapping with the
% metabolite charge), the inchiString will be removed from the
% metabolite_structure and added to a IDsSuggested list.
%
% Ines Thiele 2020/2021

verificationType0 = 'not verified';
verificationType1 = 'verified by formula and charge comparison';
verificationType2 = 'verified by formula but inchiString is neutral ';


Mets = fieldnames(metabolite_structure);
fields = fieldnames(metabolite_structure.(Mets{1}));
b = 1;IDsSuggested =[];
for i = 1 : size(Mets,1)
    % COBRA toolbox implementation
    if ~isempty(metabolite_structure.(Mets{i}).inchiString) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiString),1))
        i
        anno = split(metabolite_structure.(Mets{i}).inchiString_source,':');
        try
        [formula, nH, charge] = getFormulaAndChargeFromInChI(metabolite_structure.(Mets{i}).inchiString);
        if strcmp(metabolite_structure.(Mets{i}).chargedFormula,formula) &&   metabolite_structure.(Mets{i}).charge==charge
            metabolite_structure.(Mets{i}).inchiString_source = [anno{1},':',anno{2},':',verificationType1,':',datestr(now)];
        elseif strcmp(metabolite_structure.(Mets{i}).chargedFormula,formula) &&   charge == 0
            metabolite_structure.(Mets{i}).inchiString_source = [anno{1},':',anno{2},':',verificationType2,':',datestr(now)];
        else
            IDsSuggested{b,1} = Mets{i};
            IDsSuggested{b,2} =  [metabolite_structure.(Mets{i}).chargedFormula,',',num2str(metabolite_structure.(Mets{i}).charge)];
            IDsSuggested{b,3} = ['inchiString: ',metabolite_structure.(Mets{i}).inchiString];
            IDsSuggested{b,4} = metabolite_structure.(Mets{i}).inchiString;
            IDsSuggested{b,5} = ['suggested based on ',anno{1},' but chargedFormula:',formula,' and/or charge:',num2str(charge),' do not agree'];
            b = b + 1;
            metabolite_structure.(Mets{i}).inchiString = '';
            metabolite_structure.(Mets{i}).inchiString_source = [];
        end
        catch % wrong inchiString
             IDsSuggested{b,1} = Mets{i};
            IDsSuggested{b,2} =  [metabolite_structure.(Mets{i}).chargedFormula,',',num2str(metabolite_structure.(Mets{i}).charge)];
            IDsSuggested{b,3} = ['inchiString: ', metabolite_structure.(Mets{i}).inchiString];
            IDsSuggested{b,4} = metabolite_structure.(Mets{i}).inchiString;
            IDsSuggested{b,5} = ['suggested based on ',anno{1},' but inchiString seems to be wrong'];
            b = b + 1;
            metabolite_structure.(Mets{i}).inchiString = '';
            metabolite_structure.(Mets{i}).inchiString_source = [];
        end
    end
end