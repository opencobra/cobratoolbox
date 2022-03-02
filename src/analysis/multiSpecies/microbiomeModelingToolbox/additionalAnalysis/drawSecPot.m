function drawSecPot(dietPath, rxnmax, startMet, levels, cutoff)
% Draws part of the community structure when maximized with the given
% reaction
%
% INPUTS:
%	dietPath          char with path of the model
%   rxnmax            char with name of the rxn that gets maximized with fastFVA
%   startMet          char with starting metabolite for visualizing
%   levels            number with levels that are connected to the starting
%                     metabolite
%   cutoff            number of fluxes that are considered for drawing,
%                     only fluxes>abs(cutoff) are considered

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

microbiota_model=load(dietPath);
modelF=fieldnames(microbiota_model);
model=microbiota_model.(modelF{1});

% parameters for fastFVA
cpxControl.PARALLELMODE = 1;
cpxControl.THREADS = 1;
cpxControl.AUXROOTTHREADS = 2;

% calculating max secretion potential
%(note: if diet constraint present max. secretion flux = max(EX_rxn[fe]) - min(EX_rxn[d]))
[minFlux, maxFlux, optsol, ret, fbasol, fvamin, fvamax]  = fastFVA(model,99.99,'max',{},rxnmax,'A',cpxControl);


% all the metabolites and reactions connected to the starting
startMetnr = find(string(model.mets) == char(startMet));

[a,b] = inorder(startMetnr, model, [], [], levels(1));

% names of the reactions that are of interest
rxoi = model.rxns(b);

%  filter reactions and fluxes that are greater than abs(cutoff)
rxngz = [];
flxgz = [];
n = length(rxoi)
for i=1:n
    progress = i/n;
    sprintf('Progress %f ', progress)
    if(abs(fvamax(find(string(model.rxns)== char(rxoi(i)), 1))) > cutoff)
        rxngz = [rxngz, rxoi(i)];
        %flxgz = [flxgz, fvamax(find(string(model.rxns)== char(rxoi(i)), 1))];
    end
end

%flxgz = flxgz';

diffmets = setdiff(model.mets, model.mets(a));
[Involved_mets, Dead_ends] = draw_by_rxn(model, rxngz, 'true', 'struc', {''}, diffmets, fvamax);


