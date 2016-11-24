function subSysModel = extractSubSysModel(model,subSysNames)
%extractSubSysModel Create model for one of more model subsystems
%
% subSysModel = extractSubSysModel(model,subSysNames)
%
%INPUTS
% model         COBRA model structure
% subSysNames   List of subsystems to extract
%
%OPUTPUT
% subSysModel   COBRA model of selected subsystems
%
% Markus Herrgard 3/1/06

rxnList = model.rxns(ismember(model.subSystems,subSysNames));

subSysModel = extractSubNetwork(model,rxnList)