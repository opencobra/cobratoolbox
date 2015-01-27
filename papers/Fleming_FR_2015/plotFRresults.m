%displays the results saved from checkRankFRdriver.m

close all
path='~/Dropbox/graphStoich/results/FRresults/';
%filename='modelCollectionResults_flux_20141201T160152.mat';
%filename='modelCollectionResults_flux_20141202T130419.mat';
filename='modelCollectionResults_flux_20141202T140312.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([path filename])
% RGB Value  Short Name  Long Name
% [1 1 0] y yellow
% [1 0 1] m magenta 
% [0 1 1] c cyan
% [1 0 0] r red
% [0 1 0] g green
% [0 0 1] b blue
% [1 1 1] w white
% [0 0 0] k black


h=figure;

if 1
    for i=1:27
        model=results(i).model;
        subplot(9,3,i)
        title(strrep(results(i).modelFilename,'_',' '),'FontSize',13)
        xlabel('# reactions','FontSize',13)
        ylabel('# molecules','FontSize',13)
        hold on;
        
        X=[0,0,size(model.S,2),size(model.S,2)];
        Y=[0,size(model.S,1),size(model.S,1),0];
        fill(X,Y,[153 153 153]/255,'EdgeColor',[153 153 153]/255)
        xlim([0 size(model.S,2)])
        ylim([0 size(model.S,1)-1])
        
        X=[0,0,nnz(model.SConsistentRxnBool),nnz(model.SConsistentRxnBool)];
        Y=[0,nnz(model.SConsistentMetBool),nnz(model.SConsistentMetBool),0];
        fill(X,Y,[204 102 102]/255,'EdgeColor','none')
        
        X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
        Y=[0,nnz(model.fluxConsistentMetBool),nnz(model.fluxConsistentMetBool),0];
        fill(X,Y,[102 153 255]/255,'EdgeColor','none')
        
        if 0
            X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
            Y=[0,nnz(model.FRnonZeroBool),nnz(model.FRnonZeroBool),0];
            fill(X,Y,'k','EdgeColor','none')
            
            X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
            Y=[0,nnz(model.FRuniqueBool),nnz(model.FRuniqueBool),0];
            fill(X,Y,'w','EdgeColor','none')
        end
        
        X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
        Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
        fill(X,Y,[153 153 255]/255,'EdgeColor','none')
    end
    %legend('Original','Stoichiometrically consistent','+ Flux consistent','+ non-zero','+ unique','full rank([F R])');
    legend('Original','Stoichiometrically consistent','Stoichiometrically & Flux consistent','[F R] full row rank');
    
else
    toplot=[3,1,4,5,7,8];
    totitle={'Human cardiac mitochondrion','Human metabolism (Recon 2.0)','\it{E. coli} core metabolism','\it{E. coli} metabolism (iAF1260)','\it{Synechocystis} metabolism (iNJ678)','Mouse metabolism (iSS1393)'};
    for j=1:length(toplot)
        disp([results(toplot(j)).modelFilename '____' totitle(j)])
    end
    
    for j=1:length(toplot)
          model=results(toplot(j)).model;
        subplot(length(toplot),2,j)
        if 0
            title(strrep(results(i).modelFilename,'_',' '),'FontSize',15,'interpreter','latex')
        else
            title(totitle(j),'FontSize',15)
        end
        
        xlabel('# reactions','FontSize',15)
        ylabel('# molecular species','FontSize',15)
        hold on;
        
        X=[0,0,size(model.S,2),size(model.S,2)];
        Y=[0,size(model.S,1),size(model.S,1),0];
        fill(X,Y,[153 153 153]/255,'EdgeColor',[153 153 153]/255)
        xlim([0 size(model.S,2)])
        ylim([0 size(model.S,1)-1])
        
        X=[0,0,nnz(model.SConsistentRxnBool),nnz(model.SConsistentRxnBool)];
        Y=[0,nnz(model.SConsistentMetBool),nnz(model.SConsistentMetBool),0];
        fill(X,Y,[204 102 102]/255,'EdgeColor','none')
        
        X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
        Y=[0,nnz(model.fluxConsistentMetBool),nnz(model.fluxConsistentMetBool),0];
        fill(X,Y,[102 153 255]/255,'EdgeColor','none')
        
        if 0
            X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
            Y=[0,nnz(model.FRnonZeroBool),nnz(model.FRnonZeroBool),0];
            fill(X,Y,'k','EdgeColor','none')
            
            X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
            Y=[0,nnz(model.FRuniqueBool),nnz(model.FRuniqueBool),0];
            fill(X,Y,'w','EdgeColor','none')
        end
        
        X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
        Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
        fill(X,Y,[153 153 255]/255,'EdgeColor','none')
    end
end

%flag models that are row rank deficient
fprintf('%s\n','[F,R] does not have full row rank for:')
fprintf('%s%s%s\n','Model           ','Rows([F,R]) ', 'Rank([F,R])')
for j=2:size(FRtable,2)
    bool1=strcmp('# Rows of proper [F,R]',FRtable(:,1));
    bool2=strcmp('# Rank of proper [F,R]',FRtable(:,1));
    if FRtable{bool1,j}~=FRtable{bool2,j}
        fprintf('%10s\t%u\t%u\n',FRtable{1,j},FRtable{bool1,j},FRtable{bool2,j})
    end
end