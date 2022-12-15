function [thermoFluxConsistentMetBool,thermoFluxConsistentRxnBool,model,thermoConsistModel] = findThermoConsistentFluxSubset(model, param, removeMetBool, removeRxnBool)
% Find the thermodynamically flux consistent subset of an input model,
% optionally after removing certain metabolites and reactions
%
% INPUT
% model:                   structure with field:
%                          * .S - `m` x `n` stoichiometric matrix
%                          * .lb - `n x 1` Lower bounds
%                          * .ub - `n x 1` Upper bounds
%
% OPTIONAL INPUT
% param
% param.epsilon:                smallest flux that is considered nonzero
% param.printLevel:             print level
% model.SConsistentMetBool 
% model.SConsistentRxnBool
% model.fluxConsistentMetBool   flux consistent metabolites
% model.fluxConsistentRxnBool   flux consistent reactions
%
%
% removeMetBool:                m x 1 logical index of metabolites to
%                               remove before computing the thermodynamically
%                               consistent subset
% removeRxnBool                 n x 1 logical index of reactions to
%                               remove before computing the thermodynamically
%                               consistent subset
%
% ADVANCED OPTIONAL INPUT (Do not play with these parameters unless you know what you are doing)
% param.iterationMethod:        method to iteratively enlarge the thermodynamically consistent subset
%
% param.formulation:            mathematical formulation of inner iteration
% param.relaxBounds:      Relax bounds that don't include zero. Default is false.
% param.nMax
%
% OUTPUT
% thermoFluxConsistentMetBool    m x 1 boolean vector indicating thermodynamically flux consistent mets
% thermoFluxConsistentRxnBool    n x 1 boolean vector indicating thermodynamically flux consistent rxns
%
% model                          input model with the following fields added
%                                *.thermoFluxConsistentMetBool m x 1 boolean vector indicating thermodynamically flux consistent mets
%                                *.thermoFluxConsistentRxnBool n x 1 boolean vector indicating thermodynamically flux consistent rxns
%                                *.thermoFwdFluxConsistentRxnBool n x 1 boolean vector indicating forward thermodynamically flux consistent rxns
%                                *.thermoRevFluxConsistentRxnBool n x 1 boolean vector indicating reverse thermodynamically flux consistent rxns
%
% thermoConsistModel            subset of the input model that is thermodynamically consistent
%
% EXAMPLES:
% See COBRA.papers/2022_cardOpt/driver_testFindThermoFluxConsistency.mlx
%     COBRA.tutorials/analysis/vonBertalanffy/findThermoConsistentFluxSubset/tutorial_findThermoConsistentFluxSubset.mlx

% .. Author: - Ronan Fleming 2022
% .. Please cite:
% Fleming RMT, Haraldsdottir HS, Le HM, Vuong PT, Hankemeier T, Thiele I. 
% Cardinality optimisation in constraint-based modelling: Application to human metabolism, 2022 (submitted).

if ~exist('param','var')
    param=struct();
end
if ~isfield(param,'epsilon')
    %set parameters according to feastol
    feasTol = getCobraSolverParams('LP', 'feasTol');
    param.epsilon = feasTol;
end

if ~isfield(param,'formulation')
    %param.formulation ='v';
    %param.formulation ='pqs';
    %param.formulation ='pqs1';
    param.formulation ='pqzw';
end
if ~isfield(param,'iterationMethod')
    %param.iterationMethod='greedyAllExternal';
    param.iterationMethod='random';
    %iterationMethod='greedyRandom';
    %iterationMethod='balanced';
end

if ~isfield(param,'printLevel')
    param.printLevel=1;
end

if ~isfield(param,'secondaryRemoval')
    param.secondaryRemoval=1;
end
    
if param.printLevel>0
    fprintf('%s\n','--- findThermoFluxConsistentSubset START ----')
end

if ~isfield(param,'nMax')
    param.nMax=60; %20 may be more realistic
end

if ~isfield(model,'forcedIntRxnBool')
    model.forcedIntRxnBool = model.SConsistentRxnBool & ((model.lb > 0 & model.ub > 0) | (model.lb < 0 & model.ub < 0));
end
if param.printLevel > 0
    fprintf('%u%s\n', nnz(model.forcedIntRxnBool),' forced internal reactions.')
    if param.printLevel > 1
        printConstraints(model, -Inf, Inf, model.forcedIntRxnBool)
    end
