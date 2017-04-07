function [concentrationMatrix,excRxnNames,timeVec,biomassVec,drGenes,constrainedRxns,states] = ...
    dynamicRFBA(model,substrateRxns,initConcentrations,initBiomass,timeStep,nSteps,plotRxns,exclUptakeRxns)
% Performs dynamic rFBA simulation using the static optimization approach
% 
% USAGE:
%
%    [concentrationMatrix, excRxnNames, timeVec,biomassVec, drGenes, constrainedRxns, states] = dynamicRFBA(model, substrateRxns, initConcentrations, initBiomass, timeStep, nSteps, plotRxns, exclUptakeRxns)
%
% INPUTS:
%    model:                 a regulatory COBRA model
%    substrateRxns:         list of exchange reaction names for substrates
%                           initially in the media that may change (i.e. not
%                           h2o or co2)
%    initConcentrations:    initial concentrations of substrates (in the same
%                           structure as substrateRxns)
%    initBiomass:           initial biomass
%    timeStep:              time step size
%    nSteps:                maximum number of time steps
%    plotRxns:              reactions to be plotted
%    exclUptakeRxns:        list of uptake reactions whose substrate
%                           concentrations do not change (opt, default
%                           {'EX_co2(e)', 'EX_o2(e)', 'EX_h2o(e)', 'EX_h(e)'})
%
% OUTPUTS:
%    concentrationMatrix:   matrix of extracellular metabolite concentrations
%    excRxnNames:           names of exchange reactions for the EC metabolites
%    timeVec:               vector of time points
%    biomassVec:            vector of biomass values
%    drGenes:               vector of downregulated genes
%    constrainedRxns:       vector of downregulated reactions
%    states:                vector of regulatory network states
%
% If no initial concentration is given for a substrate that has an open
% uptake in the model (i.e. model.lb < 0) the concentration is assumed to
% be high enough to not be limiting. If the uptake rate for a nutrient is
% calculated to exceed the maximum uptake rate for that nutrient specified
% in the model and the max uptake rate specified is > 0, the maximum uptake
% rate specified in the model is used instead of the calculated uptake rate.
%
% The dynamic FBA method implemented in this function is essentially
% the same as the method described in
% *[Varma, A., and B. O. Palsson. Appl. Environ. Microbiol. 60:3724 (1994)]*.
% This function does not implement the dynamic FBA using dynamic optimization approach
% described in *[Mahadevan, R. et al. Biophys J, 83:1331-1340 (2003)]*.
%
% .. Author: - Jeff Orth 9/15/08  (modified dynamicFBA by Markus Herrgard 8/22/06)

global WAITBAR_TYPE

if (nargin < 7)
    plotRxns = {'EX_glc(e)','EX_ac(e)','EX_for(e)'};
end

% Uptake reactions whose substrate concentrations do not change
if (nargin < 8)
    exclUptakeRxns = {'EX_co2(e)','EX_o2(e)','EX_h2o(e)','EX_h(e)','EX_nh4(e)','EX_pi(e)'};
end

% Find exchange rxns
excInd = findExcRxns(model,false);
excInd = excInd & ~ismember(model.rxns,exclUptakeRxns);
excRxnNames = model.rxns(excInd);

% Figure out if substrate reactions are correct
missingInd = find(~ismember(substrateRxns,excRxnNames));
if (~isempty(missingInd))
    for i = 1:length(missingInd)
        fprintf('%s\n',substrateRxns{missingInd(i)});
    end
    error('Invalid substrate uptake reaction!');
end

% Initialize concentrations
[~, substrateMatchInd] = ismember(substrateRxns,excRxnNames); 
concentrations = zeros(length(excRxnNames),1);
concentrations(substrateMatchInd) = initConcentrations;

% Deal with reactions for which there are no initial concentrations
originalBound = -model.lb(excInd);
noInitConcentration = (concentrations == 0 & originalBound > 0);
concentrations(noInitConcentration) = 1000;

biomass = initBiomass;

% Initialize bounds
uptakeBound =  concentrations/(biomass*timeStep);

% Make sure bounds are not higher than what are specified in the model
aboveOriginal = (uptakeBound > originalBound) & (originalBound > 0);
uptakeBound(aboveOriginal) = originalBound(aboveOriginal);
model.lb(excInd) = -uptakeBound;

