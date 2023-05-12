function [thermoModel, thermoModelMetBool, thermoModelRxnBool] = thermoKernel(model, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights, param)
% From a cobra model, extract a thermodynamically flux consistent submodel
% (thermoModel), of minimal size, optionally given:
% a set of active and inactive reactions (activeInactiveRxn), 
% a set of penalties on activity/inactivity of reactions (rxnWeights),
% a set of present and absent metabolites (presentAbsentMet), and
% a set of penalties on presence/absence of metabolites (metWeights).
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%                         * S  - `m x n` Stoichiometric matrix
%                         * c  - `n x 1` Linear objective coefficients
%                         * lb - `n x 1` Lower bounds
%                         * ub - `n x 1` Upper bounds
%
% OPTIONAL INPUTS:
%    model:             (optional fields)
%          * .b - `m x 1` change in concentration with time
%          * .csense - `m x 1` character array with entries in {L,E,G}
%          * .osenseStr: Maximize ('max')/minimize ('min') (opt, default = 'max') linear part of the objective.
%          * .C - `k x n` Left hand side of C*v <= d
%          * .d - `k x n` Right hand side of C*v <= d
%          * .dsense - `k x 1` character array with entries in {L,E,G}
%          * .beta - A scalar weight on minimisation of one-norm of internal fluxes. Default 1e-4. 
%                    Larger values increase the incentive to find a flux vector to be thermodynamically feasibile in each iteration of optCardThermo 
%                    and decrease the incentive to search the steady state solution space for a flux vector that results in certain reactions and
%                    metabolites to be active and present, respectively.
%
%    activeInactiveRxn: - `n x 1` with entries {1,-1, 0} depending on whether a reaction must be active, inactive, or unspecified respectively.
%    rxnWeights:        - `n x 1` real valued penalties on zero norm of reaction flux, negative to promote a reaction to be active, positive 
%                                 to promote a reaction to be inactive and zero to be indifferent to activity or inactivity  
%    presentAbsentMet:  - `m x 1` with entries {1,-1, 0} depending on whether a metabolite must be present, absent, or unspecified respectively.
%    metWeights:        - `m x 1` real valued penalties on zero norm of metabolite "activity", negative to promote a metabolite to be present, positive 
%                                 to promote a metabolite to be absent and zero to be indifferent to presence or absence 
%
%    param:      Parameters structure:
%                   * .printLevel - greater than zero to recieve more output
%                   * .bigNum - definition of a large positive number (Default value = 1e6)
%                   * .nbMaxIteration -  maximal number of outer iterations (Default value = 30)
%                   * .epsilon - smallest non-zero flux - (Default value = feasTol = 1e-6)
%                   * .theta - parameter of the approximation (Default value = 2)
%                              For a sufficiently large parameter , the Capped-L1 approximate problem
%                              and the original cardinality optimisation problem are have the same set of optimal solutions
%                   * .normalizeZeroNormWeights - {(0),1}, normalises zero norm weights
%                                                 rxnWeights  = rxnWeights./sum(abs(rxnWeights));
%                                                 metWeights  = metWeights./sum(abs(metWeights));
%                   * .rxnWeightsConsistentWithMetWeights {(0),1} If true and metWeights are provided, make the corresponding reaction weights consistent
%                   * .metWeightsConsistentWithRxnWeights {(0),1} If true and rxnWeights are provided, make the corresponding metabolite weights consistent
%                   * .acceptRepairedFlux {(1),0} If true, a post processing step after each inner iteration minimises the absolute value of internal reaction flux, 
%                                                 while (a) all exchange fluxes are kept constant, and (b) no internal flux is allowed to change direction or increase in size.   
%                   * .relaxBounds {(0),1} If true, allow internal bounds forcing non-zero flux to be relaxed as minimising absolute value of internal 
%                                          fluxes is only guarunteed to return a thermodynamically feasible flux if such bounds can be relaxed.
%                   * .removeOrphanGenes - {(1),0}, removes orphan genes from thermoModel
%                   * .formulation - mathematical formulation of thermoKernel algorithm (Default is 'pqzwrs'. Do not change unless expert user.)
%                   * .plotThermoKernelStats {(0),1} generates a figure with confusion matrices comparing anticipated vs actual metabolites and reactions in the extracted model
%                   * .plotThermoKernelWeights {(0),1} generates a figure displaying the weights given to actual and anticipated but omitted metabolites and reactions in the extracted model
    
% OUTPUTS:
%   thermoModel:           thermodynamically consistent model extracted from input model
%   thermoModelMetBool:   `m` x 1 boolean vector of thermodynamically consistent `mets` in input model
%   thermoModelRxnBool:   `n` x 1 boolean vector of thermodynamically consistent `rxns` in input model
 
% .. Author: - Ronan Fleming 2021

[nMet,nRxn] = size(model.S);
if ~exist('activeInactiveRxn','var') || isempty(activeInactiveRxn)
    activeInactiveRxn = zeros(nRxn,1);
end
if ~exist('presentAbsentMet','var') || isempty(presentAbsentMet)
    presentAbsentMet = zeros(nMet,1);
end
if ~exist('param','var')
    param=struct();
end
if ~isfield(param,'rxnWeightsConsistentWithMetWeights')
    param.rxnWeightsConsistentWithMetWeights = 0;
end
if ~isfield(param,'metWeightsConsistentWithRxnWeights')
    param.metWeightsConsistentWithRxnWeights = 0;
