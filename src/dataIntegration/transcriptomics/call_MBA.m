function tissueModel = call_MBA(model, expressionRxns, threshold_medium, threshold_high, tol, core, epsil)
%Use the MBA algorithm (Jerby et al., 2010*) to extract a context
%specific model using data. MBA algorithm defines high-confidence reactions
%to ensure activity int the extracted model. Medium confidence reactions
%are only kept when a certain parsimony trade-off is met. In random order,
%the algorithm prunes other reactions and removes them if not reauired to
%support high- or medium- confidence reactions.
%
%INPUTS
%
%   model               input model (COBRA model structure)
%   expressionRxns      expression data, corresponding to model.rxns (see
%                       mapGeneToRxn.m)
%   threshold_medium    reactions with expression above this threshold are medium
%                       confidence (expression threshold)
%   threshold_high      reactions with expression above this threshold are high confidence
%                       (expression threshold)
%   tol                 tolerance by which reactions are defined inactive after model extraction
%                       (recommended lowest value 1e-8 since solver
%                       tolerance is 1e-9)
%   core                cell with reaction names (strings) that are manually put in
%                       the high confidence core
%   epsil               trade-off between removing medium confidence and
%                       low confidence reactions (usually 0.5)
%
%OUTPUTS
%
%   tissueModel         extracted model
%
%* Jerby et al. (201)). Computational reconstruction of tissue-specific
%metabolic models: application to human liver metabolism. Mol. Syst. Biol.
%6, 401.
%

    % Get High expression core and medium expression core
    indH = find(expressionRxns > threshold_high);
    indM = find(expressionRxns >= threshold_medium & expressionRxns <= threshold_high);
    CH = union(model.rxns(indH),core);
    CM = model.rxns(indM);
    
    NC = setdiff(model.rxns,union(CH,CM));
    
    %Biomass metabolite sinks do not have to be pruned
    nonBmsInd=cellfun(@isempty,strfind(NC, 'BMS_'));
    NC = NC(nonBmsInd);
    
    %MBA
    PM = model;
    removed = {};
    while ~isempty(NC)
        ri = randi([1,numel(NC)],1);
        r = NC{ri};
        inactive = CheckConsistency(PM, r, tol);%% TO DO - need to uniformize the use of this function among all the different methods
        eH = intersect(inactive, CH);
        eM = intersect(inactive, CM);
        eX = setdiff(inactive,union(CH,CM));
        if numel(eH)==0 && numel(eM) < epsil*numel(eX)
            PM = removeRxns(PM, inactive);
            NC = setdiff(NC,inactive);
            removed = union(removed,inactive);
        else
            NC = setdiff(NC,r);
        end
    end


    tissueModel = removeNonUsedGenes(PM);
    
    is_active = fastcc(tissueModel, tol);
    inactiveRxns = setdiff(tissueModel.rxns, tissueModel.rxns(is_active));
    if ~isempty(inactiveRxns)
        warning('Extracted model is not consistent, this might be caused by (numerical) issues in fastcc consistency checks')
    end
end

function inactiveRxns = CheckConsistency(model, r, epsilon)
    model = removeRxns(model, r);
    sol = optimizeCbModel(model);
    if sol.stat ~= 1
        inactiveRxns = model.rxns;
    else
        is_active = fastcc(model, epsilon);
        inactiveRxns = setdiff(model.rxns, model.rxns(is_active));
    end  
    inactiveRxns = [inactiveRxns;r];
end

function A = fastcc(model, epsilon) 
% The FASTCC algorithm for testing the consistency of an input model
% Output A is the consistent part of the model
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg


    N = (1:numel(model.rxns));
    I = find(model.rev==0);

    A = [];

    % start with I
    J = intersect(N, I);
    V = LP7(J, model, epsilon); 
    Supp = find(abs(V) >= 0.99*epsilon);  
    A = Supp;
    incI = setdiff(J, A);    
    if ~isempty(incI)
        %fprintf('\n(inconsistent subset of I detected)\n');
    end
    J = setdiff(setdiff(N, A), incI);

    % reversible reactions
    flipped = false;
    singleton = false;        
    while ~isempty(J)
        if singleton
            Ji = J(1);
            V = LP3(Ji, model) ; 
        else
            Ji = J;
            V = LP7(Ji, model, epsilon) ; 
        end    
        Supp = find(abs(V) >= 0.99*epsilon);  
        A = union( A, Supp);
        if ~isempty( intersect(J, A))
            J = setdiff(J, A);
            flipped = false;
        else
            JiRev = setdiff(Ji, I);
            if flipped || isempty(JiRev)
                flipped = false;
                if singleton
                    J = setdiff(J, Ji);  
                    %fprintf('\n(inconsistent reversible reaction detected)\n');
                else
                    singleton = true;
                end
            else
                model.S(:,JiRev) = -model.S(:,JiRev);
                tmp = model.ub(JiRev);
                model.ub(JiRev) = -model.lb(JiRev);
                model.lb(JiRev) = -tmp;
                flipped = true;
            end
        end
    end

    if numel(A) == numel(N)
        %fprintf('\nThe input model is consistent.\n'); 
    end
    %toc
end

function V = LP3(J, model)
% CPLEX implementation of LP-3 for input set J (see FASTCORE paper)
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg


    [m,n] = size(model.S);

    % objective
    f = zeros(1,n);
    f(J) = -1;

    % equalities
    Aeq = model.S;
    beq = zeros(m,1);

    % bounds
    lb = model.lb;
    ub = model.ub;
    
    % Set up problem
    LPproblem.A = Aeq;
    LPproblem.b = beq;
    LPproblem.c = f;
    LPproblem.lb = lb;
    LPproblem.ub = ub;
    LPproblem.osense = 1;
    LPproblem.csense(1:m,1) = 'E';

    %V = cplexlp(f,[],[],Aeq,beq,lb,ub);
    sol = solveCobraLP(LPproblem);
    V = sol.full;
end

function V = LP7(J, model, epsilon)
% CPLEX implementation of LP-7 for input set J (see FASTCORE paper)
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

    nj = numel(J);
    [m,n] = size(model.S);

    % x = [v;z]

    % objective
    f = -[zeros(1,n), ones(1,nj)];

    % equalities
    Aeq = [model.S, sparse(m,nj)];
    beq = zeros(m,1);

    % inequalities
    Ij = sparse(nj,n); 
    Ij(sub2ind(size(Ij),(1:nj)',J(:))) = -1;
    Aineq = sparse([Ij, speye(nj)]);
    bineq = zeros(nj,1);

    % bounds
    lb = [model.lb; zeros(nj,1)];
    ub = [model.ub; ones(nj,1)*epsilon];

    % Set up problem
    LPproblem.A = [Aeq;Aineq];
    LPproblem.b = [beq;bineq];
    LPproblem.c = f;
    LPproblem.lb = lb;
    LPproblem.ub = ub;
    LPproblem.osense = 1;
    LPproblem.csense(1:m,1) = 'E';
    LPproblem.csense(m+1:length(bineq)+m,1) = 'L';
    
    sol = solveCobraLP(LPproblem);
    if sol.stat == 1
        x = sol.full;    
        %x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub);
        V = x(1:n);
    else
        V = zeros(n,1);
    end
end