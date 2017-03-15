function [modelRed,hasFlux,maxes,mins] = reduceModel(model,tol,irrevFlag,verbFlag,negFluxAllowedFlag,checkConsistencyFlag,changeBoundsFlag)
%reduceModel Removes from the model all of the reactions that are never used (max and
% min are < tol). Finds the minimal bounds for the flux through each reaction.
% Also returns the results for flux variability analysis (maxes, mins).
%
% [modelRed,hasFlux,maxes,mins] = reduceModel(model,tol,irrevFlag,verbFlag,negFluxAllowedFlag,checkConsistencyFlag,changeBoundsFlag)
%
%INPUT
% model                 COBRA model structure
%
%OPTIONAL INPUTS
% tol                   Tolerance for non-zero bounds - bounds smaller in absolute
%                       value than this value will be set to zero (Default = 1e-6)
% irrevFlag             Determines if the models should be treated using
%                       the irreversible form. (Default = false)
% verbFlag              Verbose output (Default = false)
% negFluxAllowedFlag    Allow negative fluxes through irrev reactions
%                       (Default = false)
% checkConsistencyFlag  Do a consistency check of the optimal solution
%                       (Default = true)
% changeBoundsFlag      Change upper/lower bounds to the minimal bounds
%                       (Default = true)
%
%OUTPUTS
% modelRed              Reduced model
% hasFlux               The indexes of the reactions that are not blocked
%                       in the model
% maxes                 Maximum fluxes
% mins                  Minimum fluxes
%
% Gregory Hannum and Markus Herrgard 7/20/05

% Sets the tolerance for zero flux determination
if nargin < 2
    global CBT_LP_PARAMS
    if (exist('CBT_LP_PARAMS', 'var'))
        if isfield(CBT_LP_PARAMS, 'objTol')
            tol = CBT_LP_PARAMS.objTol;
        else
            tol = 1e-6
        end
    else
        tol = 1e-6;
    end
end

% Sets the irrevFlag to default
if nargin < 3
    irrevFlag = false;
end

% Print out more stuff
if nargin < 4
    verbFlag = false;
end

% Allow negative irreversible fluxes (default: reverse the reaction
% direction)
if (nargin < 5)
    negFluxAllowedFlag = false;
end

% Check if the reduced model produces consistent results
if (nargin < 6)
    checkConsistencyFlag = true;
end

% Change to minimal bounds
if (nargin < 7)
    changeBoundsFlag = true;
end

%declare some variables
maxes = [];
mins = [];
%modelRed = model;
[nMets,nRxns]= size(model.S);

%obtain maxes and mins for the fluxes
rxnID = 1;
showprogress(0,'Model reduction in progress ...');
while rxnID <= nRxns
    if mod(rxnID,10) == 0
        showprogress(rxnID/nRxns);
    end
    rxnName = model.rxns{rxnID};
    if (verbFlag)
        fprintf('%s\t',rxnName);
    end

    % Set the objective function to the current reactiom
    tempModel = changeObjective(model,rxnName);

    if (irrevFlag && model.rev(rxnID))
        % Make the forward reaction reversible temporarily
        tempModel.lb(rxnID) = -tempModel.ub(rxnID+1);
        % Disable the reverse reaction
        tempModel.ub(rxnID+1) = 0;
    end

    %solve for the minimum and maximum for the current reaction
    sol = optimizeCbModel(tempModel,'max');
    if (sol.stat > 0)
        maxBound = sol.f;
    else
        maxBound = model.ub(rxnID);
    end
    sol = optimizeCbModel(tempModel,'min');
    if (sol.stat > 0)
        minBound = sol.f;
    else
        minBound = model.lb(rxnID);
    end

    %eliminate very small boundaries and set predetermined reversible boundaries
    if abs(maxBound) < tol
        maxBound = 0;
    end

    % Ignore negative lower bounds for irrev reactions
    if abs(minBound) < tol || (~negFluxAllowedFlag && minBound < 0 && ~model.rev(rxnID))
        minBound = 0;
    end

    %set the new appropriate bounds
    if (irrevFlag && model.rev(rxnID))
        if minBound < 0 && maxBound < 0 % Negative flux
            mins(rxnID) = 0;
            mins(rxnID+1) = -maxBound;
            maxes(rxnID) = 0;
            maxes(rxnID+1) = -minBound;
        elseif minBound < 0 && maxBound >= 0 % Reversible flux
            mins(rxnID:rxnID+1) = 0;
            maxes(rxnID) = maxBound;
            maxes(rxnID+1) = -minBound;
        elseif minBound >= 0 && maxBound >= 0 % Positive flux
            mins(rxnID) = minBound;
            mins(rxnID+1) = 0;
            maxes(rxnID) = maxBound;
            maxes(rxnID+1) = 0;
        end

        if (verbFlag)
            fprintf('%g\t%g\n',mins(rxnID),maxes(rxnID));
            fprintf('%s\t',model.rxns{rxnID+1});
            fprintf('%g\t%g\n',mins(rxnID+1),maxes(rxnID+1));
        end
        % Jump over the reverse direction
        rxnID = rxnID + 1;
    else
        maxes(rxnID)=maxBound;
        mins(rxnID)=minBound;
        if (verbFlag)
            fprintf('%g\t%g\n',minBound,maxBound);
        end
    end

    rxnID = rxnID + 1;
