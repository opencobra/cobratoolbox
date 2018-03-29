function [GenSubSystem]  = findSubSysGen(model)
% Lists the subsystem that a reaction occurs in encoded by a
% gene. Returns list of subsystems. If multiple reactions are associated
% with gene, subsystem of first occurance will be listed.
%
% USAGE:
%
%    [GenSubSystem]  = findSubSysGen(model)
%
% INPUT:
%    model:            COBRA model structure
%
% OUTPUT:
%    GenSubSystem:     array listing genes and subsystmes
%
% .. Author: - Ines Thiele 10/09


GenSubSystem(:,1) = model.genes;
%rxnGeneMat is a required field for this function, so if it does not exist,
%build it.
if ~isfield(model,'rxnGeneMat')
    model = buildRxnGeneMat(model);
end
for i = 1 : length(model.genes)
    tmp = find(model.rxnGeneMat(:,i));
    GenSubSystem(i,2) = model.subSystems(tmp(1));
end
