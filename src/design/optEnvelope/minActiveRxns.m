function [data]=minActiveRxns(model, matchRev, K, minP, toDel, timeLimit, midPoints, printLevel)
% minActiveRxns determines the minimum reactions needed to be active at
% a specific point
%
%INPUT
%  model         COBRA model structure 
%  matchRev      Matching of forward and backward reactions of a reversible
%                reaction
%  K             List of reactions that cannot be selected for knockout
%  minP          Structure that contains information about biomass and product
%  toDel         Variable that shows what to delete
%                0: reactions
%                1: genes
%                2: enzymes
%  timeLimit     Time limit for gurobi optimization
%  midPoints     Number of mid points to calculate active reactions for (default: 0)
%  printLevel    Print level for gurobi optimization (default: 0)
%
%OUTPUT
%  ActiveRxns    List of minimum active reactions at a specific point
%
%  created by    Ehsan Motamedian        09/02/2022
%  modified by   Kristaps Berzins        31/10/2022
%  modified by   Kristaps Berzins        30/10/2024     Added calculation of active reactions for middle points

if nargin < 5
    toDel = 0;
end

if nargin < 6
    timeLimit = inf;
end

if nargin < 7
    midPoints = 0;
end

if nargin < 8
    printLevel = 0;
end
    
switch toDel
    %% REACTIONS
    case 0
        [nMetsR, nRxnsR] = size(model.S);
        U = max(model.ub) + 1;

        % Create MILP problem for first point
        MILP = struct;
        MILP.A = model.S;
        MILP.b = model.b;
        MILP.csense(1:nMetsR, 1) = 'E';
        MILP.c = zeros(nRxnsR, 1);
        MILP.lb = model.lb;
        MILP.ub = model.ub;
        MILP.vartype(1:nRxnsR) = 'C';
        n = 0;
        for i = 1:nRxnsR
            if ismember(i, K) == 0
                n = n + 1;
                MILP.A(nMetsR + n, i) = 1;
                MILP.A(nMetsR + n, nRxnsR + n) = -U;
                MILP.b(nMetsR + n, 1) = 0; MILP.csense(nMetsR + n, 1) = 'L';
                MILP.c(nRxnsR + n) = 1;
                MILP.lb(nRxnsR + n) = 0; MILP.ub(nRxnsR + n) = 1;
                MILP.vartype(nRxnsR + n) = 'B';
                var(n) = i;
            end
        end
        k = 0;
        for or = 1:length(matchRev)
            if matchRev(or) ~= 0 && ismember(matchRev(or), K) == 0
                k = k + 1;
                MILP.A(nMetsR + n + k, nRxnsR + find(ismember(var, or))) = 1;
                MILP.A(nMetsR + n + k, nRxnsR + find(ismember(var, matchRev(or)))) = 1;
                MILP.b(nMetsR + n + k, 1) = 1;
                MILP.csense(nMetsR + n + k, 1) = 'L';
                matchRev(matchRev(or)) = 0;
            end
        end

        MILP.A(end + 1, minP.bioID) = 1;
        MILP.A(end, nRxnsR + minP.bioID) = 1;
        MILP.b(end + 1) = 1 + minP.bioMin;
        MILP.csense(end + 1) = 'G';

        %product min
        MILP.A(end + 1,minP.proID) = 1;
        MILP.A(end, nRxnsR + minP.proID) = 1;
        MILP.b(end + 1) = 1 + minP.proMax;
        MILP.csense(end + 1) = 'G';

        MILP.x0 = zeros(nRxnsR + n, 1);
        MILP.osense = 1;

        % Solve MILP problem for first point
        
        data = struct();
        data.pro = zeros(midPoints, 1);
        data.bio = zeros(midPoints, 1);
        data.w = zeros(midPoints, 1);
        data.wBio = zeros(midPoints, 1);
        data.wPro = zeros(midPoints, 1);
        
        for i = 1:midPoints + 1
            try
                MILP.b(end) = 1 + minP.proMax - i * minP.proMin;
                s = solveCobraMILP(MILP, 'timeLimit', timeLimit, 'printLevel', printLevel);
                data.results(i) = s;
                if s.stat ~= 1
                    midPoints = midPoints + 1;
                    continue;
                end
                ActiveRxns = unique([model.rxns(var(s.int == 1)); model.rxns(K)]);
                InactiveRxns = model.rxns(var(s.int == 0));
                marModel = model;
                for ii = 1:numel(InactiveRxns)
                    tempModel = changeRxnBounds(marModel, InactiveRxns(ii), 0, 'b');
                    tempS = optimizeCbModel(tempModel);
                    if tempS.f ~= 0
                        marModel = tempModel;
                    end
                end
                if i == 1
                    data.mainModel = marModel;
                    data.mainActive = ActiveRxns;
                else
                    data.models(i-1) = marModel;
                    data.active{i-1} = ActiveRxns;
                end
                tempSol = optimizeCbModel(marModel);
                data.bio(i) = tempSol.f;
                marModel = changeObjective(marModel, marModel.rxns(minP.proID));
                marModel = changeRxnBounds(marModel, marModel.rxns(minP.bioID), 0, 'b');                
                s = optimizeCbModel(marModel,'min'); data.pro(i) = s.f;
            catch
                if isempty(ActiveRxns)
                    ActiveRxns = [];
                end
            end
        end
        
        % Calculation of n best results (showing results as graph)
        maxBio = max(data.bio);
        maxPro = max(data.pro);
        data.wBio = data.bio / maxBio;
        data.wPro = data.pro / maxPro;
        data.w = data.wBio + data.wPro;
        
    %% GENES
    case 1
        U=100001;
        model = buildRxnGeneMat(model);

        [nMetsR,nRxnsR] = size(model.S);
        nGenes = size(model.genes,1);

        % Create MILP problem for first point
        MILP = struct;
        MILP.A= model.S;
        MILP.b=model.b;
        MILP.csense(1:nMetsR,1) = 'E';
        MILP.c=zeros(nRxnsR,1);
        MILP.lb=model.lb;
        MILP.ub=model.ub;
        MILP.vartype(1:nRxnsR)='C';

        MILP.A = [MILP.A,            zeros(nMetsR, nGenes);
                  model.rxnGeneMat', -U*eye(nGenes)       ];
        
        MILP.b = [MILP.b; zeros(nGenes,1)];
        MILP.csense(end + 1:end + nGenes) = 'L';
        MILP.c = [MILP.c; ones(nGenes, 1)];
        MILP.lb = [MILP.lb; zeros(nGenes, 1)];
        MILP.ub = [MILP.ub; ones(nGenes, 1)];
        MILP.vartype(end + 1:end + nGenes) = 'B';

        MILP.A(end+1,minP.bioID)=1;
        MILP.A(end,nRxnsR+minP.bioID)=1;
        MILP.b(end+1) = 1+minP.bioMin;
        MILP.csense(end+1) = 'G';

        MILP.A(end+1,minP.proID)=1;
        MILP.A(end,nRxnsR+minP.proID)=1;
        MILP.b(end+1) = 1+minP.proMin;
        MILP.csense(end+1) = 'G';
        
        MILP.x0=zeros(nRxnsR+nGenes,1);
        MILP.osense=1;

        % Solve MILP problem for first point
        try
            s=solveCobraMILP(MILP, 'timeLimit', timeLimit);
            ActiveRxns=model.genes(s.int==1);
        catch
            ActiveRxns = [];
        end
    %% ENZYZMES    
    case 2 %enzymes
        %Spot for enzyme regulation (under construction)
end