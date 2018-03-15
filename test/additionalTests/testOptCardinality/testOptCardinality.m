% The COBRAToolbox: testOptCardinality.m
%
% Purpose:
%     - tests optimiseCardinality
%
% Authors:
%     - CI integration: Laurent Heirendt March 2018
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptCardinality'));
cd(fileDir);

% set the tolerance
tol = 1e-8;


fprintf('   Testing optimizeCardinality & optimizeWeightedCardinality...');

if 0
    filename='Recon2.0model.mat';
    if exist('Recon2.0model.mat','file')==2
        model = readCbModel(filename);
    end
    model.csense(1:size(model.S,1),1)='E';
else
    modelFolder = getDistributedModelFolder('ecoli_core_model.mat');
    % define the filename of the model
    modelFile = [modelFolder filesep 'ecoli_core_model.mat'];
    model = readCbModel(modelFile, 'modelName','model');
    %make a reaction unbalanced
    %model.S(strcmp(model.mets,'nadph[c]'),strcmp(model.rxns,'G6PDH2r'))=0;
    model.S(strcmp(model.mets,'6pgl[c]'),strcmp(model.rxns,'G6PDH2r'))=0;
    
end

% Get supposed internal reaction stoichiometric matrix from the model
model = findSExRxnInd(model); 
S = model.S(model.SIntMetBool,model.SIntRxnBool);
[mlt,nlt] = size(S);

%%optimizeCardinality
%  problem                  Structure containing the following fields describing the problem
%       p                   size of vector x
%       q                   size of vector y
%       r                   size of vector z
%       c                   (p+q+r) x 1 linear objective function vector
%       lambda              trade-off parameter of ||x||_0
%       delta               trade-off parameter of ||y||_0
%       A                   s x (p+q+r) LHS matrix
%       b                   s x 1 RHS vector
%       csense              s x 1 Constraint senses, a string containting the constraint sense for
%                           each row in A ('E', equality, 'G' greater than, 'L' less than).
%       lb                  (p+q+r) x 1 Lower bound vector
%       ub                  (p+q+r) x 1 Upper bound vector
%
% OPTIONAL INPUTS
% params                    parameters structure
%       nbMaxIteration      stopping criteria - number maximal of iteration (Defaut value = 1000)
%       epsilon             stopping criteria - (Defaut value = 10e-6)
%       theta               parameter of the approximation (Defaut value = 2)
%
% OUTPUT
% solution                  Structure containing the following fields
%       x                   p x 1 solution vector
%       y                   q x 1 solution vector
%       z                   r x 1 solution vector
%       stat                status
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input

% min       c'(x,y,z) + lambda*||x||_0 - delta*||y||_0
% s.t.      A*(x,y,z) <= b
%           l <= (x,y,z) <=u
%           x in R^p, y in R^q, z in R^r

params.nbMaxIteration = 1000;
feasTol = getCobraSolverParams('LP', 'feasTol');
params.eta = feasTol*100000;
params.zeta = 1e-6;
params.theta   = 0.5;    %parameter of capped l1 approximation
params.epsilon = 1e-3;

p=10;
q=nlt-p;
cardProblem.p=p;
cardProblem.q=q;
cardProblem.r=0;
cardProblem.c=zeros(nlt,1);
cardProblem.A=S;
cardProblem.b=zeros(mlt,1);
cardProblem.lb=-10*ones(nlt,1);
cardProblem.ub= 10*ones(nlt,1);
cardProblem.csense(1:mlt,1)='E';

if isfield(cardProblem,'lambda')
    cardProblem=rmfield(cardProblem,'lambda');
end
if isfield(cardProblem,'delta')
    cardProblem=rmfield(cardProblem,'delta');
end
    

%try
    params.lambda=0;
    params.delta=1;
    solution = optimizeCardinality(cardProblem,params);
    if solution.stat==1
        bool=solution.y>=params.eta;
        fractionConserved=nnz(bool)/length(bool);
        fractionConserved
        %assert(fractionConserved==0.21875)
    else
        error('optimizeCardinality failed')
    end
% catch ME
%     error('optimizeCardinality failed')
%     assert(length(ME.message) > 0)
% end

try
    if 0
        cardProblem.lambda = rand(p,1);
        cardProblem.delta  = rand(q,1);
    else
        cardProblem.lambda =[0.353261921655910;0.136198199554603;0.161199215283406;0.701598054693234;0.963104300338750;0.848915285870358;0.355696281562873;0.604026370901761;0.863208270875165;0.820516602129050];
        cardProblem.delta = [0.856726006637269;0.479222295857706;0.693250365030223;0.184194690365269;0.160038122601110;0.994929983836258;0.0661195204254679;0.992606041060040;0.217668082980991;0.885563825134152;0.337216530505868;0.316453801160968;0.310462944504509;0.713112858468648;0.663679819631847;0.717971113445466;0.104640343889781;0.700479020824193;0.0805864297824039;0.891195523125197;0.693880161746020;0.436474899335492;0.656991109467124;0.948094246708429;0.771053864583346;0.883352985815948;0.342974266018114;0.312664798117314;0.507688818213242;0.512523050276335;0.581846823390724;0.302786199140526;0.240719695561023;0.716435558175071;0.769903255623647;0.791240133987633;0.730011734034978;0.0484591628058197;0.286317855807064;0.648463862349204;0.551974518354735;0.704768997987814;0.949221753797141;0.403674635085002;0.874755823584694;0.0673360092347605;0.803867257560051;0.337409460743523;0.775432615766947;0.0619856321579906;0.575368119807765;0.550765711061938;0.799440812589458;0.378435388052920;0.534250510907493;0.950082837953587;0.121105671067707;0.361260315188684;0.144154618911642;0.588725242952198;0.545911394577834;0.336007538977284;0.294563063293066;0.570170186151889];
    end
    solution = optimizeCardinality(cardProblem, params);
    printLevel=1;
    if solution.stat==1
        %conserved if molecular mass is above epsilon
        bool=solution.y>=params.eta;
        fractionConserved=nnz(bool)/length(bool);
        %fractionConserved
        assert(fractionConserved==0.203125)
    else
        clear
        error('weighted optimizeCardinality failed')
    end
    
catch ME
    error('weighted optimizeCardinality failed')
    assert(length(ME.message) > 0)
end

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
