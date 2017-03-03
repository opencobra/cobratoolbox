function  [rankFR,rankFRV,rankFRvanilla,rankFRVvanilla,model] = checkRankFR(model,printLevel)
% calculates the rank of [F R] and [F;R], when restricted to certain
% rows and columns
%
%INPUT
% model.S
% printLevel
%
%OUTPUT
% rankFR                    rank of [F R], when using only FRrows
% rankFRV                   rank of [F;R], when using only FRVcols
% rankFRvanilla             rank of [F R], when using all rows
% rankFRVvanilla            rank of [F;R], when using all cols
% model.FRrows              m x 1 boolean of rows of [F R] that are nonzero, 
%                           unique upto positive scaling and part of the 
%                           maximal conservation vector
% model.FRVcols             n x 1 boolean of cols of [F;R] that are nonzero, 
%                           unique upto positive scaling and part of the 
%                           maximal conservation vector
% model.FRirows             m x 1 boolean of rows of [F R] that are dependent
% model.FRdrows             m x 1 boolean of rows of [F R] that are dependent
% model.FRwrows             m x 1 boolean of independent rows of [F R] that
%                           have dependent rows amongst model.FRdrows
% model.FRVdcols            n x 1 boolean of cols of [F;R]that are dependent
% model.SConsistentMetBool  m x 1 boolean vector indicating metabolites involved
%                           in the maximal consistent vector
% model.SConsistentRxnBool  n x 1 boolean vector indicating metabolites involved
%                           in the maximal consistent vector
% model.FRnonZeroBool       m x 1 boolean vector indicating metabolites involved
%                           in at least one internal reaction
% model.FRuniqueBool        m x 1 boolean vector indicating metabolites with
%                           reaction stoichiometry unique upto scalar multiplication
% model.SIntRxnBool         n x 1 boolean vector indicating the non exchange
%                           reactions
% model.FRVnonZeroBool      n x 1 boolean vector indicating non exchange reactions
%                           with at least one metabolite involved
% model.FRVuniqueBool       n x 1 boolean vector indicating non exchange reactions
%                           with stoichiometry unique upto scalar multiplication
% model.connectedRowsFRBool     m x 1 boolean vector indicating metabolites in connected rows of [F,R]
% model.connectedRowsFRVBool    n x 1 boolean vector indicating complexes in connected columns of [F;R]
% model.V                   S*V=0, 1'*|V|>1 for all flux consistent reactions

if ~exist('printLevel','var')
    printLevel=1;
end

%scaling of stoichiometric matrix may be necessary when badly scaled, off
%by default
scaling='none';
%scaling='gmscal';
%scaling='minimumCoefficient';
switch scaling
    case 'minimumCoefficient'
        %rescale stoichiometric coefficients
        A=abs(model.S);
        minCoefficient=min(min(A(model.S~=0)));
        model.S=model.S*(1000/minCoefficient);
        model.lb=model.lb*(1000/minCoefficient);
        model.ub=model.ub*(1000/minCoefficient);
    case 'gmscal'
        %geometric mean scaling
        [cscale,rscale] = gmscal(model.S,0,0.9);
        %
        if 0
            model.S =diag(rscale)*model.S*diag(cscale);
            model.b =diag(rscale)*model.b;
            model.lb=diag(cscale)*model.lb;
            model.ub=diag(cscale)*model.ub;
            model.c =diag(cscale)*model.c;
        else
            %only scale columns
            model.S =model.S*diag(cscale);
            model.b =model.b;
            model.lb=diag(cscale)*model.lb;
            model.ub=diag(cscale)*model.ub;
            model.c =diag(cscale)*model.c;
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vanilla forward and reverse half stoichiometric matrices
F       = -model.S;
F(F<0)  =    0;
R       =  model.S;
R(R<0)  =    0;

%vanilla ranks
[rankFRvanilla,~,~]      = getRankLUSOL([F R]);
[rankFRVvanilla,~,~]     = getRankLUSOL([F;R]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nMet,nRxn]=size(model.S);

if ~isfield(model,'SIntRxnBool')  || ~isfield(model,'SIntMetBool')
    %finds the reactions in the model which export/import from the model
    %boundary i.e. mass unbalanced reactions
    %e.g. Exchange reactions
    %     Demand reactions
    %     Sink reactions
    model = findSExRxnInd(model);
