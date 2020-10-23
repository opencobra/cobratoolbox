function [model] = adjustWholeBodyRxnCoeff(model, listOrgan, listCoeff)
% [model] = adjustWholeBodyRxnCoeff(model, listOrgan, listCoeff)
%
% This function adjusts the coefficients of the whole-body biomass
% maintenance (WBM) reaction. The WBM reaction contains each organ present
% in the whole-body metabolic reconstructions. For each organ, the
% stoichiometric coefficients represent the fractional weight contribution
% of the respective organ to the whole body weight. These coefficients can
% be updated to reflect individual specific body contributions. E.g., in
% obese individuals the ratio of muscle and adipose tissue is different
% than in a normal BMI individual. Hence, they can be updated with this
% function.
%
% INPUT
% model         whole-body metabolic model
% listOrgan     List of organs, whose stoichiometric coefficient should be
%               updated
% listCoeff     List of coefficients that replace current ones in the WBM
%               reaction (order must match the order of organs in
%               ListOrgan)
%
% OUTPUT
% model         whole-body metabolic model with adjusted stoichiometric
%               coefficients in the whole-body metabolic model
%
% Ines Thiele, 2012 - 2020

wholeBodyRxn = 'Whole_body_objective_rxn';
wholeBodyRxnID = find(ismember( model.rxns, wholeBodyRxn));
if ~isfield(model,'A')
    model.A = model.S;
    removeA = 1;
else 
    removeA = 0;
end
for i = 1 :length(listOrgan)
    % find dummy reaction for organ
    organID = strmatch(strcat(listOrgan{i},'_biomass'),model.mets); 
    organID2= (find(~cellfun(@isempty,strfind(model.mets,'_dummy_objective'))));
    organID = intersect(organID,organID2);
    if ~isempty(organID)
        % set stoichiometric coefficient to new value
        model.A(organID, wholeBodyRxnID) = -listCoeff(i)*100; % as the organ fractions are given in fraction but should be incorporated as percentage in whole body objective
    end
end
model.S = model.A;
if removeA == 1
    model = rmfield(model,'A');
end
