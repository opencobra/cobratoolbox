function singleMetaboliteThermoFigure(model,miliMolarStandard,metAbbr)
%create a vertical errorbar figure of the reactions involving the
%metabolite given by the abbreviation
% todo = fix this up
%INPUT
% model
% miliMolarStandard
% metAbbr
%
% Ronan M.T. Fleming

%%%%%%%%%vertical%%%%%%%%%%%%%
[nMet,nRxn]=size(model.S);
if miliMolarStandard
    dGt0Min=model.dGt0Min;
    dGt0Max=model.dGt0Max;
    for n=1:nRxn
        model.dGt0Min(n)=model.rxn(n).dGtmMMin;
        model.dGt0Max(n)=model.rxn(n).dGtmMMax;
    end
end
%forward possibly reversible
dGfGCforwardReversibleBool=directions.ChangeForwardReversibleBool_dGfGC;
%forward, probably reverse
fwdProbReverse=directions.ChangeForwardReversibleBool_dGfGC_byConcRHS | ...
    directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS | ...
    directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS;

%plot regions 5,6,7, with region 6 shaded
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
xip2=zeros(nnz(fwdProbReverse),1);
p=1;
for n=1:nRxn
    if fwdProbReverse(xip(n))
        xip2(p)=xip(n);
        p=p+1;
    end
end
xip=xip2;
X1=1:length(xip);

%replace the NaN due to zero st dev
nNaNpRHS=nnz(directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS);
if nNaNpRHS~=nnz(isnan((P(fwdProbReverse))))
    warning('ExtraCategory');
end
%nans are first in the ordering of indexes
NaNPInd=xip(1:nNaNpRHS);
%sorts indices of the zero std dev met by their mean dG0t
[tmp,xipNaNPInd]=sort(Y0(NaNPInd));
%new ordering with NaNs sorted to right
xip=[xip(nNaNpRHS+1:end); NaNPInd(xipNaNPInd(1:nNaNpRHS))];

% close all
figure1 = figure;
% Create axes
axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
hold on;

