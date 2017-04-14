function bool=testFastcc()
%test fastcc with reconx

%save original solver
global CBT_LP_SOLVER;
origSolverLP = CBT_LP_SOLVER;

changeCobraSolver('gurobi6','LP');

epsilon = 1e-4;
printLevel=2;

load('121114_Recon2betaModel.mat')
model=modelRecon2beta121114;

if 1
    fluxConsistentBool = fastcc(model,epsilon,printLevel);
    nnz(fluxConsistentBool)
    if numel(fluxConsistentBool)==5317
        bool=1;
    else
        bool=0;
    end
else
    %make a recon model with all reactions reversible, 
    %to see which reactions are still not flux consistent
    modelRev=model;
    modelRev.lb(:)=-1000;
    modelRev.ub(:)=1000;
    
    rev_fluxConsistentBool = fastcc(modelRev,epsilon,printLevel);
    nnz(rev_fluxConsistentBool)
end

%switch solvers back to original
if ~isempty(origSolverLP)
    changeCobraSolver(origSolverLP,'LP');
end