end
if ~isfield(param,'relaxBounds')
    param.relaxBounds=0; %relax internal bounds to admit forced reactions
end
if ~isfield(param,'acceptRepairedFlux')
    if param.relaxBounds==0 && any(model.forcedIntRxnBool)
        param.acceptRepairedFlux=0;
    else
        % repaired flux from cycleFreeFlux can only guarunteed to be 
        % thermodynamically feasible if non-zero internal bounds can be relaxed
        param.acceptRepairedFlux=1;
    end
end
if ~isfield(param,'debug')
    param.debug = 0;
end

[nMet,nRxn]=size(model.S);
if ~exist('removeMetBool','var')
    removeMetBool=false(nMet,1);
end
if ~exist('removeRxnBool','var')
    removeRxnBool=false(nRxn,1);
end

if isfield(model,'E')
    error('findThermoConsistentFluxSubset does not yet support model.E constraints')
end

feasTol = getCobraSolverParams('LP', 'feasTol');
if any(model.ub-model.lb<feasTol & model.ub~=model.lb)
    warning('findThermoConsistentFluxSubset: Lower and upper bounds closer than feasibility tolerance on non-fixed variables. May cause numerical issues.')
end

if ~isfield(model,'b')
    model.b = zeros(nMet,1);
end
% assume constraint S*v = b if csense not provided
if ~isfield(model, 'csense')
    % if csense is not declared in the model, assume that all
    % constraints are equalities.
    model.csense(1:nMet, 1) = 'E';
end

if isfield(model,'SConsistentRxnBool') && isfield(model,'SConsistentMetBool')
    if length(model.SConsistentMetBool)~=nMet
        error('Length of model.SConsistentMetBool must equal the number of rows of model.S')
    end
    if length(model.SConsistentRxnBool)~=nRxn
        error('Length of model.SConsistentRxnBool must equal the number of cols of model.S')
    end
end

if isfield(model,'fluxConsistentMetBool') && isfield(model,'fluxConsistentRxnBool')
    if length(model.fluxConsistentMetBool)~=nMet
        error('Length of model.fluxConsistentMetBool must equal the number of rows of model.S')
    end
    if length(model.fluxConsistentRxnBool)~=nRxn
        error('Length of model.fluxConsistentRxnBool must equal the number of cols of model.S')
    end
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
        model = findSExRxnInd(model,[],0);
    else
        model.SIntMetBool=true(size(model.S,1),1);
        model.SIntRxnBool=true(size(model.S,2),1);
    end
else
    if length(model.SIntMetBool)~=size(model.S,1) || length(model.SIntRxnBool)~=size(model.S,2)
        model = findSExRxnInd(model,[],0);
    end
end

%save original model
[nMet,nRxn]=size(model.S);
modelO=model;
[nMetO,nRxnO]=size(modelO.S);

solution = optimizeCbModel(model);
if solution.stat~=1
    disp(solution)
    error('findThermoConsistentFluxSubset: Input model is not feasibile.')
end

bool = model.ub-model.lb<feasTol & model.ub~=model.lb;
if any(bool)
    warning('Lower and upper bounds closer than feasibility tolerance, being fixed to lower bound.')
    model.ub(bool)=model.lb(bool);
end

if any(removeMetBool)
    %save the list of reactions to remove in case model changes size
    rxnRemoveList1 = model.rxns(removeRxnBool);
    %remove metabolites, and corresponding reactions
    rxnRemoveMethod='inclusive';%maintains stoichiometric consistency
    metRemoveList1 = model.mets(removeMetBool);
    [model, rxnRemoveList2] = removeMetabolites(model, metRemoveList1, rxnRemoveMethod);
else
    metRemoveList1=[];
    rxnRemoveList2=[];
end

if any(removeRxnBool)
    if isempty(rxnRemoveList2)
        rxnRemoveList1 = model.rxns(removeRxnBool);
    else
        rxnRemoveList1 = setdiff(rxnRemoveList1,rxnRemoveList2);
    end
    [model, metRemoveList2] = removeRxns(model, rxnRemoveList1,'metRemoveMethod','exclusive','ctrsRemoveMethod','inclusive');
    
    %update boolean of reactions removed in case some are removed when removing reactions 
    if ~isempty(rxnRemoveList2)
        rxnRemoveList1 = union(rxnRemoveList1,rxnRemoveList2);
    end
    removeRxnBool = ismember(modelO.rxns,rxnRemoveList1);
    
    if ~isempty(metRemoveList1)
        %update boolean of metabolites removed in case some are removed when removing reactions 
        metRemoveList2 = union(metRemoveList1,metRemoveList2);
    end
    removeMetBool = ismember(modelO.mets,metRemoveList2);  