% Initialize the regulatory network with optimizeRegModel
[FBAsols,DRgenes,constrainedRxns,cycleStart,modStates] = optimizeRegModel(model);
%find a growth solution
for i = 1:length(FBAsols)
    sol = FBAsols{i};
    if sol.f ~= 0
        break
    end
end
genes = DRgenes{i};
rxns = constrainedRxns{i};
iniState = modStates{i+cycleStart}(1:length(model.regulatoryGenes));
inputs1state = modStates{i+cycleStart}((length(model.regulatoryGenes)+1):(length(model.regulatoryGenes)+length(model.regulatoryInputs1)));
inputs2state = modStates{i+cycleStart}((length(model.regulatoryGenes)+length(model.regulatoryInputs1)+1):(length(model.regulatoryGenes)+length(model.regulatoryInputs1)+length(model.regulatoryInputs2)));
modelDR = deleteModelGenes(model,genes); % set rxns to 0

concentrationMatrix = sparse(concentrations);
biomassVec = biomass;
timeVec(1) = 0;
% regulatory states
drGenes{1} = genes;
constrainedRxns{1} = rxns;
states{1} = iniState;

noGrowthCount = 0;

showprogress(0,'Dynamic regulatory FBA analysis in progress ...');
for stepNo = 1:nSteps
    % Run FBA
    sol = optimizeCbModel(modelDR,'max',true);
    mu = sol.f;

    if (sol.stat ~= 1 | mu == 0) % end if no growth for 10 steps
        noGrowthCount = noGrowthCount+1;
        biomass = biomassVec(end); % no growth
        if noGrowthCount >= 20
            fprintf('No feasible solution - nutrients exhausted\n');
            break;
        end
    else
        uptakeFlux = sol.x(excInd);
        biomass = biomass*exp(mu*timeStep);
        % Update concentrations only if growth occurs
        concentrations = concentrations - uptakeFlux/mu*biomass*(1-exp(mu*timeStep));
        %concentrations = concentrations + uptakeFlux*biomass*timeStep;
        concentrations(concentrations <= 0) = 0;
    end

    biomassVec(end+1) = biomass;
    concentrationMatrix(:,end+1) = sparse(concentrations);

    % Update bounds for uptake reactions
    uptakeBound =  concentrations/(biomass*timeStep);
    % This is to avoid any numerical issues
    uptakeBound(uptakeBound > 1000) = 1000;
    % Figure out if the computed bounds were above the original bounds
    aboveOriginal = (uptakeBound > originalBound) & (originalBound > 0);
    % Revert to original bounds if the rate was too high
    uptakeBound(aboveOriginal) = originalBound(aboveOriginal);
    uptakeBound(abs(uptakeBound) < 1e-9) = 0;

    model.lb(excInd) = -uptakeBound;

    % get current regulatory state and downregulate reactions
    [finalState,finalInputs1States,finalInputs2States] = solveBooleanRegModel(model,states{end},inputs1state,inputs2state);
    KOgenes = {};
        for i = 1:length(model.regulatoryGenes)
            if finalState(i) == false
                KOgenes{end+1,1} = model.regulatoryGenes{i};
            end
        end
    genes = intersect(model.genes,KOgenes); % remove genes not associated with rxns
    [modelDR,he,rxns] = deleteModelGenes(model,genes); % set rxns to 0
    inputs1state = finalInputs1States;
    inputs2state = finalInputs2States; %reset inputs 1 and 2 states to current conditions

    drGenes{end+1} = genes;
    constrainedRxns{end+1} = rxns;
    states{end+1} = finalState;

    if WAITBAR_TYPE ~= 1
        fprintf('%d\t%f\n',stepNo,biomass);
    end
    showprogress(stepNo/nSteps);
    timeVec(stepNo+1) = stepNo*timeStep;
end

selNonZero = any(concentrationMatrix>0,2);
concentrationMatrix = concentrationMatrix(selNonZero,:);
excRxnNames = excRxnNames(selNonZero);
selPlot = ismember(excRxnNames,plotRxns);

% Plot concentrations as a function of time
clf
subplot(1,2,1);
plot(timeVec,biomassVec,'LineWidth',2);
axis tight
title('Biomass');
subplot(1,2,2);
plot(timeVec,concentrationMatrix(selPlot,:),'LineWidth',2);
axis tight
legend(strrep(excRxnNames(selPlot),'EX_',''));
