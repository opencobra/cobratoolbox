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

findSubSystemsFromGenes(model,'onlyOneSub',true);