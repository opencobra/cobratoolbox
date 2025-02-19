function [model2, targetRID, extype] = modelSetting(model, targetMet)
% modelSetting is a function of gDel_minRN that adds an auxiliary
% exchange reaction for the target metabolite when there is no
% original corresponding exchange reaction.
%
% function [model2,targetRID,extype] = modelSetting(model,targetMet)
%
% INPUTS
% model     COBRA model structure containing the following required fields to perform gDel_minRN.
%   rxns                    Rxns in the model
%   mets                    Metabolites in the model
%   genes               Genes in the model
%   grRules            Gene-protein-reaction relations in the model
%   S                       Stoichiometric matrix (sparse)
%   b                       RHS of Sv = b (usually zeros)
%   c                       Objective coefficients
%   lb                      Lower bounds for fluxes
%   ub                      Upper bounds for fluxes
%   rev                     Reversibility of fluxes
% targetMet   target metabolites
%                           (e.g.,  'btn_c')
%
% OUTPUTS
%  model2        the model that has the exchange reaction of the target metabolite
%  targetRID     ID of the exchange reaction of the target metabolite
%  extype          indicates that an auxiliary exchange reaction was added.
%                       1,2: there was the corresponding exchange reaction.
%                        3: An auxiliary exchange reaction was added.
%
%   Feb. 6, 2025   Takeyuki TAMURA
%

target = findMetIDs(model, targetMet);
m = size(model.mets, 1);
n = size(model.rxns, 1);
if isempty(find(strcmp(model.rxns, strcat('EX_',targetMet))))==0
    targetRID = find(strcmp(model.rxns, strcat('EX_',targetMet)));
    model2 = model;
    extype = 1;
elseif isempty(find(strcmp(model.rxns, strcat('DM_',targetMet))))==0
    targetRID = find(strcmp(model.rxns, strcat('DM_',targetMet)));
    model2 = model;
    extype = 2;
else
    [model2, rxnIDexists] = addReaction(model, 'Transport', {targetMet}, [-1]);
    m = size(model2.mets, 1);
    n = size(model2.rxns, 1);
    model2.S(target, n) = -1;
    model2.ub(n) = 999999;
    model2.lb(n) = 0;
    model2.rev(n) = 0;
    targetRID = n;
    extype = 3;
end
end