end
%recalculate size of S
[nMet,nRxn]=size(model.S);

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
if param.secondaryRemoval && (~isfield(model,'SConsistentRxnBool')  || ~isfield(model,'SConsistentMetBool') || length(model.SConsistentMetBool)~=size(model.S,1) || length(model.SConsistentRxnBool)~=size(model.S,2))
    
    SIntRxnBool = model.SIntRxnBool;
    
    massBalanceCheck=0;
    [SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, ~, model]...
        = findStoichConsistentSubset(model, massBalanceCheck, param.printLevel-1);
    
    if param.printLevel>0
        fprintf('%10u%%s\n',nnz(~SConsistentMetBool), ' metabolites removed by findStoichConsistentSubset called from findThermoConsistentFluxSubset.');
    end
    if param.printLevel>0
        fprintf('%10u%%s\n',nnz(SIntRxnBool & ~SConsistentRxnBool),' reactions removed by findStoichConsistentSubset called from findThermoConsistentFluxSubset.');
    end
    
end

%extract the flux consistent subset
if param.secondaryRemoval && (~isfield(model,'fluxConsistentRxnBool')  || ~isfield(model,'fluxConsistentMetBool') || length(model.fluxConsistentMetBool)~=size(model.S,1) || length(model.fluxConsistentRxnBool)~=size(model.S,2))
    if isfield(model,'C')
        fluxConsistentParam.method='fastcc';%can handle additional constraints
    else
        fluxConsistentParam.method='null_fastcc';
    end
    fluxConsistentParam.printLevel=param.printLevel-1;
    [fluxConsistentMetBool, fluxConsistentRxnBool, ~, ~,~,model] = findFluxConsistentSubset(model,fluxConsistentParam);
    
    if any(~fluxConsistentRxnBool)
        fprintf('%u%s\n',nnz(~fluxConsistentRxnBool), ' flux inconsistent reactions removed by findFluxConsistentSubset called from findThermoConsistentFluxSubset.')
    end
            
    if any(~fluxConsistentMetBool)
        fprintf('%u%s\n',nnz(~fluxConsistentMetBool), ' flux inconsistent metabolites removed by findFluxConsistentSubset called from findThermoConsistentFluxSubset.')
    end
end

%%
optCardThermoParam=param;

%recompute size in case size has been reduced
[nMet,nRxn]=size(model.S);
nIntRxn = nnz(model.SConsistentRxnBool);
nExRxn = nnz(~model.SConsistentRxnBool);

%optCardThermoParam.warmStartMethod = 'l1';
optCardThermoParam.warmStartMethod = 'random';
optCardThermoParam.thetaMultiplier=1.5;
optCardThermoParam.theta=0.5;
optCardThermoParam.regularizeOuter = 0;

if 1
    %use to debug optCardThermo
    optCardThermoParam.debug = param.debug;
end

switch optCardThermoParam.formulation
    case 'v'
        model.delta0 = 1;
        model.delta1 = 0.01;
    case 'pqs'
        paramStyle = 2;
        switch paramStyle
            case 1
                model.delta0 = 2;
                model.delta1 = 0;
                model.alpha1 = 0;
                model.beta = 1;
            case 2
                model.delta0 = 1;
                model.delta1 = 1;
                model.alpha1 = 1;
                model.beta = 1;
            case 3
                model.delta0 = 1;
                model.delta1 = 0.1;
                model.alpha1 = 0;
                model.beta = 1;
        end
    case 'pqzw'
        paramStyle = 4;
        switch paramStyle
            case 0
                model.delta0 = 0.1;
                model.delta1 = 0;
                model.alpha1 = 0;
                model.beta = 1;
            case 1
                model.delta0 = 1;
                model.delta1 = 1;
                model.alpha1 = 1;
                model.beta = 1;
            case 2
                model.delta0 = 1;
                model.delta1 = 0;
                model.alpha1 = 0;
                model.beta = 1;
            case 3
                model.delta0 = 1;
                model.delta1 = 0;
                model.alpha1 = 1;
                model.beta = 0.1;
            case 4
                model.delta0 = 1;
                model.delta1 = 1e-4;
                model.alpha1 = 1;
                model.beta = 0.1;     
        end

