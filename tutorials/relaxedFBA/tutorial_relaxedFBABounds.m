clear;
rxnForms = {' -> A','A -> B','B -> C', 'B -> D','D -> C','C ->'};
rxnNames = {'R1','R2','R3','R4','R5', 'R6'};
model = createModel(rxnNames, rxnNames,rxnForms);
model.lb(3) = 1;
model.lb(4) = 2;
model.ub(6) = 2;
%% 
% Print the constraints

printConstraints(model, -1001, 1001)
%% 
% Identify the exchange reactions and biomass reaction(s) heuristically

model = findSExRxnInd(model,size(model.S,1),0);
%    relaxOption:    Structure containing the relaxation options:
%
%                      * internalRelax:
%
%                        * 0 = do not allow to relax bounds on internal reactions
%                        * 1 = do not allow to relax bounds on internal reactions with finite bounds
%                        * 2 = allow to relax bounds on all internal reactions
relaxOption.internalRelax = 2;
%
%                      * exchangeRelax:
%
%                        * 0 = do not allow to relax bounds on exchange reactions
%                        * 1 = do not allow to relax bounds on exchange reactions of the type [0,0]
%                        * 2 = allow to relax bounds on all exchange reactions
relaxOption.exchangeRelax = 0;
%                      * steadyStateRelax:
%
%                        * 0 = do not allow to relax the steady state constraint S*v = b
%                        * 1 = allow to relax the steady state constraint S*v = b
relaxOption.steadyStateRelax = 0;
%                      * toBeUnblockedReactions - n x 1 vector indicating the reactions to be unblocked (optional)
%
%                        * toBeUnblockedReactions(i) = 1 : impose v(i) to be positive
%                        * toBeUnblockedReactions(i) = -1 : impose v(i) to be negative
%                        * toBeUnblockedReactions(i) = 0 : do not add any constraint
%
%                      * excludedReactions - n x 1 bool vector indicating the reactions to be excluded from relaxation (optional)
%
%                        * excludedReactions(i) = false : allow to relax bounds on reaction i
%                        * excludedReactions(i) = true : do not allow to relax bounds on reaction i
%
%                      * excludedMetabolites - m x 1 bool vector indicating the metabolites to be excluded from relaxation (optional)
%
%                        * excludedMetabolites(i) = false : allow to relax steady state constraint on metabolite i
%                        * excludedMetabolites(i) = true : do not allow to relax steady state constraint on metabolite i
%
%% 
% Set the tolerance to distinguish between zero and non-zero flux

feasTol = getCobraSolverParams('LP', 'feasTol');
relaxOption.epsilon = feasTol/100;%*100;
%% 
% Call the relaxFBA function, deal the solution, and set small values to 
% zero

relaxOption

tic;
solution = relaxFBA(model,relaxOption);
timeTaken=toc;
[v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);
if 0
    p(p<relaxOption.epsilon) = 0;%lower bound relaxation
    q(q<relaxOption.epsilon) = 0;%upper bound relaxation
    r(r<relaxOption.epsilon) = 0;%steady state constraint relaxation
end
%% 
% The output is a solution structure with a 'stat' field reporting the solver 
% status and a set of fields matching the relaxation of constraints given in the 
% mathematical formulation of the relaxed flux balance problem above.

% OUTPUT:
%    solution:       Structure containing the following fields:
%                      * stat - status
%                        * 1  = Solution found
%                        * 0  = Infeasible
%                        * -1 = Invalid input
%                      * r - relaxation on steady state constraints S*v = b
%                      * p - relaxation on lower bound of reactions
%                      * q - relaxation on upper bound of reactions
%                      * v - reaction rate
%% 
% Summarise the proposed relaxation solution

