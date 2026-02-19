%    model: 
%                         * C - `k x n` Left hand side of C*v <= d
%                         * d - `k x 1` Right hand side of C*v <= d
%                         * ctrs `k x 1` Cell Array of Strings giving IDs of the coupling constraints
%                         * dsense - `k x 1` character array with entries in {L,E,G}
%          v1       v2

if exist('model','var')
    clear model
end

BIG = 999;
printLevel = 1;

%% positive and negative coefficients
model.S = [0, 0];
model.rxns = {'rxn1';'rxn2'};
model.C = [ 1,  -10000];
model.d = 0;
model.dsense = 'L';
model.ctrs = {'test'};

[model_lifted] = liftCouplingConstraints(model, BIG, printLevel);

format rational
disp(full([model_lifted.C, model_lifted.D]))

% if 1
%     stp = 2^ceil(log2(qty)/dum);  % Compute the step size as a power of 2, ensuring equal division by the number of dummies
% else
%     stp = nthroot(10000,dum+1);
% end
% v1            v2             s1   
% 1              0         -16384       
% 0           -625/1024         1       


% if 0
%     stp = 2^ceil(log2(qty)/dum);  % Compute the step size as a power of 2, ensuring equal division by the number of dummies
% else
%     stp = nthroot(qty,dum+1);
% end
% Replacing 1 badly-scaled coupling constraints with sequences of
% well-scaled coupling constraints. This may take a few minutes.
%        1              0           -100       
%        0           -100              1    

%% positive and large negative coefficients
model.S = [0, 0];
model.rxns = {'rxn1';'rxn2'};
model.C = [ 1,  -1000000];
model.d = 0;
model.dsense = 'L';
model.ctrs = {'test'};

[model_lifted] = liftCouplingConstraints(model, BIG, printLevel);

format rational
disp(full([model_lifted.C, model_lifted.D]))

%% positive coefficients with second large positive coefficient
model.S = [0, 0];
model.rxns = {'rxn1';'rxn2'};
model.C = [ 1,  1000000];
model.d = 0;
model.dsense = 'L';
model.ctrs = {'test'};

[model_lifted] = liftCouplingConstraints(model, BIG, printLevel);

format rational
disp(full([model_lifted.C, model_lifted.D]))

%% positive coefficients only
model.S = [0, 0];
model.rxns = {'rxn1';'rxn2'};
model.C = [ 1,  10000];
model.d = 0;
model.dsense = 'L';
model.ctrs = {'test'};

[model_lifted] = liftCouplingConstraints(model, BIG, printLevel);

format rational
disp(full([model_lifted.C, model_lifted.D]))

%% 
model.S = [0, 0];
model.rxns = {'rxn1';'rxn2'};

model.C = [ 1,  -1e9];
model.d = 0;
model.dsense = 'L';
model.ctrs = {'test'};

[model_lifted] = liftCouplingConstraints(model, BIG, printLevel);

format rational
disp(full([model_lifted.C, model_lifted.D]))

% Replacing 1 badly-scaled coupling constraints with sequences of
% well-scaled coupling constraints. This may take a few minutes.
%        1              0          -1000              0       
%        0              0              1          -1000       
%        0          -1000              0              1      

