function [output] = buildUFBAmodel(model,variables)
% buildUFBAmodel Integrate intracellular/extracellular metabolite measurements with COBRA model for flux balance analysis
%       1) removing all exchange reactions (retains sinks and demands)
%       2) setting rate of change of measured metabolites
%       3) adding additional sinks to ensure the model simulates
%
% INPUTS
%   model           COBRA model structure
%   variables       struct containing the following required fields:
%       metNames        cell array of mets for modification -- those that
%                           have measurements (corresponding to model.mets)
%       changeSlopes    vector (length(metNames) x 1) that contains the
%                           rate of change (slope) of mets in metNames
%       changeIntervals vector (length(metNames) x 1) that contains the 95%
%                           confidence interval of slopes in changeSlopes
%       ignoreSlopes    binary vector (length(metNames) x 1) that instructs
%                           specific slopes to be ignored (ignore if 1)
%
% OPTIONAL INPUTS
%   variables       struct containing the following optional fields:
%       objRxn          objective reaction (corresponding to model.rxns)
%       metNoSink       cell array of metabolites that should not have a
%                           sink added, typically for mets where the
%                           concentration is known to be 0 (default = empty
%                           cell array, {})
%       metNoSinkUp     cell array of metabolites that should not have a
%                           sink added in the up direction (default = empty
%                           cell array, {})
%       metNoSinkDown   cell array of metabolites that should not have a
%                           sink added in the down direction (default =
%                           empty cell array, {})
%       conflictingMets     cell array of intracellular metabolites
%                           (corresponding to model.mets) that conflict
%                           with extracellular rates (default = empty cell
%                           array, {})
%       neededSinks     cell array of metabolites (corresponding to
%                           model.mets) that must have a sink at all times
%                           due to unknown degradation (default = empty
%                           cell array, {})
%       solvingStrategy one of {'case1','case2','case3','case4','case5'}
%                           (default = 'case2')
%       lambda          relaxation parameter (default = 1.5)
%       numIterations   number of iterations for the integer cut
%                           optimization method (default = 100)
%       timeLimit       time limit for solver (default = 30 seconds)
%       eWeight         weighting for preferential selection of
%                           extracellular sinks over intracellular (default
%                           = 1e6); if no weighting preferred, then set
%                           eWeight = 1
%
% OUTPUTS
%   output          struct containing the following outputs
%       model           constrained uFBA model
%       metsToUse       mets with measurements applied
%       relaxedNodes    cell array which contains which metabolites had a
%                           sink reaction added to model, the direction of
%                           the sink, and the bound of the sink reaction
%
% Aarash Bordbar, James Yurkovich 8/26/2015


%% parse inputs
if ~isstruct(model)
    error('Input not in correct COBRA model format -- must be struct')
end

if ~isstruct(variables)
    error('Input variables not in correct format -- must be struct')
end

% parse model struct for required fields
if ~isfield(model,'mets')
    error('Field does not exist: model.mets')
end

if ~isfield(model,'rxns')
    error('Field does not exist: model.rxns')
end

if ~isfield(model,'S')
    error('Field does not exist: model.S')
end

if ~isfield(model,'b')
    error('Field does not exist: model.b')
end

% parse variable struct for required fields
if ~isfield(variables,'metNames')
    error('Field does not exist: variables.metNames')
else
    metNames = variables.metNames;
end

if ~isfield(variables,'changeSlopes')
    error('Field does not exist: variables.changeSlopes')
else
    changeSlopes = variables.changeSlopes;
end

if ~isfield(variables,'changeIntervals')
    error('Field does not exist: variables.changeIntervals')
else
    changeIntervals = variables.changeIntervals;
end

if ~isfield(variables,'ignoreSlopes')
    error('Field does not exist: variables.ignoreSlopes')
else
    ignoreSlopes = variables.ignoreSlopes;
end

% parse variable struct for optional fields (if not present, then default
%   value used)
if ~isfield(variables,'objRxn')
    objRxn = model.rxns(find(model.c));
else
    objRxn = variables.objRxn;
end

if ~isfield(variables,'metNoSink')
    metNoSink = {};
else
    metNoSink = variables.metNoSink;
end

if ~isfield(variables,'metNoSinkUp')
    metNoSinkUp = {};
else
    metNoSinkUp = variables.metNoSinkUp;
end

if ~isfield(variables,'metNoSinkDown')
    metNoSinkDown = {};
