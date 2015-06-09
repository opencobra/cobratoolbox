clear

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
        %graphStoich/data/modelCollection/121114_Recon2betaModel.mat
        load 121114_Recon2betaModel.mat
        model=modelRecon2beta121114;
end

epsilon = 1e-8  vdfhaaaaaa;
printLevel=0;

if 1
    [fluxConsistent,sol]=checkFluxConsistency(model,epsilon);
    model.S
    x=sol.full;
    [m,n]=size(model.S);
    for j=1:n
        fprintf('%d\t%d\t%d\t%d\t%d\t%d\n',x(j),x(j+n),x(j+m+2*n),x(j+m+3*n),x(j+m+4*n),x(j+m+5*n));
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
