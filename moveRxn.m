function [model] = moveRxn(model,startspot,endspot)
% The function moves a reaction from one spot in the network to another,
% useful for placing important reactions at the beginning of the network to
% easier follow certain reactions.
%
% [model] = moveRxn(model,startspot,endspot)
%
%INPUTS
% model         COBRA model structure
% startspot     The reaction number to move
% endspot       The spot where the reaction is moving to%
%
%OUTPUTS
% model         COBRA toolbox model structure with moved reaction
%
% Aarash Bordbar 09/21/09

if startspot > endspot
    option = 1;
else
    option = 0;
end

oldModel = model;

lb = oldModel.lb(startspot);
if option == 1
    model.lb(endspot+1:startspot) = oldModel.lb(endspot:startspot-1);
    model.lb(endspot) = lb;
else
    model.lb(startspot:endspot-1) = oldModel.lb(startspot+1:endspot);
    model.lb(endspot) = lb;
end

ub = oldModel.ub(startspot);
if option == 1
    model.ub(endspot+1:startspot) = oldModel.ub(endspot:startspot-1);
    model.ub(endspot) = ub;
else
    model.ub(startspot:endspot-1) = oldModel.lb(startspot+1:endspot);
    model.ub(endspot) = ub;
end

c = oldModel.c(startspot);
if option == 1
    model.c(endspot+1:startspot) = oldModel.c(endspot:startspot-1);
    model.c(endspot) = c;
else
    model.c(startspot:endspot-1) = oldModel.c(startspot+1:endspot);
    model.c(endspot) = c;
end

if isfield(model,'rxns')
    rxn = oldModel.rxns(startspot);
    if option == 1
        model.rxns(endspot+1:startspot) = oldModel.rxns(endspot:startspot-1);
        model.rxns(endspot) = rxn;
    else
        model.rxns(startspot:endspot-1) = oldModel.rxns(startspot+1:endspot);
        model.rxns(endspot) = rxn;
    end
end

if isfield(model,'rxnNames')
    rxnName = oldModel.rxnNames(startspot);
    if option == 1
        model.rxnNames(endspot+1:startspot) = oldModel.rxnNames(endspot:startspot-1);
        model.rxnNames(endspot) = rxnName;
    else
        model.rxnNames(startspot:endspot-1) = oldModel.rxnNames(startspot+1:endspot);
        model.rxnNames(endspot) = rxnName;
    end
end

if isfield(model,'subSystems')
    subSystem = oldModel.subSystems(startspot);
    if option == 1
        model.subSystems(endspot+1:startspot) = oldModel.subSystems(endspot:startspot-1);
        model.subSystems(endspot) = subSystem;
    else
        model.subSystems(startspot:endspot-1) = oldModel.subSystems(startspot+1:endspot);
        model.subSystems(endspot) = subSystem;
    end
end

if isfield(model,'rules')
    rule = oldModel.rules(startspot);
    if option == 1
        model.rules(endspot+1:startspot) = oldModel.rules(endspot:startspot-1);
        model.rules(endspot) = rule;
    else
        model.rules(startspot:endspot-1) = oldModel.rules(startspot+1:endspot);
        model.rules(endspot) = rule;
    end
end

if isfield(model,'grRules')
    grRule = oldModel.rules(startspot);
    if option == 1
        model.grRules(endspot+1:startspot) = oldModel.grRules(endspot:startspot-1);
        model.grRules(endspot) = grRule;
    else
        model.grRules(startspot:endspot-1) = oldModel.grRules(startspot+1:endspot);
        model.grRules(endspot) = grRule;
    end
end

if isfield(model,'rev')
    rev = oldModel.rev(startspot);
    if option == 1
        model.rev(endspot+1:startspot) = oldModel.rev(endspot:startspot-1);
        model.rev(endspot) = rev;
    else
        model.rev(startspot:endspot-1) = oldModel.rev(startspot+1:endspot);
        model.rev(endspot) = rev;
    end
end

if isfield(model,'S')
  rxnS = oldModel.S(:,startspot);
  if option == 1
      model.S(:,endspot+1:startspot) = oldModel.S(:,endspot:startspot-1);
      model.S(:,endspot) = rxnS;
  else
      model.S(:,startspot:endspot-1) = oldModel.S(:,startspot+1:endspot);
      model.S(:,endspot) = rxnS;
  end
end

if isfield(model,'rxnGeneMat')
  rxnGene = oldModel.rxnGeneMat(startspot,:);
  if option == 1
      model.rxnGeneMat(endspot+1:startspot,:) = oldModel.rxnGeneMat(endspot:startspot-1,:);
      model.rxnGeneMat(endspot,:) = rxnGene;
  else
      model.rxnGeneMat(startspot:endspot-1,:) = oldModel.rxnGeneMat(startspot+1:endspot,:);
      model.rxnGeneMat(endspot,:) = rxnGene;
  end
end
