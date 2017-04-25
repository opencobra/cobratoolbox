function [MetConn, RxnLength] = networkTopology(model)
% Analysis of the metabolite connectivity of a metabolic model
%
% USAGE:
%
%    [MetConn, RxnLength] = NetworkTopology(model)
%
% INPUTS:
%    model:       Model structure
%
% OUTPUTS:
%    MetConn:     Vector of metabolite connectivity (how many reactions a metabolite participates in (in same order as model.mets)
%    RxnLength:   Vector of reaction participation, i.e., how many metabolites per reaction (in same order as `mode.rxns`)
%
% .. Author: - IT June 2011

[r,c]=size(model.S);

%metabolite connectivity = how often does metabolite occur in reactions
for i = 1: r
   % MetConn(i,1)=length(find(model.S(r,:)));
   MetConn(i,1)=length(find(model.S(i,:)));
end
% reaction participation -  how many metabolites are there per reaction
for i = 1: c
   % RxnLength(i,1)=length(find(model.S(:,c)));
     RxnLength(i,1)=length(find(model.S(:,i)));
end
