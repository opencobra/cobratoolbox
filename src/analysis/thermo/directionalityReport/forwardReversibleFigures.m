function forwardReversibleFigures(model, directions, confidenceLevel)
% Figures of different classes of reactions: qualitatively forward -> quantitatively reversible
%
% USAGE:
%
%    forwardReversibleFigures(model, directions, confidenceLevel)
%
% INPUTS:
%    model:              structure with fields:
%
%                          * .S
%                          * .DrGt0
%
%    directions:         subsets of qualtiatively forward -> quantiatively reversible
%
%                          * .forwardReversible
%                          * .forwardReversible_bydGt0
%                          * .forwardReversible_bydGt0LHS
%                          * .forwardReversible_bydGt0Mid
%                          * .forwardReversible_bydGt0RHS
%                          * .forwardReversible_byConc_zero_fixed_DrG0
%                          * .forwardReversible_byConc_negative_fixed_DrG0
%                          * .forwardReversible_byConc_positive_fixed_DrG0
%                          * .forwardReversible_byConc_negative_uncertain_DrG0
%                          * .forwardReversible_byConc_positive_uncertain_DrG0
%    confidenceLevel:    default = 0.95
%
% .. Author: - Ronan M.T. Fleming

figureMaster=1; % close all
figure1=1;
figure2=1;
figure345=1;
figure6=1;
figure7=1;

if ~exist('confidenceLevel','var') || isempty(confidenceLevel)
    confidenceLevel = 0.95;
end

% Map confidence level to t-value
tValueMat = [0.50, 0;...
    0.70, 1.036;...
    0.95, 1.960;...
    0.99, 2.576];

tValue = tValueMat(tValueMat(:,1) == confidenceLevel,2);

%all forward reversible classes
% forwardReversible=directions.forwardReversible;
forward2Reversible=directions.forward2Reversible;
forward2Reversible_bydGt0=directions.forward2Reversible_bydGt0;
forward2Reversible_byConc_negative_uncertain_DrG0=directions.forward2Reversible_byConc_negative_uncertain_DrG0;
forward2Reversible_byConc_positive_uncertain_DrG0=directions.forward2Reversible_byConc_positive_uncertain_DrG0;
forward2Reversible_bydGt0LHS=directions.forward2Reversible_bydGt0LHS;
forward2Reversible_bydGt0Mid=directions.forward2Reversible_bydGt0Mid;
forward2Reversible_bydGt0RHS=directions.forward2Reversible_bydGt0RHS;
forward2Reversible_byConc_negative_fixed_DrG0=directions.forward2Reversible_byConc_negative_fixed_DrG0;
forward2Reversible_byConc_positive_fixed_DrG0=directions.forward2Reversible_byConc_positive_fixed_DrG0;

[~,nRxn]=size(model.S);

thorStandard=1;
if thorStandard
    %DrGt0
    Y0=model.DrGt0;
    L0=tValue*model.DrG0_Uncertainty;
    U0=tValue*model.DrG0_Uncertainty;
    %DrGt
    Y=model.DrGtMean;
    L=Y-model.DrGtMin;
    U=model.DrGtMax-Y;

    forwardProbability=NaN*ones(nRxn,1);
    for n=1:nRxn
        if model.SIntRxnBool(n)
            %forwardProbability(n)= normcdf(0,model.DrGt0(n),tValue*model.DrG0_Uncertainty(n),tValue*model.DrG0_Uncertainty(n));
            forwardProbability(n)= normcdf(0,model.DrGt0(n),tValue*model.DrG0_Uncertainty(n),tValue*model.DrG0_Uncertainty(n));
            if strcmp(model.rxns{n},'ACYP') & 0
                fprintf('%s\n',model.rxns{n})
            end
        end
    end
