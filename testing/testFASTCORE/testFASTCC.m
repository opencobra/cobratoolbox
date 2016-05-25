function x=testFASTCC()
%test FASTCC algorithm and returns 1 for correct, else 0
%

% Thomas Pfau, May 2016


ibm = changeCobraSolver('ibm_cplex');
if ~ibm
    gurobi = changeCobraSolver('gurobi6');
    if ~gurobi
        tomlab = changeCobraSolver('tomlab_cplex')
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
printLevel=0;

A = fastcc(model, epsilon, printLevel);

if numel(A)==5317
    %|J|=0  |A|=6975
    %CBTLPSOLVER = quadMinos
    x=1;
else
    x=0;
end