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
model = createToyModelWDE();
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

%%  lift constraints with originally more than 2 variables (flux and extra variables)
% lift constraint (7) -v1 -1e6*v2 + u2 < 0 in GECKO-style model
BIG = 1e3;
printLevel = 0;
model = createToyModelWDE();
model.ctrs{7} = 'FlxExtrVar_2beLifted';




%revert to normal format
format short