end
 
% model.lambda0 = 1;
% model.lambda1 = 0.01;
% model.delta0 = 1;
% model.delta1 = 0.01;
% model.alpha1 = 0;
% model.beta = 0.1;

%initialise variables
totalFractThermoModelRxn = 0;
thermo2FluxConsistentBool0 = false(nRxn,2);
thermoExFluxConsistentBool0 = false(nRxn,1);
thermoFluxConsistentBool0 = false(nRxn,1);
thermoFluxConsistentBool00 = false(nRxn,1);
thermoExFluxConsistentBool00 = false(nRxn,1);

fractNonZeroFwdRxnThermoConsistent = 0.5;
n=1;
go=1;
noProgress=0;
model.g0=zeros(nRxn,1);

while go
    
    if n==1 %&& 0
        optCardThermoParam.printLevel = param.printLevel;
    else
        optCardThermoParam.printLevel = param.printLevel -1;
    end

    %reset incentives
    model.g0(:)=1;
    setIncentives = 1;
    while setIncentives
        %keep trying until at least one exchange reaction is being optimised
        switch param.iterationMethod
            case 'internal'
                %maximise the cardinality of internal reactions that have not yet been identified as
                %thermodynamically flux consistent
                model.g0 = -1*(~thermoFluxConsistentBool0 & model.SConsistentRxnBool);
                
            case 'greedyCertainExternal'
                %maximise the cardinality of internal reactions that have not yet been identified as
                %thermodynamically flux consistent, and certain external reactions
                model.g0(thermoFluxConsistentBool0) = 0;
                model.g0(~thermoFluxConsistentBool0) = -n;
                model.g0(~thermoFluxConsistentBool0 & ~model.SConsistentRxnBool)=-1;
                
            case 'inconsistent'
                %maximise the cardinality of internal reactions that have not yet been identified as
                %thermodynamically flux consistent, and any external reaction
                %that has also not been active in all previous iterations
                model.g0(thermoFluxConsistentBool0) = 0;
                model.g0(~thermoFluxConsistentBool0) = -1;
                
            case 'greedyAllExternal'
                %maximise the cardinality of internal reactions that have not yet been identified as
                %thermodynamically flux consistent, and to a lesser extent all external reactions
                model.g0(thermoFluxConsistentBool0) = 0;
                model.g0(~thermoFluxConsistentBool0) = -n*4;
                model.g0(~model.SConsistentRxnBool) = model.g0(~model.SConsistentRxnBool)/10;
                
            case 'random'
                model.g0 = -(rand(nRxn,1)>0.5)*5;
                %remove incentive to be active for reactions previously active
                model.g0(thermoFluxConsistentBool0) = 0;
                
            case 'greedyRandom'
                model.g0 = -(rand(nRxn,1)>0.5)*n;
                %remove incentive to be active for reactions previously active
                model.g0(thermoFluxConsistentBool0) = 0;
                
            case 'balanced'
                model.g0 = -ones(nRxn,1)*2*fractNonZeroFwdRxnThermoConsistent*3;
                model.g0(thermoFluxConsistentBool0)=0;
                
        end
        if any(model.g0(~model.SConsistentRxnBool))
            setIncentives = 0;
        else
            if param.printLevel>1
                fprintf('%s\n','findThermoConsistientFlux: No exchange reaction is being optimised, making another random selection.')
            end
        end
    end
