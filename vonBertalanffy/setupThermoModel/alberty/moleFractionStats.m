function moleFractionStats(modelT)
%Plots of mole fraction statistics.
%
%plot a histogram of the number of metabolite species relevant between pH 5
%and 9, and a stacked bar chart of the mole fractions of reactants with
%significant (<0.99) distributions over more than one metabolite species.
%
%INPUT
% modelT.S
% modelT.met(m).officialName
% modelT.met(m).mf
%
% Ronan M.T. Fleming
% Hulda SH Jul 7 2011 Enabled inclusion of up to 10 microspecies in bar
%                     graph

[nMets,nRxn]=size(modelT.S);

for m=1:nMets
    nSpecies(m)=length(find(modelT.met(m).mf)>=0.001); % Imposed a 0.1% threshold on the abundance of species - Hulda
    if (sum(modelT.met(m).mf)-1)>1e-8
        modelT.met(m)
        modelT.met(m).mf
        error('Sum of mole fractions should be one')
    end
    if nnz(find(modelT.met(m).mf<0))>1
        modelT.met(m)
        modelT.met(m).mf
        error('Mole fractions should be positive')
    end
end
[n, xout]=hist(nSpecies, [1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5 10.5]); % Uses as many bins as are needed, not just 3 - Hulda
n = n(1:find(n,1,'last'));
figure;
bar(0.5:1:(length(n) - 0.5),n);
title('Number of metabolite species for each reactant.')
ylabel('# Reactants','FontSize',14);
set(gca,'XTick',0.5:1:(length(n) - 0.5));
xTickLabels = {'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten'};
set(gca,'XTickLabel',xTickLabels(1:length(n)),'FontSize',14);


maxNSpecies=max(nSpecies);
%Y=zeros(nSpecies,maxNSpecies);
Y=zeros(1,maxNSpecies);

ns=1;
p=1;
%sorted 1,2,3
while ns<=maxNSpecies
    for m=1:nMets
        if ns==nSpecies(m)
            Y(p,1:nSpecies(m))=sort(modelT.met(m).mf','descend');
            p=p+1;
        end
    %     Y(m,1:nSpecies(m))=modelT.met(m).mf';
    end
    ns=ns+1;
end
% figure
% barh(Y,'stack')

Y=[];
%sorted by connectivity
significantMF=false(nMets,1);
Shat=sign(abs(modelT.S));
A=Shat*Shat';
metConnect=diag(A,0)';
size(metConnect);
[metConnectSorted,ix]=sort(metConnect);
p=1;
for m=1:nMets
    %only take cytoplasmic metabolites
    metAbbr=modelT.mets{ix(m)};
    if max(modelT.met(ix(m)).mf)<0.95 && strcmp('[c]',metAbbr(end-2:end))
%         Y(p,1:nSpecies(ix(m)))=sort(modelT.met(ix(m)).mf','descend');
        Y(p,1:nSpecies(ix(m)))=modelT.met(ix(m)).mf';
        metInd(p)=ix(m);
%         metNames{p,1}=[modelT.met(ix(m)).officialName metAbbr(end-2:end)];
        metNames{p,1}=modelT.met(ix(m)).officialName;
        p=p+1;
    end
    
end

left=0.1;
bottom=0.1;
width=2;
height=0.8;
% subplot(1,2,1,'Position',[left bottom width height])
figure;
barh(Y,'stack');
set(gca,'XTick',[0:0.2:1]);
set(gca,'YTick',1:length(metInd));
set(gca,'YTickLabel',metNames);
ylim([0.5 length(metInd)-0.5]) ;
xlabel('Mole Fraction','FontSize',14);
set(gca,'FontSize',14)
title('Mole fraction statistics')
saveas(gcf,'moleFraction95','fig');

left=0.8;
% subplot(1,2,2,'Position',[left bottom width height])
figure;
barh(metConnect(metInd));
set(gca,'YTick',[]);
set(gca,'YTickLabel',[]);
ylim([0.5 length(metInd)-0.5]) ;
xlabel('Metabolite (ordered as mole fraction stat figure)','FontSize',14);
xlabel('Connectivity','FontSize',14);
set(gca,'FontSize',14);
title('Mole fraction statistics: connectivity')
saveas(gcf,'moleFraction95connectivity','fig');