end
if ~isfield(param,'iterationMethod')
    param.iterationMethod = 'greedyAdd';
end
if ~isfield(param,'saveModelSFC')
    param.saveModelSFC = 0;
end
if ~exist('rxnWeights','var') || isempty(rxnWeights)
    if ~exist('metWeights','var') || isempty(metWeights)
        %by default the minimal subset of reactions
        rxnWeights = ones(nRxn,1);
        param.normalizeZeroNormWeights=0;
    else
        if param.rxnWeightsConsistentWithMetWeights
            %if metWeights are provided, make the corresponding reactions
            %consistent
            rxnWeights = zero(nRxn,1);
            %reactions exclusively involved in incentivised metabolites
            incentiveMetBool = metWeights<0;
            incentiveRxnBool = getCorrespondingCols(model.S,incentiveMetBool,true(nRxn,1),'inclusive');
            rxnWeights(incentiveRxnBool) = mean(metWeights(incentiveMetBool));
            %metabolites exclusively involved in disincentivised reactions
            disincentiveMetBool = metWeights>0;
            disincentiveRxnBool = getCorrespondingCols(model.S,disincentiveMetBool,true(nRxn,1),'inclusive');
            rxnWeights(disincentiveRxnBool) = mean(metWeights(disincentiveMetBool));
        else
            rxnWeights = zeros(nRxn,1);
        end
    end
else
    rxnWeights = full(rxnWeights);
end

if ~exist('metWeights','var') || isempty(metWeights)
    if ~exist('rxnWeights','var') || isempty(rxnWeights)
        %by default the minimal subset of metabolites
        metWeights = ones(nMet,1);
        param.normalizeZeroNormWeights=0;
    else
        if param.metWeightsConsistentWithRxnWeights
            %if reaction weights are provided, make the corresponding
            %metabolites consistent
            metWeights = zero(nMet,1);
            %metabolites exclusively involved in incentivised reactions
            incentiveRxnBool = rxnWeights<0;
            incentiveMetBool = getCorrespondingRows(model.S,true(nMet,1),incentiveRxnBool,'inclusive');
            metWeights(incentiveMetBool) = mean(rxnWeights(incentiveRxnBool));
            %metabolites exclusively involved in disincentivised reactions
            disincentiveRxnBool = rxnWeights>0;
            disincentiveMetBool = getCorrespondingRows(model.S,true(nMet,1),disincentiveRxnBool,'inclusive');
            metWeights(disincentiveMetBool) = mean(rxnWeights(disincentiveRxnBool));
        else
            metWeights = zero(nMet,1);
        end
    end
else
    metWeights = full(metWeights);
end
if length(metWeights)~=nMet
    error('length(metWeights) should equal nMet')
end
if length(rxnWeights)~=nRxn
    error('length(rxnWeights) should equal nRxn')
end

if ~isfield(param,'printLevel')
    param.printLevel = 3;%debugging
end
if param.printLevel>0
    fprintf('%s\n','--- thermoKernel START ----')
end
if ~isfield(param,'formulation')
    param.formulation = 'pqzwrs';
end
%set parameters according to feastol
feasTol = getCobraSolverParams('LP', 'feasTol');
if ~isfield(param,'epsilon')
    param.epsilon = feasTol*10;
end
if ~isfield(param,'normalizeZeroNormWeights')
    param.normalizeZeroNormWeights=0;
end
if ~isfield(param,'removeOrphanGenes')
    param.removeOrphanGenes=1;
end
if ~isfield(param,'nbMaxIteration')
    param.nbMaxIteration=30;
end
if ~isfield(param,'relaxBounds')
    param.relaxBounds=0;
end
if ~isfield(param,'plotThermoKernelStats')
    param.plotThermoKernelStats=0;
end
if ~isfield(param,'plotThermoKernelWeights')
    param.plotThermoKernelWeights=0;
end
if ~isfield(param,'nMax')
    param.nMax=40;
end
if ~isfield(param,'acceptRepairedFlux')
    if param.relaxBounds==0
        % cycleFreeFlux only guarunteed to be thermodynamically feasible if
        % bounds can be relaxed
        param.acceptRepairedFlux=1;
    else
        param.acceptRepairedFlux=0;
    end
end
if ~isfield(param,'iterationMethod')
    param.iterationMethod='greedyAdd'; %most reproducible results
    %param.iterationMethod='greedy';
    %param.iterationMethod='randomActive';
    %param.iterationMethod='disincentivise';
    %param.iterationMethod='random';
    %param.iterationMethod='greedyRandom';
    
end
if ~isfield(param,'findThermoConsistentFluxSubset')
    param.findThermoConsistentFluxSubset = 0;
end

if param.printLevel>0
    fprintf('%s\n','thermoKernel parameters:')
    disp(param)
end
%heuristically identify exchange reactions and metabolites exclusively
%involved in exchange reactions
if ~isfield(model,'SIntRxnBool')  || ~isfield(model,'SIntMetBool')
    if isfield(model,'mets')
        %attempts to finds the reactions in the model which export/import from the model
        %boundary i.e. mass unbalanced reactions
        %e.g. Exchange reactions
        %     Demand reactions
        %     Sink reactions
        model = findSExRxnInd(model,[],param.printLevel-1);
    else
        model.SIntMetBool=true(size(model.S,1),1);
        model.SIntRxnBool=true(size(model.S,2),1);
    end