%     %no cardinality optimisation of reactions forced to be active
%     model.g0(model.forcedIntRxnBool) = 0;
    
    solution = optCardThermo(model,optCardThermoParam);

    %boolean of fluxes that are non-zero (optCardThermo already sets small fluxes to zero) 
    nonZeroFwdFluxBool = solution.v > 0;
    nonZeroRevFluxBool = solution.v < 0;
    nonZeroFluxBool = nonZeroFwdFluxBool | nonZeroRevFluxBool;
    
    if isfield(solution,'vUnrepaired')
        nonZeroFwdFluxBoolUnrepaired = solution.vUnrepaired > 0;
        nonZeroRevFluxBoolUnrepaired = solution.vUnrepaired < 0;
    end
    
    %boolean of internal reactions that admitted a thermo consistent flux (zero or nonzero)
    internalThermoFluxBool = model.SConsistentRxnBool & solution.thermoConsistentFluxBool;
    if isfield(solution,'vUnrepaired')
        internalThermoFluxBoolUnrepaired = model.SConsistentRxnBool & solution.thermoConsistentUnrepairedFluxBool;
    end
    
    %boolean of non-zero, thermodynamically feasible internal fluxes
    nonZeroFwdThermoFluxBool = nonZeroFwdFluxBool & internalThermoFluxBool;
    nonZeroRevThermoFluxBool = nonZeroRevFluxBool & internalThermoFluxBool;
    if isfield(solution,'vUnrepaired')
        nonZeroFwdThermoFluxBoolUnrepaired = nonZeroFwdFluxBoolUnrepaired & internalThermoFluxBoolUnrepaired;
        nonZeroRevThermoFluxBoolUnrepaired = nonZeroRevFluxBoolUnrepaired & internalThermoFluxBoolUnrepaired;
    end
    
    %boolean of non-zero external fluxes
    nonZeroExternalFluxBool = nonZeroFluxBool & ~model.SConsistentRxnBool;
    
    %fraction of internal forward and reverse non-zero fluxes that were thermodynamically feasible in this iteration
    fractNonZeroFwdRxnThermoConsistent =  nnz(nonZeroFwdThermoFluxBool)/nnz(nonZeroFwdThermoFluxBool & model.SConsistentRxnBool);
    fractNonZeroRevRxnThermoConsistent =  nnz(nonZeroRevThermoFluxBool)/nnz(nonZeroRevThermoFluxBool & model.SConsistentRxnBool);
    if isfield(solution,'vUnrepaired')
        fractNonZeroFwdThermoConsistentUnrepaired =  nnz(nonZeroFwdThermoFluxBoolUnrepaired)/nnz(nonZeroFwdFluxBoolUnrepaired & model.SConsistentRxnBool);
        fractNonZeroRevThermoConsistentUnrepaired =  nnz(nonZeroRevThermoFluxBoolUnrepaired)/nnz(nonZeroRevFluxBoolUnrepaired & model.SConsistentRxnBool);
    else
        fractNonZeroFwdThermoConsistentUnrepaired = fractNonZeroFwdRxnThermoConsistent;
        fractNonZeroRevThermoConsistentUnrepaired = fractNonZeroRevRxnThermoConsistent;
    end

    %total boolean of internal reactions that admit a non-zero thermodynamically consistent flux and external reactions that admit a non-zero flux
    thermo2FluxConsistentBool0(model.SConsistentRxnBool,1) = thermo2FluxConsistentBool0(model.SConsistentRxnBool,1) | nonZeroFwdThermoFluxBool(model.SConsistentRxnBool);
    thermo2FluxConsistentBool0(model.SConsistentRxnBool,2) = thermo2FluxConsistentBool0(model.SConsistentRxnBool,2) | nonZeroRevThermoFluxBool(model.SConsistentRxnBool);
    thermoExFluxConsistentBool0(~model.SConsistentRxnBool) = thermoExFluxConsistentBool0(~model.SConsistentRxnBool) | nonZeroExternalFluxBool(~model.SConsistentRxnBool);
    
    if all(thermoExFluxConsistentBool0(~model.SConsistentRxnBool))
        RR = 'R';
        if param.printLevel>1
            fprintf('%s\n','Resetting exchanges associated with thermodynamically feasible fluxes')
        end
        thermoExFluxConsistentBool00 = thermoExFluxConsistentBool00 | thermoExFluxConsistentBool0;
        thermoExFluxConsistentBool0(~model.SConsistentRxnBool)=0;
    else
        RR = ' ';
        thermoExFluxConsistentBool00 = thermoExFluxConsistentBool00 | thermoExFluxConsistentBool0;
    end
    
    %amalgamate all three into one vector
    thermoFluxConsistentBool0 = thermo2FluxConsistentBool0(:,1) | thermo2FluxConsistentBool0(:,2) | thermoExFluxConsistentBool0;
    thermoFluxConsistentBool00 = thermo2FluxConsistentBool0(:,1) | thermo2FluxConsistentBool0(:,2) | thermoExFluxConsistentBool00;
    
    %total fraction of reactions that admit a non-zero thermodynamically consistent flux in all iterations
    %forward, reverse, external
    totalFractThermoFeasFwdRxn = nnz(thermo2FluxConsistentBool0(model.SConsistentRxnBool,1))/nIntRxn;
    totalFractThermoFeasRevRxn = nnz(thermo2FluxConsistentBool0(model.SConsistentRxnBool,2))/nIntRxn;
    totalFractThermoFeasIntRxn = nnz(thermo2FluxConsistentBool0(model.SConsistentRxnBool,1) | thermo2FluxConsistentBool0(model.SConsistentRxnBool,2))/nIntRxn;
    totalFractExternalRxn = nnz(thermoExFluxConsistentBool00(~model.SConsistentRxnBool))/nExRxn;
    totalFractThermoFeasRxn = nnz(thermoFluxConsistentBool00 | thermoExFluxConsistentBool00)/nRxn;
    
    %total fraction of internal reactions that admit a non-zero thermodynamically
    %consistent flux and external reactions that admit a non-zero flux
    totalFractThermoModelRxnOld = totalFractThermoModelRxn;
    totalFractThermoModelRxn = nnz(thermoFluxConsistentBool00)/(2*nRxn+nExRxn);
    
    if param.debug && length(solution.v)<10
        if isfield(solution,'vUnrepaired')
            table(model.rxns,model.g0,solution.vUnrepaired,solution.p,solution.q,nonZeroFluxBool*1,solution.v,solution.thermoConsistentFluxBool*1,model.forcedIntRxnBool*1,thermoFluxConsistentBool00*1,'VariableNames',{'rxns' 'g0' 'v' 'p' 'q' 'nz' 'vThermo' 'it.therm' 'forced' 't.therm'})
        else
            table(model.rxns,model.g0,solution.v,solution.p,solution.q,nonZeroFluxBool*1,model.forcedIntRxnBool*1,'VariableNames',{'rxns' 'g0' 'v' 'p' 'q' 'nz' 'forced'})
        end
    end
        
    if param.printLevel>0 && n==1
        fprintf('%6s%8s%8s%8s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\n',...
            'Reset','iter','nnz(g0<0)','nnz',...
            '  feas.f', '   rep.feas.f', 't.feas.f.',...
            '  feas.r', '   rep.feas.r', 't.feas.r',...
            't.feas.int', 't.feas.ext','iteration', 'formulation')
    end
    if param.printLevel>0
        fprintf('%6s%8u%8u%8u%12.3f%12.3f%12.3f%12.3f%12.3f%12.3f%12.3f%12.3f%12s%12s\n',...
            RR,n,nnz(model.g0<0),nnz(nonZeroFluxBool),...
            fractNonZeroFwdThermoConsistentUnrepaired,fractNonZeroFwdRxnThermoConsistent,totalFractThermoFeasFwdRxn,...
            fractNonZeroRevThermoConsistentUnrepaired,fractNonZeroRevRxnThermoConsistent,totalFractThermoFeasRevRxn,...
            totalFractThermoFeasRxn,totalFractExternalRxn, param.iterationMethod,optCardThermoParam.formulation);
    end
    if totalFractThermoModelRxnOld==totalFractThermoModelRxn
        noProgress=noProgress+1;
    end
    
    if (totalFractExternalRxn==1 && totalFractThermoFeasIntRxn ==1) || n==param.nMax || noProgress==5
        if param.printLevel>0
            fprintf('%6s%8s%8s%8s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\n','Reset','iter','nnz(g0<0)','nnz','  feas.f', '   rep.feas.f', 't.feas.f.','  feas.r', '   rep.feas.r', 't.feas.r', 't.feas.int', 't.feas.ext','iteration', 'formulation')
            if n ==param.nMax
                fprintf('%s%s%s\n','findThermoConsistentFluxSubset: terminating early, ', 'n = nMax = ',int2str(n))
            end
            if noProgress==5
                fprintf('%s%s\n','findThermoConsistentFluxSubset: terminating early, ', 'no progress on % internal reactions thermodynamically flux consistent')
            end
            if n == length(solution.v)
                fprintf('%s%s%s\n','findThermoConsistentFluxSubset: terminating early, ', 'n == nRxns')
            end
            if totalFractThermoFeasIntRxn ==1
                fprintf('%s\n','All internal reactions are thermodynamically flux consistent in at least one direction.')
            end
        end
        go = 0;
    end
    
    if noProgress==3
        %param.iterationMethod='random';
        param.iterationMethod='greedyRandom';
    end
    n=n+1;
