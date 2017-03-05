function metaboliteMassBalancePlot(model,metAbbr,solution,N)
%plots the top N reactions producing and consuming a metabolite in a flux
%solution
%
%INPUT
% model
% metAbbr       metabolite abbreviation
% solution      solveCobraLP output of a solution to FBA problem
% N             Number of reactions to include for production/consumption
%
%Ronan M.T. Fleming


[nMet,nRxn]=size(model.S);

metInd=find(strcmp(metAbbr,model.mets));
if isempty(metInd)
    error('metabolite abbreviation not found')
end

tol = 1e-6;

negS=(model.S(metInd,:)<0)';
posS=(model.S(metInd,:)>0)';

v=solution.full;

consumeBool=( negS & v>tol ) | ( posS & v<-tol );
produceBool=( posS & v>tol ) | ( negS & v<-tol );

vConsume=zeros(nRxn,1);
vProduce=zeros(nRxn,1);

vConsume(consumeBool)=v(consumeBool);
vProduce(produceBool)=v(produceBool);

[sortedConsume,XIMax]=sort(abs(vConsume),'descend');
NConsume=nnz(sortedConsume~=0);

[sortedProduce,XIMin]=sort(abs(vProduce),'descend');
NProduce=nnz(sortedProduce~=0);

figure
h1=subplot(2,1,1);
NConsume=min([NConsume,N]);
YI=(1:NConsume)';
barh(YI,v(XIMax(1:NConsume)));
% title(['Consumers (top) and Producers of ' metAbbr],'FontSize',16)

if NConsume==0
    set(h1,'YTickLabel','NONE','FontSize',8);
else
    for n=1:NConsume
        if strcmp(model.rxn(XIMax(n)).directionality,'forward')
            YTickLabelMax{n}=['*' model.rxns{XIMax(n)}];
        else
            YTickLabelMax{n}=model.rxns{XIMax(n)};
        end
    end
    set(h1,'Ytick', 1:NConsume)
    set(h1,'YTickLabel',YTickLabelMax,'FontSize',8);
    ylim([0.5 NConsume+0.5])
end
xlabel(['Consumer of ' metAbbr],'FontSize',12)

h2=subplot(2,1,2);
NProduce=min([NProduce,N]);
YI=(1:NProduce)';
barh(YI,v(XIMin(1:NProduce)));
if NProduce==0
    set(h1,'YTickLabel','NONE','FontSize',8);
else
    for n=1:NProduce
        if strcmp(model.rxn(XIMin(n)).directionality,'forward')
            YTickLabelMin{n}=['*' model.rxns{XIMin(n)}];
        else
            YTickLabelMin{n}=model.rxns{XIMin(n)};
        end
    end
    set(h2,'Ytick', 1:NProduce)
    set(h2,'YTickLabel',YTickLabelMin,'FontSize',8);
    ylim([0.5 NProduce+0.5])
end
xlabel(['Producer of ' metAbbr],'FontSize',12)
