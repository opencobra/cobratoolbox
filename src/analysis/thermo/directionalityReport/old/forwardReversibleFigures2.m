function forwardReversibleFigures2(model,directions)
% Figures of different classes of reactions: qualitatively forward -> quantitatively reversible
%
%INPUT
%model.DrGt0

%model.S
%
% directions        subsets of qualtiatively forward  -> quantiatively reversible 
%   .forwardReversible
%   .forwardReversible_bydGt0
%   .forwardReversible_bydGt0LHS
%   .forwardReversible_bydGt0Mid
%   .forwardReversible_bydGt0RHS
%   .forwardReversible_byConc_zero_fixed_DrG0
%   .forwardReversible_byConc_negative_fixed_DrG0
%   .forwardReversible_byConc_positive_fixed_DrG0
%   .forwardReversible_byConc_negative_uncertain_DrG0
%   .forwardReversible_byConc_positive_uncertain_DrG0

% thorStandard


[nMet,nRxn]=size(model.S);

% if ~isfield(model,'DrGt0Mean')
%     model.DrGt0Mean=(model.DrGt0Min+model.DrGt0Max)/2;
% end
% if ~isfield(model,'DrGtMean')
%     model.DrGtMean=(model.DrGtMin+model.DrGtMax)/2;
% end

directions=model.directions;

% close all
figureMaster=1;
figure1=1;
figure2=1;
figure345=1;
figure6=1;
figure7=1;

