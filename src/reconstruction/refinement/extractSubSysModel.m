function subSysModel = extractSubSysModel(model, subSysNames)
% Creates model for one of more model subsystems
%
% USAGE:
%
%    subSysModel = extractSubSysModel(model, subSysNames)
%
% INPUTS:
%    model:          COBRA model structure
%    subSysNames:    List of subsystems to extract
%
% OUTPUT:
%    subSysModel:    COBRA model of selected subsystems
%
% .. Author: - Markus Herrgard 3/1/06

rxnList = model.rxns(ismember(model.subSystems,subSysNames));

subSysModel = extractSubNetwork(model,rxnList)
