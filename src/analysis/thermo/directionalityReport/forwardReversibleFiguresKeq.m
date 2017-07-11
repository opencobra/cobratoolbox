function forwardReversibleFiguresKeq(model,directions,thorStandard)
% Figure of qualitatively forward -> quantitatively reversible (keq)
%
%make figure of  reactions that have changed from qualitatively forward
%to quantitatively reversible, where all metabolites dGt0 were back
%calculated from Keq. Omit those reactions that are transport reactions
%
%INPUT
% model
%
% directions must have the fields below:
%   directions.ChangeForwardReversible_dGfKeq
%
% thorStandard          {(0),1} use new standard reactant concentration
%                       half way between upper and lower concentration
%                       bounds
%
% Ronan M.T. Fleming

[nMet,nRxn]=size(model.S);
%ignore thor standard for keq
thorStandard=0;
if thorStandard
    dGt0Min=model.dGt0Min;
    dGt0Max=model.dGt0Max;
    for n=1:nRxn
        model.dGt0Min(n)=model.rxn(n).dGtmMMin;
        model.dGt0Max(n)=model.rxn(n).dGtmMMax;
    end
end

 %%%%%%%%%vertical%%%%%%%%%%%%%
%forward possibly reversible
fwdPossiblyReverseKeq=directions.ChangeForwardReversible_dGfKeq;

%only plot the non transport reactions
for n=1:nRxn
    if fwdPossiblyReverseKeq(n)
        metAbbrRxn=model.mets(model.S(:,n)~=0);
        for m=1:length(metAbbrRxn)
            metAbbr=metAbbrRxn{m};
            compartment{m}=metAbbr(end-2:end);
        end
        if length(unique(compartment))~=1
            fwdPossiblyReverseKeq(n)=0;
        end
    end
end
%dGrt
Y=(model.dGtMin+model.dGtMax)/2;
L=Y-model.dGtMin;
U=model.dGtMax-Y;
%sort by mean dGt0
Y0=(model.dGtMin+model.dGtMax)/2;
[tmp,xip]=sort(model.dGtMax,'descend');
%     only take the indices of the problematic reactions, but be sure to
%     take them in order of descending (model.dGtMin+model.dGtMax)/2
xip2=zeros(nnz(fwdPossiblyReverseKeq),1);
p=1;
for n=1:nRxn
    if fwdPossiblyReverseKeq(xip(n))
        xip2(p)=xip(n);
        p=p+1;
    end
end
xip=xip2;
X1=1:length(xip);

% close all
figure1 = figure;
% Create axes
axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
hold on;
%upper and lower X
minX=min(model.dGtMin(fwdPossiblyReverseKeq));
maxX=max(model.dGtMax(fwdPossiblyReverseKeq));
% %baselines
% PreversibleBar_byConcRHS=ones(1,nRxn)*minX;
% %bar for 6
% PreversibleBar_byConcRHS(directions.ChangeForwardReversibleBool_dGfGC_byConcRHS)=maxX;
% bar_handle6=barh(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minX,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');

%dGrt errorbar
%   PLOTERR(X,Y,{LX,UX},{LY,UY}) plots the graph of vector X vs. vector Y 
%   with error bars specified by LX and UX in horizontal direction and
%   with error bars specified by LY and UY in vertical direction.
%   H = PLOTERR(...) returns a vector of line handles in this order:
%      H(1) = handle to datapoints
%      H(2) = handle to errorbar y OR errorbar x if error y not specified
%      H(3) = handle to errorbar x if error y specified
% LineSpec=[''LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r'']
LineSpec='r.'; 
hE = ploterr(Y(xip),X1,{model.dGtMin(xip) model.dGtMax(xip)},[],LineSpec,'hhxy',0);
set(gca,'XTick',[]);
set(hE(2),'LineWidth',10);

%mean dGrt0
[AX,H1,H2] =plotyy(zeros(1,length(X1)),X1,Y0(xip),X1);
%position
set(AX(1),'Position',[0.05 0.1 0.4 0.8]);
set(AX(2),'Position',[0.05 0.1 0.4 0.8]);
%lines
set(H1,'Color','w','LineWidth',2,'LineStyle','--');
set(H2,'Marker','.','LineStyle','none','MarkerSize',18)
%mean dGt0
set(AX(1),'YTick',[],'YTickLabelMode','manual');
set(AX(2),'XTickMode','manual','XTick',floor(minX/100)*200:20:maxX,'YColor','k');
set(AX(2),'YTickMode','manual','YTick',1:length(xip));
%axis limits
axis(AX(1),[minX maxX 0 length(X1)+0.5 ])
axis(AX(2),[minX maxX 0 length(X1)+0.5 ])
title({'Qualitatively forward -> quantitatively reversible. (\Delta_{r}G^{\primeo} from K_{eq}).'},'FontSize',16)
set(get(AX(2),'Xlabel'),'String','\Delta_{r}G^{\prime} (kJ/mol)','FontSize',16)

% ylabel('Reactions, sorted by maximum \Delta_{r}G^{\prime}');

for n=1:length(xip)
%     textLen(n)=length(model.rxn(xip(n)).officialName)+length(model.rxn(xip(n)).equation);
%     textLen(n)=length(model.rxn(xip(n)).equation);
   textLen(n)=length(model.rxn(xip(n)).officialName);
end
textLenMax=max(textLen);
for n=1:length(xip)
    YTickLabel{n}=[model.rxn(xip(n)).officialName blanks(textLenMax-textLen(n)+5) model.rxn(xip(n)).equation];
    %get rid of the cytoplasmic compartment abbreviations
    YTickLabel{n} = strrep(YTickLabel{n}, '[c]', '');
    
   % no idea why this does not work 
   %     fprintf('%s\n',[model.rxn(xip(n)).officialName blanks(textLenMax-textLen(n)+5) model.rxn(xip(n)).equation]);
end
set(AX(2),'YTickLabel',YTickLabel,'FontSize',10);
saveas(figure1 ,'fwdReversibleKeq_nonTransport','fig');

%change back
if thorStandard
    model.dGt0Min=dGt0Min;
    model.dGt0Max=dGt0Max;
end