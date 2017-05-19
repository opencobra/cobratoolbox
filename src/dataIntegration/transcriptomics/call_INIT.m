function tissueModel = call_INIT(model, weights, tol, epsilon, logfile, runtime)
%Use the INIT algorithm (Agren et al., 2012*) to extract a context
%specific model using data. INIT algorithm find the optimal trade-off
%between inluding and removing reactions based on their given weights. If
%desired, accumulation of certain metabolites can be allowed or even
%forced.
%
%INPUTS
%
%   model               input model (COBRA model structure)
%   weights             column with positive and negative weights for each reaction
%                       positive weights are reactions with high expression, negative
%                       weigths for reaction with low expression (must be same length 
%                       as model.rxns)
%   tol                 tolerance by which reaction fluxes are defined inactive after model extraction
%                       (recommended lowest value 1e-8 since solver
%                       tolerance is 1e-9)
%   epsilon             minimum flux threshold for "expressed" reactions
%   logfile             name of the file to save the MILP log (string)
%   runtime             maximum solve time for the MILP (seconds)%% TO SET - default value -set between 3600
%                       and 7200
%
%OUTPUTS
%
%   tissueModel         extracted model
%
%* Agren et al. (2012). Reconstruction of genome-scale active metabolic
%networks for 69 human cell types and 16 cancer types using INIT. PLoS
%Comput. Biol. 8, e1002518.
%
% Implementation adapted from the cobra toolbox (createTissueSpecificModel.m) by S. Opdam and A. Richelle, May 2017


    RHindex = find(weights > 0);
    RLindex = find(weights < 0);
    %Weights of 0 will be handled the same as in iMAT

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
    c_w = [weights(RHindex);weights(RHindex);abs(weights(RLindex))];
    c = [c_v;c_w.*c_y];

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

    solution = solveCobraMILP_loc(MILPproblem, 'timeLimit', runtime, 'logFile', logfile, 'printLevel', 3);
    
    x = solution.cont;
    rxnRemList = model.rxns(abs(x) < tol);
    tissueModel = removeRxns(model,rxnRemList); 
    inactiveRxns = findBlockedReaction(tissueModel); %% TO DO - need to provide a way to modulate the tolerance of this function (set at 10e-10)
    %inactiveRxns = findBlockedReaction(tissueModel,tol)%% should be write
    %like that
    tissueModel = removeRxns(tissueModel,inactiveRxns);
    tissueModel = removeNonUsedGenes(tissueModel);
end