else
    if length(model.SIntMetBool)~=size(model.S,1) || length(model.SIntRxnBool)~=size(model.S,2)
        model = findSExRxnInd(model,[],param.printLevel-1);
    end
end

%extract the stoichiometrically consistent subset
if ~isfield(model,'SConsistentRxnBool')  || ~isfield(model,'SConsistentMetBool') || length(model.SConsistentMetBool)~=size(model.S,1) || length(model.SConsistentRxnBool)~=size(model.S,2)
    
    massBalanceCheck=0;
    [SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model, stoichConsistModel]...
        = findStoichConsistentSubset(model, massBalanceCheck, param.printLevel-1);
    
    %reduce the size of the input data
    activeInactiveRxn = activeInactiveRxn(~model.rxnRemoveBool);
    rxnWeights = rxnWeights(~model.rxnRemoveBool);
    if any(model.rxnRemoveBool)
        fprintf('%u%s\n',nnz(model.rxnRemoveBool), ' stoichiometrically inconsistent reactions removed.')
    end
        
    presentAbsentMet = presentAbsentMet(~model.metRemoveBool);
    metWeights = metWeights(~model.metRemoveBool);
    
    if any(model.metRemoveBool)
        fprintf('%u%s\n',nnz(model.metRemoveBool), ' stoichiometrically inconsistent metabolites removed.')
    end
    
    model = stoichConsistModel;
end
%no optimisation of cardinality of non-stoichiometrically consistent
%metabolites
metWeights(~model.SConsistentMetBool)=0;

%extract the flux consistent subset
if ~isfield(model,'fluxConsistentRxnBool')  || ~isfield(model,'fluxConsistentMetBool') || length(model.fluxConsistentMetBool)~=size(model.S,1) || length(model.fluxConsistentRxnBool)~=size(model.S,2)
    fluxConsistentParam.method='fastcc';%can handle additional constraints
    fluxConsistentParam.printLevel=param.printLevel-1;
    [fluxConsistentMetBool, fluxConsistentRxnBool, ~, ~,~,model] = findFluxConsistentSubset(model,fluxConsistentParam);
    
    %reduce the size of the input data
    activeInactiveRxn = activeInactiveRxn(fluxConsistentRxnBool);
    rxnWeights = rxnWeights(fluxConsistentRxnBool);
    if any(~fluxConsistentRxnBool)
        fprintf('%u%s\n',nnz(~fluxConsistentRxnBool), ' flux inconsistent reactions removed.')
    end
        
    presentAbsentMet = presentAbsentMet(fluxConsistentMetBool);
    metWeights = metWeights(fluxConsistentMetBool);
    
    if any(~fluxConsistentMetBool)
        fprintf('%u%s\n',nnz(~fluxConsistentMetBool), ' flux inconsistent metabolites removed.')
    end
end

%extract the thermodynamically flux consistent subset
if param.findThermoConsistentFluxSubset || (~isfield(model,'thermoFluxConsistentMetBool')  || ~isfield(model,'thermoFluxConsistentRxnBool'))
    paramT.printLevel = 1;
    [thermoFluxConsistentMetBool,thermoFluxConsistentRxnBool,~,model]  = findThermoConsistentFluxSubset(model,paramT);

    %reduce the size of the input data
    activeInactiveRxn = activeInactiveRxn(thermoFluxConsistentRxnBool);
    rxnWeights = rxnWeights(thermoFluxConsistentRxnBool);
    if any(~thermoFluxConsistentRxnBool)
        fprintf('%u%s\n',nnz(~thermoFluxConsistentRxnBool), ' thermodynamicaly flux inconsistent reactions removed.')
    end
        
    presentAbsentMet = presentAbsentMet(thermoFluxConsistentMetBool);
    metWeights = metWeights(thermoFluxConsistentMetBool);
    
    if any(~thermoFluxConsistentMetBool)
        fprintf('%u%s\n',nnz(~thermoFluxConsistentMetBool), ' thermodynamicaly flux inconsistent metabolites removed.')
    end
end

if param.saveModelSFC
    save('modelSFC','model')
end

if param.normalizeZeroNormWeights
    %normalise zero norm weights
    if sum(abs(rxnWeights))>0
        model.g0 = rxnWeights/sum(abs(rxnWeights));
    else
        model.g0 = rxnWeights;
    end
    if sum(sum(abs(metWeights)))>0
        model.h0 = metWeights/sum(abs(metWeights));
    else
        model.h0 = metWeights;
    end
else
    model.g0 = rxnWeights;
    model.h0 = metWeights;
end

if param.normalizeZeroNormWeights
    forceRxnWeight = 1;
    forceMetWeight = 1;
else
    %replace hard constraints with optimisation
    forceRxnWeight = max(abs(model.g0));
    forceMetWeight = max(abs(model.h0));
end

[nMet,nRxn] = size(model.S);

%
if ~isfield(model,'forcedIntRxnBool') || length(model.forcedIntRxnBool)~=length(model.lb)
    model.forcedIntRxnBool = model.SConsistentRxnBool & ((model.lb > 0 & model.ub > 0) | (model.lb < 0 & model.ub < 0));
