function OptimizationModel = buildMTAproblemFromModel(model,rxnFBS,Vref,varargin)
% Returns the COBRA Optimization model needed to perform the MTA
%
% USAGE:
%
%       OptimizationModel = buildMTAproblemFromModel(model,rxnFBS,Vref,alpha,epsilon)
%
% INPUT:
%    model:                 Metabolic model (COBRA format)
%    rxnFBS:                Forward, Backward and Unchanged (+1;0;-1) values
%                           corresponding to each reaction.
%    Vref:                  Reference flux of the source state.
%    alpha:                 parameter of the quadratic problem (default = 0.66)
%    epsilon                minimun disturbance for each reaction, (default = 0)
%
% OUTPUTS:
%    OptimizationModel:     COBRA model struct that includes the
%                           stoichiometric contrains, the thermodinamic
%                           constrains and the binary variables.
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.

p = inputParser; % check the inputs
% check requiered arguments
addRequired(p, 'model');
addRequired(p, 'rxnFBS', @isnumeric);
addRequired(p, 'Vref', @isnumeric);
% Check optional arguments
addOptional(p, 'alpha', 0.66, @isnumeric);
addOptional(p, 'epsilon', zeros(size(model.rxns)), @isnumeric);
% extract variables from parser
parse(p, model, rxnFBS, Vref, varargin{:});
alpha = p.Results.alpha;
epsilon = p.Results.epsilon;

% sometimes epsilon can be given as a single value
if numel(epsilon)==1
    epsilon = epsilon * ones(size(model.rxns));
end


%% --- set the COBRA model ---

% variables
v = 1:length(model.rxns);
y_plus_F = (1:sum(rxnFBS==+1)) + v(end);             % 1 if change in rxnForward, 0 otherwise
y_minus_F = (1:sum(rxnFBS==+1)) + y_plus_F(end);     % 1 if no change in rxnForward, 0 otherwise
y_plus_B = (1:sum(rxnFBS==-1)) + y_minus_F(end);     % 1 if change in rxnBackward, 0 otherwise
y_minus_B = (1:sum(rxnFBS==-1)) + y_plus_B(end);     % 1 if no change in rxnBackward, 0 otherwise
n_var = y_minus_B(end);

% limits of the variables
lb = zeros(n_var,1);
ub = ones (n_var,1);
lb(v) = model.lb;
ub(v) = model.ub;

%type of variables
vartype(1:n_var) = 'B';
vartype(v) = 'C';

% constrains
Eq1 = 1:length(model.mets);                 % Stoichiometric matrix
Eq2 = (1:length(y_plus_F)) + Eq1(end);      % Changes in Forward
Eq3 = (1:length(y_plus_F)) + Eq2(end);      % Change or not change in Forward
Eq4 = (1:length(y_plus_B)) + Eq3(end);      % Changes in Backward
Eq5 = (1:length(y_plus_B)) + Eq4(end);      % Change or not change in Backward
nCon = Eq5(end);

% generate constrain matrix
A = spalloc(nCon, n_var, nnz(model.S) + 5*length(Eq2) + 5*length(Eq4));
b = zeros(nCon,1);
csense = char(zeros(nCon,1));

posF = find(rxnFBS == +1);
posB = find(rxnFBS == -1);
posS = find(rxnFBS == 0);

% First contraint, stoichiometric
A(Eq1,v) = model.S;
b(Eq1) = 0;
csense(Eq1) = 'E';

% Second contraint, Change or not change in Forward
A(Eq2,v(posF)) = eye(length(posF));
A(Eq2,y_plus_F) = - ( Vref(posF) + epsilon(posF) ) .* eye(length(posF));
A(Eq2,y_minus_F) = - model.lb(posF) .* eye(length(posF));
b(Eq2) = 0;
csense(Eq2) = 'G';

% Third contraint, Change or not change in Forward
A(Eq3,y_plus_F) = eye(length(Eq3));
A(Eq3,y_minus_F) = eye(length(Eq3));
b(Eq3) = 1;
csense(Eq3) = 'E';

% Fourth contraint, Backward changes
A(Eq4,posB) = eye(length(posB));
A(Eq4,y_plus_B) = - ( Vref(posB) - epsilon(posB) ) .* eye(length(posB));
A(Eq4,y_minus_B) = - model.ub(posB) .* eye(length(posB));
b(Eq4) = 0;
csense(Eq4) = 'L';

% Fiveth contraint, Change or not change in Backward
A(Eq5,y_plus_B) = eye(length(Eq5));
A(Eq5,y_minus_B) = eye(length(Eq5));
b(Eq5) = 1;
csense(Eq5) = 'E';

% Objective fuction
% linear part
c = zeros(n_var,1);
c(y_minus_F) = alpha/2;
c(y_minus_B) = alpha/2;
c(v(posS)) = -2 * Vref(posS) * (1-alpha);
% quadratic part
F = spalloc(n_var,n_var,length(posS));
F(v(posS),v(posS)) =  2 * (1-alpha) .* eye(length(posS));

% save the resultant model
OptimizationModel = struct();
[OptimizationModel.A, OptimizationModel.lb, OptimizationModel.ub] = deal(A, lb, ub);
[OptimizationModel.b, OptimizationModel.csense] = deal(b, csense);
[OptimizationModel.c, OptimizationModel.F] = deal(c, F);
[OptimizationModel.osense, OptimizationModel.vartype] = deal(+1, vartype); % +1 for minimization

%save the index of the variables
OptimizationModel.idx_variables.v = v;
OptimizationModel.idx_variables.y_plus_F = y_plus_F;
OptimizationModel.idx_variables.y_minus_F = y_minus_F;
OptimizationModel.idx_variables.y_plus_B = y_plus_B;
OptimizationModel.idx_variables.y_minus_B = y_minus_B;

end