%% gecko-style model - with pre-existing D and E fields and some equalities in constraints
% create toy model with contraints:
% (1) -1e6*v2 + v3 < 0, with only flux variables to be lifted
% (2) v1 -v2 -v3 < 0, with more than 2 flux variables (not to belifted)
% (3) v2 -v3 < 0, with 2 flux variables and no bad element (not to be lifted)
% (4) -1e6*v1 + u1 = 0,  with 1 flux variable and 1 extra-variable, with a bad element (to be lifted) 
% (5) u1 + u2 -upool = 0, with extravariables only, equivalente to sum of all enzyme usages in GECKO (not to be lifted)
% (6) -v3 + u2 = 0, with 1 flux variable and 1 extra-variable, with no bad element (not to be lifted) 
% (7) -v1 -1e6*v2 + u2 < 0, with more than 2 variables (flux and extra variables) - not to be lifted for now)
model.S = [1, -1, -1]; % v1 = V2 + v3
model.rxns = {'v1'; 'v2'; 'v3'};
model.mets = {'met1'};
model.csense = 'E';
model.b = 0;
model.c = [0; 0; 0]; % fluxes of reactions using enzymes in GECKO-style models is positive (no irreversible rxns)
model.lb = zeros(3, 1);
model.ub = 10*ones(numel(model.rxns), 1);
model.osense = 1; % minimize
% coupling constraint with flux variables only and to be lifted:
% -1e6v2 + v3 < 0
C1 = [0 -1e6 1]; 
D1 = [0 0 0];
% coupling constraint with flux variables only and not to be selected for
% further processing:
% v1 -v2 -v3 < 0
C2 = [1 -1 -1]; 
D2 = [0 0 0];
% coupling constraint with flux variables only and to be selected for
% further processing:
% v2 - v3 < 0
C3 = [0 1 -1];
D3 = [0 0 0];
% coupling constraint with flux variables and extra variables to be lifted:
% -1e6v1 + u1 = 0
C4 = [-1e6 0 0]; 
D4 = [1 0 0];
% coupling constraint with extra variable only and not to be lifted -
% equivalent to sum of all enzyme usage variables in GECKO:
% u1 + u2 - u3 = 0
C5 = [0 0 0];
D5 = [1 1 -1];
% coupling constraint with flux variables and extra variables to be
% selected for further processing, but not lifted:
% -v3 + u2 = 0 
C6 = [0 0 -1];
D6 = [0 1 0];
% coupling constraint with flux variables and extra variables not to be
% selected for further processing (since it has more than 2 variables):
% -v1 -1e6v2 + u2 < 0
C7 = [-1 -1e6 0];
D7 = [0 1 0];

model.C = [C1; C2; C3; C4; C5; C6; C7];
model.D = [D1; D2; D3; D4; D5; D6; D7];
model.ctrs = {'flxVarOnly_2beLifted'; 'flxVarOnly_Not2beProcessed'; 'flxVarOnly_2beProcessed'; 'FlxExtrVar_2beLifted'; 'ExtrVarOnly_sumflux'; 'FlxExtrVar_2beProcessed'; 'FlxExtrVar_Not2beProcessed'};
model.ctrNames = model.ctrs;
model.d = zeros(numel(model.ctrs), 1);
model.dsense = [repmat('L', 3, 1); 'E'; repmat('L', 3, 1)];
model.evars = {'u1'; 'u2'; 'upool'};
model.evarNames = model.evars;
model.evarc = [0; 0; 1]; % minimize the enzyme pool
model.evarlb = zeros(numel(model.evars), 1); % enzyme concentration cannot be negative
model.evarub = [1e9; 1e3; 1e3];
model.E = zeros(size(model.S, 1), numel(model.evars));

% solve before lifting
param = struct();
LP0 = buildOptProblemFromModel(model, 'true', struct());
sol0 = solveCobraLP(LP0, struct()); % considers additional constraints from C, D and E when doing FBA

% lift
BIG = 1e3;
printLevel = 0;
model_lifted = liftCouplingConstraints(model, BIG, printLevel, true); % true for handling equalities

% solve after lifting
LP1 = buildOptProblemFromModel(model_lifted, 'true', struct());
sol1 = solveCobraLP(LP1);

% test if objective value is the same
tol = getCobraSolverParams('LP','optTol');
assert(sol0.stat == 1) % it is feasible before
assert(sol1.stat == 1) % it is feasible after lifting
assert(abs(sol0.obj - sol1.obj) < tol);

% test if flux vector is the same
[~, n] = size(model.S);
nOrigExtrVar = numel(model.evars); % # of enzyme usage variables in GECKO
nOrigVar = n + nOrigExtrVar;
assert(all(abs(sol1.full(1:nOrigVar) - sol0.full(1:nOrigVar)) < tol));

% compare expected lifted and obtained fields
C_expt = [1, -1, -1; ...
           0, 0, 0; ...
           -1, -1e6, 0; ...
           0, 0, 1; ...
           0, 1, -1; ...
           0, 0, 0; ...
           0, 0, -1; ...
           0, 0, 0;
           0, -100, 0;
           0, 0, 0;
           -100, 0, 0];
