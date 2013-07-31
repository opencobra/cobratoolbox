function forwardTransportQuantReverseFigures(model,directions,thorStandard)
% figure of the qualitatively forward transport reactions that are quantitatively reversible
%
%create a vertical errorbar figure of the qualitatively forward transport reactions
%that are quantitatively reversible, whether from group contribution or
%Keq, that then need to be assigned to be forward, to limit the growth rate
% i.e. abc transporters or reactions involving protons
%
% INPUT
% model.transportRxnBool
% model.dGt0Min
% model.dGt0Max
% directions.ChangeForwardReversible
% thorStandard
%
% Ronan M.T. Fleming

[nMet,nRxn]=size(model.S);
%transport reactions
forwardTransportQuantReverseBool=false(nRxn,1);
for n=1:nRxn
    %if reaction directionality changed from forward to Reversible and als
    %a transport reaction
    if directions.ChangeForwardReversible(n) && model.transportRxnBool(n)
        %abc transporters or reactions involving protons
        if ~isempty(strfind(model.rxns{n},'abc')) ||  nnz(strcmp('h[c]',model.mets(model.S(:,n)~=0)))~=0 || nnz(strcmp('h[e]',model.mets(model.S(:,n)~=0)))~=0
            forwardTransportQuantReverseBool(n,1)=1;
        end
    end
end

%%%%%%%%%vertical%%%%%%%%%%%%%
if thorStandard
    dGt0Min=model.dGt0Min;
    dGt0Max=model.dGt0Max;
    for n=1:nRxn
        model.dGt0Min(n)=model.rxn(n).dGtmMMin;
        model.dGt0Max(n)=model.rxn(n).dGtmMMax;
    end
end

X1=1:nRxn;
%dGrt0
Y0=(model.dGt0Min+model.dGt0Max)/2;
L0=Y0-model.dGt0Min;
U0=model.dGt0Max-Y0;
%dGrt
Y=(model.dGtMin+model.dGtMax)/2;
L=Y-model.dGtMin;
U=model.dGtMax-Y;
%find the amount of reactions with normal cumulative distribution over
%range of dGt0
P = normcdf(0,Y0,L0);
%sort by probability that a reaction is forward (puts any NaN first)
[tmp,xip]=sort(P,'descend');
%     only take the indices of the problematic reactions, but be sure to
%     take them in order of descending P
xip2=zeros(nnz(forwardTransportQuantReverseBool),1);
p=1;
for n=1:nRxn
    if forwardTransportQuantReverseBool(xip(n))
        xip2(p)=xip(n);
        p=p+1;
    end
end
xip=xip2;
X1=1:length(xip);

%replace the NaN due to zero st dev
forwardReversible_dGf_dG0Fwd=false(nRxn,1);
forwardReversible_dGf_dG0Rev=false(nRxn,1);
for n=1:nRxn
    %only the transport reactions
    if forwardTransportQuantReverseBool(n)
        if model.dGt0Min(n)==model.dGt0Max(n)
            if model.dGt0Min(n)<0
                forwardReversible_dGf_dG0Fwd(n)=1;
            else
                forwardReversible_dGf_dG0Rev(n)=1;
            end
        end
    end
end
nNaNpLHS=nnz(forwardReversible_dGf_dG0Fwd);
nNaNpRHS=nnz( forwardReversible_dGf_dG0Rev);
if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(forwardTransportQuantReverseBool))))
    warning('ExtraCategory');
end
%nans are first in the ordering of indexes
NaNPInd=xip(1:nNaNpLHS+nNaNpRHS);
%sorts indices of the zero std dev met by their mean dG0t
[tmp,xipNaNPInd]=sort(Y0(NaNPInd));
%new ordering
xip=[NaNPInd(xipNaNPInd(1:nNaNpLHS)); xip(nNaNpLHS+nNaNpRHS+1:end); NaNPInd(xipNaNPInd(nNaNpLHS+1:nNaNpLHS+nNaNpRHS))];

% close all
figure1 = figure;
% Create axes
axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
hold on;

%upper and lower X
minX=min(model.dGtMin(forwardTransportQuantReverseBool));
maxX=max(model.dGtMax(forwardTransportQuantReverseBool));
%baselines
Y1(1:length(xip))=minX;
P(P==1)=NaN;
P(P==0.5)=NaN;
Y1(~isnan(P(xip)) & P(xip)~=1 & P(xip)~=0.5)=maxX;
bar_handle6=barh(X1,Y1,1,'BaseValue',minX,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');

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
set(hE(2),'LineWidth',5);
% hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
%dGrt0 errorbar on top and inside dGrt
LineSpec='b.';
hE = ploterr(Y0(xip),X1,{model.dGt0Min(xip) model.dGt0Max(xip)},[],LineSpec,'hhxy',0);
set(hE(2),'LineWidth',5);
% hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');

%mean dGrt0
plot(Y0(xip),X1,'.','LineStyle','none','Color',[0.3412 0.7961 0.1922]);
%zero line
%cumulative probability that reaction is really forward, assuming a
%normal distribution about the mean dGt0
[AX,H1,H2]=plotyy(zeros(1,length(X1)),X1,P(xip),X1);
set(gca,'XTick',[]);
set(AX(1),'XTickMode','manual','YTick',floor(minX/100)*200:50:maxX);%,'TickDirMode','manual','TickDir','out');
set(AX(2),'YTick',1:length(xip));
set(H1,'LineStyle','none')
set(H2,'LineStyle','-','LineWidth',2,'Color','k')
plot(zeros(1,length(X1)),X1,'w','LineWidth',2,'LineStyle','--');
%axis limits
set(AX(1),'FontSize',10,'YColor','k')
set(AX(1),'YTick',[],'YTickLabelMode','manual');
set(AX(1),'XTickMode','manual','XTick',floor(minX/100)*200:50:maxX);
set(get(AX(1),'Xlabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
set(get(AX(1),'Xlabel'),'FontSize',10)
set(AX(1),'Position',[0.05 0.1 0.4 0.8]);
% axis(AX(1),[minX maxX 0 length(X1)+0.5 ]);
axis(AX(1),[-350 350 0 length(X1)+0.5 ]);

set(AX(2),'FontSize',10,'YColor','k')
set(AX(2),'YTick',1:length(X1),'YTickLabelMode','manual');
set(AX(2),'XAxisLocation','top');
set(get(AX(2),'Xlabel'),'String','P(\Delta_{r}G^{\primem}<0)');
set(get(AX(2),'Xlabel'),'FontSize',10);
axis(AX(2),[0 1 0.5 length(X1)+0.5 ]);
set(AX(2),'Position',[0.05 0.1 0.4 0.8]);

% ylabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0) (blue)');
title({'Qualitatively forward transport reactions, but quantitatively reversible'},'FontSize',16)

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
saveas(figure1 ,'forwardTransportQuantReverseBoolSetToForward','fig');

%change back
if thorStandard
    model.dGt0Min=dGt0Min;
    model.dGt0Max=dGt0Max;
end