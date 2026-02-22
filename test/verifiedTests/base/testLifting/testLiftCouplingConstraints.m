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

%% gecko-style model - with pre-existing D and E fields, including constraints with equalities and more than 2 variables
% crate model with constraints:
% #1: -1e6*v2 + v3 < 0,   with 2 flux variables and bad scaled
%                         coefficient.
% #2: v1 -v2 -v3 < 0,     with more than 2 flux variables.
% #3: v2 -v3 < 0,         with 2 flux variables and no bad scaled
%                         coefficient.
% #4: -1e6*v1 + u1 = 0,   with 2 variables (1 flux variable + 1 extra
%                         variable), and a badscaled coefficient.
% #5: u1 + u2 -upool < 0, with more that 2 variables (all extra
%                         variables), and no bad scaled coefficient.
% #6: -v3 + u2 = 0,       with 2 variables (1 flux variable + 1 extra
%                         variable), and no bad coeficient.
% #7: -v1 -1e6*v2 + u2 < 0, with more than 2 variables
%                           (flux and extra variables).
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
C_expt = [1, -1, -1;
           0, 0, 0;
           1, 0, 0;
           0, 0, 1;
           0, 1, -1;
           0, 0, 0;
           0, 0, -1;
           0, 0, 0;
           0, 0, 0;
           0, -100, 0;
           0, 0, 0;
           -100, 0, 0;
           0, 0, 0;
           0, -100, 0];
D_expt = [zeros(1, 10);
          [1, 1, -1, zeros(1, 7)];
          [0, -1, 0, 1, zeros(1, 6)];
          [zeros(1, 4), -100, zeros(1, 5)];
           zeros(1, 10);
           [1, zeros(1, 5), -100, zeros(1, 3)];
           [0, 1, zeros(1, 8)];
           [zeros(1, 3), 1, zeros(1, 4), -100, 0];
           [zeros(1, 4), 1, -100, zeros(1, 4)];
           [zeros(1, 5), 1, zeros(1, 4)];
           [zeros(1, 6), 1, -100, 0, 0];
           [zeros(1, 7), 1, 0, 0];
           [zeros(1, 8), 1, -100];
           [zeros(1, 9), 1]];
E_expt = zeros(1, 10);
evarlb_expt = [zeros(3, 1); -Inf*ones(7, 1)];
evarub_expt = [[1e9; 1e3; 1e3]; Inf*ones(7, 1)];
evarc_expt = [zeros(2, 1); 1; zeros(7, 1)];
evars_expt = {'u1'; 'u2'; 'upool'; 'z_1'; 'LIFT1_v2'; 'LIFT2_v2'; 'LIFT1_v1'; 'LIFT2_v1'; 'LIFT1_v2'; 'LIFT2_v2'};
dsense_expt = [repmat('L', 2, 1); 'E'; repmat('L', 2, 1); 'E'; repmat('L', 4, 1); repmat('E', 2, 1); repmat('L', 2, 1)];

assert(isequal(model_lifted.C(:), C_expt(:)));
assert(isequal(model_lifted.D(:),  D_expt(:)));
assert(isequal(model_lifted.E(:), E_expt(:)));

assert(isequal(model_lifted.evarlb, evarlb_expt));
assert(isequal(model_lifted.evarub, evarub_expt));

assert(isequal(model_lifted.evarc, evarc_expt));
assert(isequal(model_lifted.evars, evars_expt));

assert(isequal(model_lifted.dsense, dsense_expt));