else
    metNoSinkDown = variables.metNoSinkDown;
end

if ~isfield(variables,'conflictingMets')
    conflictingMets = {};
else
    conflictingMets = variables.conflictingMets;
end

if ~isfield(variables,'neededSinks')
    neededSinks = {};
else
    neededSinks = variables.neededSinks;
end

if ~isfield(variables,'solvingStrategy')
    solvingStrategy = 'case2';
else
    solvingStrategy = variables.solvingStrategy;
end

if ~isfield(variables,'lambda')
    lambda = 1.5;
else
    lambda = variables.lambda;
end

if ~isfield(variables,'numIterations')
    numIterations = 100;
else
    numIterations = variables.numIterations;
end

if ~isfield(variables,'timeLimit')
    timeLimit = 30;
else
    timeLimit = variables.timeLimit;
end

if ~isfield(variables,'eWeight')
    eWeight = 1e6;
else
    eWeight = variables.eWeight;
end


%% create uFBA model
% remove exchange reactions
exRxns = strmatch('EX_',model.rxns);
model = removeRxns(model,model.rxns(exRxns));

% add neededSinks if exist
if ~isempty(neededSinks)
    model = addSinkReactions(model,neededSinks,-1000*ones(length(neededSinks),1),1000*ones(length(neededSinks),1));
end
model.csense = '';
model.csense(1:length(model.mets)) = 'E';

% build UFBAmodel
uFBAmodel = model;
uFBAmodel.S = [model.S ; model.S];
uFBAmodel.b = [model.b ; model.b];
uFBAmodel.mets = [strcat(model.mets,'_G') ; strcat(model.mets,'_L')];
uFBAmodel.metNames = [model.metNames ; model.metNames];
uFBAmodel.csense = [model.csense,model.csense];

% Filter out non-quantified metabolites
toRemove = find(changeIntervals == 0);
metNames(toRemove) = [];
changeSlopes(toRemove) = [];
changeIntervals(toRemove) = [];
ignoreSlopes(toRemove) = [];

% Filter to mets in model
loc = find(ismember(metNames,model.mets));
metsToUse = metNames(loc);
slopesToUse = changeSlopes(loc);
intervalsToUse = changeIntervals(loc);
ignoreSlopesToUse = ignoreSlopes(loc);

stableMets = metsToUse(ignoreSlopesToUse == 1);
metsToUse = metsToUse(ignoreSlopesToUse == 0);
slopesToUse = slopesToUse(ignoreSlopesToUse == 0);
intervalsToUse = intervalsToUse(ignoreSlopesToUse == 0);

metsToModify = setdiff(model.mets,[metsToUse ; stableMets]);
metsToModify = setdiff(metsToModify,metNoSink);
n = length(metsToModify);

% add two sinks (one in each direction) for each metsToModify; metNoSink
%   mets are filtered out for the specified direction
upMets = setdiff(metsToModify,metNoSinkUp);
upMetsG = strcat(upMets,'_G');
upMetsL = strcat(upMets,'_L');
for i = 1:length(upMets)
    uFBAmodel = addReaction(uFBAmodel,strcat('sink_',upMets{i},'_up'),...
        [upMetsG(i),upMetsL(i)],[-1,-1],0,0,1000,0,'','',[],[],false);
end

downMets = setdiff(metsToModify,metNoSinkDown);
downMetsG = strcat(downMets,'_G');
downMetsL = strcat(downMets,'_L');
for i = 1:length(downMets)
    uFBAmodel = addReaction(uFBAmodel,strcat('sink_',downMets{i},'_down'),...
        [downMetsG(i),downMetsL(i)],[1,1],0,0,1000,0,'','',[],[],false);
end