end
if any(model.forcedIntRxnBool)
    if param.relaxBounds==0
        fprintf('%u%s\n', nnz(model.forcedIntRxnBool), ' forced internal reactions and no relaxation of bounds so cycleFreeFlux cannot determine thermodynamic feasibility of these reactions.') 
    else
        fprintf('%u%s\n', nnz(model.forcedIntRxnBool), ' forced internal reactions and relaxation of bounds so cycleFreeFlux only determines thermodynamic feasibility of these reactions with relaxed not forced bounds.') 
    end
end
thermoModelRxnBool=false(nRxn,1);
totalFractModelThermoIncentiveRxnBool=0;
totalModelThermoProdBool=false(nMet,1);
totalFractModelThermoIncentiveProdBool=0;

%optCardThermoParam.warmStartMethod = 'l1';
optCardThermoParam.warmStartMethod = 'random';
optCardThermoParam.formulation=param.formulation;
optCardThermoParam.thetaMultiplier=1.5;
optCardThermoParam.theta=0.5;
optCardThermoParam.regularizeOuter = 1; % opposite of findThermoConsistentFluxSubset
optCardThermoParam.epsilon=param.epsilon;
optCardThermoParam.printLevel=param.printLevel-1;
optCardThermoParam.relaxBounds=param.relaxBounds;
optCardThermoParam.acceptRepairedFlux=param.acceptRepairedFlux;
%optCardThermoParam.nbMaxIteration=param.nbMaxIteration; % added by IT as optCardThermo has a different default max number than thermoKernel

if 0
    model.lambda0 = 1;
    model.lambda1 = 1e-4;
    model.delta0 = 1;
    model.delta1 = 1e-4;
    model.alpha1 = 0;
    if ~isfield(model,'beta')
        model.beta = 0;
    end
else
    model.lambda0 = 1;
    model.lambda1 = 0;
    model.delta0 = 1;
    model.delta1 = 0;
    model.alpha1 = 0;%if it is nonzero, it also minimises one norm of exchange reactions
    if ~isfield(model,'beta')
        model.beta = 1e-4;
    end
end

%core metabolites and reactions
if isempty(activeInactiveRxn)
    model.activeRxn = false(nRxn,1);
    model.inactiveRxn = false(nRxn,1);
else
    model.activeRxn = activeInactiveRxn == 1;
    model.inactiveRxn = activeInactiveRxn ==-1;
end

if isempty(presentAbsentMet)
    model.presentMet=false(nMet,1);
    model.absentMet=false(nMet,1);
else
    model.presentMet = presentAbsentMet ==  1;
    model.absentMet =  presentAbsentMet == -1;
end

%hard version of absent and present constraints
if any(model.activeRxn) || any(model.presentMet) || any(model.inactiveRxn) || any(model.absentMet)
    try
        if 1
            solution = optCardThermo(model,optCardThermoParam);
        else
            solution.stat=1;
        end
        hardBoth=0;
        hardPresentActive = 0;
    catch ME
        hardBoth=1;
    end
    
    if (any(model.activeRxn) || any(model.presentMet)) && (hardBoth || solution.stat~=1)
        %replace hard constraints on presence and activity, with objective
        %weights
        model.h0(model.presentMet,1)= -forceMetWeight; %incentive to be present
        model.g0(model.activeRxn,1)= -forceRxnWeight; %incentive to be active
        model.presentMet(:,1)=0;
        model.activeRxn(:,1)=0;
        fprintf('%s\n','Hard present/active constraints with absent/inactive constraints are collectively infeasible, replaced by cardinality optimisation.')
        try
            %semi hard version of absent and present constraints
            solution = optCardThermo(model,optCardThermoParam);
            hardPresentActive = 0;
        catch ME
            hardPresentActive = 1;
        end
        
    end
    
    if hardPresentActive || solution.stat~=1
        model.h0(model.absentMet,1) = forceMetWeight; %incentive to be absent
        model.g0(model.inactiveRxn,1) = forceRxnWeight; %incentive to be inactive
        model.absentMet(:,1)=0;
        model.inactiveRxn(:,1)=0;
        fprintf('%s\n','Hard absent/inactive constraints are collectively infeasible, replaced by cardinality optimisation.')
    end
else
    hardPresentActive = 0;
end

%store the original set of incentices (-ve), disincentives(+ve), and
%irrespectives (0).
g0orig = model.g0;
h0orig = model.h0;

noRxnProgress=0;
noMetProgress=0;
go=1;
n=1;
statOptCardThermo=NaN;
while go
    if n==2 %&& 0 %debugging
        %only print out the first inner iteration
        optCardThermoParam.printLevel=param.printLevel-1;
    end
        
    %update weights from the second iteration onward
    if n>1
        switch param.iterationMethod
            case 'vanilla'
                %remove incentive to be active for internal reactions previously active
                model.g0(g0orig<0 & thermoModelRxnBool) = 0;
                %remove incentive to be active for metabolites previously present
                model.h0(h0orig<0 & totalModelThermoProdBool) = 0;
                
            case 'greedy'
                %remove incentive to be active for internal reactions previously active
                model.g0(g0orig<0 & thermoModelRxnBool) = 0;
                %remove incentive to be active for metabolites previously present
                model.h0(h0orig<0 & totalModelThermoProdBool) = 0;
                
                %multiply incentive to be active for internal reactions previously inactive
                model.g0(g0orig<0 & ~thermoModelRxnBool) = g0orig(g0orig<0 & ~thermoModelRxnBool)*n;
                %multiply incentive to be active for metabolites previously absent
                model.h0(h0orig<0 & ~totalModelThermoProdBool) = h0orig(h0orig<0 & ~totalModelThermoProdBool)*n;
                
           case 'greedyAdd'
