function [OfConstraint, OfAll] = determineFluxValuesOnBoundary(model, solution)
% This function determines the number of reactions in the flux distributions that are on
% the boundaries
%
% [OfConstraint, OfAll] = determineFluxValuesOnBoundary(model, solution)
%
% INPUT
% model         Model structure
% solution      Solution structure
% 
% OUTPUT 
% OfConstraint  Fraction of flux values that are on the lower and upper bounds
%               of all constrained reactions (assuming a minimum infinity
%               of -1,000,000 and a  maximum infinity of 1,000,000
% OfAll         Fraction of flux values that are on the lower and upper bounds
%               of all reactions in the model
% 
% Ines Thiele, December 2018
%
%
%
minInf = -1000000;
maxInf = 1000000;
% find reactions that have flux values on upper bound 
I = find(abs(solution.full)>1e-6);
% find all non-zero and non-inf bounds
J = find(abs(model.ub)~=0);
Ji = find(abs(model.ub)<=abs(minInf));
IJ = intersect(I,J);
IJ = intersect(IJ,Ji);
Usedub = model.ub(IJ);
UsedF = solution.full(IJ);
UsedR = model.rxns(IJ);
OnUB= length(find(abs(Usedub-UsedF)<1e-5));

% find reactions that have flux values on lower bound 
I = find(abs(solution.full)>1e-6);
% find all non-zero and non-inf bounds
J = find(abs(model.lb)~=0);
Ji = find(abs(model.lb)<=abs(maxInf));
IJ = intersect(I,J);
IJ = intersect(IJ,Ji);
Usedlb = model.lb(IJ);
UsedF = solution.full(IJ);
UsedR = model.rxns(IJ);
OnLB= length(find(abs(Usedlb-UsedF)<1e-5));

% constraint reactions
minConstraints = length(intersect(find(model.lb>minInf),find(model.lb)));
maxConstraints =length(intersect(find(model.ub<maxInf),find(model.ub)));
PercentageConstraintRxns_model = (minConstraints + maxConstraints)*100/length(model.ub);
%percentage of all reactions
OfAll = (OnLB+OnUB)/length(model.rxns);
OfConstraint = (OnLB+OnUB)/(minConstraints + maxConstraints);
