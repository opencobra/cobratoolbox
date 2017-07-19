function bool=testFluxConsistency()
%test fastcc with toy model

%save original solver
global CBT_LP_SOLVER;
origSolverLP = CBT_LP_SOLVER;

changeCobraSolver('gurobi6','LP');

modelToUse='toy';
switch modelToUse
    case 'toy'
        S=zeros(4,6);
        S(1,1)=-1;
        S(2,1)=1;
        S(2,2)=-1;
        S(3,2)=1;
        S(3,3)=1;
        S(1,3)=-1;
        S(2,4)=-1;
        S(4,4)=1;
        S(1,5)=1;
        S(3,6)=-1;
        model.S=S;
        model.lb=zeros(6,1);
        model.ub=10*ones(6,1);
        model.b=zeros(4,1);        
    otherwise
        load 121114_Recon2betaModel.mat
        model=modelRecon2beta121114;
end

epsilon = 1e-8;
printLevel=2;

if 1
    fluxConsistentBool = fastcc(model,epsilon,printLevel);
    model.S
    if isequal(fluxConsistentBool,[1 2 3 5 6]')
        bool = true;
    else
        bool = false;
    end
else
    if 0
        fluxConsistentBool = fastcc(model,epsilon,printLevel);
        nnz(fluxConsistentBool)
    else
        %make a recon model with all reactions reversible, to see which reactions
        %are still not flux consistent
        modelRev=model;
        modelRev.lb(:)=-1000;
        modelRev.ub(:)=1000;
        
        rev_fluxConsistentBool = fastcc(modelRev,epsilon,printLevel);
        nnz(rev_fluxConsistentBool)
    end
end

%switch solvers back to original
if ~isempty(origSolverLP)
    changeCobraSolver(origSolverLP,'LP');
end

end