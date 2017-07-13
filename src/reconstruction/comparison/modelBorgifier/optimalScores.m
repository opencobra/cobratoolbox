function Stats = optimalScores(rxnList, optimizer)
% Takes the 3D SCORE matrix produced from `compareCbModels` and
% weights the scores based on a given training set using either SVM or
% linear optimization. Colapses SCORE into a `cRxnN x tRxnN` matrix and
% also produced the structure `Stats`, which include the best matches for
% each reaction in `CMODEL` and the corresponding index in `TMODEL`. `rxnList`
% is the training set. If `rxnList` is not provided, then `optimalScores`
% just colapses the 3D SCORE matrix to `scoreTotal`.
% Called by `reactionCompare`, `reactionCompareGUI`, `compareCbModels`, calls `optWeightLin`, `opnWeightExp`, `colapseScore`.
%
% USAGE:
%
%    Stats = optimalScore(rxnList, optimizer)
%
% INPUTS:
%    rxnList:       reactions` list
%    optimizer:     Either 'svm', 'RF', 'linear', or 'exp'; the latter two are custom
%                   functions contained within the functions `optWeightLin` and
%                   optWeightExp.
%    CMODEL:        global input
%    TMODEL:        global input
%    SCORE:         global input
%
% OUTPUTS:
%   Stats:            Structure containing:
%   bestMatch:        Array of the best matching reactions
%   bestMatchIndex:   Indicies of the best matching reactions.
%   weightArray:
%   scoreTotal:       Readjusted `scoreTotal` based on training set.
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

global SCORE % Declare variables

%% Compute SCORE total and stats.
[scoreTotal, Stats] = colapseScore(SCORE) ;

%% Optimize SCORE weights.
if exist('rxnList','var')
    % Determine hits and positions in SCORE.
    fprintf('Constructing training set data.\n')
    hitPos = find(rxnList > 0) ;
    hitPos(:, 2) = rxnList(hitPos) ;
    hitVec = zeros(size(SCORE, 3), length(hitPos)) ;

    % Determine misses. Use the next best SCORE after a hit and the best
    % SCORE from a declared new reaction.
    missPos = find(rxnList == 0) ;
    missVec = zeros(size(SCORE, 3), length(hitPos) + length(missPos)) ;

    % Sorted scoreTotal matrix to find misses.
    [~, sortI] = sort(scoreTotal, 2, 'descend') ;

    % Find the scores for the hits, and mark next best scores as misses.
    for i = 1:length(hitPos)
        hitVec(:, i) = SCORE(hitPos(i, 1),hitPos(i, 2),:) ;
        % The miss from top 2 matches. Assumes hit is also in the top 2.
        missSet = setdiff(sortI(hitPos(i, 1), 1:2), hitPos(i, 2)) ;
        for j = 1:1
            nowLow = SCORE(hitPos(i, 1), missSet(j), :) ;
            nowLow = reshape(nowLow, size(nowLow, 3), size(nowLow, 1)) ;
            missVec(:, i * j) = nowLow ;
        end
    end

    % Now add to that the reactions declared as new from the training set.
    for i = 1:length(missPos)
        missSet = sortI(missPos(i), 1:1) ;
        for j = 1:1
            nowLow = SCORE(missPos(i), missSet(j), :) ;
            nowLow = reshape(nowLow, size(nowLow, 3), size(nowLow, 1)) ;
            missVec(:, length(hitPos) + i * j) = nowLow ;
        end
    end

    % Choose weighting function.
    fprintf('Optimizing.\n')
    if strcmp(optimizer, 'svm')
        fprintf('SVMing.\n')

        % Transpose and concatenate the scores for hits and misses
        combinedVec = [hitVec'; missVec'] ;

        % Make logical array which indicates hits (1) and misses (0)
        labelVec = [ones(size(hitVec, 2), 1); zeros(size(missVec, 2), 1)] ;

        % Train model and pull out weights
        SVMModel = fitcsvm(combinedVec, labelVec) ;

        weights = SVMModel.Beta ;

    elseif strcmp(optimizer, 'RF')
        fprintf('Using Random Forest.\n')
        try
            traindata = [hitVec missVec]' ;
            trainlabel = [true(1, size(hitVec, 2)) false(1, size(missVec, 2))]' ;
            trunk = zeros(size(traindata, 1), size(traindata, 2), size(traindata, 2)) ;
            % construct square training data
            for it = 1:size(trunk, 1)
                trunk(it, :, :) = traindata(it, :)' * traindata(it, :) ;
            end
            % calculate discriminating quality of products of single score
            % dimensions
            qual = zeros(size(traindata, 2)) ;
            qualsign = zeros(size(traindata, 2)) ;

            for it = 1:size(qual, 1)
                for it2 = it:size(qual, 1)
                    [~, qual(it, it2)] = ttest2(trunk(trainlabel, it, it2), trunk(~trainlabel, it, it2)) ;
                    qualsign(it, it2) = (mean(trunk(trainlabel, it, it2)) < mean(trunk(~trainlabel, it, it2))) ;
                end
            end
            % discard useless values
            qual(isnan(qual)) = 1 ;
            qual(qual > 0.1) = 1 ;
            % convert p-value to weight
            weight2 = -log10(qual) ;
            weight2(isinf(weight2)) = 0 ;
            weight2(qualsign == 1) = -weight2(qualsign == 1) ;

        catch
            fprintf('Random Forest training failed, using default weights.\n')
            weights = ones(size(hitVec, 1), 1) ;
            optimizer = 'none' ;
        end

    elseif strcmp(optimizer,'linear')
        fprintf('Using optWeightLin function.\n')
        try
            weights = fminunc(@(weight)optWeightLin(weight, hitVec, missVec), ...
                      ones(size(hitVec, 1), 1)) ;
        catch
            fprintf('optWeightLin training failed, using default weights.\n')
            weights = ones(size(hitVec, 1), 1) ;
            optimizer = 'none' ;
        end

    elseif strcmp(optimizer,'exp')
        fprintf('Using optWeightExp function.\n')
        try
            [wnum, hitnum] = size(hitVec) ;
            missnum = size(missVec, 2) ;
            signs = sign(mean([hitVec missVec], 2)) ;
            weights = fmincon(@(weight)optWeightExp(weight, hitVec, missVec, ...
                                                    wnum, hitnum, missnum), ...
                      ones(size(hitVec, 1), 2), ...
                      [], [], [], [],...
                      [zeros(wnum, 1) repmat(0.3, wnum, 1)], ...
                      [repmat(1000, wnum, 1) repmat(3, wnum, 1)] ) ;
            weights(:, 1) = weights(:, 1) .* signs ;
        catch
            fprintf('optWeightExp training failed, using default weights.\n')
            weights = ones(size(hitVec, 1), 1) ;
            optimizer = 'none' ;
        end


    elseif strcmp(optimizer, 'none')
        weights = ones(size(hitVec, 1), 1) ;
    end

    % Adjust SCORE by the new weights and recompute normalization.
    scoreWeighted = zeros(size(scoreTotal)) ;
    if strcmp(optimizer, 'exp')
        for i = 1:size(weights, 1)
            scoreWeighted = scoreWeighted + ...
                (double(abs(SCORE(:, :, i))) .^ weights(i, 2)) * weights(i, 1) ;
        end
        [scoreTotal, Stats] = colapseScore(scoreWeighted) ;
        Stats.weights = weights ;

    elseif strcmp(optimizer, 'RF')
        for it = 1:size(weight2, 1)
            for it2 = 1:size(weight2, 2)
                scoreWeighted = scoreWeighted + ...
                    double(SCORE(:, :, it)) .* double(SCORE(:, :, it2)) .* weight2(it, it2) ;
            end
        end
        [scoreTotal, Stats] = colapseScore(scoreWeighted) ;
        Stats.weight2 = weight2 ;
    else
        % Ensure all weights are positive.
        weights(weights < 0) = 0 ;

        for i = 1:length(weights)
            scoreWeighted = scoreWeighted + ...
                double(SCORE(:, :, i)) * weights(i) ;
        end
        [scoreTotal, Stats] = colapseScore(scoreWeighted) ;
        Stats.weights = weights ;
    end

    fprintf('Optimization finished.\n')

end

% Put scoreTotal in Stats for output.
Stats.scoreTotal = scoreTotal ;

%% Subfunctions
% Colapse matrix and normalize scores.
function [scoreTotal, Stats] = colapseScore(scoreWeighted)
global TMODEL CMODEL

% Compute total scores from subscores. If colapseScore is fed an already
% summed SCORE matrix as an argument, this function is impotent.
scoreTotal = sum(scoreWeighted, 3) ;
clear scoreWeighted

% Find the lowest SCORE that isn't a biomass reaction and set the biomass
% reaction scores to that. This is caught by reactions with many mets.
% Also adjust any reaction with more than 10 reactants or products.
scoreTotalHigh = scoreTotal ;
manyMetC = find(CMODEL.metNums(:, 3) > 10) ;
manyMetC = [manyMetC; find(CMODEL.metNums(:, 5) > 10)] ;
scoreTotalHigh(manyMetC, :) = 1000 ;
clear manyMetC
manyMetT = find(TMODEL.metNums(:, 3) > 10) ;
manyMetT = [manyMetT; find(TMODEL.metNums(:, 5) > 10)] ;
scoreTotalHigh(:, manyMetT) = 1000 ;
clear manyMetT

% Lowest SCORE which isn't from a biomass reaction.
minScore = min(min(scoreTotalHigh)) ;
% Set found reactions to that.
scoreTotal1k = find(scoreTotalHigh == 1000) ;
clear scoreTotalHigh
scoreTotal(scoreTotal1k) = minScore ;
clear scoreTotal1k

% Normalize scores.
scoreTotal = scoreTotal + abs(min(min(scoreTotal))) ;
scoreTotal = scoreTotal ./ max(max(scoreTotal)) ;

% Find best matches.
[bestMatch, bestMatchIndex] = max(scoreTotal, [], 2) ;
Stats.bestMatch = bestMatch ;
Stats.bestMatchIndex = bestMatchIndex ;