%                 %remove incentive to be active for internal reactions previously active
%                 model.g0(g0orig<0 & thermoModelRxnBool) = 0;
%                 %remove incentive to be active for metabolites previously present
%                 model.h0(h0orig<0 & totalModelThermoProdBool) = 0;
                
                %multiply incentive to be active for internal reactions previously inactive
                model.g0(g0orig<0 & ~thermoModelRxnBool) = g0orig(g0orig<0 & ~thermoModelRxnBool)*n;
                %multiply incentive to be active for metabolites previously absent
                model.h0(h0orig<0 & ~totalModelThermoProdBool) = h0orig(h0orig<0 & ~totalModelThermoProdBool)*n;    
                
            case 'greedyRandom'
                model.g0 = g0orig;
                %remove incentive to be active for reactions previously active
                model.g0(g0orig<0 & thermoModelRxnBool) = 0;
                %random incentive to be active for random subset of reactions previously inactive
                model.g0(g0orig<0 & ~thermoModelRxnBool & rand(nRxn,1)>0.5) = -forceRxnWeight*n;
                
                model.h0 = h0orig;
                %remove incentive to be active for metabolites previously present
                model.h0(h0orig<0 & totalModelThermoProdBool) = 0;
                %multiply incentive to be active for random subset of metabolites previously absent
                model.h0(h0orig<0 & ~totalModelThermoProdBool & rand(nMet,1)>0.5) = -forceMetWeight*n;
                
                
            case 'greedyRandomSubset'
                model.g0 = g0orig;
                %remove incentive to be active for reactions previously active
                model.g0(g0orig<0 & thermoModelRxnBool) = 0;
                %multiply incentive to be active for random subset of reactions previously inactive
                bool = g0orig<0 & ~thermoModelRxnBool & rand(nRxn,1)>0.5;
                model.g0(bool) = g0orig(bool)*n;
                
                model.h0 = h0orig;
                %remove incentive to be active for metabolites previously present
                model.h0(h0orig<0 & totalModelThermoProdBool) = 0;
                %multiply incentive to be active for random subset of metabolites previously absent
                bool = h0orig<0 & ~totalModelThermoProdBool & rand(nMet,1)>0.5;
                model.h0(bool) = h0orig(bool)*n;
                
            case 'disincentivise'
                %remove incentive to be active for internal reactions previously active
                model.g0(model.g0<0 & (nonZeroThermoFluxBool | nonZeroExternalFluxBool)) = 0;
                %remove incentive to be active for metabolites previously present
                model.h0(model.h0<0 & nonZeroThermoProdBool) = 0;
                
            case 'random'
                %real weights for a random subset of active reactions and zero for the rest
                model.g0 = g0orig;
                bool = rand(nRxn,1)>0.5;
                model.g0(g0orig<0 & bool) = 0;
                
                model.h0 = h0orig;
                bool = rand(nMet,1)>0.5;
                model.h0(h0orig<0 & bool) = 0;
                
            case 'randomIncentive'
                %random incentive weights for active reactions
                model.g0 = g0orig;
                randRxnIncentive = -(rand(nRxn,1)>0.5)*10;
                model.g0(g0orig<0)=randRxnIncentive(g0orig<0);
                
                model.h0 = h0orig;
                randMetIncentive = -(rand(nMet,1)>0.5)*10;
                model.h0(h0orig<0)=randMetIncentive(h0orig<0);
        end
        

    end
        
    %% optimize reaction and metabolite cardinality with thermodynamic consistency incentives
    while statOptCardThermo~=1 
        try
            solution = optCardThermo(model,optCardThermoParam);
        catch ME
            %TODO cycle free flux sporadically fails for numerical reasons - not sure why - Ronan
            warning('optCardThermo iteration errored')
            disp(ME)
            msgText = getReport(ME);
            disp(msgText)
            solution.stat = NaN;
        end
        statOptCardThermo=solution.stat;
        
    end
    
        
    %%
    % boolean of fluxes that are non-zero
    nonZeroFluxBool = abs(solution.v)>=param.epsilon;
    if isfield(solution,'vUnrepaired')
        nonZeroFluxBoolUnrepaired = abs(solution.vUnrepaired)>=param.epsilon;
    end
    % boolean of internal reactions that admitted a thermo consistent flux (zero or nonzero)
    internalThermoFluxBool = model.SConsistentRxnBool & solution.thermoConsistentFluxBool;
    if isfield(solution,'vUnrepaired')
        internalThermoFluxBoolUnrepaired = model.SConsistentRxnBool & solution.thermoConsistentUnrepairedFluxBool;
    end
    
    % boolean of non-zero, thermodynamically feasible internal fluxes in this iteration
    nonZeroThermoFluxBool = nonZeroFluxBool & internalThermoFluxBool;
    if isfield(solution,'vUnrepaired')
        nonZeroThermoFluxBoolUnrepaired = nonZeroFluxBoolUnrepaired & internalThermoFluxBoolUnrepaired;
    end
    
    % boolean of non-zero external fluxes
    nonZeroExternalFluxBool = nonZeroFluxBool & ~model.SConsistentRxnBool;
        
    % fraction of non-zero internal reaction fluxes that were thermodynamically feasible in this iteration
    fractNonZeroInternalRxnThermoConsistent =  nnz(nonZeroThermoFluxBool)/nnz(nonZeroFluxBool & model.SConsistentRxnBool);
    if isfield(solution,'vUnrepaired')
        fractNonZeroInternalRxnThermoConsistentUnrepaired =  nnz(nonZeroThermoFluxBoolUnrepaired)/nnz(nonZeroFluxBoolUnrepaired & model.SConsistentRxnBool);
    else
        fractNonZeroInternalRxnThermoConsistentUnrepaired = fractNonZeroInternalRxnThermoConsistent;
    end
    
    % number of non-zero, thermodynamically feasible internal fluxes
    nNonZeroThermoFluxBool = nnz(nonZeroThermoFluxBool);
    
    % number of internal reactions that are non-zero
    nNonzeroInternalFlux = nnz(nonZeroFluxBool & model.SConsistentRxnBool);
    
    %fraction of internal reactions that admitted a non-zero thermodynamically consistent flux in this iteration
    fractThermoFeasInternalRxn = nnz(nonZeroThermoFluxBool)/nnz(model.SConsistentRxnBool);
    %fractThermoFeasInternalRxn = nnz(abs(solution.v)>=param.epsilon & model.SConsistentRxnBool & solution.thermoConsistentFluxBool)/nnz(model.SConsistentRxnBool);

    %total boolean of reactions that admit a non-zero thermodynamically
    %consistent flux
    thermoModelRxnBool = thermoModelRxnBool | nonZeroThermoFluxBool | nonZeroExternalFluxBool;
    
    %save the previous number of thermodynamically feasible fluxes
    totalFractModelThermoIncentiveRxnBoolOld = totalFractModelThermoIncentiveRxnBool;
    
    %total fraction of internal reactions that admit a non-zero thermodynamically
    %consistent flux in all iterations thus far
    totalFractModelThermoRxnBool = nnz(thermoModelRxnBool)/nRxn;

    %total fraction of internal reactions that admit a non-zero thermodynamically
    %consistent flux in all iterations thus far
    totalFractThermoFeasInternalRxn = nnz(thermoModelRxnBool(model.SConsistentRxnBool))/nnz(model.SConsistentRxnBool);
    
    %total fraction of external reactions that admit a non-zero thermodynamically
    %consistent flux in all iterations thus far
    totalFractThermoFeasExternalRxn = nnz(thermoModelRxnBool(~model.SConsistentRxnBool))/nnz(~model.SConsistentRxnBool);
   
    %total fraction of incentivised reactions with thermodynamically feasible flux in all iterations thus far
    totalFractModelThermoIncentiveRxnBool = nnz(thermoModelRxnBool & g0orig<0)/nnz(g0orig<0);
    
    %total fraction of disincentivised reactions with thermodynamically feasible flux in all iterations thus far
    totalFractModelThermoDisincentiveRxnBool = nnz(thermoModelRxnBool & g0orig>0)/nnz(g0orig>0);
    
    %% metabolites corresponding to net flux of thermodynamically feasible reactions
    if ~all(model.SConsistentMetBool)
        %in case there are any stoichiometrically inconsistent metabolites, e.g., dummy metabolites
        nonZeroProdPlusConsumBool=false(size(model.S,1),1);
        nonZeroProdPlusConsumBool(model.SConsistentMetBool)=abs(solution.s)>=param.epsilon;
    else
        nonZeroProdPlusConsumBool  = abs(solution.s)>=param.epsilon;
    end
    
    thermoProd = 2; %was 0 when iDN models generated before christmas, but now it is consistent with final model selection
    switch thermoProd
        case 0
            nonZeroThermoProdBool = nonZeroProdPlusConsumBool;
            
        case 1
            %metabolites inclusively involved in thermodynamically consistent
            %internal fluxes are thermodynamically consistent, but may be zero
            %non-zero, thermodynamically feasible fluxes in this iteration
            nonZeroThermoProdBool = getCorrespondingRows(model.S,nonZeroProdPlusConsumBool,solution.thermoConsistentFluxBool,'inclusive');
            
        case 2
            
            %metabolites inclusively involved in nonzero thermodynamically
            %consistent fluxes in this iteration
            nonZeroThermoProdBool = getCorrespondingRows(model.S,true(size(model.S,1),1),nonZeroThermoFluxBool | nonZeroExternalFluxBool,'inclusive');
            
        case 3
            nonZeroThermoSumIntFluxBool = abs(solution.p + solution.q)>=param.epsilon & nonZeroThermoFluxBool;
            nonZeroThermoSumIntFluxBool = nonZeroThermoSumIntFluxBool(model.SConsistentRxnBool);
            nonZeroThermoProdBool = getCorrespondingRows(model.S(:,model.SConsistentRxnBool),true(size(model.S,1),1),nonZeroThermoSumIntFluxBool,'inclusive');
            
        case 4
            nonZeroThermoProdBool = getCorrespondingRows(model.S,true(size(model.S,1),1),nonZeroFluxBool & solution.thermoConsistentFluxBool,'inclusive');
            
        case 5
            %boolean of metabolites that are thermodynamically feasibly produced by
            %internal reactions
            nonZeroThermoProdBool = nonZeroProdPlusConsumBool & getCorrespondingRows(model.S,true(size(model.S,1),1),internalThermoFluxBool,'inclusive');
            
        case 6
            %boolean of metabolites that are thermodynamically feasibly produced by
            %internal reactions
            nonZeroThermoProdBool = nonZeroProdPlusConsumBool & getCorrespondingRows(model.S,true(size(model.S,1),1),solution.thermoConsistentFluxBool,'inclusive');
            
        case 7
            %metabolites inclusively involved in nonzero thermodynamically
            %consistent internal fluxes in this iteration
            nonZeroThermoProdBool = getCorrespondingRows(model.S,true(size(model.S,1),1),nonZeroThermoFluxBool,'inclusive');
            %Note that this is the same approach to select all of the metabolites for the final network.
            %thermoModelMetBool = getCorrespondingRows(model.S,true(size(model.S,1),1),thermoModelRxnBool,'inclusive');
    end
    
    
    if 0
        nnz(nonZeroProdPlusConsumBool)
        nonZeroProdPlusConsumBool2 = abs(solution.r)>=param.epsilon;
        nnz(nonZeroProdPlusConsumBool2)
        nnz(nonZeroThermoProdBool)
        nnz(nonZeroThermoProdBool)
        fprintf('%5u%10u%10u%18.2f\n',thermoProd, nnz(nonZeroThermoProdBool),nnz(nonZeroThermoProdBool & h0orig<0),nnz(nonZeroThermoProdBool & h0orig<0)/nnz(h0orig<0))
    end

    %fraction of non-zero metabolite production that was thermodynamically feasible in this iteration
    fractNonZeroProdThermoConsistent =  nnz(nonZeroThermoProdBool)/nnz(nonZeroProdPlusConsumBool);
    if fractNonZeroProdThermoConsistent>1
        %TODO debug how to make sure this is <= 1
        %pause(0.1)
    end
    
    %number of metabolites produced by thermodynamically feasible
    %reactions in this iteration
    nNonZeroThermoProdBool = nnz(nonZeroThermoProdBool);
        
    %fraction of metabolites that admitted non-zero thermodynamically
    %consistent production in this iteration
    fractThermoFeasProd = nnz(nonZeroThermoProdBool)/nMet;
    
    %total boolean of metabolites that admit non-zero thermodynamically
    %consistent production
    totalModelThermoProdBool = totalModelThermoProdBool | nonZeroThermoProdBool;
    
    %save the previous fraction of incentivised metabolites with thermodynamically feasible production
    totalFractModelThermoIncentiveProdBoolOld = totalFractModelThermoIncentiveProdBool;
    
    %total fraction of metabolites with thermodynamically feasible production in all iterations thus far
    totalFractModelThermoProdBool = nnz(totalModelThermoProdBool)/nMet;
    
    %total fraction of incentivised metabolites with thermodynamically feasible production in all iterations thus far
    totalFractModelThermoIncentiveProdBool = nnz(totalModelThermoProdBool & h0orig<0)/nnz(h0orig<0);
        
    %total fraction of disincentivised metabolites with thermodynamically feasible production in all iterations thus far
    totalFractModelThermoDisincentiveProdBool = nnz(totalModelThermoProdBool & h0orig>0)/nnz(h0orig>0);
        
    %%
    if n==1
        if param.printLevel>0
            fprintf('%5s%10s%12s%12s%12s%12s%12s%12s%12s%16s%16s%20s\n',...
                'iter.','    nnz','  feas.int','   rfeas.int', ' t.feas.inc', ' t.feas.dis',' nz.prod.',' feas.nz.prod.', ' feas.inc.prod.', ' t.feas.inc.prod.', ' t.feas.dis.prod.','formulation')
        end
    end
    if param.printLevel>0
        fprintf('%5u%10u%12.5f%12.5f%12.5f%12.5f%11u%15.5f%15.5f%16.5f%16.5f%20s\n',...
            n,nnz(nonZeroFluxBool),fractNonZeroInternalRxnThermoConsistentUnrepaired, fractNonZeroInternalRxnThermoConsistent,totalFractModelThermoIncentiveRxnBool,...
            totalFractModelThermoDisincentiveRxnBool,nnz(nonZeroProdPlusConsumBool),fractNonZeroProdThermoConsistent,fractThermoFeasProd, totalFractModelThermoIncentiveProdBool,totalFractModelThermoDisincentiveProdBool,param.iterationMethod)
    end
    
    if totalFractModelThermoIncentiveRxnBoolOld==totalFractModelThermoIncentiveRxnBool
        noRxnProgress=noRxnProgress+1;
    end
    if totalFractModelThermoIncentiveProdBoolOld==totalFractModelThermoIncentiveProdBool
        noMetProgress=noMetProgress+1;
    end
    
    %% termination criteria
    if n==param.nMax ||...
            totalFractModelThermoIncentiveProdBool==1 && isnan(totalFractModelThermoIncentiveRxnBool)  ||...
            totalFractModelThermoIncentiveRxnBool==1  && isnan(totalFractModelThermoIncentiveProdBool)  ||...
            isnan(totalFractModelThermoIncentiveRxnBool==1)  && isnan(totalFractModelThermoIncentiveProdBool)  ||...
            totalFractModelThermoIncentiveProdBool==1 && totalFractModelThermoIncentiveRxnBool==1      ||...
            noMetProgress>=3 && isnan(totalFractModelThermoIncentiveRxnBool)  ||...
            noRxnProgress>=3 && isnan(totalFractModelThermoIncentiveProdBool) ||...
            (noMetProgress>=3 && noRxnProgress>=3)

        if param.printLevel>0
            fprintf('%5s%10s%18s%18s%10s%18s%18s%20s\n',...
                'iter.','nz.flux.','%it.feas.int.flux.', '%feas.inc.flux.','nz.prod.','%it.feas.nz.prod.', '%feas.inc.prod.','formulation')
        end
        if n ==param.nMax
            fprintf('%s%s%s\n','thermoKernel terminating early: ', 'n = nMax = ',int2str(n))
        end
        if noRxnProgress==5
            fprintf('%s%s\n','thermoKernel terminating early: ', 'no progress on % internal reactions thermodynamically flux consistent')
        end
        if noMetProgress==5
            fprintf('%s%s\n','thermoKernel terminating early: ', 'no progress on % metabolite production thermodynamically flux consistent')
        end
        if n == length(solution.v)
            fprintf('%s%s%s\n','thermoKernel terminating early: ', 'n == nRxns')
        end
        if fractThermoFeasInternalRxn == 1
            fprintf('%s\n','All internal reactions are thermodynamically flux consistent')
        end
        if n == length(solution.v)
            fprintf('%s%s%s\n','thermoKernel terminating early: ', 'n == nRxns')
        end
        if fractThermoFeasInternalRxn == 1
            fprintf('%s\n','All internal reactions are thermodynamically flux consistent')
        end
        if nnz(thermoModelRxnBool(g0orig<0))==nnz(g0orig<0) && nnz(g0orig<0)>0
            fprintf('%s\n','All incentivised reactions are active.') 
        end
        if nnz(totalModelThermoProdBool(h0orig<0))==nnz(h0orig<0) && nnz(h0orig<0)>0
            fprintf('%s\n','All incentivised metabolites are produced.') 
        end
        
        go = 0;
    end
    
    if (noMetProgress>=2 && noRxnProgress>=2) && 0
        param.iterationMethod='random' ;
    end
    
    %reset status of optCardThermo
    statOptCardThermo=NaN;
    %next iteration
    n=n+1;
