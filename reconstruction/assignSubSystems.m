function model = assignSubSystems(model,gpraFile)
%assignSubSystems Assign each reaction a subsystem in the model structure
%
% model = assignSubSystems(model,gpraFile)
%
%INPUTS
% model         COBRA model structure
% gpraFile      SimPheny GPRA file
%
%OUTPUT
% model         COBRA model structure with subsystem assignment
%
% Markus Herrgard

gpraModel = parseSimPhenyGPRA(gpraFile);

[isInList,rxnInd] = ismember(model.rxns,gpraModel.rxns);

for i = 1:length(model.rxns)
    if (isInList(i))
        model.subSystems{i} = gpraModel.subSystems{rxnInd(i)};
    else
        model.subSystems{i} = 'Exchange';
    end
end

model.subSystems = model.subSystems';