D_expt = [zeros(1, 7); ...
          [1, 1, -1, zeros(1, 4)]; ...
          [0, 1, zeros(1, 5)]; ...
          [zeros(1, 3), -100, zeros(1, 3)]; ...
           zeros(1, 7); ...
           [1, zeros(1, 4), -100, 0];
           [0, 1, zeros(1, 5)];
           [zeros(1, 3), 1, -100, 0, 0]; ...
           [zeros(1, 4), 1, 0, 0]; ...
           [zeros(1, 5), 1, -100];
           [zeros(1, 6), 1]];
E_expt = zeros(1, 7);
evarlb_expt = [zeros(3, 1); -Inf*ones(4, 1)];
evarub_expt = [[1e9; 1e3; 1e3]; Inf*ones(4, 1)];
evarc_expt = [zeros(2, 1); 1; zeros(4, 1)];
evars_expt = {'u1'; 'u2'; 'upool'; 'LIFT1_v2'; 'LIFT2_v2'; 'LIFT1_v1'; 'LIFT2_v1'};
dsense_expt = [repmat('L', 5, 1); 'E'; repmat('L', 3, 1); repmat('E', 2, 1)];

assert(isequal(model_lifted.C(:), C_expt(:)));
assert(isequal(model_lifted.D(:),  D_expt(:)));
assert(isequal(model_lifted.E(:), E_expt(:)));

assert(isequal(model_lifted.evarlb, evarlb_expt));
assert(isequal(model_lifted.evarub, evarub_expt));

assert(isequal(model_lifted.evarc, evarc_expt));
assert(isequal(model_lifted.evars, evars_expt));

assert(isequal(model_lifted.dsense, dsense_expt));

format short
disp(full([model_lifted.C, model_lifted.D]));

% ADD EQUALITIES AND TEST WITH SIMPLER MODEL OR THIS MODEL MODIFIED
% LIFT IN CASES OF -v1 -1e6v2 + u2 < 0
% TEST
% PUT FUNCTION AS CLOSE TO THE ORIGINAL

% test when fields for extra variables are missing: 'D', 'E', 'evars', ...
model = rmfield(model, {'E', 'D', 'evars', 'evarNames', 'evarc', 'evarlb', 'evarub'});
model.C = model.C(1:3, :); % removes constraints using extra variables in the previous test model
model.ctrs = model.ctrs(1:3, :);
model.ctrNames = model.ctrNames(1:3, :);
model.d = model.d(1:3, :);
model.dsense = model.dsense(1:3, :);

param = struct();
LP0 = buildOptProblemFromModel(model, 'true', struct());
sol0 = solveCobraLP(LP0, struct());
model_lifted = liftCouplingConstraints(model, BIG, printLevel);
LP1 = buildOptProblemFromModel(model_lifted, 'true', struct());
sol1 = solveCobraLP(LP1);
assert(sol0.stat == 1) % it is feasible before
assert(sol1.stat == 1) % it is feasible after lifting
assert(abs(sol0.obj - sol1.obj) < tol);
[~, n] = size(model.S);
assert(all(abs(sol1.full(1:n) - sol0.full(1:n)) < tol));
C_expt = [1, -1,  -1; ...
          0, 0, 1; ...
          0, 1, -1; ...
          0, 0, 0; ...
          0, -100, 0];
D_expt = [0, 0; ...
          -100, 0; ...
          0, 0; ...
          1, -100; ...
          0, 1];
E_expt = zeros(1, 2);
evarlb_expt = -Inf*ones(2, 1);
evarub_expt = Inf*ones(2, 1);
evarc_expt = zeros(2, 1);
evars_expt = {'LIFT1_v2'; 'LIFT2_v2'};
dsense_expt = repmat('L', 5, 1);

assert(isequal(model_lifted.C(:), C_expt(:)));
assert(isequal(model_lifted.D(:), D_expt(:)));
assert(isequal(model_lifted.E(:), E_expt(:)));

assert(isequal(model_lifted.evarlb, evarlb_expt));
assert(isequal(model_lifted.evarub, evarub_expt));

assert(isequal(model_lifted.evarc, evarc_expt));
assert(isequal(model_lifted.evars, evars_expt));

assert(isequal(model_lifted.dsense, dsense_expt));

%revert to normal format
format short