disp(full([model_lifted.C, model_lifted.D]));
% Row 1: v1 -v2 -v3 < 0 (constraint #2)
% Row 2: u1 + u2 - upool < 0 (constraint #5)
% Row 3: -u2 + z1 + v1 = 0 (constraint #7 - split variable definition: z1 = u2 -v1)
% Row 4: v3 -100s1 < 0 (constraint #1 - dummy chain)
% Row 5: v2 - v3 < 0 (constraint #3)
% Row 6: u1 - 100s3 = 0 (constraint #4 - dummy chain)
% Row 7: -v3 + u2 < 0 (constraint #6)
% Row 8: z1 - 100s5 < 0 (constraint #7 - dummy chain)
% Row 9: s1 -100s2 < 0 (constraint #1 - dummy chain)
% Row 10: s2 -100v2 < 0 (constraint #1 - dummy chain)
% Row 11: s3 -100s4 = 0 (constraint #4 - dummy chain)
% Row 12: s4 -100v1 = 0 (constraint #4 - dummy chain)
% Row 13: s5 -100s6 < 0 (constraint #7 - dummy chain)
% Row 14: s6 -100v2 < 0 (constraint #7 - dummy chain)


% test when fields for extra variables are missing: 'D', 'E', 'evars'
model = rmfield(model, {'E', 'D', 'evars', 'evarNames', 'evarc', 'evarlb', 'evarub'});
model.C = model.C(1:3, :); % removes constraints using extra variables in the previous test model
model.ctrs = model.ctrs(1:3, :);
model.ctrNames = model.ctrNames(1:3, :);
model.d = model.d(1:3, :);
model.dsense = model.dsense(1:3, :);

param = struct();
LP0 = buildOptProblemFromModel(model, 'true', struct());
sol0 = solveCobraLP(LP0, struct());
BIG = 1e3;
printLevel = 0;
model_lifted = liftCouplingConstraints(model, BIG, printLevel);
LP1 = buildOptProblemFromModel(model_lifted, 'true', struct());
sol1 = solveCobraLP(LP1);
assert(sol0.stat == 1) % it is feasible before
assert(sol1.stat == 1) % it is feasible after lifting
assert(abs(sol0.obj - sol1.obj) < tol);
[~, n] = size(model.S);
assert(all(abs(sol1.full(1:n) - sol0.full(1:n)) < tol));
C_expt = [1, -1,  -1;
          0, 0, 1;
          0, 1, -1;
          0, 0, 0;
          0, -100, 0];
D_expt = [0, 0;
          -100, 0;
          0, 0;
          1, -100;
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
disp(full([model_lifted.C, model_lifted.D]));
% Row 1: v1 -v2 -v3 < 0 (constraint #2)
% Row 2: v3 -100 s1 < 0 (constraint #1 chain)
% Row 3: v2 -v3 < 0 (constraint #3)
% Row 4: s1 - 100s2 < 0 (constraint #1 chain)
% Row 5: s2 -100v2 < 0 (constraint #1 chain)

% test if spliting of constraints with more than 2 variables
% also happens when D and E are missing
model.C = [-1, -1e6, 1]; % model just with -v1 -1e6v2 + v3 < 0
model.d = 0;
model.dsense = 'L';
model.ctrs = {'flxVarOnly_splitAndLift'};
model.ctrNames = {'flxVarOnly_splitAndLift'};
param = struct();
LP0 = buildOptProblemFromModel(model, 'true', struct());
sol0 = solveCobraLP(LP0, struct());
BIG = 1e3;
printLevel = 0;
model_lifted = liftCouplingConstraints(model, BIG, ...
    printLevel, true); % 'true' is needed to allow equalities.
%                         during splitting equalities are created
%                         to define the split variable
LP1 = buildOptProblemFromModel(model_lifted, 'true', struct());
sol1 = solveCobraLP(LP1);
assert(sol0.stat == 1) % it is feasible before
assert(sol1.stat == 1) % it is feasible after lifting
assert(abs(sol0.obj - sol1.obj) < tol);
[~, n] = size(model.S);
assert(all(abs(sol1.full(1:n) - sol0.full(1:n)) < tol));
C_expt = [1, 0, -1;
          0, 0, 0;
          0, 0, 0;
          0, -100, 0];
D_expt = [1, 0, 0;
          1, -100, 0;
          0, 1, -100;
          0, 0, 1];
E_expt = zeros(1, 3);
evarlb_expt = -Inf*ones(3, 1);
evarub_expt = Inf*ones(3, 1);
evarc_expt = [0; 0; 0];
evars_expt = {'z_1'; 'LIFT1_v2'; 'LIFT2_v2'};
dsense_expt = ['E'; repmat('L', 3, 1)];

assert(isequal(model_lifted.C(:), C_expt(:)));
assert(isequal(model_lifted.D(:), D_expt(:)));
assert(isequal(model_lifted.E(:), E_expt(:)));

assert(isequal(model_lifted.evarlb, evarlb_expt));
assert(isequal(model_lifted.evarub, evarub_expt));

assert(isequal(model_lifted.evarc, evarc_expt));
assert(isequal(model_lifted.evars, evars_expt));

assert(isequal(model_lifted.dsense, dsense_expt));
disp(full([model_lifted.C, model_lifted.D]));
% Row 1: v1 -v2 + z1 = 0
% Row 2: z1 -100s1 < 0
% Row 3: s1 - 100s2 < 0
% Row 4: s2 -100v2 < 0

% % THIS TEST IS CURRENTLY FAILING - these constraints are being skipped
% % The same maths applied before does not apply in this case
% % objective value is same before and after lifting but 
% % assert(all(abs(sol1.full(1:n) - sol0.full(1:n)) < tol)); fails.
% %
% % Test if spliting of constraints with more than 2 variables
% % works when there is more than 1 coefficient to be lifted in same
% % constraint
% clear model
% model.S = [1 -1 -1];
% model.rxns = {'v1'; 'v2'; 'v3'};
% model.mets = {'met1'};
% model.b = 0;
% model.csense = 'E';
% model.c = [0; 0; 1];
% model.lb = zeros(3, 1);
% model.ub = [1e9; 1e3; 1e3];
% % model just with constraint -1e6v1 -1e4v2 + 1e4v3 < 0
% model.C = [-1e6, -1e4, 1e4];
% model.d = 0;
% model.dsense = 'L';
% model.ctrs = {'flxVarOnly_splitAndLift'};
% model.ctrNames = {'flxVarOnly_splitAndLift'};
% param = struct();
% LP0 = buildOptProblemFromModel(model, 'true', struct());
% sol0 = solveCobraLP(LP0, struct());
% BIG = 1e3;
% printLevel = 0;
% model_lifted = liftCouplingConstraints(model, BIG, ...
%     printLevel, true); % 'true' is needed to allow equalities.
% %                         during splitting equalities are created
% %                         to define the split variable
% LP1 = buildOptProblemFromModel(model_lifted, 'true', struct());
% sol1 = solveCobraLP(LP1);
% assert(sol0.stat == 1) % it is feasible before
% assert(sol1.stat == 1) % it is feasible after lifting
% assert(abs(sol0.obj - sol1.obj) < tol);
% [~, n] = size(model.S);
% assert(all(abs(sol1.full(1:n) - sol0.full(1:n)) < tol));
% C_expt = [0, 0, 0;
%           0, 0, 0;
%           0, 0, 0;
%           -100, 0, 0;
%           0, 0, 0;
%           0, 0, 0;
%           0, 100, 0;
%           0, 0, 100];
% D_expt = [1, 0, 0, -1, 0, 1, 0;
%           1, -100, zeros(1, 5);
%           0, 1, -100, zeros(1, 4);
%           0, 0, 1, zeros(1, 4);
%           zeros(1, 5), 1, -100;
%           zeros(1, 3), 1, -100, 0, 0;
%           zeros(1, 4), 1, 0, 0;
%           zeros(1, 6), 1];
% E_expt = zeros(1, 7);
% evarlb_expt = -Inf*ones(7, 1);
% evarub_expt = Inf*ones(7, 1);
% evarc_expt = zeros(7, 1);
% evars_expt = {'z_1'; 'LIFT1_v1'; 'LIFT2_v1'; 'z_2'; 'LIFT1_v2'; 'z_3'; 'LIFT1_v3'};
% dsense_expt = ['E'; repmat('L', 3, 1); repmat('E', 4, 1)];
% 
% assert(isequal(model_lifted.C(:), C_expt(:)));
% assert(isequal(model_lifted.D(:), D_expt(:)));
% assert(isequal(model_lifted.E(:), E_expt(:)));
% 
% assert(isequal(model_lifted.evarlb, evarlb_expt));
% assert(isequal(model_lifted.evarub, evarub_expt));
% 
% assert(isequal(model_lifted.evarc, evarc_expt));
% assert(isequal(model_lifted.evars, evars_expt));
% 
% assert(isequal(model_lifted.dsense, dsense_expt));
% disp(full([model_lifted.C, model_lifted.D]));


% ?when 2 constraints with a bad coefficient
% in the same variable are lifted, the name of the new evar is the same,
% therefore the same evar name exists for two different evar entries.
% Should be solved?

%revert to normal format
format short

