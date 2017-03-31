load('iAF1260.mat');
clear model, Pl

if ~exist('model','var')
    %finds the reactions in the model which export/import from the model
    %boundary i.e. mass unbalanced reactions
    %e.g. Exchange reactions
    %     Demand reactions
    %     Sink reactions
    model = findSExRxnInd(iAF1260);
    model.description='iAF1260';

    %Integerize reactions involving O2
    A=model.S-round(model.S);
    A(:,~model.SIntRxnBool)=0;
    o2MetBool=strcmp(model.mets,'o2[c]');
    o2RxnBool=A(o2MetBool,:)~=0;
    model.S(o2MetBool,o2RxnBool)=model.S(o2MetBool,o2RxnBool)*2;
    
    if 1
        figure(1);
        A=model.S-round(model.S);
        A(:,~model.SIntRxnBool)=0;
        nnz(A)
        spy(A)
    end
end

tic
% if ~exist('Pl','var')
    fprintf('%s\n','Extreme pools')
    %calculates the matrix of extreme pools
    positivity=1;
    [Pl,Vl,A]=extremePools(model,positivity);
% end
toc

if 1
    figure(2);
    signPl=sign(Pl);
    nnzPl=sum(signPl,2);
    plot(nnzPl)
end
