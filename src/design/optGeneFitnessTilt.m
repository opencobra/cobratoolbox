function [val] = optGeneFitnessTilt(rxn_vector_matrix, model, targetRxn, rxnListInput, isGeneList)
% The fitness function
%
% USAGE:
%
%    [val] = optGeneFitnessTilt(rxn_vector_matrix, model, targetRxn, rxnListInput, isGeneList)
%
% INPUTS:
%    rxn_vector_matrix:
%    model:
%    targetRxn:
%    rxnListInput:
%    isGeneList:
%
% OUTPUT:
%    val:   fitness value

global MaxKnockOuts
%size(rxn_vector_matrix)

popsize = size(rxn_vector_matrix,1);
val = zeros(1,popsize);

for i = 1:popsize
    rxn_vector = rxn_vector_matrix(i,:);
    rxnList = rxnListInput(logical(rxn_vector));


    %see if we've done this before
    val_temp = memoize(rxn_vector);
    if ~ isempty(val_temp)
        val(i) = val_temp;
        continue;
    end

    % check to see if mutations is above the max number allowed
    nummutations = sum(rxn_vector);
    if nummutations > MaxKnockOuts
        continue;
    end

	% generate knockout.
    if isGeneList
        modelKO = deleteModelGenes(model, rxnList);
    else % is reaction list
        [isValidRxn,removeInd] = ismember(rxnList,model.rxns);
        removeInd = removeInd(isValidRxn);
        modelKO = model;
        modelKO.ub(removeInd) = 0;
        modelKO.lb(removeInd) = 0;
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % augment BOF (tilt)
 [modelKO] = augmentBOF(modelKO, targetRxn, .001);

 % find growthrate
    if exist('LPBasis', 'var')
        modelKO.LPBasis = LPBasis;
    end

    [slnKO, LPOUT] = solveCobraLPCPLEX(modelKO, 0,1);
    LPBasis = LPOUT.LPBasis;
    growthrate = slnKO.obj;
    [tmp,tar_loc] = ismember(targetRxn,modelKO.rxns);
    minProdAtSetGR = slnKO.full(tar_loc);

    % check to ensure that GR is above a certain value
    if growthrate < .10
        continue;
    end

% %    display('second optimization');
%     % find the lowesest possible production rate (a hopefully high number)
%     % at the max growth rate minus some set factor gamma (a growth rate slightly
%     % smaller than the max). A positive value will eliminate solutions where the
%     % production envelope has a vertical line at the max GR, a "non-unique"
%     % solution. Set value to zero if "non-unique" solutions are not an issue.
%     gamma = 0.01; % proportional to Grwoth Rate (hr-1), a value around 0.5 max.
%
%     %find indicies of important vectors
%     indBOF = find(modelKO.c);
%     indTar = findRxnIDs(modelKO, targetRxn);
%     % generate a model with a fixed max KO growth rate
%     modelKOsetGR = modelKO;
%     modelKOsetGR.lb(indBOF) = growthrate - gamma; % this growth rate is required as lb.
%     modelKOsetGR.c = zeros(size(modelKO.c));
%     modelKOsetGR.c(indTar) = -1; % minimize for this variable b/c we want to look at the very minimum production.
%
%     % find the minimum production rate for the targeted reaction.
%
% %     slnKOsetGR = optimizeCbModel(modelKOsetGR);
% %     minProdAtSetGR1 = -slnKOsetGR.f;  % This should be a negative value b/c of the minimization setup, so -1 is necessary.
%
%     if exist('LPBasis2', 'var')
%         modelKOsetGR.LPBasis = LPBasis2;
%     end
%
%     [slnKOsetGR, LPOUT2] = solveCobraLPCPLEX(modelKOsetGR, 0,1);
%     LPBasis2 = LPOUT2.LPBasis;
%     minProdAtSetGR = -slnKOsetGR.obj;


    % objective function for optGene algorithm = val (needs to be a negative value, since it is
    % a minimization)
    val(i) = -minProdAtSetGR;
    % penalty for a greater number of mutations

    %val(i) = -minProdAtSetGR * (.98^nummutations);

    % select best substrate-specific productivity
    % val(i) = -minProdAtSetGR * (.98^nummutations) * growthrate;

    % check to prevent very small values from being considerered improvments
    if val(i) > -1e-3
        val(i) = 0;
    end

    memoize(rxn_vector, val(i));
end

return;



%% Memoize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MEMOIZE %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% internal function to speed things up.

function [value] =  memoize(gene_vector, value)
global HTABLE
hashkey = num2str(gene_vector);
hashkey = strrep(hashkey,' ',''); % cut out white space from string (more space efficient).

if nargin == 1
    value = HTABLE.get(hashkey);
    return;
else
    if HTABLE.size() > 50000
        HTABLE = java.util.Hashtable;  %reset the hashtable if more than 50,000 entries.
    end
    HTABLE.put(hashkey, value);
    value = [];
    return;
end
return
