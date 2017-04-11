function [FBAsols,DRgenes,constrainedRxns,cycleStart,states] = optimizeRegModel(model,initialRegState)
% Finds the steady state solution of a model with Boolean regulatory constraints
% 
%
% USAGE:
%    [FBAsols, DRgenes, constrainedRxns, cycleStart, states] = optimizeRegModel(model, initialRegState)
%
% INPUTS:
%    model:             a regulatory COBRA model
%    initialRegState:   the initial state of the regulatory network as a 
%                       Boolean vector (opt, default = all false)
%
% OUTPUTS:
%    FBAsols:           all of the FBA solutions at the steady state (or stable
%                       cycle) of the regulatory network 
%    DRgenes:           the genes that are OFF for every FBA solution
%    constrainedRxns:   the reactions that are OFF for every FBA solution
%    cycleStart:        the number of iterations before the regulatory network
%                       reaches the steady state or cycle
%    states:            the state of the regulatory network at every iteration
%                       calculated
%
% .. Author: - Jeff Orth 8/19/08

if nargin < 2
    rFBAsol1 = false.*ones(length(model.regulatoryGenes),1); % initial state
    inputs1state = false.*ones(length(model.regulatoryInputs1),1);
    inputs2state = false.*ones(length(model.regulatoryInputs2),1);
    state1 = false.*ones(length(model.regulatoryGenes)+length(model.regulatoryInputs1)+length(model.regulatoryInputs2),1); %vector for entire state
else
    if length(initialRegState) ~= (length(model.regulatoryGenes)+length(model.regulatoryInputs1)+length(model.regulatoryInputs2))
        error('initialRegState is invalid length');
    end
    state1 = initialRegState;
    rFBAsol1 = state1(1:length(model.regulatoryGenes));
    inputs1state = state1((length(model.regulatoryGenes)+1):(length(model.regulatoryGenes)+length(model.regulatoryInputs1)));
    inputs2state = state1((length(model.regulatoryGenes)+length(model.regulatoryInputs1)+1):(length(model.regulatoryGenes)+length(model.regulatoryInputs1)+length(model.regulatoryInputs2)));
end
    
rFBAsols = {rFBAsol1}; % matrices of all solutions
inputs1states = {inputs1state};
inputs2states = {inputs2state};
states = {state1};

[rFBAsol2,finalInputs1States,finalInputs2States] = solveBooleanRegModel(model,rFBAsol1,inputs1state,inputs2state); %get first solution
rFBAsols{2} = rFBAsol2; % add solution to array of solutions
inputs1states{2} = finalInputs1States;
inputs2states{2} = finalInputs2States;
states{2} = [rFBAsol2;finalInputs1States;finalInputs2States];

% continue solving until steady state
cycleReached = false;
while ~cycleReached % while current solution ~= any previous solutions
    rFBAsol1 = rFBAsols{length(rFBAsols)};
    inputs1state = inputs1states{length(inputs1states)};
    inputs2state = inputs2states{length(inputs2states)};
    [rFBAsol2,finalInputs1States,finalInputs2States] = solveBooleanRegModel(model,rFBAsol1,inputs1state,inputs2state);
    rFBAsols{length(rFBAsols)+1} = rFBAsol2; % add solution to array of solutions
    inputs1states{length(inputs1states)+1} = finalInputs1States;
    inputs2states{length(inputs2states)+1} = finalInputs2States;
    states{length(states)+1} = [rFBAsol2;finalInputs1States;finalInputs2States];
    %check if this state has been reached before
    cycleStart = [];
    for i = 1:(length(states)-1)
        if all(states{length(states)} == states{i})
            cycleStart = i;
        end
    end
    if any(cycleStart)
        cycleReached = true;
    end
end

% remove downregulated genes and compute growth by FBA
FBAsols = {};
DRgenes = {};
constrainedRxns = {};
k = 0;
for i = cycleStart:(length(states)-1)
    k = k+1;
    genes = {};
        for j = 1:length(model.regulatoryGenes)
            if rFBAsols{i}(j) == false 
                genes{length(genes)+1,1} = model.regulatoryGenes{j};
            end
        end
    genes = intersect(model.genes,genes); % remove genes not associated with rxns
    [modelDR,he,rxns] = deleteModelGenes(model,genes); % set rxns to 0
    fbasol = optimizeCbModel(modelDR,'max',true);
    FBAsols{k} = fbasol;
    DRgenes{k} = genes;
    constrainedRxns{k} = rxns;
end