%upper and lower X
minX=min(model.dGtMin(fwdProbReverse));
maxX=max(model.dGtMax(fwdProbReverse));
%baselines
PreversibleBar_byConcRHS=ones(1,nRxn)*minX;
%bar for 6
PreversibleBar_byConcRHS(directions.ChangeForwardReversibleBool_dGfGC_byConcRHS)=maxX;
bar_handle6=barh(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minX,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');

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
set(hE(2),'LineWidth',10);
% hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
%dGrt0 errorbar on top and inside dGrt
LineSpec='b.';
hE = ploterr(Y0(xip),X1,{model.dGt0Min(xip) model.dGt0Max(xip)},[],LineSpec,'hhxy',0);
set(hE(2),'LineWidth',10);
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
set(AX(1),'FontSize',16,'YColor','k')
set(AX(1),'YTick',[],'YTickLabelMode','manual');
set(AX(1),'XTickMode','manual','XTick',floor(minX/100)*200:50:maxX);
set(get(AX(1),'Xlabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
set(get(AX(1),'Xlabel'),'FontSize',16)
set(AX(1),'Position',[0.05 0.1 0.4 0.8]);
axis(AX(1),[minX maxX 0.5 length(X1)+0.5 ]);
% axis(AX(1),[-250 250 0 length(X1)+0.5 ]);

set(AX(2),'FontSize',16,'YColor','k')
set(AX(2),'YTick',1:length(X1),'YTickLabelMode','manual');
set(AX(2),'XAxisLocation','top');
set(get(AX(2),'Xlabel'),'String','P(\Delta_{r}G^{\primem}<0)');
set(get(AX(2),'Xlabel'),'FontSize',16);
axis(AX(2),[0 1 0.5 length(X1)+0.5 ]);
set(AX(2),'Position',[0.05 0.1 0.4 0.8]);

% ylabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0) (blue)');
title('Qualitatively forward, but probably quantitatively reverse, using group contribution estimates of \Delta_{r}G^{\primem}.','FontSize',16)

for n=1:length(xip)
%     textLen(n)=length(model.rxn(xip(n)).officialName)+length(model.rxn(xip(n)).equation);
%     textLen(n)=length(model.rxn(xip(n)).equation);
   textLen(n)=length(model.rxn(xip(n)).officialName);
end
textLenMax=max(textLen);
for n=1:length(xip)
%     YTickLabel{n}=[model.rxn(xip(n)).officialName blanks(textLenMax-textLen(n)+5) model.rxn(xip(n)).equation];
    YTickLabel{n}=[model.rxn(xip(n)).officialName ' ' model.rxn(xip(n)).equation];
    %get rid of the cytoplasmic compartment abbreviations
    YTickLabel{n} = strrep(YTickLabel{n}, '[c]', '');
    
   % no idea why this does not work 
   %     fprintf('%s\n',[model.rxn(xip(n)).officialName blanks(textLenMax-textLen(n)+5) model.rxn(xip(n)).equation]);
end
set(AX(2),'YTickLabel',YTickLabel,'FontSize',16);
saveas(figure1 ,'fwdProbReverseGC','fig');

%change back
if miliMolarStandard
    model.dGt0Min=dGt0Min;
    model.dGt0Max=dGt0Max;
end


%horizontal bar
horizontal=0;
if horizontal
    [nMet,nRxn]=size(model.S);
    if miliMolarStandard
        dGt0Min=model.dGt0Min;
        dGt0Max=model.dGt0Max;
        for n=1:nRxn
            model.dGt0Min(n)=model.rxn(n).dGtmMMin;
            model.dGt0Max(n)=model.rxn(n).dGtmMMax;
        end
    end
    %forward possibly reversible
    dGfGCforwardReversibleBool=directions.ChangeForwardReversibleBool_dGfGC;
    %forward, probably reverse
    fwdProbReverse=directions.ChangeForwardReversibleBool_dGfGC_byConcRHS | ...
        directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS | ...
        directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS;
    
    %plot regions 5,6,7, with region 6 shaded
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
    xip2=zeros(nnz(fwdProbReverse),1);
    p=1;
    for n=1:nRxn
        if fwdProbReverse(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    %replace the NaN due to zero st dev
    nNaNpRHS=nnz(directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS);
    if nNaNpRHS~=nnz(isnan((P(fwdProbReverse))))
        warning('ExtraCategory');
    end
    %nans are first in the ordering of indexes
    NaNPInd=xip(1:nNaNpRHS);
    %sorts indices of the zero std dev met by their mean dG0t
    [tmp,xipNaNPInd]=sort(Y0(NaNPInd));
    %new ordering with NaNs sorted to right
    xip=[xip(nNaNpRHS+1:end); NaNPInd(xipNaNPInd(1:nNaNpRHS))];
    
    figure1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape');
    % Create axes
    axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.dGtMin(fwdProbReverse));
    maxY=max(model.dGtMax(fwdProbReverse));
    %baselines
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    %bar for 6
    PreversibleBar_byConcRHS(directions.ChangeForwardReversibleBool_dGfGC_byConcRHS & directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS)=maxY;
    bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
    % adjust error bar width
    hE_c=get(hE, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');
    % adjust error bar width
    hE_c=get(hE2, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    
    %mean dGrt0
    plot(X1,Y0(xip),'.','LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,P(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:50:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none')
    set(H2,'LineStyle','-','LineWidth',2,'Color','k')
    plot(X1,zeros(1,length(X1)),'w','LineWidth',2,'LineStyle','--');
    %axis limits
    axis(AX(1),[0 length(X1) minY maxY])
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    axis(AX(2),[0 length(X1) 0 1])
    title({'Qualitatively forward, but quantitatively reversible' ; 'using group contribution estimates of \Delta_{r}G^{\primem}.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0) (blue)');
    saveas(figure1 ,'GCfwdProbFwd','fig');
    
    %change back
    if miliMolarStandard
        model.dGt0Min=dGt0Min;
        model.dGt0Max=dGt0Max;
    end
end