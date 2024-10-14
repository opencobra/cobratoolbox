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

%revert to normal format
format short