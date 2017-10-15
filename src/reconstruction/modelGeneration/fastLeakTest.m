function [LeakMets, modelClosed, FluxExV] = fastLeakTest(model, testRxns, demandTest)
% Tests if any metabolites in a model are leaking. A metabolite is leaking
% if the exchange reaction can carry secretion flux in the closed model (no
% uptake flux through any exchange reactions is permitted).
%
% USAGE:
%
%    [LeakMets, modelClosed, FluxExV] = fastLeakTest(model, testRxns, demandTest)
%
% INPUTS:
%    model:          Model structure
%    testRxns:       List of exchange reactions to be testetd for leaks
%    demandTest:     Optional: if 'true' is entered, demand reactions
%                    for all metabolites in the model are created
% OUTPUTS:
%    LeakMets:       List of exchange reactions for leaking metabolites
%    modelClosed:    Model strucutre that has been tested for leaks
%    FluxExV:        Flux vector for computed exchange reactions in the closed model
%
% .. Authors:
%       - IT Jan 2015
%       - description added by AH July 2017
%
if nargin<3
    demandTest = 'true';
end
tol = 1e-06;
modelClosed = model;
% find all reactions that have only one entry in S
exp = full((sum(model.S ~= 0) == 1) & (sum(model.S < 0) == 1))';
upt = full((sum(model.S ~= 0) == 1) & (sum(model.S > 0) == 1))';
count = exp | upt;
%Exporters should not be able to have a flux lower than zero
%Importers should not be able to have a flux larger than zero

modelClosed.lb(exp) = 0;
modelClosed.ub(upt) = 0;

ExR = modelClosed.rxns(find(count));

modelexchangesAbbr = unique([testRxns;ExR]);
FluxEx = [];
cnt =1;
%% test for all demand reactions is an option
if strcmp(demandTest,'true')
% add demand reactions for all metabolites in model to check for those too
% [modelClosed,rxnNames] = addDemandReaction(modelClosed,modelClosed.mets,0);
[modelClosed,rxnNames] = addDemandReaction(modelClosed,modelClosed.mets);
else
    rxnNames = '';
end
modelexchangesAbbr = unique([modelexchangesAbbr;rxnNames']);
TestRxnNum = length(modelexchangesAbbr);
FluxExV =[];
while cnt == 1
    modelClosed = changeObjective(modelClosed,modelexchangesAbbr);
    FF2=optimizeCbModel(modelClosed,'max');
    if FF2.stat == 0
        %This should not happen, but can due to constraints making the
        %problem infeasible. However this should not happen in a leak test
        %so we throw an error.
        error(['Trivial solution is not a solution of the model.\n',...
               'Check that you are not enforcing flux as Leak testing does not work with forced fluxes.']);
    elseif FF2.stat ~=1
        error(['Problems exist in the model, which lead to the trivial problem being unbounded or otherwise problematic.\n',...
               'If unbounded, one option could be to reduce the maximal upper/lower bounds to a specified value.']);
    end
   ObjValue = FF2.f;
    if FF2.f >= tol
        FluxR = modelClosed.rxns(find(abs(FF2.x)>tol));
        FluxEx = [FluxEx;intersect(modelexchangesAbbr,FluxR)];
        FluxExV = [FluxExV;FF2.x(find(ismember( modelClosed.rxns,intersect(modelexchangesAbbr,FluxR))))];
        modelexchangesAbbr = setdiff(modelexchangesAbbr, FluxEx);
    else
        cnt = 2;
    end
end

LeakMets = FluxEx;
