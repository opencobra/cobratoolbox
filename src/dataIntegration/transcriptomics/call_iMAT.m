function tissueModel = call_iMAT(model, expressionRxns, threshold_lb, threshold_ub, tol, core, epsilon, logfile, runtime)
%Use the iMAT algorithm (Zur et al., 2010*) to extract a context
%specific model using data. iMAT algorithm find the optimal trade-off
%between inluding high-expression reactions and removing low-expression
%reactions.
%
%INPUTS
%
%   model               input model (COBRA model structure)
%   expressionRxns      expression data, corresponding to model.rxns (see
%                       mapGeneToRxn.m)
%   threshold_lb        lower bound of expression threshold, reactions with
%                       expression below this value are "non-expressed"
%   threshold_ub        upper bound of expression threshold, reactions with
%                       expression above this value are "expressed"
%   tol                 tolerance by which reactions are defined inactive after model extraction
%                       (recommended lowest value 1e-8 since solver
%                       tolerance is 1e-9)
%   core                cell with reaction names (strings) that are manually put in
%                       the high confidence set
%   epsilon             minimum flux threshold for "expressed" reactions
%                       %%TO SET - default value -set to 1
%   logfile             name of the file to save the MILP log (string)
%   runtime             maximum solve time for the MILP %% TO SET - default value -set between 3600
%                       and 7200
%
%OUTPUTS
%
%   tissueModel         extracted model
%
%* Zur et al. (2010). iMAT: an integrative metabolic analysis tool.
%Bioinformatics 26, 3140-3142.
%
% Implementation adapted from the cobra toolbox (createTissueSpecificModel.m) by S. Opdam and A. Richelle, May 2017


    RHindex = find(expressionRxns >= threshold_ub);
    RLindex = find(expressionRxns >= 0 & expressionRxns < threshold_lb);
    
    %Manually add defined core reactions to the core
    for i = 1:length(core)
        rloc = find(ismember(model.rxns, core{i}));
        if ~isempty(rloc) && isempty(intersect(RHindex,rloc))
            RHindex(end+1) = rloc;
        end
        if isempty(rloc)
            disp(['Manual added core reaction: ', core{i}, ' not found'])
        end
    end

    S = model.S;
    lb = model.lb;
    ub = model.ub;

    % Creating A matrix
    A = sparse(size(S,1)+2*length(RHindex)+2*length(RLindex),size(S,2)+2*length(RHindex)+length(RLindex));
    [m,n,s] = find(S);
    for i = 1:length(m)
        A(m(i),n(i)) = s(i);
    end

    for i = 1:length(RHindex)
        A(i+size(S,1),RHindex(i)) = 1;
        A(i+size(S,1),i+size(S,2)) = lb(RHindex(i)) - epsilon;
        A(i+size(S,1)+length(RHindex),RHindex(i)) = 1;
        A(i+size(S,1)+length(RHindex),i+size(S,2)+length(RHindex)+length(RLindex)) = ub(RHindex(i)) + epsilon;
    end

    for i = 1:length(RLindex)
        A(i+size(S,1)+2*length(RHindex),RLindex(i)) = 1;
        A(i+size(S,1)+2*length(RHindex),i+size(S,2)+length(RHindex)) = lb(RLindex(i));
        A(i+size(S,1)+2*length(RHindex)+length(RLindex),RLindex(i)) = 1;
        A(i+size(S,1)+2*length(RHindex)+length(RLindex),i+size(S,2)+length(RHindex)) = ub(RLindex(i));
    end

    % Creating csense
    csense1(1:size(S,1)) = 'E';
    csense2(1:length(RHindex)) = 'G';
    csense3(1:length(RHindex)) = 'L';
    csense4(1:length(RLindex)) = 'G';
    csense5(1:length(RLindex)) = 'L';
    csense = [csense1 csense2 csense3 csense4 csense5];

    % Creating lb and ub
    lb_y = zeros(2*length(RHindex)+length(RLindex),1);
    ub_y = ones(2*length(RHindex)+length(RLindex),1);
    lb = [lb;lb_y];
    ub = [ub;ub_y];

    % Creating c
    c_v = zeros(size(S,2),1);
    c_y = ones(2*length(RHindex)+length(RLindex),1);
    c = [c_v;c_y];

    % Creating b
    b_s = zeros(size(S,1),1);
    lb_rh = lb(RHindex);
    ub_rh = ub(RHindex);
    lb_rl = lb(RLindex);
    ub_rl = ub(RLindex);
    b = [b_s;lb_rh;ub_rh;lb_rl;ub_rl];

    % Creating vartype
    vartype1(1:size(S,2),1) = 'C';
    vartype2(1:2*length(RHindex)+length(RLindex),1) = 'B';
    vartype = [vartype1;vartype2];

    MILPproblem.A = A;
    MILPproblem.b = b;
    MILPproblem.c = c;
    MILPproblem.lb = lb;
    MILPproblem.ub = ub;
    MILPproblem.csense = csense;
    MILPproblem.vartype = vartype;
    MILPproblem.osense = -1;
    MILPproblem.x0 = [];

    solution = solveCobraMILP(MILPproblem, 'timeLimit', runtime, 'logFile', logfile, 'printLevel', 3);
    
    x = solution.cont;
    rxnRemList = model.rxns(abs(x) < tol);
    tissueModel = removeRxns(model,rxnRemList); 
    inactiveRxns = findBlockedReaction(tissueModel); %% TO DO - need to provide a way to modulate the tolerance of this function (set at 10e-10)
    %inactiveRxns = findBlockedReaction(tissueModel,tol)%% should be write
    %like that
    tissueModel = removeRxns(tissueModel,inactiveRxns);
    tissueModel = removeNonUsedGenes(tissueModel);
end