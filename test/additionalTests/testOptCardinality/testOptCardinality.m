% The COBRAToolbox: testOptCardinality.m
%
% Purpose:
%     - tests optimiseCardinality
%
% Authors:
%     - CI integration: Laurent Heirendt March 2018
%

param.printLevel=3;

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptCardinality'));
cd(fileDir);

fprintf('%s\n','   Testing optimizeCardinality & optimizeWeightedCardinality...');

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
end

%paramaters
feasTol = getCobraSolverParams('LP', 'feasTol');
param.eta = feasTol*1e5;
if 0
    param.nbMaxIteration = 1000;
    param.zeta = 1e-6;
    param.theta   = 0.5;    %parameter of capped l1 approximation
    param.epsilon = 1e-3;
end

% DC programming for solving the cardinality optimization problem
% The `l0` norm is approximated by capped-`l1` function.
% :math:`min c'(x, y, z) + lambda_0*||k.*x||_0 - delta_0*||d.*y||_0 
%                        + lambda_1*||x||_1 + delta_1*||y||_1` 
% s.t. :math:`A*(x, y, z) <= b`
% :math:`l <= (x,y,z) <= u`
% :math:`x in R^p, y in R^q, z in R^r`

%problem structure
[mlt,nlt]=size(model.S);
cardProblem.r=1;%first reaction is the objective
p=20;%minimise first 20 reactions
q=nlt-p-cardProblem.r;%maximise remainder of reactions
cardProblem.p=p;%minimise
cardProblem.q=q;%maximise
cardProblem.c=zeros(nlt,1);
cardProblem.c(1)=-1;%maximise biomass reaction
cardProblem.A=[model.S(:,model.c~=0),model.S(:,model.c==0)];%stick the objective first
cardProblem.b=zeros(mlt,1);
cardProblem.lb=-10*ones(nlt,1);
cardProblem.lb(1)=1;
cardProblem.ub= 10*ones(nlt,1);
cardProblem.csense(1:mlt,1)='E';

if isfield(cardProblem,'lambda')
    cardProblem=rmfield(cardProblem,'lambda');
end
if isfield(cardProblem,'delta')
    cardProblem=rmfield(cardProblem,'delta');
end

param.lambda=0;
param.delta=1;

if 1
    if 0
        solution = optimizeCardinality(cardProblem,param);
        boolx=solution.x>=param.eta;
        booly=solution.y>=param.eta;
        reactionDifference=nnz(booly)-nnz(boolx);
        disp(reactionDifference)
    else
        try
            solution = optimizeCardinality(cardProblem,param);
            if solution.stat==1
                boolx=solution.x>=param.eta;
                booly=solution.y>=param.eta;
                reactionDifference=nnz(booly)-nnz(boolx);
                %disp(reactionDifference)
                assert(reactionDifference==19)
            else
                error('optimizeCardinality failed')
            end
        catch ME
            error('optimizeCardinality failed')
            assert(length(ME.message) > 0)
        end
    end
end
%                   * .lambda_0 - trade-off parameter of `||x||_0`
%                   * .lambda_1 - trade-off parameter of `||x||_1`
%                   * .delta_0 - trade-off parameter of `||y||_0`
%                   * .delta_1 - trade-off parameter of `||y||_1`
%                   * .k - `p x 1` strictly positive weight vector of `x`
%                   * .d - `q x 1` strictly positive weight vector of `y`

if 0
    cardProblem.k = rand(p,1);
    cardProblem.d  = rand(q,1);
    
    solution = optimizeCardinality(cardProblem, param);
    printLevel=1;
    if solution.stat==1
        boolx=solution.x>=param.eta;
        booly=solution.y>=param.eta;
        reactionDifference=nnz(booly)-nnz(boolx);
        %disp(reactionDifference)
    else
        clear
        error('weighted optimizeCardinality failed')
    end
else
    try
        if 1
            cardProblem.k = rand(p,1);
            cardProblem.d  = rand(q,1);
        else
            cardProblem.k =[0.353261921655910;0.136198199554603;0.161199215283406;0.701598054693234;0.963104300338750;0.848915285870358;0.355696281562873;0.604026370901761;0.863208270875165;0.820516602129050];
            cardProblem.d = [0.856726006637269;0.479222295857706;0.693250365030223;0.184194690365269;0.160038122601110;0.994929983836258;0.0661195204254679;0.992606041060040;0.217668082980991;0.885563825134152;0.337216530505868;0.316453801160968;0.310462944504509;0.713112858468648;0.663679819631847;0.717971113445466;0.104640343889781;0.700479020824193;0.0805864297824039;0.891195523125197;0.693880161746020;0.436474899335492;0.656991109467124;0.948094246708429;0.771053864583346;0.883352985815948;0.342974266018114;0.312664798117314;0.507688818213242;0.512523050276335;0.581846823390724;0.302786199140526;0.240719695561023;0.716435558175071;0.769903255623647;0.791240133987633;0.730011734034978;0.0484591628058197;0.286317855807064;0.648463862349204;0.551974518354735;0.704768997987814;0.949221753797141;0.403674635085002;0.874755823584694;0.0673360092347605;0.803867257560051;0.337409460743523;0.775432615766947;0.0619856321579906;0.575368119807765;0.550765711061938;0.799440812589458;0.378435388052920;0.534250510907493;0.950082837953587;0.121105671067707;0.361260315188684;0.144154618911642;0.588725242952198;0.545911394577834;0.336007538977284;0.294563063293066;0.570170186151889];
        end
        solution = optimizeCardinality(cardProblem, param);
        printLevel=1;
        if solution.stat==1
            boolx=solution.x>=param.eta;
            booly=solution.y>=param.eta;
            reactionDifference=nnz(booly)-nnz(boolx);
            %disp(reactionDifference)
            assert(reactionDifference==19)
        else
            clear
            error('weighted optimizeCardinality failed')
        end
        
    catch ME
        error('weighted optimizeCardinality failed')
        assert(length(ME.message) > 0)
    end
end
% output a success message
fprintf('     Done.\n');

% change the directory
cd(currentDir)
