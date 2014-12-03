function [OMNISol,bilevelMILPProblem] = OMNI(model, selectedRxnList, options, constrOpt, measOpt, prevSolutions, verbFlag)
%
%% ***********************NOT WORKING**************************************
%

%function [OMNISol,bilevelMILPProblem] = OMNI(model,selectedRxnList,options,constrOpt,prevSolutions,verbFlag,solutionFileNameTmp)

%OMNI Run OMNI in the most general form
%
% OMNI(model,selectedRxnList,options,constrOpt,prevSolutions,verbFlag,solutionFileName)
%
%INPUTS
% model                 Structure containing all necessary variables to 
%                       describe a stoichiometric model
%   rxns                  Rxns in the model
%   mets                  Metabolites in the model
%   S                     Stoichiometric matrix (sparse)
%   b                     RHS of Sv = b (usually zeros)
%   c                     Objective coefficients
%   lb                    Lower bounds for fluxes
%   ub                    Upper bounds for fluxes
%   rev                    Reversibility of fluxes
% selectedRxnList       List of reactions that can be knocked-out in OMNI
% options               OMNI options
%   numDel                # of bottlenecks
%   numDelSense           Direction of # of bottleneck constraint (G/E/L)
%   vMax                  Max flux
%   solveOMNI             Solve problem within Matlab
%   createGams            Create GAMS input file
%   gamsFile              GAMS input file name
% constrOpt             Explicitly constrained reaction options
%   rxnList               Reaction list
%   values                Values for constrained reactions
%   sense                 Constraint senses for constrained reactions
%                         (G/E/L)
% measOpt               Measured flux options
%   rxnSel                Names of measured reactions
%   values                Flux values of measured reactions
%   weights               Weights for measured fluxes
%
%OPTIONAL INPUTS
% prevSolutions         Previous solutions
% verbFlag              Verbose flag
% solutionFileName      File name for storing temporary solutions
%
%OUTPUTS
% OMNISol               OMNI solution structure
% bilevelMILPProblem    bi-level MILP problem structure used
%
% Markus Herrgard 3/28/05

% Set these for MILP callbacks
global MILPproblemType;
global selectedRxnIndIrrev;
%global rxnList;
global irrev2rev;
%global solutionFileName;
%global biomassRxnID;
%global OMNIKOrxnList;
%global OMNIObjective;
%global OMNIGrowth;
%global solID;

if (nargin < 5)
    prevSolutions = [];
end
if (nargin < 6)
    verbFlag = false;
end
% if (nargin < 7)
%     solutionFileName = 'OMNISolutions.mat';
% else
%     solutionFileName = solutionFileNameTmp;
% end

