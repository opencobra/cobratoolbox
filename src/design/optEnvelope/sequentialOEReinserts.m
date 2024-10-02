function [mainKnockouts, finalMidKnockouts] = sequentialOEReinserts(modelOld, data, K, toDel, minP, midPoints, numTries, timeLimit)
% Calculates knockouts from set of inactive reactions. Uses sequential method.

switch toDel
    case 0  %Reactions
        rxns = data.mainActive;
        rxns = ismember(modelOld.rxns, [modelOld.rxns(K); rxns]);

        %adds numTries 
        idx = linspace(1, numel(data.mainModel.rxns), numel(data.mainModel.rxns));
        if ~isempty(numTries)
            for i = 1:numTries
                randIdx = randperm(length(idx));
                idx(i + 1, :) = randIdx;
            end
        end
        
        finalKOs = {};
        
        tic
        for j = 1:size(idx, 1)
            idxi = idx(j, :);
            model = data.mainModel;
            model = changeRxnBounds(model, model.rxns(minP.bioID), 0, 'b');
            model = changeObjective(model, model.rxns(minP.proID));
            MinB1 = optimizeCbModel(model, 'min');
            MinB1 = MinB1.f;
            model2 = data.mainModel;
            
            mainKnockouts = {}; n1 = 0;
            for i = 1:numel(model.rxns)
                if ismember(idxi(i), find(rxns)) == 0 %model.lb(idx(i)) == 0 && model.ub(idx(i)) == 0 %
                    model.lb(idxi(i)) = modelOld.lb(idxi(i));
                    model.ub(idxi(i)) = modelOld.ub(idxi(i));
                    solMin2 = optimizeCbModel(model, 'min');
                    if MinB1 - solMin2.f > 10^-6
                        model.ub(idxi(i)) = model2.ub(idxi(i)); model.lb(idxi(i)) = model2.lb(idxi(i));
                        n1 = n1 + 1; mainKnockouts(n1, 1) = model.rxns(idxi(i));
                    end
                end
            end
            if isempty(finalKOs) || length(mainKnockouts) < length(finalKOs)
                finalKOs = mainKnockouts;
            end
            time = toc;
            if time > timeLimit
                disp(['Time limit of ', num2str(timeLimit), 's reached. Completed ', num2str(j), '/', num2str(numTries), ' iterations.'])
                break;
            end
        end

        mainKnockouts = finalKOs;
        
        finalMidKnockouts = cell(1, midPoints);
        if midPoints ~= 0
            for i = 1:midPoints
                idx = linspace(1, numel(data.mainModel.rxns), numel(data.mainModel.rxns));
                rxns = data.active{i};
                rxns = ismember(modelOld.rxns, [modelOld.rxns(K); rxns]); 
                for j = 1:size(idx, 1)
                    idxi = idx(j, :);
                    model = data.models(i);
                    model = changeRxnBounds(model, model.rxns(minP.bioID), 0, 'b');
                    model = changeObjective(model, model.rxns(minP.proID));
                    MinB1 = optimizeCbModel(model, 'min');
                    MinB1 = MinB1.f;
                    model2 = data.models(i);

                    midKnockouts = {}; n1 = 0;
                    for k = 1:numel(model.rxns)
                        if ismember(idxi(k), find(rxns))==0
                            model.lb(idxi(k)) = modelOld.lb(idxi(k));
                            model.ub(idxi(k)) = modelOld.ub(idxi(k));
                            solMin = optimizeCbModel(model, 'min');
                            solMax = optimizeCbModel(model, 'max');
                            if MinB1 - solMin.f > 10^-6
                                model.ub(idxi(k)) = model2.ub(idxi(k)); model.lb(idxi(k)) = model2.lb(idxi(k));
                                n1 = n1 + 1; midKnockouts(n1, 1) = model.rxns(idxi(k));
                            end
                        end
                    end
                    if isempty(finalMidKnockouts{i}) || length(midKnockouts) < length(finalMidKnockouts{i})
                        finalMidKnockouts{i} = midKnockouts;
                    end
                    time = toc;
                    if time > timeLimit
                        break;
                    end
                end
            end
        else
            finalMidKnockouts = [];
        end
        
    case 1  %Genes
        model = buildRxnGeneMat(modelOld);
        genes = ActiveRxns;
        genes = ismember(model.genes, genes);
        genes = ismember(model.genes, model.genes(genes));
        [model, ~, ~] = deleteModelGenes(model, model.genes(~genes));
        s = optimizeCbModel(model); MaxB1 = s.f;
        
        mainKnockouts = model.genes(genes);
        mainKnockouts = erase(mainKnockouts, '_deleted');
    case 2
        %Enzymes
end