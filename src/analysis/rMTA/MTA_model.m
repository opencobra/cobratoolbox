function CplexModel = MTA_model(model,rxnFBS,Vref,alpha,epsilon)
% Returns the CPLEX model needed to perform the MTA
%
% USAGE:
% 
%       CplexModel = MTA_model(model,rxnFBS,Vref,alpha,epsilon)
%
% INPUT:
%    model:            Metabolic model (COBRA format)
%    rxnFBS:           Forward, Backward and Unchanged (+1;0;-1) values
%                      corresponding to each reaction.
%    Vref:             Reference flux of the source state.
%    alpha:            parameter of the quadratic problem (default = 0.66)
%    epsilon           minimun disturbance for each reaction, (default = 0)
%
% OUTPUTS:
%    CplexModel:       CPLEX model struct that includes the stoichiometric
%                      contrains, the thermodinamic constrains and the
%                      binary variables.
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
% .. Revisions:
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.


%% --- check the inputs ---

if nargin<3
    ME = MException('InputMTA_Model:InputData', ...
        'There are not enough input arguments.');
    throw(ME);
end

if ~exist('alpha','var')
    alpha = 0.66;
end

if ~exist('epsilon','var')
    epsilon = zeros(size(model.rxns));
end

%% --- set the CPLEX model ---

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
ctype(1:n_var) = 'B';
ctype(v) = 'C';

% constrains
Eq1 = 1:length(model.mets);                 % Stoichiometric matrix
Eq2 = (1:length(y_plus_F)) + Eq1(end);      % Changes in Forward
Eq3 = (1:length(y_plus_F)) + Eq2(end);      % Change or not change in Forward
Eq4 = (1:length(y_plus_B)) + Eq3(end);      % Changes in Backward
Eq5 = (1:length(y_plus_B)) + Eq4(end);      % Change or not change in Backward
n_cons = Eq5(end);

% generate constrain matrix
A = spalloc(n_cons, n_var, nnz(model.S) + 5*length(Eq2) + 5*length(Eq4));

posF = find(rxnFBS == +1);
posB = find(rxnFBS == -1);
posS = find(rxnFBS == 0);

% First contraint, stoichiometric
A(Eq1,v) = model.S;
lhs(Eq1) = 0;
rhs(Eq1) = 0;

% Second contraint, Change or not change in Forward
A(Eq2,v(posF)) = eye(length(posF));
A(Eq2,y_plus_F) = - ( Vref(posF) + epsilon(posF) ) .* eye(length(posF));
A(Eq2,y_minus_F) = - model.lb(posF) .* eye(length(posF));
lhs(Eq2) = 0;
rhs(Eq2) = inf;

% Third contraint, Change or not change in Forward
A(Eq3,y_plus_F) = eye(length(Eq3));
A(Eq3,y_minus_F) = eye(length(Eq3));
lhs(Eq3) = 1;
rhs(Eq3) = 1;

% Fourth contraint, Backward changes
A(Eq4,posB) = eye(length(posB));
A(Eq4,y_plus_B) = - ( Vref(posB) - epsilon(posB) ) .* eye(length(posB));
A(Eq4,y_minus_B) = - model.ub(posB) .* eye(length(posB));
lhs(Eq4) = -inf;
rhs(Eq4) = 0;

% Fiveth contraint, Change or not change in Backward
A(Eq5,y_plus_B) = eye(length(Eq5));
A(Eq5,y_minus_B) = eye(length(Eq5));
lhs(Eq5) = 1;
rhs(Eq5) = 1;

% Objective fuction
% linear part
c = zeros(n_var,1);
c(y_minus_F) = alpha/2;
c(y_minus_B) = alpha/2;
c(v(posS)) = -2 * Vref(posS) * (1-alpha);
% quadratic part
Q = spalloc(n_var,n_var,length(posS));
Q(v(posS),v(posS)) =  2 * (1-alpha) .* eye(length(posS));

% save the resultant model
CplexModel = struct();
[CplexModel.A, CplexModel.lb, CplexModel.ub] = deal(A, lb, ub);
[CplexModel.lhs, CplexModel.rhs] = deal(lhs, rhs);
[CplexModel.obj, CplexModel.Q] = deal(c, Q);
[CplexModel.sense, CplexModel.ctype] = deal('minimize', ctype);

%save the index of the variables
CplexModel.idx_variables.v = v;
CplexModel.idx_variables.y_plus_F = y_plus_F;
CplexModel.idx_variables.y_minus_F = y_minus_F;
CplexModel.idx_variables.y_plus_B = y_plus_B;
CplexModel.idx_variables.y_minus_B = y_minus_B;

end