if figureMaster
%     %make the master plot of all 7 regions, 2, 4,6 are shaded
%     X1=1:nRxn;%nnz(directions.forwardReversible);
%     %dGrt0
%     Y0=(model.dGt0Min+model.dGt0Max)/2;
%     L0=Y0-model.dGt0Min;
%     U0=model.dGt0Max-Y0;
%     %dGrt
%     Y=(model.dGtMin+model.dGtMax)/2;
%     L=Y-model.dGtMin;
%     U=model.dGtMax-Y;
%     %find the amount of reactions with normal cumulative distribution over
%     %range of dGt0
%     P = normcdf(0,Y0,L0);

    %Y0=model.DrGt0; %model.DrGt0 = model.DrGt0 + delta_pH + delta_chi;
    Y0=(model.DrGt0Min+model.DrGt0Max)/2;%old vonB11
    L0=Y0-model.DrGt0Min;
    U0=model.DrGt0Max-Y0;

    Y=model.DrGtMean; %model.DrGtMean=(model.DrGtMax+model.DrGtMin)/2;
    L=Y-model.DrGtMin;
    U=model.DrGtMax-Y;
    
    P=directions.forwardProbability;
    %sort by probability that a reaction is forward (puts any NaN first)
    [tmp,xip]=sort(P,'descend');
    
    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(directions.forwardReversible),1);
    p=1;
    for n=1:nRxn
         if directions.forwardReversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    %replace the NaN due to zero st dev
    %NaNpLHS=nnz(directions.forwardReversible_byConc_negative_uncertain_DrG0);
    %nNaNpRHS=nnz(directions.forwardReversible_byConc_positive_uncertain_DrG0);
    nNaNpLHS=nnz(isnan(directions.forwardReversible_byConc_negative_uncertain_DrG0));
    nNaNpRHS=nnz(isnan(directions.forwardReversible_byConc_positive_uncertain_DrG0));
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(directions.forwardReversible))))
        warning('A:B','Extra category of NaN P(Delta_{r}G^{primem}<0) not taken into account');
        %nans are first in the ordering of indexes
        NaNPInd=xip(1:nNaNpLHS+nNaNpRHS);
        %sorts indices of the zero std dev met by their mean dG0t
        [tmp,xipNaNPInd]=sort(model.DrGt0Mean(NaNPInd));
        %new ordering
        xip=[NaNPInd(xipNaNPInd(1:nNaNpLHS)); xip(nNaNpLHS+nNaNpRHS+1:end); NaNPInd(xipNaNPInd(nNaNpLHS+1:nNaNpLHS+nNaNpRHS))];
    end
       
    figure1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape');
    % Create axes
    axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.DrGtMin(directions.forwardReversible));
    maxY=max(model.DrGtMax(directions.forwardReversible));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(directions.forwardReversible_byConc_negative_uncertain_DrG0)=maxY;
    PreversibleBar_byConcRHS(directions.forwardReversible_byConc_positive_uncertain_DrG0)=maxY;
    %bar for 4
    PreversibleBar_bydGt0(directions.forwardReversible_bydGt0Mid)=maxY;
    bar_handle4=bar(X1,PreversibleBar_bydGt0(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
    if 0
        % adjust error bar width
        %hE_c=get(hE, 'Children'); % deprecated since 2014b
        %errorbarXData= get(hE_c(2), 'XData');
        errorbarXData=get(hE, 'XData');
        errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
        errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
        errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
        errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
        %set(hE_c(2), 'XData', errorbarXData);
        set(hE, 'XData', errorbarXData);
    end
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');
    if 0
        % adjust error bar width
        %hE_c=get(hE2, 'Children');
        %errorbarXData= get(hE_c(2), 'XData');
        errorbarXData= get(hE2, 'XData');
        errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
        errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
        errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
        errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
        %set(hE_c(2), 'XData', errorbarXData);
        set(hE2, 'XData', errorbarXData);
    end
    
    %mean dGrt0
    plot(X1,Y0(xip),'.','LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,P(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:100:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none')
    set(H2,'LineStyle','-','LineWidth',2,'Color','k')
    plot(X1,zeros(1,length(X1)),'w','LineWidth',2,'LineStyle','--');
    %axis limits
    %     axis(AX(1),[0 length(X1) minY maxY])
    axis(AX(1),[0 length(X1) -500 500]);
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    axis(AX(2),[0 length(X1) 0 1])
    title('Qualitatively forward, but quantitatively reversible using group contribution estimates of \Delta_{r}G^{\primem}.','FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by \Delta_{r}G^{\primem} or P(\Delta_{r}G^{\primem}<0)');
    saveas(figure1 ,'fwdReversible','fig');
end

%qualitatively forward reactions that are quantitatively
%reversible by concentration alone (no dGt0 error)
% fprintf('%i%s\n',nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS),' qualitatively forward reactions that are GC quantitatively forward by dGr0t, but reversible by concentration alone (No error in GC dGr0t).');
%if figure1 && any(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS)
if ishandle(figure1) && any(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS)

    %make the master plot of all 7 regions, 2, 4,6 are shaded
    X1=1:nRxn;%nnz(directions.forwardReversible);
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
    xip2=zeros(nnz(directions.forwardReversible),1);
    p=1;
    for n=1:nRxn
        if directions.forwardReversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS);
    nNaNpRHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(directions.forwardReversible))))
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
%     dGfGCforwardReversibleBool_bydGt0Mid=P<0.6 & P>0.4 & directions.forwardReversible;
    
    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS),1);
    p=1;
    for n=1:length(xip)
        if dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    figure1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape');
    % Create axes
    axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.dGtMin(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS));
    maxY=max(model.dGtMax(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(dGfGCforwardReversibleBool_byConcLHS)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
   
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',9,'DisplayName','forwardReversible','Color','r');
    % adjust error bar width
    hE_c=get(hE, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',9,'DisplayName','forwardReversible','Color','b');
    % adjust error bar width
    hE_c=get(hE2, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    
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
% fprintf('%i%s\n',nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration.(No error in GC dGr0t).');
if figure7 && any(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS)
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
    xip2=zeros(nnz(directions.forwardReversible),1);
    p=1;
    for n=1:nRxn
        if directions.forwardReversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS);
    nNaNpRHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(directions.forwardReversible))))
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
%     dGfGCforwardReversibleBool_bydGt0Mid=P<0.6 & P>0.4 & directions.forwardReversible;
    
    %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS),1);
    p=1;
    for n=1:length(xip)
        if dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    figure1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape');
    % Create axes
    axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.dGtMin(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS));
    maxY=max(model.dGtMax(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(dGfGCforwardReversibleBool_byConcLHS)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
   
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',16,'DisplayName','forwardReversible','Color','r');
    % adjust error bar width
    hE_c=get(hE, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',16,'DisplayName','forwardReversible','Color','b');
    % adjust error bar width
    hE_c=get(hE2, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    
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
% fprintf('%i%s\n',nnz(dGfGCforwardReversibleBool_byConcLHS),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration.');
if figure2 && any(dGfGCforwardReversibleBool_byConcLHS)
    %make the master plot of all 7 regions, 2, 4,6 are shaded
    X1=1:nRxn;%nnz(directions.forwardReversible);
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
    xip2=zeros(nnz(directions.forwardReversible),1);
    p=1;
    for n=1:nRxn
        if directions.forwardReversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS);
    nNaNpRHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(directions.forwardReversible))))
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
%     dGfGCforwardReversibleBool_bydGt0Mid=P<0.6 & P>0.4 & directions.forwardReversible;
    
        %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(dGfGCforwardReversibleBool_byConcLHS),1);
    p=1;
    for n=1:length(xip)
        if dGfGCforwardReversibleBool_byConcLHS(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    figure1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape');
    % Create axes
    axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.dGtMin(dGfGCforwardReversibleBool_byConcLHS));
    maxY=max(model.dGtMax(dGfGCforwardReversibleBool_byConcLHS));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(dGfGCforwardReversibleBool_byConcLHS)=maxY;
    PreversibleBar_byConcRHS(dGfGCforwardReversibleBool_byConcRHS)=maxY;
    %bar for 4
    PreversibleBar_bydGt0(dGfGCforwardReversibleBool_bydGt0Mid)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