if solution.stat == 1
   
   dispCutoff=relaxOption.epsilon;

    fprintf('%s\n',['Relaxed flux balance analysis problem solved in ' num2str(timeTaken) ' seconds.'])
    
    fprintf('%u%s\n',nnz(r),' steady state constraints relaxed');
     
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & ~abs(q)>dispCutoff & model.SIntRxnBool),' internal only lower bounds relaxed');
    fprintf('%u%s\n',nnz(abs(q)>dispCutoff & ~abs(p)>dispCutoff & model.SIntRxnBool),' internal only upper bounds relaxed');
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & abs(q)>dispCutoff & model.SIntRxnBool),' internal lower and upper bounds relaxed');

    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & ~abs(q)>dispCutoff & ~model.SIntRxnBool),' external only lower bounds relaxed');
    fprintf('%u%s\n',nnz(abs(q)>dispCutoff & ~abs(p)>dispCutoff & ~model.SIntRxnBool),' external only upper bounds relaxed');
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & abs(q)>dispCutoff & ~model.SIntRxnBool),' external lower and upper bounds relaxed');
    
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff | abs(q)>dispCutoff & ~model.SIntRxnBool),' external lower or upper bounds relaxed');
    
    maxUB = max(max(model.ub),-min(model.lb));
    minLB = min(-max(model.ub),min(model.lb));
    intRxnFiniteBound = ((model.ub < maxUB) & (model.lb > minLB));
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & intRxnFiniteBound),' finite lower bounds relaxed');
    fprintf('%u%s\n',nnz(abs(q)>dispCutoff & intRxnFiniteBound),' finite upper bounds relaxed');
    
    exRxn00 = ((model.ub == 0) & (model.lb == 0));
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & exRxn00),' lower bounds relaxed on fixed reactions (lb=ub=0)');
    fprintf('%u%s\n',nnz(abs(q)>dispCutoff & exRxn00),' upper bounds relaxed on fixed reactions (lb=ub=0)');
    
else
    disp('relaxFBA problem infeasible, check relaxOption fields');
end
rxnForms = {' -> A',...
            'A -> B',...
            'A -> C',...
            'D -> B',...
            'E -> C',...
            'E -> D',...
            'E -> ',...
            'A -> F',...
            'G -> F',...
            'H -> G',...
            'E -> H'};
rxnNames = {'R1','R2','R3','R4','R5','R6','R7','R8','R9','R10','R11'};
model = createModel(rxnNames, rxnNames,rxnForms);
%% 
% Assume all reactions are irreversible

model.lb(:) = 0;
model.ub(:) = 10;
%% 
% Reaction R7 with bounds 1 <= v_7 <= 10

model.lb(7) = 1;
%% 
% Print the constraints

printConstraints(model, -1001, 1001)
%% 
% Identify the exchange reactions and biomass reaction(s) heuristically

model = findSExRxnInd(model,size(model.S,1),0);
%    relaxOption:    Structure containing the relaxation options:
%
%                      * internalRelax:
%
%                        * 0 = do not allow to relax bounds on internal reactions
%                        * 1 = do not allow to relax bounds on internal reactions with finite bounds
%                        * 2 = allow to relax bounds on all internal reactions
relaxOption.internalRelax = 2;
%
%                      * exchangeRelax:
%
%                        * 0 = do not allow to relax bounds on exchange reactions
%                        * 1 = do not allow to relax bounds on exchange reactions of the type [0,0]
%                        * 2 = allow to relax bounds on all exchange reactions
relaxOption.exchangeRelax = 0;
%                      * steadyStateRelax:
%
%                        * 0 = do not allow to relax the steady state constraint S*v = b
%                        * 1 = allow to relax the steady state constraint S*v = b
relaxOption.steadyStateRelax = 0;
%                      * toBeUnblockedReactions - n x 1 vector indicating the reactions to be unblocked (optional)
%
%                        * toBeUnblockedReactions(i) = 1 : impose v(i) to be positive
%                        * toBeUnblockedReactions(i) = -1 : impose v(i) to be negative
%                        * toBeUnblockedReactions(i) = 0 : do not add any constraint
%
%                      * excludedReactions - n x 1 bool vector indicating the reactions to be excluded from relaxation (optional)
%
%                        * excludedReactions(i) = false : allow to relax bounds on reaction i
%                        * excludedReactions(i) = true : do not allow to relax bounds on reaction i
%
%                      * excludedMetabolites - m x 1 bool vector indicating the metabolites to be excluded from relaxation (optional)
%
%                        * excludedMetabolites(i) = false : allow to relax steady state constraint on metabolite i
%                        * excludedMetabolites(i) = true : do not allow to relax steady state constraint on metabolite i
%% 
% Set the tolerance to distinguish between zero and non-zero flux