% loop through metsToUse and set bounds
for i = 1:length(metsToUse)
    tmpModel = uFBAmodel;
    tmpMet = metsToUse(i);
    tmpSlope = slopesToUse(i);
    tmpI = intervalsToUse(i);
    [~,tmpComp] = strtok(tmpMet,'[');
    metLoc1 = findMetIDs(tmpModel,strcat(tmpMet,'_G'));
    metLoc2 = findMetIDs(tmpModel,strcat(tmpMet,'_L'));

    % Add Constraints
    tmpModel.b(metLoc1) = tmpSlope-tmpI;
    tmpModel.csense(metLoc1) = 'G';
    tmpModel.b(metLoc2) = tmpSlope+tmpI;
    tmpModel.csense(metLoc2) = 'L';

    % Certain metabolites can only be taken up and exo to endo values do not
    % match, use exo data (assumed to be better than endo data)
    if length(intersect(tmpMet,conflictingMets)) > 0 && ...
            length(intersect(strrep(tmpMet,'[c]','[e]'),metsToUse)) > 0
        newTmpMet = strrep(tmpMet,'[c]','[e]');
        newLoc = strmatch(newTmpMet,metsToUse,'exact');
        newSlope = slopesToUse(newLoc) * -1;
        newI = intervalsToUse(newLoc);
        if (newSlope-newI) > (tmpSlope+tmpI) || (newSlope+newI) < (tmpSlope - tmpI)
            tmpModel.b(metLoc1) = newSlope - newI;
            tmpModel.b(metLoc2) = newSlope + newI;
        end
    elseif length(intersect(tmpMet,conflictingMets)) > 0 && ...
            length(intersect(strrep(tmpMet,'[c]','[e]'),stableMets)) > 0
        tmpModel.b(metLoc1) = 0;
        tmpModel.b(metLoc2) = 0;
    elseif length(intersect(strrep(tmpMet,'[e]','[c]'),conflictingMets)) > 0 && ...
            length(intersect(strrep(tmpMet,'[e]','[c]'),stableMets)) > 0
        newTmpMet = strrep(tmpMet,'[e]','[c]');
        newMetLoc1 = findMetIDs(tmpModel,strcat(newTmpMet,'_G'));
        newMetLoc2 = findMetIDs(tmpModel,strcat(newTmpMet,'_L'));
        tmpModel.b(newMetLoc1) = -tmpSlope - tmpI;
        tmpModel.csense(newMetLoc1) = 'G';

        tmpModel.b(newMetLoc2) = -tmpSlope + tmpI;
        tmpModel.csense(newMetLoc2) = 'L';
    end
    sol = optimizeCbModel(tmpModel);
    uFBAmodel = tmpModel;
end
maxMetChange = max(abs(uFBAmodel.b));
uFBAmodel.ub(length(model.c)+1:end) = maxMetChange * 2;
uFBAmodelOpen = uFBAmodel;

