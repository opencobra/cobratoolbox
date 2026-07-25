function plotThermoKernelStats(activeInactiveRxn, rxnWeights, thermoModelRxnBool, presentAbsentMet, metWeights, thermoModelMetBool)
% Plot confusion matrices for active/inactive reactions and present/absent
% metabolites
%
% USAGE:
%
%    plotThermoKernelStats(activeInactiveRxn, rxnWeights, thermoModelRxnBool, presentAbsentMet, metWeights, thermoModelMetBool)
%
% INPUTS:
%    activeInactiveRxn:    `n x 1` with entries {1, -1, 0} for reactions that must be active, inactive, or unspecified
%    rxnWeights:    `n x 1` real-valued penalties on reaction flux (negative promotes active, positive promotes inactive)
%    thermoModelRxnBool:    `n x 1` boolean vector of thermodynamically consistent reactions in the input model
%    presentAbsentMet:    `m x 1` with entries {1, -1, 0} for metabolites that must be present, absent, or unspecified
%    metWeights:    `m x 1` real-valued penalties on metabolite activity (negative promotes present, positive promotes absent)
%    thermoModelMetBool:    `m x 1` boolean vector of thermodynamically consistent metabolites in the input model

nMet = length(thermoModelMetBool);
nRxn = length(thermoModelRxnBool);

if isempty(presentAbsentMet)
    presentAbsentMet = zeros(nMet,1);
end
if ~isempty(metWeights)
    presentAbsentMet(metWeights < 0) =  1;
    presentAbsentMet(metWeights > 0) = -1;
end

if isempty(activeInactiveRxn)
    activeInactiveRxn = zeros(nRxn,1);
end
if ~isempty(rxnWeights)
    activeInactiveRxn(rxnWeights < 0) =  1;
    activeInactiveRxn(rxnWeights > 0) = -1;
end

if 1
    figure
    t = tiledlayout(1,2);
    
    P = cell(nRxn,1);
    P(thermoModelRxnBool==1)={'Active'};
    P(thermoModelRxnBool==0)={'Inactive'};
    
    T = cell(nRxn,1);
    
    T(activeInactiveRxn==1)={'Active'};
    T(activeInactiveRxn==-1)={'Inactive'};
    T=T(activeInactiveRxn~=0);
    P=P(activeInactiveRxn~=0);
    
    
    labels = {'Active';'Inactive'};
    %    CM = CONFUSIONMAT(G,GHAT) returns the confusion matrix CM determined
    %    by the known group labels G and the predicted group labels GHAT.
    C = confusionmat(P,T,'order',labels);
    ax1 = nexttile;
    plotConfMat(C,labels,'FontSize',12);
    accuracy = sum(diag(C),1)/sum(sum(C,1));
    title(ax1,'Reactions','FontSize',12)
    subtitle(ax1,['Accuracy = ' num2str(accuracy)],'FontSize',12)
    xlabel('Input weights','FontSize',12);
    ylabel('Output model','FontSize',12);
    %     figure;
    %     histogram(presentAbsentMet)
    %     title('Absent(-1) and Present(+1) metabolites')
    
    ax2 = nexttile;
    P = cell(nMet,1);
    P(thermoModelMetBool==1)={'Active'};
    P(thermoModelMetBool==0)={'Inactive'};
    
    T = cell(nMet,1);
    
    T(presentAbsentMet==1)={'Active'};
    T(presentAbsentMet==-1)={'Inactive'};
    T=T(presentAbsentMet~=0);
    P=P(presentAbsentMet~=0);
    
    labels = {'Active';'Inactive'};
    C = confusionmat(P,T,'order',labels);
    plotConfMat(C,labels,'FontSize',12);
    accuracy = sum(diag(C),1)/sum(sum(C,1));
    title(ax2,'Metabolites','FontSize',12)
    subtitle(ax2,['Accuracy = ' num2str(accuracy)],'FontSize',12)
    xlabel('Input weights','FontSize',12);
    ylabel('Output model','FontSize',12);
else
    if any(activeInactiveRxn~=0)        
        figure
        P = cell(nRxn,1);
        P(thermoModelRxnBool==1)={'Active'};
        P(thermoModelRxnBool==0)={'Inactive'};
        
        T = cell(nRxn,1);
        
        T(activeInactiveRxn==1)={'Active'};
        T(activeInactiveRxn==-1)={'Inactive'};
        T=T(activeInactiveRxn~=0);
        P=P(activeInactiveRxn~=0);
        
        
        labels = {'Active';'Inactive'};
        C = confusionmat(P,T,'order',labels);
        plotConfMat(C,labels);
        accuracy = sum(diag(C),1)/sum(sum(C,1));
        title(['Reaction confusion matrix, accuracy = ' num2str(accuracy)])
    end
    
    if any(presentAbsentMet~=0)
        %     figure;
        %     histogram(presentAbsentMet)
        %     title('Absent(-1) and Present(+1) metabolites')
        
        figure;
        P = cell(nMet,1);
        P(thermoModelMetBool==1)={'Active'};
        P(thermoModelMetBool==0)={'Inactive'};
        
        T = cell(nMet,1);
        
        T(presentAbsentMet==1)={'Active'};
        T(presentAbsentMet==-1)={'Inactive'};
        T=T(presentAbsentMet~=0);
        P=P(presentAbsentMet~=0);
        
        labels = {'Active';'Inactive'};
        C = confusionmat(P,T,'order',labels);
        plotConfMat(C,labels);
        accuracy = sum(diag(C),1)/sum(sum(C,1));
        title(['Metabolite confusion matrix, accuracy = ' num2str(accuracy)])
    end
end