feasTol = getCobraSolverParams('LP', 'feasTol');
relaxOption.epsilon = feasTol/100;%*100;
%% 
% Call the relaxFBA function, deal the solution, and set small values to 
% zero

tic;
solution = relaxFBA(model,relaxOption);
timeTaken=toc;
[v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);
if 0
    p(p<relaxOption.epsilon) = 0;%lower bound relaxation
    q(q<relaxOption.epsilon) = 0;%upper bound relaxation
    r(r<relaxOption.epsilon) = 0;%steady state constraint relaxation
end
%% 
% The output is a solution structure with a 'stat' field reporting the solver 
% status and a set of fields matching the relaxation of constraints given in the 
% mathematical formulation of the relaxed flux balance problem above.

% OUTPUT:
%    solution:       Structure containing the following fields:
%                      * stat - status
%                        * 1  = Solution found
%                        * 0  = Infeasible
%                        * -1 = Invalid input
%                      * r - relaxation on steady state constraints S*v = b
%                      * p - relaxation on lower bound of reactions
%                      * q - relaxation on upper bound of reactions
%                      * v - reaction rate
%% 
% Summarise the proposed relaxation solution

if solution.stat == 1
   
   dispCutoff=relaxOption.epsilon;

    fprintf('%s\n',['Relaxed flux balance analysis problem solved in ' num2str(timeTaken) ' seconds.'])
    
    fprintf('%u%s\n',nnz(r),' steady state constraints relaxed');
     
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & ~abs(q)>dispCutoff & model.SIntRxnBool),' internal only lower bounds relaxed');
    fprintf('%u%s\n',nnz(abs(q)>dispCutoff & ~abs(p)>dispCutoff & model.SIntRxnBool),' internal only upper bounds relaxed');
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & abs(q)>dispCutoff & model.SIntRxnBool),' internal lower and upper bounds relaxed');

    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & ~abs(q)>dispCutoff & ~model.SIntRxnBool),' external only lower bounds relaxed');
    fprintf('%u%s\n',nnz(abs(q)>dispCutoff & ~abs(p)>dispCutoff & ~model.SIntRxnBool),' external only upper bounds relaxed');
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & abs(q)>dispCutoff & ~model.SIntRxnBool),' external lower and upper bounds relaxed');
    
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff | abs(q)>dispCutoff & ~model.SIntRxnBool),' external lower or upper bounds relaxed');
    
    maxUB = max(max(model.ub),-min(model.lb));
    minLB = min(-max(model.ub),min(model.lb));
    intRxnFiniteBound = ((model.ub < maxUB) & (model.lb > minLB));
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & intRxnFiniteBound),' finite lower bounds relaxed');
    fprintf('%u%s\n',nnz(abs(q)>dispCutoff & intRxnFiniteBound),' finite upper bounds relaxed');
    
    exRxn00 = ((model.ub == 0) & (model.lb == 0));
    fprintf('%u%s\n',nnz(abs(p)>dispCutoff & exRxn00),' lower bounds relaxed on fixed reactions (lb=ub=0)');
    fprintf('%u%s\n',nnz(abs(q)>dispCutoff & exRxn00),' upper bounds relaxed on fixed reactions (lb=ub=0)');
    
else
    disp('relaxFBA problem infeasible, check relaxOption fields');
end