% Reconcile data and fluxes
[m,~] = size(uFBAmodel.S);
[~,n] = size(model.S);
numSinkRxns = length(uFBAmodel.c) - length(model.c);
intCut1 = [];
intCut2 = [];
eps=1e-6;
intCutLimit = 1e4;
for i = 1:numIterations
    clear MILPproblem
    [mIC,nIC] = size(intCut1);
    if sum(sum(intCut1))>0
        MILPproblem.A = [uFBAmodel.S, sparse(m,numSinkRxns),sparse(m,mIC/2);
            sparse(numSinkRxns,n),speye(numSinkRxns),-eps*speye(numSinkRxns),sparse(numSinkRxns,mIC/2);
            sparse(numSinkRxns,n),speye(numSinkRxns),-1001*speye(numSinkRxns),sparse(numSinkRxns,mIC/2);
            sparse(size(intCut1,1),length(uFBAmodel.rxns)),intCut1,intCut2];
        tmpB = sum(intCut1')'-1;
        tmpB(2:2:end) = 1-intCutLimit;
        MILPproblem.b = [uFBAmodel.b;
            zeros(numSinkRxns*2,1);
            tmpB];
    else
        MILPproblem.A = [uFBAmodel.S, sparse(m,numSinkRxns);
            sparse(numSinkRxns,n),speye(numSinkRxns),-eps*speye(numSinkRxns);
            sparse(numSinkRxns,n),speye(numSinkRxns),-1001*speye(numSinkRxns)];
        MILPproblem.b = [uFBAmodel.b;
            zeros(numSinkRxns*2,1)];
    end
    MILPproblem.csense = uFBAmodel.csense;
    for l = 1:numSinkRxns, MILPproblem.csense(end+1) = 'G'; end
    for l = 1:numSinkRxns, MILPproblem.csense(end+1) = 'L'; end
    for l = 1:size(intCut1,1)/2, MILPproblem.csense(end+1:end+2) = 'LG'; end
    MILPproblem.lb = [uFBAmodel.lb;
        zeros(numSinkRxns,1);
        zeros(mIC/2,1)];
    MILPproblem.ub = [uFBAmodel.ub;
        ones(numSinkRxns,1);
        ones(mIC/2,1)];
    MILPproblem.vartype = '';
    for l = 1:length(uFBAmodel.rxns), MILPproblem.vartype(end+1,1) = 'C'; end
    for l = 1:numSinkRxns, MILPproblem.vartype(end+1,1) = 'B'; end
    for l = 1:mIC/2, MILPproblem.vartype(end+1,1) = 'B'; end
    MILPproblem.osense = 1;
    MILPproblem.x0 = [];

    switch solvingStrategy
        case 'case1'
            changeCobraSolver('gurobi7','MILP');
            MILPproblem.c = [zeros(length(model.rxns),1);
                zeros(numSinkRxns,1);
                ones(numSinkRxns,1);
                zeros(mIC/2,1)];

            % weight [e] mets preferentially over [c] mets
            targetIndices = length(model.rxns) + numSinkRxns + 1 : length(model.rxns) + numSinkRxns * 2;
            cMetIndices = [];
            cMetNames = [upMets ; downMets];
            for j = 1:length(cMetNames)
                [~,tmp] = strtok(cMetNames{j},'[');
                if ~strcmp(tmp,'[e]')
                    cMetIndices(end+1,1) = j;
                end
            end
            MILPproblem.c(targetIndices(cMetIndices)) = MILPproblem.c(targetIndices(cMetIndices)) * eWeight;
            tmpSol=solveCobraMILP(MILPproblem,'timeLimit',timeLimit);
        case 'case2'
            changeCobraSolver('gurobi7','LP');
            MILPproblem.c = [zeros(length(model.rxns),1);
                ones(numSinkRxns,1);
                zeros(numSinkRxns,1);
                zeros(mIC/2,1)];

            % weight [e] mets preferentially over [c] mets
            targetIndices = length(model.rxns) + 1 : length(model.rxns) + numSinkRxns;
            cMetIndices = [];
            cMetNames = [upMets ; downMets];
            for j = 1:length(cMetNames)
                [~,tmp] = strtok(cMetNames{j},'[');
                if ~strcmp(tmp,'[e]')
                    cMetIndices(end+1,1) = j;
                end
            end
            MILPproblem.c(targetIndices(cMetIndices)) = MILPproblem.c(targetIndices(cMetIndices)) * eWeight;
            tmpSol=solveCobraMILP(MILPproblem,'timeLimit',timeLimit);
        case 'case3'
            changeCobraSolver('gurobi7','LP');
            MILPproblem.c = [ones(length(model.rxns),1);
                ones(numSinkRxns,1);
                zeros(numSinkRxns,1);
                zeros(mIC/2,1)];

            % weight [e] mets preferentially over [c] mets
            targetIndices = 1 : length(model.rxns) + numSinkRxns;
            cMetIndices = [];
            cMetNames = [upMets ; downMets];
            for j = 1:length(cMetNames)
                [~,tmp] = strtok(cMetNames{j},'[');
                if ~strcmp(tmp,'[e]')
                    cMetIndices(end+1,1) = j;
                end
            end
            MILPproblem.c(targetIndices(cMetIndices)) = MILPproblem.c(targetIndices(cMetIndices)) * eWeight;
            tmpSol=solveCobraMILP(MILPproblem,'timeLimit',timeLimit);
        case 'case4'
            changeCobraSolver('gurobi7','MIQP');
            MILPproblem.c = [zeros(length(model.rxns),1);
                zeros(numSinkRxns,1);
                zeros(numSinkRxns,1);
                zeros(mIC/2,1)];
            MILPproblem.F = [zeros(n,n),zeros(n,numSinkRxns),zeros(n,numSinkRxns), zeros(n,mIC/2);
                zeros(numSinkRxns,n),speye(numSinkRxns,numSinkRxns),zeros(numSinkRxns,numSinkRxns),zeros(numSinkRxns,mIC/2);
                zeros(numSinkRxns,n),zeros(numSinkRxns,numSinkRxns),zeros(numSinkRxns,numSinkRxns),zeros(numSinkRxns,mIC/2);
                zeros(mIC/2,n+numSinkRxns+numSinkRxns+mIC/2)];

            % weight [e] mets preferentially over [c] mets
            targetIndices = n + 1 : n + numSinkRxns;
            fMetIndices = [];
            fMetNames = [upMets ; downMets];
            for j = 1:length(fMetNames)
                [~,tmp] = strtok(fMetNames{j},'[');
                if ~strcmp(tmp,'[e]')
                    fMetIndices(end+1,1) = j;
                end
            end
            MILPproblem.F(targetIndices(fMetIndices),targetIndices(fMetIndices)) = ...
                MILPproblem.F(targetIndices(fMetIndices),targetIndices(fMetIndices)) * eWeight;
            tmpSol=solveCobraMIQP(MILPproblem,'timeLimit',timeLimit);
        case 'case5'
            changeCobraSolver('gurobi7','MIQP');
            MILPproblem.c = [zeros(length(model.rxns),1);
                zeros(numSinkRxns,1);
                zeros(numSinkRxns,1);
                zeros(mIC/2,1)];
            MILPproblem.F = [speye(n,n),zeros(n,numSinkRxns), zeros(n,numSinkRxns), zeros(n,mIC/2);
                zeros(numSinkRxns,n),speye(numSinkRxns,numSinkRxns),zeros(numSinkRxns,numSinkRxns),zeros(numSinkRxns,mIC/2);
                zeros(numSinkRxns,n),zeros(numSinkRxns,numSinkRxns),zeros(numSinkRxns,numSinkRxns),zeros(numSinkRxns,mIC/2);
                zeros(mIC/2,n+numSinkRxns+numSinkRxns+mIC/2)];

            % weight [e] mets preferentially over [c] mets
            targetIndices = 1 : n + numSinkRxns;
            fMetIndices = [];
            fMetNames = [upMets ; downMets];
            for j = 1:length(fMetNames)
                [~,tmp] = strtok(fMetNames{j},'[');
                if ~strcmp(tmp,'[e]')
                    fMetIndices(end+1,1) = j;
                end
            end
            MILPproblem.F(targetIndices(fMetIndices),targetIndices(fMetIndices)) = ...
                MILPproblem.F(targetIndices(fMetIndices),targetIndices(fMetIndices)) * eWeight;
            tmpSol=solveCobraMIQP(MILPproblem,'timeLimit',timeLimit);
        otherwise
            error('Not a valid solver option.')
    end

    tmpSol.int = tmpSol.full(n + numSinkRxns + 1:end-mIC/2);
    intCut1 = [intCut1;double(tmpSol.int'==1);double(tmpSol.int' == 0)];
    intCut2 = [intCut2,sparse(size(intCut2,1),1);
        sparse(2,size(intCut2,2)),ones(2,1)*-intCutLimit];
end

% use final result of integer cut method
total=sum(double(intCut1(1:2:end-1,:)))';
MILPproblem.A = [uFBAmodel.S, sparse(m,numSinkRxns);
    sparse(numSinkRxns,n),speye(numSinkRxns),-eps*speye(numSinkRxns);
    sparse(numSinkRxns,n),speye(numSinkRxns),-1001*speye(numSinkRxns)];
MILPproblem.b = [uFBAmodel.b;
    zeros(numSinkRxns*2,1)];
MILPproblem.csense = uFBAmodel.csense;
for l = 1:numSinkRxns, MILPproblem.csense(end+1) = 'G'; end
for l = 1:numSinkRxns, MILPproblem.csense(end+1) = 'L'; end
MILPproblem.lb = [uFBAmodel.lb;
    zeros(numSinkRxns,1)];
MILPproblem.ub = [uFBAmodel.ub;
    ones(numSinkRxns,1)];
MILPproblem.vartype = '';
for l = 1:length(uFBAmodel.rxns), MILPproblem.vartype(end+1,1) = 'C'; end
for l = 1:numSinkRxns, MILPproblem.vartype(end+1,1) = 'B'; end
MILPproblem.osense = 1;
MILPproblem.x0 = [];

switch solvingStrategy
    case 'case1'
        MILPproblem.c = [zeros(length(model.rxns),1);
            zeros(numSinkRxns,1);
            numIterations + 1 - total];

        % weight [e] mets preferentially over [c] mets
        targetIndices = length(model.rxns) + numSinkRxns + 1 : length(model.rxns) + numSinkRxns * 2;
        cMetIndices = [];
        cMetNames = [upMets ; downMets];
        for j = 1:length(cMetNames)
            [~,tmp] = strtok(cMetNames{j},'[');
            if ~strcmp(tmp,'[e]')
                cMetIndices(end+1,1) = j;
            end
        end
        MILPproblem.c(targetIndices(cMetIndices)) = MILPproblem.c(targetIndices(cMetIndices)) * eWeight;
        finalSol=solveCobraMILP(MILPproblem,'timeLimit',timeLimit);
    case 'case2'
        MILPproblem.c = [zeros(length(model.rxns),1);
            numIterations + 1 - total;
            zeros(numSinkRxns,1)];

        % weight [e] mets preferentially over [c] mets
        targetIndices = length(model.rxns) + 1 : length(model.rxns) + numSinkRxns;
        cMetIndices = [];
        cMetNames = [upMets ; downMets];
        for j = 1:length(cMetNames)
            [~,tmp] = strtok(cMetNames{j},'[');
            if ~strcmp(tmp,'[e]')
                cMetIndices(end+1,1) = j;
            end
        end
        MILPproblem.c(targetIndices(cMetIndices)) = MILPproblem.c(targetIndices(cMetIndices)) * eWeight;
        finalSol=solveCobraMILP(MILPproblem,'timeLimit',timeLimit);
    case 'case3'
        MILPproblem.c = [ones(length(model.rxns),1);
            numIterations + 1 - total;
            zeros(numSinkRxns,1)];

        % weight [e] mets preferentially over [c] mets
        targetIndices = 1 : length(model.rxns) + numSinkRxns;
        cMetIndices = [];
        cMetNames = [upMets ; downMets];
        for j = 1:length(cMetNames)
            [~,tmp] = strtok(cMetNames{j},'[');
            if ~strcmp(tmp,'[e]')
                cMetIndices(end+1,1) = j;
            end
        end
        MILPproblem.c(targetIndices(cMetIndices)) = MILPproblem.c(targetIndices(cMetIndices)) * eWeight;
        finalSol=solveCobraMILP(MILPproblem,'timeLimit',timeLimit);
    case 'case4'
        MILPproblem.c = [zeros(length(model.rxns),1);
            zeros(numSinkRxns,1);
            zeros(numSinkRxns,1)];
        MILPproblem.F = [zeros(n,n),zeros(n,numSinkRxns), zeros(n,numSinkRxns);
            zeros(numSinkRxns,n),spdiags(numIterations + 1 - total,0,speye(numSinkRxns)),zeros(numSinkRxns,numSinkRxns);
            zeros(numSinkRxns,n),zeros(numSinkRxns,numSinkRxns),zeros(numSinkRxns,numSinkRxns)];

        % weight [e] mets preferentially over [c] mets
        targetIndices = n + 1 : n + numSinkRxns;
        fMetIndices = [];
        fMetNames = [upMets ; downMets];
        for j = 1:length(fMetNames)
            [~,tmp] = strtok(fMetNames{j},'[');
            if ~strcmp(tmp,'[e]')
                fMetIndices(end+1,1) = j;
            end
        end
        MILPproblem.F(targetIndices(fMetIndices),targetIndices(fMetIndices)) = ...
            MILPproblem.F(targetIndices(fMetIndices),targetIndices(fMetIndices)) * eWeight;
        finalSol=solveCobraMIQP(MILPproblem,'timeLimit',timeLimit);
        finalSol.int = finalSol.full(n + numSinkRxns + 1:end);
    case 'case5'
        MILPproblem.c = [zeros(length(model.rxns),1);
            zeros(numSinkRxns,1);
            zeros(numSinkRxns,1)];
        MILPproblem.F = [speye(n,n),zeros(n,numSinkRxns),zeros(n,numSinkRxns);
            zeros(numSinkRxns,n),spdiags(numIterations + 1 - total,0,speye(numSinkRxns)),zeros(numSinkRxns,numSinkRxns);
            zeros(numSinkRxns,n),zeros(numSinkRxns,numSinkRxns),zeros(numSinkRxns,numSinkRxns)];

        % weight [e] mets preferentially over [c] mets
        targetIndices = 1 : n + numSinkRxns;
        fMetIndices = [];
        fMetNames = [upMets ; downMets];
        for j = 1:length(fMetNames)
            [~,tmp] = strtok(fMetNames{j},'[');
            if ~strcmp(tmp,'[e]')
                fMetIndices(end+1,1) = j;
            end
        end
        MILPproblem.F(targetIndices(fMetIndices),targetIndices(fMetIndices)) = ...
            MILPproblem.F(targetIndices(fMetIndices),targetIndices(fMetIndices)) * eWeight;
        finalSol=solveCobraMIQP(MILPproblem,'timeLimit',timeLimit);
        finalSol.int = finalSol.full(n + numSinkRxns + 1:end);
    otherwise
        error('Not a valid solver option.')
end

% remove sink reactions that have bound of 1e-6 (numerical precision limit)
sinkRxnsToKeep = uFBAmodel.rxns(find(finalSol.int)+length(model.rxns));
tmpRxns = {};
tmpUB = finalSol.full(find(finalSol.int)+length(model.rxns));
for i = 1:length(sinkRxnsToKeep)
    if tmpUB(i) ~= 1e-6
        tmpRxns{end+1,1} = sinkRxnsToKeep{i};
    end
end
sinkRxnsToKeep = tmpRxns;

% remove unnecessary sink reactions
toRemove = setdiff(uFBAmodel.rxns(length(model.rxns)+1:end),sinkRxnsToKeep);
tmpModel = removeRxns(uFBAmodel,toRemove);

% if sinks that hit lower precision limit are not needed, discard
try
    tmpSol = optimizeCbModel(tmpModel);
    tmpSol.x(end) = 1;
catch
    warning('Sinks with very low bounds required for model to simulate.');

    sinkRxnsToKeep = uFBAmodel.rxns(find(finalSol.int)+length(model.rxns));
    toRemove = setdiff(uFBAmodel.rxns(length(model.rxns)+1:end),sinkRxnsToKeep);
    tmpModel = removeRxns(uFBAmodel,toRemove);
end
tmpModel.c = zeros(length(tmpModel.c),1);

if strcmp(solvingStrategy,'case1') || strcmp(solvingStrategy,'case2') || strcmp(solvingStrategy,'case3')
    changeCobraSolver('gurobi7','LP');

    tmpModel.c(length(model.c)+1:end) = 1;
    tmpSol = optimizeCbModel(tmpModel,'min');
    tmpModel.ub(length(model.c)+1:end) = tmpSol.x(length(model.c)+1:end) * lambda;
else
    changeCobraSolver('gurobi7','QP');

    tmpProb.A = tmpModel.S;
    tmpProb.b = tmpModel.b;
    tmpProb.c = tmpModel.c;

    tmpProb.lb = tmpModel.lb;
    tmpProb.ub = tmpModel.ub;

    tmpProb.csense = tmpModel.csense;
    tmpProb.osense = 1;
    tmpProb.x0 = [];

    if strcmp(solvingStrategy,'case4')
        tmpProb.F = [zeros(n,n), zeros(n,length(sinkRxnsToKeep));
            zeros(length(sinkRxnsToKeep),n),speye(length(sinkRxnsToKeep))];
    else
        tmpProb.F = [speye(n,n), zeros(n,length(sinkRxnsToKeep));
            zeros(length(sinkRxnsToKeep),n),speye(length(sinkRxnsToKeep))];
    end

    tmpSol = solveCobraQP(tmpProb);
    tmpSol.int = tmpSol.full(n + numSinkRxns + 1:end);
    tmpModel.ub(length(model.c)+1:end) = tmpSol.full(length(model.c)+1:end) * lambda;
end

% remove any unnecessary sink reactions (lb = ub = 0)
toRemove = sinkRxnsToKeep(tmpModel.ub(n+1:end) == 0);
sinkRxnsToKeep = setdiff(sinkRxnsToKeep,toRemove);
tmpModel = removeRxns(tmpModel,toRemove);
sinkRxnsBounds = tmpModel.ub(findRxnIDs(tmpModel,sinkRxnsToKeep));
uFBAmodelConstrained = changeObjective(tmpModel,objRxn);

% store relaxed node information in readable format
relaxedNodes = cell(length(sinkRxnsToKeep),3);
relaxedNodes{1,1} = 'nodes'; relaxedNodes{1,2} = 'direction'; relaxedNodes{1,3} = 'bound';
for i = 2:length(sinkRxnsToKeep)+1
    [~,tmp] = strtok(sinkRxnsToKeep{i-1},'_');
    tmp = tmp(2:end);
    [tmp1,tmp2] = strtok(tmp,']');
    tmp1 = strcat(tmp1,tmp2(1));
    tmp2 = tmp2(2:end);

    relaxedNodes{i,1} = tmp1;
    relaxedNodes{i,2} = tmp2(2:end);
    relaxedNodes{i,3} = sinkRxnsBounds(i-1);
end

% set outputs
output.model = uFBAmodelConstrained;
output.metsToUse = metsToUse;
output.relaxedNodes = relaxedNodes;
