function x=testFASTCC()
%test FASTCC algorithm and returns 1 for correct, else 0
%

% Thomas Pfau, May 2016


try
    ILOGcplex = Cplex('fba');% Initialize the CPLEX object
    ibm = changeCobraSolver('ibm_cplex','LP');
catch
    ibm=0;
end
if ~ibm
    if exist('gurobi','file')
        gurobi = changeCobraSolver('gurobi6','LP');
    else
        gurobi=0;
    end
    if ~gurobi
        tomlab = changeCobraSolver('tomlab_cplex','LP');
        if ~tomlab
            %Those are the allowed solvers for FASTCORE. Others can be
            %used, but likely lead to numeric issues.
            x = 0;
            return
        end    
    end
end

%load a model
load('FastCoreTest.mat')
model=modelR204;

%randomly pick some reactions
epsilon=1e-4;
printLevel=2;
modeFlag=0;

A = fastcc(model, epsilon, printLevel,modeFlag);

if numel(A)==5317
    %|J|=0  |A|=6975
    %CBT_LP_SOLVER = quadMinos
    x=1;
else
    x=0;
end