end
model.SIntRxnBool_findSExRxnInd=model.SIntRxnBool;

%mass and charge balance
if isfield(model,'metFormulas')
    [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
        = checkMassChargeBalance(model,printLevel);
    model.balancedRxnBool=~imBalancedRxnBool;
    model.balancedMetBool=balancedMetBool;
    model.Elements=Elements;
    model.missingFormulaeBool=missingFormulaeBool;
    
    if nnz(model.missingFormulaeBool)<size(model.S,1)
        %assumes that all mass imbalanced reations are exchange reactions
        model.SIntRxnBool = model.SIntRxnBool & model.balancedRxnBool;
        model.SIntMetBool = model.SIntMetBool & model.balancedMetBool;
    end
end

%stoichiometric consistency
if ~isfield(model,'SConsistentMetBool') || ~isfield(model,'SConsistentRxnBool')
    %finds the metabolites in the model that are stoichiometrically
    %consistent
    if 0
        method.interface='solveCobraLP';
        method.solver='mosek';
        method.param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_DUAL_SIMPLEX';
    else
        method.interface='solveCobraLP';
        method.solver='gurobi6';
        method.param.Method=1;
    end
    [inform,m,model]=checkStoichiometricConsistency(model,printLevel-1,method);
    
    %assumes that all stoichiometrically inconsistent reactions are exchange reactions
    model.SIntRxnBool = model.SIntRxnBool & model.SConsistentRxnBool;
    model.SIntMetBool = model.SIntMetBool & model.SConsistentMetBool;
end

if printLevel>0
    fprintf('%u%s\n',nnz(~model.SIntRxnBool),' exchange reactions (imbalanced elementally, or involves a stoichiometrically inconsistent molecular species)')
    for i=1:nRxn
        if ~model.SIntRxnBool(i) && model.SIntRxnBool_findSExRxnInd(i)
            fprintf('%s%s\n',model.rxns{i},': deemed an exchange reaction')
        end
    end
    fprintf('---------\n')
end

if any(~model.SIntMetBool) & printLevel>0
    fprintf('%u%s\n',nnz(~model.SIntMetBool),' rows of S only involved in exchange reactions')
    for i=1:nMet
        if ~model.SIntMetBool(i)
            fprintf('%s%s\n',model.mets{i}',': deemed a molecular species only involved in exchange reactions')
        end
    end
    fprintf('---------\n')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%metBool1=(model.SConsistentMetBool | ~model.SIntMetBool); %incorrect to
%include mets that are only exchanged
metBool1=model.SConsistentMetBool;
rxnBool1=(model.SConsistentRxnBool | ~model.SIntRxnBool);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find rows that are not all zero when a subset of reactions omitted
A1=[F(:,rxnBool1) R(:,rxnBool1)];
model.FRnonZeroRowBool1 = any(A1,2);

%find cols that are not all zero when a subset of metabolites omitted
A1=[F(metBool1,:); R(metBool1,:)];
model.FRnonZeroColBool1 = any(A1,1)';

%only report for the consistent rows
if any(~model.FRnonZeroRowBool1 & metBool1) & printLevel>0
    fprintf('%u%s\n',nnz(~model.FRnonZeroRowBool1 & metBool1),' zero rows of [F,R]')
    for i=1:nMet
        if ~model.FRnonZeroRowBool1(i) && metBool1(i)
            fprintf('%s%s\n',model.mets{i},': is a zero row of [F,R]')
        end
    end
    fprintf('\n')
end

%only report for the consistent cols
if any(~model.FRnonZeroColBool1 & rxnBool1) && 0
    fprintf('%u%s\n',nnz(~model.FRnonZeroColBool1 & rxnBool1),' zero cols of consistent [F;R]')
    for i=1:nRxn
        if ~model.FRnonZeroColBool1(i) && rxnBool1(i)
            fprintf('%s%s\n',model.rxns{i},': is a zero col of consistent [F;R]')
        end
    end
    fprintf('\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=[F,R];%depends on the direction of reaction

%detect the rows of A that are identical upto scalar multiplication
%divide each row by the sum of each row.
sumA2            = sum(A,2);
sumA2(sumA2==0) = 1;
normalA2          = diag(1./sumA2)*A;

%get unique rows, but do not change the order
% [C,IA,IC] = unique(A,'rows') also returns index vectors IA and IC such
% that C = A(IA,:) and A = C(IC,:).
[uniqueRowsA,IA,IC] = unique(normalA2,'rows','stable');
model.FRuniqueRowBool=zeros(nMet,1);
model.FRuniqueRowBool(IA)=1;

if any(~model.FRuniqueRowBool & metBool1) & printLevel>0
    fprintf('%u%s\n',nnz(~model.FRuniqueRowBool & metBool1),' non-unique rows of stoich consistent [F,R]')
    for i=1:nMet
        if ~model.FRuniqueRowBool(i) && metBool1(i)
            fprintf('%s%s\n',model.mets{i},': not unique row of stoich consistent [F,R]')
        end
    end
    fprintf('\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=F+R;%invariant to direction of reaction

%detect the cols of A that are identical upto scalar multiplication
%divide each col by the sum of each row.
sumA1          = sum(A,1);
sumA1(sumA1==0)  = 1;
normalA1          = A*diag(1./sumA1);

%get unique cols, but do not change the order
% [C,IA,IC] = unique(A,'rows') also returns index vectors IA and IC such
% that C = A(IA,:) and A = C(IC,:).
[uniqueColsA,IA,IC] = unique(normalA1','rows','stable');
model.FRuniqueColBool=zeros(nRxn,1);
model.FRuniqueColBool(IA)=1;

if any(~model.FRuniqueColBool & rxnBool1) & printLevel>0
    fprintf('%u%s\n',nnz(~model.FRuniqueColBool & rxnBool1),' non-unique cols of stoich consistent [F;R]')
    for i=1:nRxn
        if ~model.FRuniqueColBool(i) && rxnBool1(i)
            fprintf('%s%s\n',model.rxns{i},': not unique col of stoich consistent [F;R]')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if printLevel>0
    fprintf('\n%s\n','Diagnostics on size of boolean vectors for rows:')
    fprintf('%s%u\n','SIntMetBool:                 ',nnz(model.SIntMetBool))
    fprintf('%s%u\n','SConsistentMetBool:          ',nnz(model.SConsistentMetBool))
    fprintf('%s%u\n','FRnonZeroRowBool1:               ',nnz(model.FRnonZeroRowBool1))
    fprintf('%s%u\n','FRuniqueRowBool:               ',nnz(model.FRuniqueRowBool))
    
    
    fprintf('\n%s\n','Diagnostics on size of boolean vectors for cols:')
    fprintf('%s%u\n','SIntRxnBool:                 ',nnz(model.SIntRxnBool))
    fprintf('%s%u\n','SConsistentRxnBool:          ',nnz(model.SConsistentRxnBool))
    fprintf('%s%u\n','FRnonzeroColBool:               ',nnz(model.FRnonZeroColBool1))
    fprintf('%s%u\n','FRuniqueColBool:               ',nnz(model.FRuniqueColBool))
    fprintf('\n')
end

if ~isempty(find(strcmp(model.mets(~model.SConsistentMetBool),'h[c]')))
    warning('h[c] is one of the inconsistent molecules')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
metBool2=model.SConsistentMetBool & model.FRuniqueRowBool & model.FRnonZeroRowBool1;
if 0
rxnBool2=(model.SConsistentRxnBool | ~model.SIntRxnBool);
else
rxnBool2=(model.SConsistentRxnBool | ~model.SIntRxnBool) & model.FRuniqueColBool;
end


%the uniqueness check has to be done before flux consistency since some
%models have a forward and backward reaction in separately, but these are
%the same reaction when both considered reversible.
if 1
    %from the unique exchange reactions, and the subset of the unique non-exchange
    %reactions that form a matrix with stoichiometrically consistent rows, 
    %check for reactions that are also flux consistent, with all reactions
    %reversible
    modelRev.S = model.S(metBool2,rxnBool2);
    
    %infinite bounds may be necessary when stoichiometric matrix is badly
    %scaled, in that case the minimum flux required (epsilon) is set to 1, the 
    %default lower and upper bounds are {-1000, 1000}, with epsilon 1e-4,
    %as that is two orders of magnitude higher than the typical feasibility
    %tolerance for volation of mass balance constraints.
    fluxConsistencyBounds='aThousand';
    switch fluxConsistencyBounds
        case 'aThousand'
            %use all reactions reversible
            modelRev.lb=-1000*ones(size(modelRev.S,2),1);
            modelRev.ub= 1000*ones(size(modelRev.S,2),1);
            epsilon = 1e-4;
        case 'infinity'
            %use all reactions reversible
            modelRev.lb=-inf*ones(size(modelRev.S,2),1);
            modelRev.ub= inf*ones(size(modelRev.S,2),1);
            epsilon = 1;
        case 'reconstruction'
            %use reconstruction reactions
            modelRev.lb=model.lb(rxnBool2);
            modelRev.ub=model.ub(rxnBool2);
            epsilon = 1e-4;
    end
    modelRev.mets=model.mets(metBool2);
    modelRev.rxns=model.rxns(rxnBool2);
    
    %fast consistency check code from Nikos Vlassis et al
    modeFlag=1;
    [indFluxConsist,~,V0]=fastcc(modelRev,epsilon,printLevel-1,modeFlag);
    modelRev.fluxConsistentRxnBool=false(size(modelRev.S,2),1);
    modelRev.fluxConsistentRxnBool(indFluxConsist)=1;
    
    %build the vector the same size as the original S
    model.fluxConsistentRxnBool=false(nRxn,1);
    %assign the boolean state to the original size model
    model.fluxConsistentRxnBool(rxnBool2)=modelRev.fluxConsistentRxnBool;
    
    %pad out V0 to correspond to the original size of S
    model.V=sparse(nRxn,size(V0,2));
    model.V(rxnBool2,:)=V0;
    
    %check to make sure booleans are correct
    if nnz(model.SConsistentRxnBool & ~model.SIntRxnBool)~=0
        error('No exchange reaction should be stoichiometrically consistent')
    end
    
    %check to make sure that V in nullspace of S.
    tmp=norm(full(model.S(metBool2,model.SConsistentRxnBool & model.SIntRxnBool)*model.V(model.SConsistentRxnBool & model.SIntRxnBool,:)...
           + model.S(metBool2,~model.SIntRxnBool)*model.V(~model.SIntRxnBool,:)));
    %two extra digits spare   
    if tmp>100*epsilon
        disp(tmp)
        error('Not flux consistent')
    end
    %create a stoichiometric matrix of perpetireactions only for
    %stoichiometrically and flux consistent part
    model.P=sparse(nMet,size(V0,2));
    model.P(metBool2,:)=model.S(metBool2,~model.SIntRxnBool)*model.V(~model.SIntRxnBool,:);
else
    model.fluxConsistentRxnBool=true(nRxn,1);
end
%rows corresponding to flux consistent reactions
model.fluxConsistentMetBool = sum(model.S(:,model.fluxConsistentRxnBool)~=0,2)~=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%eliminate the metabolites and reactions that are stoichiometrically 
%inconsistent or flux inconsistent from further consideration, but keep the
%flux consistent exchange reactions, also eliminate scalar multiples
metBool3=model.SConsistentMetBool & model.fluxConsistentMetBool & model.FRuniqueRowBool & model.FRnonZeroRowBool1;
rxnBool3=(model.SConsistentRxnBool | ~model.SIntRxnBool)  & model.FRuniqueColBool & model.fluxConsistentRxnBool;

%find rows that are not all zero when a subset of reactions omitted
A3=[F(:,rxnBool3) R(:,rxnBool3)];
model.FRnonZeroRowBool = any(A3,2);

%find cols that are not all zero when a subset of metabolites omitted
A3=[F(metBool3,:); R(metBool3,:)];
model.FRnonZeroColBool = any(A3,1)';

%only report for the latest subset of rows
if any(~model.FRnonZeroRowBool & metBool3) & printLevel>0
    fprintf('%u%s\n',nnz(~model.FRnonZeroRowBool & metBool3),' zero rows of [F,R]')
    for i=1:nMet
        if ~model.FRnonZeroRowBool(i) && metBool3(i)
            fprintf('%s%s\n',model.mets{i},': is a zero row of [F,R]')
        end
    end
    fprintf('\n')
end

%only report for the latest subset of cols
if any(~model.FRnonZeroColBool & rxnBool3) && 0
    fprintf('%u%s\n',nnz(~model.FRnonZeroColBool & rxnBool3),' zero cols of consistent [F;R]')
    for i=1:nRxn
        if ~model.FRnonZeroColBool(i) && rxnBool3(i)
            fprintf('%s%s\n',model.rxns{i},': is a zero col of consistent [F;R]')
        end
    end
    fprintf('\n')
end

%pause(eps)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A4=F(:,rxnBool3)+R(:,rxnBool3);%invariant to direction of reaction
% 
% %detect the cols of A that are identical upto scalar multiplication
% %divide each col by the sum of each row.
% sumA4             = sum(A4,1);
% sumA4(sumA4==0)   = 1;
% normalA4          = A4*diag(1./sumA4);
% 
% %get unique cols, but do not change the order
% % [C,IA,IC] = unique(A,'rows') also returns index vectors IA and IC such
% % that C = A(IA,:) and A = C(IC,:).
% [uniqueColsA,IA,IC] = unique(normalA4','rows','stable');
% model.FRuniqueColBool2=zeros(nRxn,1);
% model.FRuniqueColBool2(IA)=1;
% 
% if any(~model.FRuniqueColBool2 & rxnBool3)
%     fprintf('%u%s\n',nnz(~model.FRuniqueColBool2 & rxnBool3),' non-unique cols of consistent [F;R]')
%     for i=1:nRxn
%         if ~model.FRuniqueColBool(i) && rxnBool1(i)
%             fprintf('%s%s\n',model.rxns{i},': not unique col of consistent [F;R]')
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The largest connected component - not necessary, flux consistency takes
%care of this
if 0
    if 1
        %connected rows of [F,R] and columns of [F;R]
        [model.connectedRowsFRBool,model.connectedColsFRVBool]=connectedFR(F,R);
        [~,maxInd]=max(sum(model.connectedRowsFRBool,1));
        model.largestConnectedRowsFRBool=model.connectedRowsFRBool(:,maxInd);
        [~,maxInd]=max(sum(model.connectedColsFRVBool,1));
        model.largestConnectedColsFRVBool=model.connectedColsFRVBool(:,maxInd);
    else
        %largest connected rows of [F,R] and columns of [F;R]
        [model.largestConnectedRowsFRBool,model.largestConnectedColsFRVBool]=largestConnectedFR(F,R);
    end
else
    %bypass test for connectedness
    model.largestConnectedRowsFRBool=true(nMet,1);
    model.largestConnectedColsFRVBool=true(nRxn,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%diagnostics
if printLevel>0
    fprintf('\n%s\n','Diagnostics on size of boolean vectors for rows:')
    fprintf('%s%u\n','SConsistentMetBool:         ',nnz(model.SConsistentMetBool))
    fprintf('%s%u\n','fluxConsistentMetBool:      ',nnz(model.fluxConsistentMetBool))
    fprintf('%s%u\n','FRuniqueRowBool:               ',nnz(model.FRuniqueRowBool))
    fprintf('%s%u\n','FRnonZeroRowBool1:              ',nnz(model.FRnonZeroRowBool1))
    fprintf('%s%u\n','FRnonZeroRowBool:              ',nnz(model.FRnonZeroRowBool))
   % fprintf('%s%u\n','largestConnectedRowsFRBool: ',nnz(model.largestConnectedRowsFRBool))

    fprintf('\n%s\n','Diagnostics on size of boolean vectors for cols:')
    fprintf('%s%u\n','SIntRxnBool:                 ',nnz(model.SIntRxnBool))
    fprintf('%s%u\n','SConsistentRxnBool:          ',nnz(model.SConsistentRxnBool))
    fprintf('%s%u\n','fluxConsistentRxnBool:       ',nnz(model.fluxConsistentRxnBool))
    fprintf('%s%u\n','FRuniqueColBool:               ',nnz(model.FRuniqueColBool))
    fprintf('%s%u\n','FRnonZeroColBool1:              ',nnz(model.FRnonZeroColBool1))
    fprintf('%s%u\n','FRnonZeroColBool:              ',nnz(model.FRnonZeroColBool))
    %fprintf('%s%u\n','largestConnectedColsFRVBool: ',nnz(model.largestConnectedColsFRVBool))
    fprintf('\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%only use rows that are nonzero, unique upto positive scaling, part of
%the maximal conservation vector, and part of the largest component
selection='c';
switch selection
    case 'a'
        model.FRrows = model.SConsistentMetBool...
            & model.fluxConsistentMetBool...
            & model.FRnonZeroRowBool...
            & model.FRuniqueRowBool;
        model.FRVcols = (model.SConsistentRxnBool | ~model.SIntRxnBool)...
            & model.fluxConsistentRxnBool...
            & model.FRuniqueColBool...
            & model.FRnonZeroColBool;
    case 'b'
        %exchange reactions not considered when rank([F,R]) measured
        model.FRrows = model.SConsistentMetBool...
            & model.fluxConsistentMetBool...
            & model.FRnonZeroRowBool...
            & model.FRuniqueRowBool;
        model.FRVcols = model.SConsistentRxnBool...
            & model.fluxConsistentRxnBool...
            & model.FRuniqueColBool...
            & model.FRnonZeroColBool;
    case 'c'
        model.FRrows = model.SConsistentMetBool...
            & model.fluxConsistentMetBool...
            & model.FRnonZeroRowBool1...
            & model.FRnonZeroRowBool...
            & model.FRuniqueRowBool;
        model.FRVcols = (model.SConsistentRxnBool | ~model.SIntRxnBool)...
            & model.fluxConsistentRxnBool...
            & model.FRuniqueColBool...
            & model.FRnonZeroColBool;
    case 'd'
        model.FRrows = model.SConsistentMetBool...
            & model.fluxConsistentMetBool...
            & model.FRnonZeroRowBool1...
            & model.FRnonZeroRowBool...
            & model.FRuniqueRowBool;
        model.FRVcols = (model.SConsistentRxnBool | ~model.SIntRxnBool)...
            & model.fluxConsistentRxnBool;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%omit both the rows and the columns as specified above
Fr = F(model.FRrows,model.FRVcols);
Rr = R(model.FRrows,model.FRVcols);
Fc = F(model.FRrows,model.FRVcols);
Rc = R(model.FRrows,model.FRVcols);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
    method.interface='solveCobraLP';
    method.solver='mosek';
    method.param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_DUAL_SIMPLEX';
else
    method.interface='solveCobraLP';
    method.solver='gurobi5';
    method.param.Method=1;
end
modelCheck.S = Rr-Fr;
modelCheck.SIntRxnBool=model.SIntRxnBool;
modelCheck.SIntMetBool=model.SIntMetBool(model.FRrows);
[informC,mC,~]=checkStoichiometricConsistency(modelCheck,0,method);
%save check on consistency
model.mC=mC;
if informC~=1
    disp(length(mC)-nnz(mC))
    error('(R-F) not stoichiometrically consistent')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
    [A,B,C]=bilinearDecomposition(model.S(model.FRrows,model.FRVcols));
    %forward and reverse half stoichiometric matrices
    Fb        =   -B;
    Fb(Fb<0)  =    0;
    Rb        =    B;
    Rb(Rb<0)  =    0;
    Fb(Fb~=0) =    1;
    Rb(Rb~=0) =    1;
    adj = inc2adj([Fb Rb]);
    
    % Test whether a graph is bipartite, if yes, return the two vertex sets
    % Inputs: graph in the form of adjancency list (neighbor list, see adj2adjL.m)
    % Outputs: True/False (boolean), empty set (if False) or two sets of vertices
    tic
    [isit,partA,partB]=isbipartite(adj2adjL(adj));
    toc
    %pause(eps)
end

%check rank of bilinear version
if 1
    [A,B,C]=bilinearDecomposition(Fr-Rr);
    %forward and reverse half stoichiometric matrices
    Frb        =   -B;
    Frb(Frb<0)  =    0;
    Rrb        =    B;
    Rrb(Rrb<0)  =    0;
    
    %rank of [F R]
    [rankBilinearFrRr,bilinearFrRrp,bilinearFrRrq] = getRankLUSOL([Frb Rrb]);
    model.Frb=Frb;
    model.Rrb=Rrb;
    model.rankBilinearFrRr=rankBilinearFrRr;
    %pause(eps)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%rank of [F R]
[rankFR,FRp,FRq]      = getRankLUSOL([Fr Rr]);

%indices of rows that are dependent
ind=find(model.FRrows);
iR=ind(FRp(1:rankFR));
dR=ind(FRp(rankFR+1:length(FRp)));
model.FRdrows=false(nMet,1);
model.FRdrows(dR)=1;
model.FRirows=false(nMet,1);
model.FRirows(iR)=1;
model.FRq=FRq;
model.FRp=FRp;
model.Fr=Fr;
model.Rr=Rr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%rank of [F;R]
[rankFRV,FRVp,FRVq]  = getRankLUSOL([Fc;Rc]);

%boolean of non-exchange columns that are dependent
vertInd=find(model.FRVcols);
iC=vertInd(FRVq(1:rankFRV));
dC=vertInd(FRVq(rankFRV+1:length(FRVq)));
model.FRVdcols=false(nRxn,1);
model.FRVdcols(dC)=1;
model.FRVicols=false(nRxn,1);
model.FRVicols(iC)=1;
model.FRVq=FRVq;
model.FRVp=FRVp;
model.Fc=Fc;
model.Rc=Rc;

%sanity check
if nnz(model.FRrows) ~= nnz(model.FRrows & model.FRdrows)
    error('')
end
if nnz(model.FRVcols) ~= nnz(model.FRVcols & model.FRVdcols)
    error('')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%examine the dependencies between rows and columns if any
model.FRrowRankDeficiency=nnz(model.FRrows)-rankFR;
if model.FRrowRankDeficiency>0
    T  = [Fr Rr];
    %code from Michael
    C1 = T(FRp(1:rankFR),:);
    C2 = T(FRp(rankFR+1:length(FRp)),:);
    W0 = C1' \ C2'; % solves LS problems min ||C1'*W_k - C2_k'||

    model.FRW=sparse(model.FRrowRankDeficiency,nMet);
    model.FRW(:,iR)=W0';%L
    model.FRW(:,dR)=-speye(model.FRrowRankDeficiency);
    
    %indices of independent rows that other rows are dependent on
    wR=find(sum(abs(model.FRW),1)>0)';
    model.FRwrows=false(nMet,1);
    model.FRwrows(wR)=1;

    if 1
        %sanity checks
        disp(norm(C1'*W0 - C2',inf)) %should be zero
        disp(norm([W0',-speye(model.FRrowRankDeficiency)]*[C1;C2],inf)) %should be zero
        
        W = sparse(model.FRrowRankDeficiency,size([Fr Rr],1));
        W(:,FRp(1:rankFR))=W0';
        W(:,FRp(rankFR+1:length(FRp)))=-speye(model.FRrowRankDeficiency);
        disp(norm(W*[Fr Rr],inf)) %should be zero
               
        model.FRW=sparse(model.FRrowRankDeficiency,nMet);
        model.FRW(:,model.FRrows)=W;
        disp(norm(model.FRW*[F(:,model.FRVcols), R(:,model.FRVcols)],inf)) %should be zero
        %%%%% N B %%%%
        disp(norm(model.FRW*[F,R],inf)) % will not in general be zero as other columns of [F R] could contribute
    end
    
    if 0
        nnz(W)
        figure; spy(W)
        figure; spy(abs(W) > 1e-3)  % say
    end
end

model.FRcolRankDeficiency=nnz(model.FRVcols)-rankFRV;
if model.FRcolRankDeficiency>0
    VT  = [Fc;Rc];
    %code from Michael
    VC1  = VT(:,model.FRVq(1:rankFRV)); % independent columns
    VC2  = VT(:,model.FRVq(rankFRV+1:size(VT,2))); % dependent columns
    VW0  = VC1 \ VC2; % solves LS problems min ||VC1*WV_k - VC2_k||
    
    model.FRVW=sparse(nRxn,model.FRcolRankDeficiency);
    model.FRVW(iC,:)=VW0; % independent columns
    model.FRVW(dC,:)=-speye(model.FRcolRankDeficiency); % dependent columns
    
    %indices of independent cols that other cols are dependent on
    wC=find(sum(abs(model.FRVW),2)>0);
    model.FRVwcols=false(nRxn,1);
    model.FRVwcols(wC)=1;
    
    if printLevel>2
        %sanity check
        disp(norm([F(model.FRrows,:); R(model.FRrows,:)]*model.FRVW,inf))%should be zero
        %%%%% N B %%%%
        disp(norm([F;R]*model.FRVW,inf)) % will not in general be zero as other rows [F;R] could contribute
    end
    
    if 0
        nnz(VW0)
        figure; spy(VW0)
        figure; spy(abs(VW0) > 1e-3)  % say
    end
end
