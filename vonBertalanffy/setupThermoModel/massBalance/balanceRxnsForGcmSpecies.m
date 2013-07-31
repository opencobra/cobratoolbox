function model = balanceRxnsForGcmSpecies(model,imBalancedBool)

% Balance reconstruction reactions for the species output by the group
% contribution method. Necessary to accurately calculate DrGt0 for
% transport reactions.
% 
% model = balanceRxnsForGcmSpecies(model,imBalancedBool)
% 
% INPUTS
% model             model structure containing the fields:
%                   .mets: m x 1 cell array of metabolite identifiers.
%                   .met: m x 1 array of structures containing thermodynamic
%                   data for each metabolite.
%                   .S: m x n stoichiometric matrix. Mass- and
%                   charge-balanced in terms of reconstruction species.
% imBalancedBool    n x 1 boolean vector. True for mass- or
%                   charge-imbalanced reactions
% 
% OUTPUT
% model.gcmS        m x n stoichiometric matrix. Mass- and charge-balanced
%                   in terms of species output by the group contribution
%                   method.

modelT = model;
imbalancedReconRxnBool = imBalancedBool;


gcmFormulas = cell(size(modelT.mets)); % Chemical formulas for species output by gcm.
gcmZ = zeros(size(modelT.mets)); % Charges of species output by gcm.

for n = 1:length(modelT.mets)
    if ~any(isnan(modelT.met(n).formulaMarvin)) && ~isnan(modelT.met(n).chargeMarvin)
        gcmFormulas{n} = modelT.met(n).formulaMarvin;
        gcmZ(n) = modelT.met(n).chargeMarvin;
    end
end

% Set up model for checking mass- and charge-balance when gcm species are
% used.
gcmModelT = modelT;
gcmModelT.metFormulas = gcmFormulas;
gcmModelT.metCharges = gcmZ;
[massImbalance,imBalancedMass,imBalancedCharge,imbalancedGcmRxnBool,Elements] = checkMassChargeBalance(gcmModelT); % Check mass- and charge-balance.

% Locate reactions where stoichiometric coefficients for protons need to be adjusted
% when reconstruction species are replaced by gcm species.
DfG0gcm = cat(1,modelT.met.dGf0GroupCont);
nanMets = isnan(DfG0gcm);
nanRxns = sum(modelT.S(nanMets,:)~=0)~=0;
nanRxns = nanRxns';
bool = imbalancedGcmRxnBool & ~imbalancedReconRxnBool & ~nanRxns & (sum(modelT.S' ~= 0, 2) > 1) & (massImbalance(:,1) == imBalancedCharge);

[compartments,uniqueCompartments]=getCompartment(modelT.mets);
noCompMets = regexprep(modelT.mets, '\[\w\]', '');

% Adjust stoichiometric coefficients for protons
for n = 1:length(modelT.rxns)
   if bool(n)
       nCompartments = length(unique(compartments(modelT.S(:,n)~=0)));
       if nCompartments == 1 % Adjust stoichiometric coefficient for proton in the compartment where the reaction takes place
           compartment = unique(compartments(modelT.S(:,n)~=0));
           compartment = compartment{:};
           gcmModelT.S(strcmp(['h[' compartment ']'],modelT.mets),n) = gcmModelT.S(strcmp(['h[' compartment ']'],modelT.mets),n) - massImbalance(n,1);
       elseif nCompartments == 2 % Adjust coefficient for proton in the compartment where the reaction-part of the active transport mechanism takes place. Passive transport reactions should not get imbalanced when reconstruction species are replaced by gcm species.
           metIdx = find(modelT.S(:,n));
           [uMets,uMetIdx] = unique(noCompMets(metIdx));
           uMetIdx = metIdx(uMetIdx);
           noTransMets = setdiff(noCompMets(metIdx),noCompMets(setdiff(metIdx,uMetIdx)));
           noTransMetIdx = ismember(noCompMets,noTransMets) & modelT.S(:,n)~=0;
           compartment = unique(compartments(noTransMetIdx));
           compartment = compartment{:};
           gcmModelT.S(strcmp(['h[' compartment ']'],modelT.mets),n) = gcmModelT.S(strcmp(['h[' compartment ']'],modelT.mets),n) - massImbalance(n,1);
       else
           error('Reaction takes place in more than two compartments')
       end
   end
end

model.gcmS = gcmModelT.S;

end