end

% Identify any dummy metabolites and reactions
dummyMetBool = contains(model.mets,'dummy_Met_');
dummyRxnBool = contains(model.rxns,'dummy_Rxn_');

if ~param.relaxBounds
    if any(model.forcedIntRxnBool)
        if param.printLevel>0
            fprintf('%u%s\n',nnz(model.forcedIntRxnBool),' forced internal reactions, added to thermodynamically consistent subset, even though they cannot be confirmed thermodynamically consistent')
        end
        thermoModelRxnBool = (thermoModelRxnBool | model.forcedIntRxnBool) & ~dummyRxnBool;
    end
end

thermoModelMetBool = getCorrespondingRows(model.S,true(size(model.S,1),1),thermoModelRxnBool,'inclusive');

if param.plotThermoKernelWeights == 1 || param.printLevel>2
    %plot the input weights and the weights of metabolites and reactions incentivised yet omitted
    plotThermoKernelWeights(metWeights, rxnWeights,thermoModelMetBool,thermoModelRxnBool);
    saveas(gcf,'thermoKernelWeightsAndOmitted.fig')
end
    
if param.plotThermoKernelStats == 1 || param.printLevel>2
    %plot the confusion maat
    plotThermoKernelStats(activeInactiveRxn, rxnWeights, thermoModelRxnBool, presentAbsentMet, metWeights, thermoModelMetBool)
    saveas(gcf,'thermoKernelConfusionMatrix.fig')