%     bar_handle4=bar(X1,PreversibleBar_bydGt0(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
%     bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
%     
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',4.5,'DisplayName','forwardReversible','Color','r');
    % adjust error bar width
    hE_c=get(hE, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',4.5,'DisplayName','forwardReversible','Color','b');
    % adjust error bar width
    hE_c=get(hE2, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    
    %mean dGrt0
    plot(X1,Y0(xip),'.','MarkerSize',9,'LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,P(xip));
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
    title({'Qualitatively forward, but quantitatively reversible. Negative group contribution \Delta_{r}G^{\primem} estimate,';...
            'even with uncertainty, but with a quantitatively reversible concentration range.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0)');
end

%qualitatively reverse reactions that are quantitatively
%reversible by concentration alone (with dGt0 error)
% fprintf('%i%s\n',nnz(dGfGCforwardReversibleBool_byConcRHS),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration.');
if figure6 && any(dGfGCforwardReversibleBool_byConcRHS)
    %make the master plot of all 7 regions, 2, 4,6 are shaded
    X1=1:nRxn;%nnz(directions.forwardReversible);
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
    xip2=zeros(nnz(directions.forwardReversible),1);
    p=1;
    for n=1:nRxn
        if directions.forwardReversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS);
    nNaNpRHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(directions.forwardReversible))))
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
%     dGfGCforwardReversibleBool_bydGt0Mid=P<0.6 & P>0.4 & directions.forwardReversible;
    
        %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(dGfGCforwardReversibleBool_byConcRHS),1);
    p=1;
    for n=1:length(xip)
        if dGfGCforwardReversibleBool_byConcRHS(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    figure1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape');
    % Create axes
    axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.dGtMin(dGfGCforwardReversibleBool_byConcRHS));
    maxY=max(model.dGtMax(dGfGCforwardReversibleBool_byConcRHS));
    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(dGfGCforwardReversibleBool_byConcLHS)=maxY;
    PreversibleBar_byConcRHS(dGfGCforwardReversibleBool_byConcRHS)=maxY;
    %bar for 4
    PreversibleBar_bydGt0(dGfGCforwardReversibleBool_bydGt0Mid)=maxY;
%     bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
%     bar_handle4=bar(X1,PreversibleBar_bydGt0(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
%     
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',10,'DisplayName','forwardReversible','Color','r');
    % adjust error bar width
    hE_c=get(hE, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',10,'DisplayName','forwardReversible','Color','b');
    % adjust error bar width
    hE_c=get(hE2, 'Children');
    errorbarXData= get(hE_c(2), 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    set(hE_c(2), 'XData', errorbarXData);
    
    %mean dGrt0
    plot(X1,Y0(xip),'.','MarkerSize',16,'LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,P(xip));
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
    title({'Qualitatively forward, but quantitatively reversible. Positive group contribution \Delta_{r}G^{\primem} estimate,';...
            'even with uncertainty, but with a quantitatively reversible concentration range.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0)');
end


%qualitatively forward reactions that are quantitatively reversible by
%the range of dGt0
% fprintf('%i%s\n',nnz(dGfGCforwardReversibleBool_bydGt0),' qualitatively forward reactions that are GC quantitatively reversible by range of dGt0.');
if figure345 && any(dGfGCforwardReversibleBool_bydGt0)
    %make the master plot of all 7 regions, 2, 4,6 are shaded
    X1=1:nRxn;%nnz(directions.forwardReversible);
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
    xip2=zeros(nnz(directions.forwardReversible),1);
    p=1;
    for n=1:nRxn
        if directions.forwardReversible(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    %replace the NaN due to zero st dev
    nNaNpLHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS);
    nNaNpRHS=nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS);
    if (nNaNpLHS+nNaNpRHS)~=nnz(isnan((P(directions.forwardReversible))))
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
%     dGfGCforwardReversibleBool_bydGt0Mid=P<0.6 & P>0.4 & directions.forwardReversible;
    
            %     only take the indices of the problematic reactions, but be sure to
    %     take them in order of descending P
    xip2=zeros(nnz(dGfGCforwardReversibleBool_bydGt0),1);% dGfGCforwardReversibleBool_byConcRHS),1);
    p=1;
    for n=1:length(xip)
        if dGfGCforwardReversibleBool_bydGt0(xip(n))
            xip2(p)=xip(n);
            p=p+1;
        end
    end
    xip=xip2;
    X1=1:length(xip);
    
    figure1 = figure('PaperSize',[11 8.5],'PaperOrientation','landscape');
    % Create axes
    axes1 = axes('Parent',figure1,'Color',[0.702 0.7804 1]);
    hold on;
    %upper and lower Y
    minY=min(model.dGtMin(dGfGCforwardReversibleBool_bydGt0));
    maxY=max(model.dGtMax(dGfGCforwardReversibleBool_bydGt0));

    %baselines
    PreversibleBar_byConcLHS=ones(1,nRxn)*minY;
    PreversibleBar_byConcRHS=ones(1,nRxn)*minY;
    PreversibleBar_bydGt0=ones(1,nRxn)*minY;
    %bar for 2 & 6
    PreversibleBar_byConcLHS(dGfGCforwardReversibleBool_byConcLHS)=maxY;
    PreversibleBar_byConcRHS(dGfGCforwardReversibleBool_byConcRHS)=maxY;
    %bar for 4
    PreversibleBar_bydGt0(dGfGCforwardReversibleBool_bydGt0Mid)=maxY;
    bar_handle2=bar(X1,PreversibleBar_byConcLHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle4=bar(X1,PreversibleBar_bydGt0(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    bar_handle6=bar(X1,PreversibleBar_byConcRHS(xip),1,'BaseValue',minY,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
    
    %dGrt errorbar
    hE=errorbar(X1,Y(xip),L(xip),U(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
    % adjust error bar width
    %hE_c=get(hE, 'Children');
    %errorbarXData= get(hE_c(2), 'XData');
    errorbarXData= get(hE, 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    %set(hE_c(2), 'XData', errorbarXData);
    set(hE, 'XData', errorbarXData);
    %dGrt0 errorbar on top and inside dGrt
    hE2=errorbar(X1,Y0(xip),L0(xip),U0(xip),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');
    % adjust error bar width
    %hE_c=get(hE2, 'Children');
    %errorbarXData= get(hE_c(2), 'XData');
    errorbarXData= get(hE2, 'XData');
    errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
    errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
    errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
    %set(hE_c(2), 'XData', errorbarXData);
    set(hE2, 'XData', errorbarXData);
    
    %mean dGrt0
    plot(X1,Y0(xip),'.','MarkerSize',6,'LineStyle','none','Color',[0.3412 0.7961 0.1922]);
    %zero line
    %cumulative probability that reaction is really forward, assuming a
    %normal distribution about the mean dGt0
    [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,P(xip));
    set(AX(1),'YTickMode','manual','YTick',floor(minY/100)*200:100:maxY);%,'TickDirMode','manual','TickDir','out');
    set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
    set(H1,'LineStyle','none')
    set(H2,'LineStyle','-','LineWidth',2,'Color','k')
    plot(X1,zeros(1,length(X1)),'w','LineWidth',2,'LineStyle','--');
    %axis limits
    %     axis(AX(1),[0 length(X1) minY maxY])
    axis(AX(1),[0 length(X1) -500 500]);
    set(AX(1),'FontSize',16)
    set(AX(2),'FontSize',16,'YColor','k')
    axis(AX(2),[0 length(X1) 0 1])
    title({'Qualitatively forward, but quantitatively reversible. The group contribution ';
           '\Delta_{r}G^{\primem} estimates span the zero line.'},'FontSize',16)
    set(get(AX(1),'Ylabel'),'String','\Delta_{r}G^{\primem}  (blue)    or     \Delta_{r}G^{\prime} (red) (kJ/mol)')
    set(get(AX(2),'Ylabel'),'String','P(\Delta_{r}G^{\primem}<0)')
    set(get(AX(1),'Ylabel'),'FontSize',16)
    set(get(AX(2),'Ylabel'),'FontSize',16)
    xlabel('Reactions, sorted by P(\Delta_{r}G^{\primem}<0)');
end

changedDirections = directions;
% old code
%         %reactions that are qualitatively forward but quantitatively reverse
%         X=1:nnz(changedDirections.forwardReversible);
%         Y=(model.dGt0Min(changedDirections.forwardReversible)+model.dGt0Max(changedDirections.forwardReversible))/2;
%         L=Y-model.dGt0Min(changedDirections.forwardReversible);
%         U=model.dGt0Max(changedDirections.forwardReversible)-Y;
%         [tmp,xi]=sort(Y);
%         [tmp,xi]=sort(model.dGt0Max(changedDirections.forwardReversible)-model.dGt0Min(changedDirections.forwardReversible));
%         errorbar(X,Y(xi),L(xi),U(xi),'b.')
%         title('All reactions that are qualitatively forward, yet quantitatively reversible');
%         ylabel('dGt0 (kJ/mol)')
%         xlabel('Reactions, sorted by uncertainty in dGt0')
%     
%         X=1:nnz(forwardReversibleKeq);
%         Y=(model.dGt0Min(forwardReversibleKeq)+model.dGt0Max(forwardReversibleKeq))/2;
%         L=Y-model.dGt0Min(forwardReversibleKeq);
%         U=model.dGt0Max(forwardReversibleKeq)-Y;
%         [tmp,xi]=sort(Y);
%         figure;
%         errorbar(X,Y(xi),L(xi),U(xi),'b.')
%         title('Reactions qualitiatively forward, but quantitatively reversible by Alberty');
%         ylabel('dGt0 (kJ/mol)')
%         xlabel('Reactions, sorted by mean dGt0')
% %     %GC forward prediction of reactions qualitiatively forward
% %     X1=1:nnz(dGfGCforwardForwardBool);
% %     Y=(model.dGt0Min(dGfGCforwardForwardBool)+model.dGt0Max(dGfGCforwardForwardBool))/2;
% %     L=Y-model.dGt0Min(dGfGCforwardForwardBool);
% %     U=model.dGt0Max(dGfGCforwardForwardBool)-Y;
% %     [tmp,xi]=sort(Y);
% %     figure;
% %     hold on
% %     errorbar(X1,Y(xi),L(xi),U(xi),'b.')
% %     legend('forwardForward')
% %     title('GC forward prediction of reactions qualitiatively forward')
% %     ylabel('dGt0 (kJ/mol)')
% %     xlabel('Reactions, sorted by mean dGt0')
% %
% %     [tmp,xi]=sort(abs(model.dGt0Max(dGfGCforwardForwardBool)-model.dGt0Min(dGfGCforwardForwardBool)));
% %     figure;
% %     hold on
% %     errorbar(X1,Y(xi),L(xi),U(xi),'b.')
% %     legend('forwardForward')
% %     title('GC forward prediction of reactions qualitiatively forward')
% %     ylabel('dGt0 (kJ/mol)')
% %     xlabel('Reactions, sorted by uncertainty in dGt0')
% %
% %     figure
% %     plot(Y(xi),L(xi),'.g')
% %     title('GC forward prediction of reactions qualitiatively forward')
% %     ylabel('dGt0 Uncertainty (kJ/mol)')
% %     xlabel('Reaction dGt0 (kJ/mol), sorted by uncertainty in dGt0')
% 
%     %GC reversible prediction of reactions qualitiatively forward by dGrt
%     %dGr0t
%     X1=1:nnz(directions.forwardReversible);
%     Y=(model.dGt0Min(directions.forwardReversible)+model.dGt0Max(directions.forwardReversible))/2;
%     L=Y-model.dGt0Min(directions.forwardReversible);
%     U=model.dGt0Max(directions.forwardReversible)-Y;
% %     [tmp,xi]=sort(Y);
% %     figure
% %     errorbar(X1,Y(xi),L(xi),U(xi),'r.')
% %     title('All GC reversible prediction of reactions qualitiatively forward')
% %     legend('forwardReversible')
% %     ylabel('dGt0 (kJ/mol)')
% %     xlabel('Reactions, sorted by mean dGt0')
%     %dGrt
%     Y2=(model.dGtMin(directions.forwardReversible)+model.dGtMax(directions.forwardReversible))/2;
%     L2=Y2-model.dGtMin(directions.forwardReversible);
%     U2=model.dGtMax(directions.forwardReversible)-Y2;
%     [tmp,xi]=sort(abs(model.dGt0Max(directions.forwardReversible)-model.dGt0Min(directions.forwardReversible)));
%     figure
%     hold on;
%     %dGrt errorbar
%     hE=errorbar(X1,Y2(xi),L2(xi),U2(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
%     % adjust error bar width
% %     hE_c=get(hE, 'Children');
% %     errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE, 'XData');
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE, 'XData', errorbarXData);
%     %dGrt0 errorbar on top and inside dGrt
%     hE2=errorbar(X1,Y(xi),L(xi),U(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');
%     % adjust error bar width
%     %hE_c=get(hE2, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE2, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE2, 'XData', errorbarXData);
%     %mean dGrt0
%     plot(X1,Y(xi),'.g','LineStyle','none');
%     %zero line
%     plot(X1,zeros(1,length(X1)),'k');
%     title('GC reversible prediction of reactions qualitiatively forward');
%     ylabel('dGt0 (kJ/mol)');
%     xlabel('Reactions, sorted by uncertainty in dGt0');
% 
%     %%%%%%%%
%     %qualitatively forward reactions that are quantitatively reversible by concentration alone
%     %dGrt0
%     Y=(model.dGt0Min(dGfGCforwardReversibleBool_byConc)+model.dGt0Max(dGfGCforwardReversibleBool_byConc))/2;
%     L=Y-model.dGt0Min(dGfGCforwardReversibleBool_byConc);
%     U=model.dGt0Max(dGfGCforwardReversibleBool_byConc)-Y;
%     %dGrt
%     Y2=(model.dGtMin(dGfGCforwardReversibleBool_byConc)+model.dGtMax(dGfGCforwardReversibleBool_byConc))/2;
%     L2=Y2-model.dGtMin(dGfGCforwardReversibleBool_byConc);
%     U2=model.dGtMax(dGfGCforwardReversibleBool_byConc)-Y2;
%     [tmp,xi]=sort(abs(model.dGt0Max(dGfGCforwardReversibleBool_byConc)-model.dGt0Min(dGfGCforwardReversibleBool_byConc)));
% 
%     figure
%     hold on;
%     %dGrt errorbar underneath
%     X1=1:nnz(dGfGCforwardReversibleBool_byConc);
%     hE=errorbar(X1,Y2(xi),L2(xi),U2(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
%     % adjust error bar width
%     %hE_c=get(hE, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE, 'XData', errorbarXData);
%     
%     %dGrt0 errorbar on top and inside dGrt
%     hE2=errorbar(X1,Y(xi),L(xi),U(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');
%     % adjust error bar width
%     %hE_c=get(hE2, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE2, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE2, 'XData', errorbarXData);
% 
% 
%     %mean dGrt0
% %     plot(X1,Y(xi),'Marker','none','LineStyle','none');
%     plot(X1,Y(xi),'.g','LineStyle','none');
%     %zero line
%     plot(X1,zeros(1,length(X1)),'k');
%     title('Qualitatively forward reactions that are GC quantitatively reversible by concentration');
%     ylabel('dGt0 or dGt(kJ/mol)');
%     xlabel('Reactions, sorted by uncertainty in dGt0');
% 
% 
%     %qualitatively forward reactions that are quantitatively reversible by
%     %the range of dGt0
%     fprintf('%i%s\n',nnz(dGfGCforwardReversibleBool_bydGt0),' qualitatively forward reactions that are gc quantitatively reversible by range of dGt0');
%     X1=1:nnz(dGfGCforwardReversibleBool_bydGt0);
%     %dGrt0
%     Y=(model.dGt0Min(dGfGCforwardReversibleBool_bydGt0)+model.dGt0Max(dGfGCforwardReversibleBool_bydGt0))/2;
%     L=Y-model.dGt0Min(dGfGCforwardReversibleBool_bydGt0);
%     U=model.dGt0Max(dGfGCforwardReversibleBool_bydGt0)-Y;
%     %dGrt
%     Y2=(model.dGtMin(dGfGCforwardReversibleBool_bydGt0)+model.dGtMax(dGfGCforwardReversibleBool_bydGt0))/2;
%     L2=Y2-model.dGtMin(dGfGCforwardReversibleBool_bydGt0);
%     U2=model.dGtMax(dGfGCforwardReversibleBool_bydGt0)-Y2;
%     [tmp,xi]=sort(abs(model.dGt0Max(dGfGCforwardReversibleBool_bydGt0)-model.dGt0Min(dGfGCforwardReversibleBool_bydGt0)));
% 
%     figure;
%     hold on;
%     %dGrt errorbar
%     hE=errorbar(X1,Y2(xi),L2(xi),U2(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
%     % adjust error bar width
%     %hE_c=get(hE, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE, 'XData', errorbarXData);
%     
%     %dGrt0 errorbar on top and inside dGrt
%     hE2=errorbar(X1,Y(xi),L(xi),U(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');
%     % adjust error bar width
%     %hE_c=get(hE2, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE2, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE2, 'XData', errorbarXData);
% 
%     %mean dGrt0
% %     plot(X1,Y(xi),'Marker','none','LineStyle','none');
%     plot(X1,Y(xi),'.g','LineStyle','none');
%     %zero line
%     plot(X1,zeros(1,length(X1)),'k');
%     title('Qualitatively forward reactions that are GC quantitatively reversible by range of dGt0');
%     ylabel('dGt0 or dGt(kJ/mol)');
%     xlabel('Reactions, sorted by uncertainty in dGt0');
% 
%      %qualitatively forward reactions that are quantitatively reverseible by
%     %the range of dGt0
%     fprintf('%i%s\n',nnz(dGfGCforwardReversibleBool_bydGt0),' qualitatively forward reactions that are gc quantitatively reversible by range of dGt0');
%     X1=1:nnz(dGfGCforwardReversibleBool_bydGt0);
%     %dGrt0
%     Y=(model.dGt0Min(dGfGCforwardReversibleBool_bydGt0)+model.dGt0Max(dGfGCforwardReversibleBool_bydGt0))/2;
%     L=Y-model.dGt0Min(dGfGCforwardReversibleBool_bydGt0);
%     U=model.dGt0Max(dGfGCforwardReversibleBool_bydGt0)-Y;
%     %dGrt
%     Y2=(model.dGtMin(dGfGCforwardReversibleBool_bydGt0)+model.dGtMax(dGfGCforwardReversibleBool_bydGt0))/2;
%     L2=Y2-model.dGtMin(dGfGCforwardReversibleBool_bydGt0);
%     U2=model.dGtMax(dGfGCforwardReversibleBool_bydGt0)-Y2;
%     %find the amount of reactions with normal cumulative distribution
%     P = normcdf(0,Y,L);
% 
%     %sort by fraction of uncertainty that is negative
% %     [tmp,xi]=sort(abs(model.dGt0Min(dGfGCforwardReversibleBool_bydGt0))./abs(model.dGt0Max(dGfGCforwardReversibleBool_bydGt0)-model.dGt0Min(dGfGCforwardReversibleBool_bydGt0)),'descend');
%     %     [tmp,xi]=sort(Y);
%     [tmp,xi]=sort(P,'descend');
%     %cuttoff for probabilities: must be reflective about 0.5;
%     PSortedeversibleBool=tmp<0.6 & tmp>0.4;
%     %reversible section bar in the background
%     figure1=figure;
%     hold on;
%     xbar=1:length(PSortedeversibleBool);
%     PSortedeversibleBar=ones(1,length(PSortedeversibleBool))*min(model.dGtMin(dGfGCforwardReversibleBool_bydGt0));
%     PSortedeversibleBar(PSortedeversibleBool)=max(model.dGtMax(dGfGCforwardReversibleBool_bydGt0));
%     bar_handle=bar(xbar,PSortedeversibleBar,1,'BaseValue',min(model.dGtMin(dGfGCforwardReversibleBool_bydGt0)),'EdgeColor',[0.86 0.86 0.86]);
%     %dGrt errorbar
%     hE=errorbar(X1,Y2(xi),L2(xi),U2(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
%     % adjust error bar width
%     %hE_c=get(hE, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE, 'XData', errorbarXData);
%     
%     %dGrt0 errorbar on top and inside dGrt
%     hE2=errorbar(X1,Y(xi),L(xi),U(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');
%     % adjust error bar width
%     %hE_c=get(hE2, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE2, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE2, 'XData', errorbarXData);
% 
% 
%     %mean dGrt0
% %     plot(X1,Y(xi),'Marker','none','LineStyle','none');
%     plot(X1,Y(xi),'.g','LineStyle','none');
%     %zero line
%     %cumulative probability that reaction is really forward, assuming a
%     %normal distribution about the mean dGt0
%     [AX,H1,H2]=plotyy(X1,zeros(1,length(X1)),X1,P(xi));
%     set(AX(2),'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
%     set(H1,'LineStyle','none')
%     set(H2,'LineStyle','--','Color','k')
%     plot(X1,zeros(1,length(X1)),'k');
%     axis(AX(1),[0 length(X1) min(model.dGtMin(dGfGCforwardReversibleBool_bydGt0)) max(model.dGtMax(dGfGCforwardReversibleBool_bydGt0))])
%     axis(AX(2),[0 length(X1) 0 1])
%     title('Qualitatively forward reactions that are GC quantitatively reversible by range of dGt0');
%     ylabel('dGt0 or dGt(kJ/mol)');
%     xlabel('Reactions, sorted by cumulative probability of being forward');
% 
%     %qualitatively forward reactions that are quantitatively reverse by
%     %dGt0
%     fprintf('%i%s\n',nnz(dGfGCforwardReversibleBool_byConcRHS),' qualitatively forward reactions that are GC quantitatively forward by dGf0');
%     X1=1:nnz(dGfGCforwardReversibleBool_byConcRHS);
%     %dGrt0
%     Y=(model.dGt0Min(dGfGCforwardReversibleBool_byConcRHS)+model.dGt0Max(dGfGCforwardReversibleBool_byConcRHS))/2;
%     L=Y-model.dGt0Min(dGfGCforwardReversibleBool_byConcRHS);
%     U=model.dGt0Max(dGfGCforwardReversibleBool_byConcRHS)-Y;
%     %dGrt
%     Y2=(model.dGtMin(dGfGCforwardReversibleBool_byConcRHS)+model.dGtMax(dGfGCforwardReversibleBool_byConcRHS))/2;
%     L2=Y2-model.dGtMin(dGfGCforwardReversibleBool_byConcRHS);
%     U2=model.dGtMax(dGfGCforwardReversibleBool_byConcRHS)-Y2;
%     [tmp,xi]=sort(abs(model.dGt0Max(dGfGCforwardReversibleBool_byConcRHS)-model.dGt0Min(dGfGCforwardReversibleBool_byConcRHS)));
% 
%     figure
%     hold on;
%     %dGrt errorbar
%     hE=errorbar(X1,Y2(xi),L2(xi),U2(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','r');
%     % adjust error bar width
%     %hE_c=get(hE, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE, 'XData', errorbarXData);
%     
%     %dGrt0 errorbar on top and inside dGrt
%     hE2=errorbar(X1,Y(xi),L(xi),U(xi),'LineStyle','none','LineWidth',2,'DisplayName','forwardReversible','Color','b');
%     % adjust error bar width
%     %hE_c=get(hE2, 'Children');
%     %errorbarXData= get(hE_c(2), 'XData');
%     errorbarXData= get(hE2, 'XData');
%     
%     errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0.2;
%     errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0.2;
%     errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0.2;
%     %set(hE_c(2), 'XData', errorbarXData);
%     set(hE2, 'XData', errorbarXData);
%     %mean dGrt0
% %     plot(X1,Y(xi),'Marker','none','LineStyle','none');
%     plot(X1,Y(xi),'.g','LineStyle','none');
%     %zero line
%     plot(X1,zeros(1,length(X1)),'k');
%     title('Qualitatively forward reactions that are GC quantitatively forward by dGf0');
%     ylabel('dGt0 or dGt(kJ/mol)');
%     xlabel('Reactions, sorted by uncertainty in dGt0');
    