end

if (verbFlag)
    fprintf('\n');
end

% Create a list of flux indexes that have non-zero flux (hasFlux)
hasFluxSel = (abs(maxes) > tol | abs(mins) > tol);
hasFlux = find(hasFluxSel);
hasFlux = columnVector(hasFlux);

% Remove reactions that are blocked
modelRed = removeRxns(model,model.rxns(~hasFluxSel),irrevFlag,true);

% Update bounds
if (changeBoundsFlag)
    modelRed.lb = columnVector(mins(hasFlux));
    modelRed.ub = columnVector(maxes(hasFlux));
    selInconsistentBounds = (modelRed.ub < modelRed.lb);
    modelRed.ub(selInconsistentBounds) = modelRed.lb(selInconsistentBounds);
    %update the reversible list with new bounds
    nRxnsNew = size(modelRed.S,2);
    for rxnID = 1:nRxnsNew
        if (~irrevFlag)
            if (modelRed.lb(rxnID) >= 0)
                % Only runs in positive direction
                modelRed.rev(rxnID) = false;
            end
            if (modelRed.ub(rxnID) <= 0)

                % Only runs in negative direction -> reverse the reaction
                modelRed.rev(rxnID) = false;
                if (~negFluxAllowedFlag)
                    ubTmp = modelRed.ub(rxnID);
                    lbTmp = modelRed.lb(rxnID);
                    modelRed.S(:,rxnID) = -modelRed.S(:,rxnID);
                    modelRed.ub(rxnID) = -lbTmp;
                    modelRed.lb(rxnID) = -ubTmp;
                    modelRed.c(rxnID) = -modelRed.c(rxnID);
                    modelRed.rxns{rxnID} = [modelRed.rxns{rxnID} '_r'];
                end
            end
        end
    end

    if (checkConsistencyFlag)
        fprintf('Perform model consistency check\n');
        modelOK = checkConsistency(model,modelRed,tol);
        if (~modelOK)
            modelRed = expandBounds(model,modelRed,tol);
        end
    end
else
    if (checkConsistencyFlag)
        fprintf('Perform model consistency check\n');
        modelOK = checkConsistency(model,modelRed,tol);
    end
end

%%
function modelRed = expandBounds(model,modelRed,tol)
% Expand bounds to achieve the desired objective value
%
% modelRed = expandBounds(model,modelRed,tol)
%

modelOK = false;
cushion = tol;
tempModel = modelRed;
while (~modelOK)
    narrowInd = find(modelRed.ub-modelRed.lb < cushion & modelRed.ub ~= modelRed.lb);
    tempModel.lb(narrowInd) = tempModel.lb(narrowInd) - cushion;
    narrowIrrevInd =intersect(narrowInd,find(~tempModel.rev));
    tempModel.lb(narrowIrrevInd) = max(tempModel.lb(narrowIrrevInd),0);
    tempModel.ub(narrowInd) = tempModel.ub(narrowInd) + cushion;
    modelRed.lb(narrowInd) = tempModel.lb(narrowInd);
    modelRed.ub(narrowInd) = tempModel.ub(narrowInd);
    cushion = cushion*2;
    modelOK = checkConsistency(model,tempModel,tol);
end

%%
function modelOK = checkConsistency(model,modelRed,tol)
%
% modelOK = checkConsistency(model,modelRed,tol)
%

if (sum(model.c ~= 0) > 0)

    % Original model
    solOrigMax = optimizeCbModel(model,'max');
    solOrigMin = optimizeCbModel(model,'min');

    % Reduced model
    solRedMax = optimizeCbModel(modelRed,'max');
    solRedMin = optimizeCbModel(modelRed,'min');

    diffMax = abs(solRedMax.f - solOrigMax.f);
    diffMin = abs(solRedMin.f - solOrigMin.f);

    if (diffMax > tol || diffMin > tol)
        fprintf('reduceModel.m: Inconsistent objective values %g %g %g %g\n',solOrigMax.f,solRedMax.f,solOrigMin.f,solRedMin.f);
        modelOK = false;
    else
        fprintf('reduceModel.m: Model is consistent\n');
        modelOK = true;
    end

else
    modelOK = true;
end