% Convert to irreversible rxns
[modelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(model);

% Create the index of the previous KO's suggested by OMNI to avoid obtaining the same
% solution again
selPrevSolIrrev = [];
for i = 1:size(prevSolutions,2)
    prevSolRxnList = model.rxns(prevSolutions(:,i)==1);
    selPrevSol = ismember(model.rxns,prevSolRxnList);
    selPrevSolIrrev(:,i) = selPrevSol(irrev2rev);
end

[nMets,nRxns] = size(modelIrrev.S);

% Create matchings for reversible reactions in the set selected for KOs 
% This is to ensure that both directions of the reaction are knocked out
selSelectedRxn = ismember(model.rxns,selectedRxnList);
selSelectedRxnIrrev = selSelectedRxn(irrev2rev);
selectedRxnIndIrrev = find(selSelectedRxnIrrev);
cnt = 0;
%prevRxnID = -10;
nSelected = length(selectedRxnIndIrrev);
selRxnCnt = 1;
while selRxnCnt <= nSelected
    rxnID = selectedRxnIndIrrev(selRxnCnt);
    if (matchRev(rxnID)>0)
        cnt = cnt + 1;
        selectedRxnMatch(cnt,1) = selRxnCnt;
        selectedRxnMatch(cnt,2) = selRxnCnt+1;
        selRxnCnt = selRxnCnt + 1;
    end
    selRxnCnt = selRxnCnt + 1;
end

% Set inner constraints for the LP
constrOptIrrev = setConstraintsIrrevModel(constrOpt,model,modelIrrev,rev2irrev);
% constrOptIrrev = model; 
% constrOptIrrev = []; 
    
% Set objectives for linear and integer parts
cLinear = zeros(nRxns,1);
cInteger = zeros(sum(selSelectedRxnIrrev),1);

% Set the correct objective coefficient (not necessary for OMNI)
% targetRxnID = find(ismember(model.rxns,options.targetRxn));
% targetRxnIDirrev = rev2irrev{targetRxnID}(1);
% cLinear(targetRxnIDirrev) = 1;

% Set measured reaction in objective
sel_meas_rxn = measOpt.rxnSel';
b_meas_rxn = measOpt.values';
wt_meas_rxn = measOpt.weights';
n_m = length(sel_meas_rxn);

% Create selection vector in the decoupled representation
% This is to ensure that the objective function for measured reversible
% reactions is constructed correctly
sel_m = zeros(nRxns,1);
ord_ir = [];
b_meas_tmp = [];
wt_meas_tmp = [];
for i = 1:n_m
    rxn_name = sel_meas_rxn{i};
    rxn_id = find(strcmp(model.rxns,rxn_name));
    if (~isempty(rxn_id)) % Protect against measured fluxes that are not part of the model
        b_meas_tmp = [b_meas_tmp;b_meas_rxn(i)];
        wt_meas_tmp = [wt_meas_tmp;wt_meas_rxn(i)];
        % Reversible rxns
        if (model.rev(rxn_id))
            rxn_id_ir = rev2irrev{rxn_id}(1);
            sel_m(rxn_id_ir) = 1;
            sel_m(rxn_id_ir+1) = -1;
        else
            % Irrev rxns
            rxn_id_ir = rev2irrev{rxn_id};
            sel_m(rxn_id_ir) = 1;
        end
        % Figure out ordering in decoupled representation
        ord_ir = [ord_ir rxn_id_ir];
    end
end
% Get ordering indices
[tmp,ord_ind] = sort(ord_ir);
% Reorder or create weights
if (sum(wt_meas_rxn) == 0)
    measOpts.weights = ones(n_m,1);
else
    measOpts.weights = wt_meas_tmp(ord_ind);
end
% Reorder measured flux values
measOpts.values = b_meas_tmp(ord_ind);

measOpts.rxnSel = sel_m;

% Create the constraint matrices for the bilevel MILP
bilevelMILPProblem = createBilevelMILPproblem(modelIrrev,cLinear,cInteger,selSelectedRxnIrrev,...
    selectedRxnMatch,constrOptIrrev,measOpts,options,selPrevSolIrrev);

% Initial guess (random)
%bilevelMILPProblem.x0 = round(rand(length(bilevelMILPProblem.c),1));
if isfield(options,'initSolution')
    if (length(options.initSolution) > options.numDel | ~all(ismember(options.initSolution,selectedRxnList)))
        warning('Initial solution not valid - starting from a random initial solution')
        bilevelMILPProblem.x0 = [];
    else
        % Set initial integer solution
        selInitRxn = ismember(model.rxns,options.initSolution);
        selInitRxnIrrev = selInitRxn(irrev2rev);
        initRxnIndIrrev = find(selInitRxnIrrev);
        initIntegerSol = ~ismember(selectedRxnIndIrrev,initRxnIndIrrev);
        selInteger = bilevelMILPProblem.vartype == 'B';
        [nConstr,nVar] = size(bilevelMILPProblem.A);
        bilevelMILPProblem.x0 = nan(nVar,1);
        bilevelMILPProblem.x0(selInteger) = initIntegerSol;    
        
%         LPproblem.b = bilevelMILPProblem.b - bilevelMILPProblem.A(:,selInteger)*initIntegerSol;
%         LPproblem.A = bilevelMILPProblem.A(:,bilevelMILPProblem.vartype == 'C');
%         LPproblem.c = bilevelMILPProblem.c(bilevelMILPProblem.vartype == 'C');
%         LPproblem.lb = bilevelMILPProblem.lb(bilevelMILPProblem.vartype == 'C');
%         LPproblem.ub = bilevelMILPProblem.ub(bilevelMILPProblem.vartype == 'C');
%         LPproblem.osense = -1;
%         LPproblem.csense = bilevelMILPProblem.csense;
%         LPsol = solveCobraLP(LPproblem);
%         
%         bilevelMILPProblem.x0(~selInteger) = LPsol.full;
    end
else
    bilevelMILPProblem.x0 = [];
end

% Minimize
bilevelMILPProblem.osense = 1;

if (verbFlag) 
    [nConstr,nVar] = size(bilevelMILPProblem.A);
    nInt = length(bilevelMILPProblem.intSolInd);
    fprintf('MILP problem with %d constraints %d integer variables and %d continuous variables\n',...
        nConstr,nInt,nVar);
end

bilevelMILPProblem.model = modelIrrev;

% Set these for CPLEX callbacks
MILPproblemType = 'OMNI';
% rxnList = model.rxns;
% biomassRxnID = find(modelIrrev.c==1);
% solID = 0;
% OMNIObjective = [];
% OMNIGrowth = [];
% OMNIKOrxnList = {};

% Solve problem
if (options.solveOMNI)
    OMNISol = solveCobraMILP(bilevelMILPProblem,'printLevel',0);
    if OMNISol.stat~=0
        if (~isempty(OMNISol.cont))
            OMNISol.fluxes = convertIrrevFluxDistribution(OMNISol.cont(1:length(matchRev)),matchRev);
        end
        if (~isempty(OMNISol.int))
            % Figure out the KO reactions
            OMNIRxnInd = selectedRxnIndIrrev(OMNISol.int < 1e-4);
            OMNISol.kos = model.rxns(unique(irrev2rev(OMNIRxnInd)));
            
%             %sanity check
%             modelTemp = changeRxnBounds(model,OMNISol.kos,0,'b');
%             solTemp = optimizeCbModel(modelTemp);
%             if abs(solTemp.f - OMNISol.obj) > 1e-4
%                 [OMNISol,bilevelMILPProblem] = OMNI(model, selectedRxnList, options, constrOpt, measOpt, prevSolutions, verbFlag);
%                 previous_solutions(:,end+1) = zeros(length(model.rxns),1);
%             end
        end
    else
        OMNISol.fluxes=[];
        OMNISol.kos={};
    end
else 
    OMNISol.rxnList = {};
    OMNISol.fluxes = [];
end



