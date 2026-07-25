function model = assignSubSystems(model, gpraFile)
% Assigns each reaction a subsystem in the model structure
%
% USAGE:
%
%    model = assignSubSystems(model, gpraFile)
%
% INPUTS:
%    model:       COBRA model structure with fields:
%
%                   * .rxns - `n x 1` reaction identifiers, matched
%                     against the reactions parsed from `gpraFile`
%                   * .subSystems - `n x 1` subsystem assignments,
%                     overwritten for every reaction (looked up from
%                     `gpraFile`, or set to `'Exchange'` if not found)
%    gpraFile:    SimPheny GPRA file
%
% OUTPUT:
%    model:       COBRA model structure with subsystem assignment
%
% .. Author: - Markus Herrgard

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
