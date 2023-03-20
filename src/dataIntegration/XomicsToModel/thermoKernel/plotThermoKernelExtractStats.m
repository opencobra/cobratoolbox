function plotThermoModelExtractStats(model, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights, thermoModelMetBool, thermoModelRxnBool)

nMet=length(thermoModelMetBool);
nRxn=length(thermoModelRxnBool);

if 0
    figure
    H1 = subplot(2,1,1);
    plot(abs(solution.v),g0orig,'.')
    xlim(H1,[-1/max(abs(solution.v)),max(abs(solution.v))])
    xlabel('Reaction flux magnitude')
    ylabel('Reaction weight')
    H2 = subplot(2,1,2);
    plot(abs(solution.d),model.h0,'.')
    xlim(H2,[-1/max(abs(solution.d)),max(abs(solution.d))])
    xlabel('Metabolite production rate')
    ylabel('Metabolite weight')
else
    
    if 0
        T = false(3,nRxn);
        T(1,:) = abs(solution.v)>=param.epsilon;
        T(2,:) = abs(solution.v)>=param.epsilon | abs(solution.v)<param.epsilon;
        T(2,:) = abs(solution.v)<param.epsilon;
        P = false(3,nRxn);
        P(1,:) = g0orig < 0;
        P(2,:) = g0orig == 0;
        P(3,:) = g0orig > 0;
        plotconfusion(T,P,'Reaction activity')
    else
        
        if 0
            T = cell(nRxn,1);
            T(abs(solution.v)>=param.epsilon & g0orig ~= 0)={'Active'};
            T(abs(solution.v)<param.epsilon & g0orig ~= 0)={'Inactive'};
            T(g0orig == 0)={'Unspecified'};
            P = cell(nRxn,1);
            P(g0orig < 0)={'Active'};
            P(g0orig == 0)={'Unspecified'};
            P(g0orig > 0)={'Inactive'};
            %             usage:
            %             % Find the confusionmat matrix first
            %             [C,order] = confusionmat(TestResults,PredictionResults)
            %             % Then, plot
            %             plotConfMat(C) plots the confmat with integers 1 to n as class labels
            %             plotConfMat(C, order) plots the confmat with the specified labels
            C = confusionmat(T,P,'order',{'Active';'Inactive';'Unspecified'});
            plotConfMat(C,{'Active';'Inactive';'Unspecified'});
        else
            
            
            if any(rxnWeights~=0)
                figure;
                hist(rxnWeights)
                title('Reaction weights')
                figure
                P = cell(nRxn,1);
                P(thermoModelRxnBool==1)={'Active'};
                P(thermoModelRxnBool==0)={'Inactive'};
                
                T = cell(nRxn,1);
                if 1
                    T(rxnWeights < 0)={'Active'};
                    T(rxnWeights > 0)={'Inactive'};
                    T=T(rxnWeights~=0);
                    P=P(rxnWeights~=0);
                else
                    T(activeInactiveRxn==1)={'Active'};
                    T(activeInactiveRxn==-1)={'Inactive'};
                    T=T(activeInactiveRxn~=0);
                    P=P(activeInactiveRxn~=0);
                end
                
                %             usage:
                %             % Find the confusionmat matrix first
                %             [C,order] = confusionmat(TestResults,PredictionResults)
                %             % Then, plot
                %             plotConfMat(C) plots the confmat with integers 1 to n as class labels
                %             plotConfMat(C, order) plots the confmat with the specified labels
                
                %    CM = CONFUSIONMAT(G,GHAT) returns the confusion matrix CM determined
                
                
                %    by the known group labels G and the predicted group labels GHAT.
                if any(rxnWeights == 0) && 0
                    labels = {'Active';'Inactive';'Unspecified'};
                else
                    labels = {'Active';'Inactive'};
                end
                C = confusionmat(P,T,'order',labels);
                plotConfMat(C,labels);
                accuracy = sum(diag(C),1)/sum(sum(C,1));
                title(['Reaction confusion matrix, accuracy = ' num2str(accuracy)])
            end
            
            
            
            if any(metWeights~=0)
                figure;
                hist(metWeights)
                title('Metabolite weights')
                
                figure;
                P = cell(nMet,1);
                P(thermoModelMetBool==1)={'Active'};
                P(thermoModelMetBool==0)={'Inactive'};
                
                
                T = cell(nMet,1);
                if 1
                    T(metWeights < 0)={'Active'};
                    T(metWeights >= 0)={'Inactive'};
                    T=T(metWeights~=0);
                    P=P(metWeights~=0);
                else
                    T(presentAbsentMet==1)={'Active'};
                    T(presentAbsentMet==-1)={'Inactive'};
                    T=T(presentAbsentMet~=0);
                    P=P(presentAbsentMet~=0);
                end
                %             usage:
                %             % Find the confusionmat matrix first
                %             [C,order] = confusionmat(TestResults,PredictionResults)
                %             % Then, plot
                %             plotConfMat(C) plots the confmat with integers 1 to n as class labels
                %             plotConfMat(C, order) plots the confmat with the specified labels
                
                %    CM = CONFUSIONMAT(G,GHAT) returns the confusion matrix CM determined
                
                %    by the known group labels G and the predicted group labels GHAT.
                if any(metWeights == 0) && 0
                    labels = {'Active';'Inactive';'Unspecified'};
                else
                    labels = {'Active';'Inactive'};
                end
                C = confusionmat(P,T,'order',labels);
                plotConfMat(C,labels);
                accuracy = sum(diag(C),1)/sum(sum(C,1));
                title(['Metabolite confusion matrix, accuracy = ' num2str(accuracy)])
            end
        end
    end
end