else
    X1=1:nRxn;%nnz(forward2Reversible);
    %dGrt0
    Y0=(model.DrGt0Min+model.DrGt0Max)/2;
    L0=Y0-model.DrGt0Min;
    U0=model.DrGt0Max-Y0;
    %dGrt
    Y=(model.DrGtMin+model.DrGtMax)/2;
    L=Y-model.DrGtMin;
    U=model.DrGtMax-Y;
    %find the amount of reactions with normal cumulative distribution over
    %range of dGt0
    forwardProbability = normcdf(0,Y0,L0);
end


if 0
    figure
    plot(model.DrG0_Uncertainty,model.directions.forwardProbability,'*')

    figure
    hist(forwardProbability(model.SIntRxnBool),100)
end

%make the master plot of all 7 regions, 2, 4,6 are shaded
if figureMaster
    %sort by probability that a reaction is forward (puts any NaN first)
    [tmp,xip]=sort(forwardProbability,'descend');

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending forwardProbability
    xip2=zeros(nnz(forward2Reversible),1);
    p=1;
    for n=1:nRxn
        if forward2Reversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(forward2Reversible_byConc_negative_fixed_DrG0);
    nNaNpRHS=nnz(forward2Reversible_byConc_positive_fixed_DrG0);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((forwardProbability(forward2Reversible))))
        warning('A:B','Extra category of NaN P(\Delta_{r}G^{\primem}<0) not taken into account');

        %nans are first in the ordering of indexes
        NaNPInd=xip(1:nNaNpLHS+nNaNpRHS);
        %sorts indices of the zero std dev met by their mean dG0t
        [tmp,xipNaNPInd]=sort(Y0(NaNPInd));
        %new ordering
        xip=[NaNPInd(xipNaNPInd(1:nNaNpLHS)); xip(nNaNpLHS+nNaNpRHS+1:end); NaNPInd(xipNaNPInd(nNaNpLHS+1:nNaNpLHS+nNaNpRHS))];
    end

    %fig1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape');
    fig1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape','units','normalized','outerposition',[0 0 1 1]);
    % Create axes
    axes1 = axes('Parent',fig1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.DrGtMin(forward2Reversible));
    maxY=max(model.DrGtMax(forward2Reversible));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(forward2Reversible_byConc_negative_uncertain_DrG0)=maxY;
    PreversibleBar_byConcRHS(forward2Reversible_byConc_positive_uncertain_DrG0)=maxY;
    %bar for 4
    PreversibleBar_bydGt0(forward2Reversible_bydGt0Mid)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle4=bar(X1,PreversibleBar_bydGt0(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');

    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',length(xip)/1000,'DisplayName','fwdRev by DrGt','Color','r');
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',length(xip)/1000,'DisplayName','fwdRev by DrGt0','Color','b');

    %mean dGrt0
    plot(X1,Y0(xip),'.','LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,forwardProbability(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:100:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none')
    set(H2,'LineStyle','-','LineWidth',2,'Color','k')
    plot(X1,zeros(1,length(X1)),'w','LineWidth',2,'LineStyle','--');
    %axis limits
    if 1
        axis(AX(1),[0 length(X1) minY maxY])
    else
        axis(AX(1),[0 length(X1) -500 500]);
    end
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    axis(AX(2),[0 length(X1) 0 1])
    title('Qualitatively forward, but quantitatively reversible using estimates of \Delta_{r}G^{\primem}.','FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by \Delta_{r}G^{\primem} or P(\Delta_{r}G^{\primem}<0)');
    saveas(fig1 ,'fwdReversible','fig');
    saveas(fig1 ,'fwdReversible','eps');
end


%qualitatively forward reactions that are quantitatively
%reversible by concentration alone (no dGt0 error)
% fprintf('%i%s\n',nnz(forward2Reversible_byConc_negative_fixed_DrG0),' qualitatively forward reactions that are GC quantitatively forward by dGr0t, but reversible by concentration alone (No error in GC dGr0t).');
if figure1 && any(forward2Reversible_byConc_negative_fixed_DrG0)
    %sort by probability that a reaction is forward (puts any NaN first)
    [tmp,xip]=sort(P,'descend');

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(forward2Reversible),1);
    p=1;
    for n=1:nRxn
        if forward2Reversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(forward2Reversible_byConc_negative_fixed_DrG0);
    nNaNpRHS=nnz(forward2Reversible_byConc_positive_fixed_DrG0);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(forward2Reversible))))
        warning('ExtraCategory');
    end
    %nans are first in the ordering of indexes
    NaNPInd=xip(1:nNaNpLHS+nNaNpRHS);
    %sorts indices of the zero std dev met by their mean dG0t
    [tmp,xipNaNPInd]=sort(Y0(NaNPInd));
    %new ordering
    xip=[NaNPInd(xipNaNPInd(1:nNaNpLHS)); xip(nNaNpLHS+nNaNpRHS+1:end); NaNPInd(xipNaNPInd(nNaNpLHS+1:nNaNpLHS+nNaNpRHS))];
    %     xip=xip(nNaNpLHS+nNaNpRHS+1:end);

    %reactions that cannot be assigned directionality
    %cuttoff for probabilities: must be reflective about 0.5;
    %     forward2Reversible_bydGt0Mid=P<0.6 & P>0.4 & forward2Reversible;

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(forward2Reversible_byConc_negative_fixed_DrG0),1);
    p=1;
    for n=1:length(xip)
        if forward2Reversible_byConc_negative_fixed_DrG0(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    fig1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape','units','normalized','outerposition',[0 0 1 1]);
    % Create axes
    axes1 = axes('Parent',fig1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.DrGtMin(forward2Reversible_byConc_negative_fixed_DrG0));
    maxY=max(model.DrGtMax(forward2Reversible_byConc_negative_fixed_DrG0));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(forward2Reversible_byConc_negative_uncertain_DrG0)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');

    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','r');
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','b');

    %mean dGrt0
    plot(X1,Y0(xip),'.','MarkerSize',20,'LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,P(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:20:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none')
    set(H2,'LineStyle','-','LineWidth',2,'Color','k')
    plot(X1,zeros(1,length(X1)),'w','LineWidth',2,'LineStyle','--');
    %axis limits
    %     axis(AX(1),[0 length(X1) minY maxY])
    axis(AX(1),[0 length(X1) -200 200]);
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    axis(AX(2),[0 length(X1) 0 1])
    title({'Qualitatively forward, but quantitatively reversible. Exact negative \Delta_{r}G^{\primem},';...
        'but with a quantitatively reversible concentration range.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0)');
end

%qualitatively reverse reactions that are quantitatively
%reversible by concentration alone (no dGt0 error)
% fprintf('%i%s\n',nnz(forward2Reversible_byConc_positive_fixed_DrG0),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration.(No error in GC dGr0t).');
if figure7 && any(forward2Reversible_byConc_positive_fixed_DrG0)
    %sort by probability that a reaction is forward (puts any NaN first)
    [tmp,xip]=sort(forwardProbability,'descend');

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(forward2Reversible),1);
    p=1;
    for n=1:nRxn
        if forward2Reversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(forward2Reversible_byConc_negative_fixed_DrG0);
    nNaNpRHS=nnz(forward2Reversible_byConc_positive_fixed_DrG0);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(forward2Reversible))))
        warning('ExtraCategory');
    end
    %nans are first in the ordering of indexes
    NaNPInd=xip(1:nNaNpLHS+nNaNpRHS);
    %sorts indices of the zero std dev met by their mean dG0t
    [tmp,xipNaNPInd]=sort(Y0(NaNPInd));
    %new ordering
    xip=[NaNPInd(xipNaNPInd(1:nNaNpLHS)); xip(nNaNpLHS+nNaNpRHS+1:end); NaNPInd(xipNaNPInd(nNaNpLHS+1:nNaNpLHS+nNaNpRHS))];
    %     xip=xip(nNaNpLHS+nNaNpRHS+1:end);

    %reactions that cannot be assigned directionality
    %cuttoff for probabilities: must be reflective about 0.5;
    %     forward2Reversible_bydGt0Mid=P<0.6 & P>0.4 & forward2Reversible;

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(forward2Reversible_byConc_positive_fixed_DrG0),1);
    p=1;
    for n=1:length(xip)
        if forward2Reversible_byConc_positive_fixed_DrG0(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    fig1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape','units','normalized','outerposition',[0 0 1 1]);
    % Create axes
    axes1 = axes('Parent',fig1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.DrGtMin(forward2Reversible_byConc_positive_fixed_DrG0));
    maxY=max(model.DrGtMax(forward2Reversible_byConc_positive_fixed_DrG0));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(forward2Reversible_byConc_negative_uncertain_DrG0)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');

    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','r');

    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','b');

    %mean dGrt0
    plot(X1,Y0(xip),'.','MarkerSize',24,'LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,P(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:20:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none')
    set(H2,'LineStyle','-','LineWidth',2,'Color','k')
    plot(X1,zeros(1,length(X1)),'w','LineWidth',2,'LineStyle','--');
    %axis limits
    axis(AX(1),[0 (length(X1)+1) minY maxY])
    %     axis(AX(1),[0 length(X1) -500 500]);
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    axis(AX(2),[0 (length(X1)+1) 0 1])
    title({'Qualitatively forward, but quantitatively reversible. Exact positive \Delta_{r}G^{\primem},';...
        'but with a quantitatively reversible concentration range.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0)');
end

%qualitatively reverse reactions that are quantitatively
%reversible by concentration alone (with dGt0 error)
% fprintf('%i%s\n',nnz(forward2Reversible_byConc_negative_uncertain_DrG0),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration.');
if figure2 && any(forward2Reversible_byConc_negative_uncertain_DrG0)
    %sort by probability that a reaction is forward (puts any NaN first)
    [tmp,xip]=sort(forwardProbability,'descend');

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(forward2Reversible),1);
    p=1;
    for n=1:nRxn
        if forward2Reversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(forward2Reversible_byConc_negative_fixed_DrG0);
    nNaNpRHS=nnz(forward2Reversible_byConc_positive_fixed_DrG0);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((forwardProbability(forward2Reversible))))
        warning('ExtraCategory');
    end
    %nans are first in the ordering of indexes
    NaNPInd=xip(1:nNaNpLHS+nNaNpRHS);
    %sorts indices of the zero std dev met by their mean dG0t
    [tmp,xipNaNPInd]=sort(Y0(NaNPInd));
    %new ordering
    xip=[NaNPInd(xipNaNPInd(1:nNaNpLHS)); xip(nNaNpLHS+nNaNpRHS+1:end); NaNPInd(xipNaNPInd(nNaNpLHS+1:nNaNpLHS+nNaNpRHS))];
    %     xip=xip(nNaNpLHS+nNaNpRHS+1:end);

    %reactions that cannot be assigned directionality
    %cuttoff for probabilities: must be reflective about 0.5;
    %     forward2Reversible_bydGt0Mid=P<0.6 & P>0.4 & forward2Reversible;

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(forward2Reversible_byConc_negative_uncertain_DrG0),1);
    p=1;
    for n=1:length(xip)
        if forward2Reversible_byConc_negative_uncertain_DrG0(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    fig1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape','units','normalized','outerposition',[0 0 1 1]);
    % Create axes
    axes1 = axes('Parent',fig1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.DrGtMin(forward2Reversible_byConc_negative_uncertain_DrG0));
    maxY=max(model.DrGtMax(forward2Reversible_byConc_negative_uncertain_DrG0));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    %PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    %PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(forward2Reversible_byConc_negative_uncertain_DrG0)=maxY;
    %PreversibleBar_byConcRHS(forward2Reversible_byConc_positive_uncertain_DrG0)=maxY;
    %bar for 4
    %PreversibleBar_bydGt0(forward2Reversible_bydGt0Mid)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    %     bar_handle4=bar(X1,PreversibleBar_bydGt0(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    %     bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    %
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','r');
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','b');

    %mean dGrt0
    plot(X1,Y0(xip),'.','MarkerSize',9,'LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,forwardProbability(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:50:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none');
    set(H2,'LineStyle','-','LineWidth',2,'Color','k');
    plot(X1,zeros(1,length(X1)),'w','LineWidth',2,'LineStyle','--');
    %axis limits
    if length(X1)~=1
        axis(AX(1),[1 length(X1) minY maxY])
    else
        axis(AX(1),[1-0.5 length(X1)+0.5 minY maxY])
    end
    %     axis(AX(1),[1 length(X1) -500 500]);
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    if length(X1)~=1
        axis(AX(2),[1 length(X1) 0 1])
    else
        axis(AX(2),[1-0.5 length(X1)+0.5 0 1])
    end
    title({'Qualitatively forward, but quantitatively reversible. Negative  \Delta_{r}G^{\primem} estimate,';...
        'even with uncertainty, but with a quantitatively reversible concentration range.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0)');
end

%qualitatively reverse reactions that are quantitatively
%reversible by concentration alone (with dGt0 error)
% fprintf('%i%s\n',nnz(forward2Reversible_byConc_positive_uncertain_DrG0),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration.');
if figure6 && any(forward2Reversible_byConc_positive_uncertain_DrG0)
    %sort by probability that a reaction is forward (puts any NaN first)
    [tmp,xip]=sort(forwardProbability,'descend');

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(forward2Reversible),1);
    p=1;
    for n=1:nRxn
        if forward2Reversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(forward2Reversible_byConc_negative_fixed_DrG0);
    nNaNpRHS=nnz(forward2Reversible_byConc_positive_fixed_DrG0);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((forwardProbability(forward2Reversible))))
        warning('ExtraCategory');
    end
    %nans are first in the ordering of indexes
    NaNPInd=xip(1:nNaNpLHS+nNaNpRHS);
    %sorts indices of the zero std dev met by their mean dG0t
    [tmp,xipNaNPInd]=sort(Y0(NaNPInd));
    %new ordering
    xip=[NaNPInd(xipNaNPInd(1:nNaNpLHS)); xip(nNaNpLHS+nNaNpRHS+1:end); NaNPInd(xipNaNPInd(nNaNpLHS+1:nNaNpLHS+nNaNpRHS))];
    %     xip=xip(nNaNpLHS+nNaNpRHS+1:end);

    %reactions that cannot be assigned directionality
    %cuttoff for probabilities: must be reflective about 0.5;
    %     forward2Reversible_bydGt0Mid=forwardProbability<0.6 & forwardProbability>0.4 & forward2Reversible;

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending forwardProbability
    xip2=zeros(nnz(forward2Reversible_byConc_positive_uncertain_DrG0),1);
    p=1;
    for n=1:length(xip)
        if forward2Reversible_byConc_positive_uncertain_DrG0(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    fig1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape','units','normalized','outerposition',[0 0 1 1]);
    % Create axes
    axes1 = axes('Parent',fig1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.DrGtMin(forward2Reversible_byConc_positive_uncertain_DrG0));
    maxY=max(model.DrGtMax(forward2Reversible_byConc_positive_uncertain_DrG0));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(forward2Reversible_byConc_negative_uncertain_DrG0)=maxY;
    PreversibleBar_byConcRHS(forward2Reversible_byConc_positive_uncertain_DrG0)=maxY;
    %bar for 4
    PreversibleBar_bydGt0(forward2Reversible_bydGt0Mid)=maxY;
    %     bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    %     bar_handle4=bar(X1,PreversibleBar_bydGt0(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    %
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','r');
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','b');

    %mean dGrt0
    plot(X1,Y0(xip),'.','MarkerSize',16,'LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,forwardProbability(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:20:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none');
    set(H2,'LineStyle','-','LineWidth',2,'Color','k');
    plot(X1,zeros(1,length(X1)),'w','MarkerSize',10,'LineWidth',2,'LineStyle','--');
    %axis limits
    axis(AX(1),[0.48 (length(X1)+0.48) minY maxY])
    %     axis(AX(1),[0.48 (length(X1)+0.48) -500 500]);
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    axis(AX(2),[0.48 (length(X1)+0.48) 0 1])
    title({'Qualitatively forward, but quantitatively reversible. Positive  \Delta_{r}G^{\primem} estimate,';...
        'even with uncertainty, but with a quantitatively reversible concentration range.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0)');
end

%qualitatively forward reactions that are quantitatively reversible by
%the range of dGt0
% fprintf('%i%s\n',nnz(forward2Reversible_bydGt0),' qualitatively forward reactions that are GC quantitatively reversible by range of dGt0.');
if figure345 && any(forward2Reversible_bydGt0)
    %sort by probability that a reaction is forward (puts any NaN first)
    [tmp,xip]=sort(forwardProbability,'descend');

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending forwardProbability
    xip2=zeros(nnz(forward2Reversible),1);
    p=1;
    for n=1:nRxn
        if forward2Reversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(forward2Reversible_byConc_negative_fixed_DrG0);
    nNaNpRHS=nnz(forward2Reversible_byConc_positive_fixed_DrG0);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((forwardProbability(forward2Reversible))))
        warning('A:B','Extra category of NaN P(\Delta_{r}G^{\primem}<0) not taken into account');

        %nans are first in the ordering of indexes
        NaNPInd=xip(1:nNaNpLHS+nNaNpRHS);
        %sorts indices of the zero std dev met by their mean dG0t
        [tmp,xipNaNPInd]=sort(Y0(NaNPInd));
        %new ordering
        xip=[NaNPInd(xipNaNPInd(1:nNaNpLHS)); xip(nNaNpLHS+nNaNpRHS+1:end); NaNPInd(xipNaNPInd(nNaNpLHS+1:nNaNpLHS+nNaNpRHS))];
    end

    %reactions that cannot be assigned directionality
    %cuttoff for probabilities: must be reflective about 0.5;
    %     forward2Reversible_bydGt0Mid=forwardProbability<0.6 & forwardProbability>0.4 & forward2Reversible;

    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending forwardProbability
    xip2=zeros(nnz(forward2Reversible_bydGt0),1);% forward2Reversible_byConc_positive_uncertain_DrG0),1);
    p=1;
    for n=1:length(xip)
        if forward2Reversible_bydGt0(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);

    fig1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape','units','normalized','outerposition',[0 0 1 1]);
    % Create axes
    axes1 = axes('Parent',fig1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.DrGtMin(forward2Reversible_bydGt0));
    maxY=max(model.DrGtMax(forward2Reversible_bydGt0));

    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(forward2Reversible_byConc_negative_uncertain_DrG0)=maxY;
    PreversibleBar_byConcRHS(forward2Reversible_byConc_positive_uncertain_DrG0)=maxY;
    %bar for 4
    PreversibleBar_bydGt0(forward2Reversible_bydGt0Mid)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none'); %TODO - problem here with zeros at end of xip
    bar_handle4=bar(X1,PreversibleBar_bydGt0(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');

    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',length(xip)/400,'DisplayName','forward2Reversible','Color','r');
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',length(xip)/500,'DisplayName','forward2Reversible','Color','b');

    %mean dGrt0
    plot(X1,Y0(xip),'.','MarkerSize',6,'LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,forwardProbability(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:100:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none')
    set(H2,'LineStyle','-','LineWidth',2,'Color','k')
    plot(X1,zeros(1,length(X1)),'w','LineWidth',2,'LineStyle','--');
    %axis limits
    %     axis(AX(1),[0 length(X1) minY maxY])
    %axis limits
    if 1
        axis(AX(1),[0 length(X1) minY maxY])
    else
        axis(AX(1),[0 length(X1) -500 500]);
    end
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    axis(AX(2),[0 length(X1) 0 1])
    title({'Qualitatively forward, but quantitatively reversible. The  ';
        '\Delta_{r}G^{\primem} estimates span the zero line.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0)');
end