end

if param.debug && length(solution.v)<10
    if isfield(solution,'vUnrepaired')
        table(model.rxns,model.g0,solution.vUnrepaired,solution.p,solution.q,nonZeroFluxBool*1,solution.v,solution.thermoConsistentFluxBool*1,model.forcedIntRxnBool*1,thermoFluxConsistentBool00*1,'VariableNames',{'rxns' 'g0' 'v' 'p' 'q' 'nz' 'vThermo' 'therm' 'forced' 'final'})
    else
        table(model.rxns,model.g0,solution.v,solution.p,solution.q,nonZeroFluxBool*1,model.forcedIntRxnBool*1,thermoFluxConsistentBool00*1,'VariableNames',{'rxns' 'g0' 'v' 'p' 'q' 'nz' 'forced' 't.therm'})
    end
end
    
model.thermoFluxConsistentRxnBool=thermoFluxConsistentBool00; 
model.thermoFwdFluxConsistentRxnBool = thermo2FluxConsistentBool0(:,1);
model.thermoRevFluxConsistentRxnBool = thermo2FluxConsistentBool0(:,2);

%metabolites inclusively involved in thermodynamically consistent reactions are deemed thermodynamically consistent also
model.thermoFluxConsistentMetBool = getCorrespondingRows(model.S,true(size(model.S,1),1),model.thermoFluxConsistentRxnBool,'inclusive');
    
