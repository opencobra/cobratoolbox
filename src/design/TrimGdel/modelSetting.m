function [model2, targetRID, extype] = modelSetting(model, targetMet)
% modelSetting is a submodule of gDel_minRN that adds an auxiliary exchange
% reaction for the target metabolite when the model has no corresponding
% exchange reaction.
%
% USAGE:
%
%    [model2, targetRID, extype] = modelSetting(model, targetMet)
%
% INPUTS:
%    model:        COBRA model structure with the fields:
%
%                * .rxns - reaction identifiers (n x 1 cell array)
%                * .mets - metabolite identifiers (m x 1 cell array)
%
%    targetMet:    target metabolite identifier (e.g. 'btn_c')
%
% OUTPUTS:
%    model2:       the input model, augmented when necessary with an auxiliary
%                  exchange reaction for the target metabolite. When such a
%                  reaction is added, the function writes the fields:
%
%                    * .S - sets the target-metabolite entry of the new reaction column
%                    * .lb - lower flux bound of the new reaction (set to 0)
%                    * .ub - upper flux bound of the new reaction (set to 999999)
%                    * .rev - reversibility flag of the new reaction (set to 0)
%
%    targetRID:    reaction index of the (existing or added) exchange reaction
%                  of the target metabolite
%    extype:       type of exchange reaction used for the target metabolite:
%
%                    * 1, 2 - an existing exchange reaction was found
%                    * 3 - an auxiliary exchange reaction was added
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
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