end

if any(dummyMetBool) || any(dummyRxnBool)
    [nMet,nRxn]=size(model.S);
     %remove any dummy metabolites and reactions that are present
    model = destroyDummyModel(model);
    [nMet2,nRxn2]=size(model.S);
    if param.printLevel>0
        fprintf('%u%s\n',nMet-nMet2, ' dummy metabolites removed');
        fprintf('%u%s\n',nRxn-nRxn2, ' dummy reactions removed');
    end
    thermoModelMetBool = thermoModelMetBool(~dummyMetBool);
    thermoModelRxnBool = thermoModelRxnBool(~dummyRxnBool);
end

if isfield(model,'g0')
    model = rmfield(model,'g0');
end
if isfield(model,'h0')
    model = rmfield(model,'h0');
end
if isfield(model,'presentMet')
    model = rmfield(model,'presentMet');
end
if isfield(model,'absentMet')
    model = rmfield(model,'absentMet');
end
if isfield(model,'inactiveRxn')
    model = rmfield(model,'inactiveRxn');
end
if isfield(model,'activeRxn')
    model = rmfield(model,'activeRxn');
end

[thermoModel,metRemoveList]= removeRxns(model, model.rxns(~thermoModelRxnBool),'metRemoveMethod','exclusive','ctrsRemoveMethod','inclusive');
metRemoveBoolTest=ismember(model.mets,metRemoveList);
if ~all(~thermoModelMetBool==metRemoveBoolTest)
    error('inconsistent metabolite removal')
end
if param.removeOrphanGenes
    try
        thermoModel = removeUnusedGenes(thermoModel);
    catch ME
        disp(ME.message)
    end
else
    disp('No genes removed, for speed.')
end

if param.printLevel>0
    fprintf('%s\n','--- thermoKernel END ----')
end