if any(model.thermoFluxConsistentRxnBool)
    rxnRemoveList = model.rxns(~model.thermoFluxConsistentRxnBool);
    [thermoConsistModel, metRemoveList] = removeRxns(model, rxnRemoveList,'metRemoveMethod','exclusive','ctrsRemoveMethod','inclusive');
    thermoFluxConsistentMetBool2=~ismember(model.mets,metRemoveList);
    if ~all(model.thermoFluxConsistentMetBool == thermoFluxConsistentMetBool2)
        error('inconsistent metabolite removal')
    end
    if 0
        try
            thermoConsistModel = removeUnusedGenes(thermoConsistModel);
        catch ME
            disp(ME.message)
        end
    end
else
    thermoConsistModel = model;
end

solution = optimizeCbModel(thermoConsistModel);
if solution.stat~=1
    disp(solution)
    warning('findThermoConsistentFluxSubset: thermoConsistModel is not feasible.')
end

%check in case the model has been reduced in size
[nMet,nRxn]=size(thermoConsistModel.S);
if nMet~=nMetO || nRxn~=nRxnO
    %retrieve original model
    model=modelO;
    
    %metabolites
    thermoFluxConsistentMetBool=false(nMetO,1);
    metBool = ismember(model.mets,thermoConsistModel.mets);
    thermoFluxConsistentMetBool(metBool)=thermoConsistModel.thermoFluxConsistentMetBool;
    
    %reactions
    thermoFluxConsistentRxnBool=false(nRxnO,1);
    rxnBool = ismember(model.rxns,thermoConsistModel.rxns);
    thermoFluxConsistentRxnBool(rxnBool)=thermoConsistModel.thermoFluxConsistentRxnBool;
    
    %forward
    thermoFwdFluxConsistentRxnBool=false(nRxnO,1);
    rxnBool = ismember(model.rxns,thermoConsistModel.rxns);
    thermoFwdFluxConsistentRxnBool(rxnBool)=thermoConsistModel.thermoFwdFluxConsistentRxnBool;
    
    %reverse
    thermoRevFluxConsistentRxnBool=false(nRxnO,1);
    rxnBool = ismember(model.rxns,thermoConsistModel.rxns);
    thermoRevFluxConsistentRxnBool(rxnBool)=thermoConsistModel.thermoRevFluxConsistentRxnBool;
else
    %input and output models are the same size
    thermoFluxConsistentMetBool = model.thermoFluxConsistentMetBool;
    thermoFluxConsistentRxnBool = model.thermoFluxConsistentRxnBool;
    thermoFwdFluxConsistentRxnBool=model.thermoFwdFluxConsistentRxnBool;
    thermoRevFluxConsistentRxnBool=model.thermoRevFluxConsistentRxnBool;
end

model.thermoFluxConsistentMetBool=thermoFluxConsistentMetBool;
model.thermoFluxConsistentRxnBool=thermoFluxConsistentRxnBool;
model.thermoFwdFluxConsistentRxnBool=thermoFwdFluxConsistentRxnBool;
model.thermoRevFluxConsistentRxnBool=thermoRevFluxConsistentRxnBool;

if param.printLevel>0
    fprintf('%s\n','--- findThermoFluxConsistentSubset END ----')
end
