function tissueModel = GIMME(model, expressionRxns, threshold, obj_frac)
% Use the GIMME algorithm (`Becker and Palsson, 2008`) to extract a context
% specific model using data. GIMME minimizes usage of low-expression
% reactions while keeping the objective (e.g., biomass) above a certain
% value. Note that this algorithm does not favor the inclusion of reactions
% not related to the objective.
%
% USAGE:
%
%    tissueModel = GIMME(model, expressionRxns, threshold)
%
% INPUTS:
%
%    model:               input model (COBRA model structure)
%    expressionRxns:      expression data, corresponding to model.rxns (see
%                         mapGeneToRxn.m)
%    threshold:           expression threshold, reactions below this are
%                         minimized
%
% OPTIONAL INPUT:
%    obj_frac:            minimum fraction of the objective(s) of model
%                         (default value - 0.9)
%
% OUTPUTS:
%    tissueModel:         extracted model
%
% `Becker and Palsson (2008). Context-specific metabolic networks are
% consistent with experiments. PLoS Comput. Biol. 4, e1000082.`
%
% .. Author: - Originally written by Becker and Palsson, adapted by S. Opdam and A. Richelle - May 2017

    
    if nargin < 4 || isempty(obj_frac)
        obj_frac =0.9;
    end

    objectiveCol = [find(model.c) obj_frac]; 

    nRxns = size(model.S,2);

    %first make model irreversible
    [modelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(model);

    nbExpressionRxns = size(expressionRxns,1);
    if (nbExpressionRxns < nRxns)
        display('Warning: Fewer expression data inputs than reactions');
        expressionRxns(nbExpressionRxns+1:nRxns,:) = zeros(nRxns-nbExpressionRxns, size(expressionRxns,2));
    end

    nIrrevRxns = size(irrev2rev,1);
    expressionRxnsIrrev = zeros(nIrrevRxns,1);
    for i=1:nIrrevRxns
        expressionRxnsIrrev(i,1) = expressionRxns(irrev2rev(i,1),1);
    end

    nObjectives = size(objectiveCol,1);
    for i=1:nObjectives
        objectiveColIrrev(i,:) = [rev2irrev{objectiveCol(i,1),1}(1,1) objectiveCol(i,2)];
    end

    %Solve initially to get max for each objective
    for i=1:size(objectiveCol)
        %define parameters for initial solution
        modelIrrev.c=zeros(nIrrevRxns,1);
        modelIrrev.c(objectiveColIrrev(i,1),1)=1;

        %find max objective
        FBAsolution = optimizeCbModel(modelIrrev);
        if (FBAsolution.stat ~= 1)
            not_solved=1;
            error('Failed to solve initial FBA problem');
        end
        maxObjective(i)=FBAsolution.f;
    end

    model2gimme = modelIrrev;
    model2gimme.c = zeros(nIrrevRxns,1);


    for i=1:nIrrevRxns
        if (expressionRxnsIrrev(i,1) > -1)   %if not absent reaction
            if (expressionRxnsIrrev(i,1) < threshold)
                model2gimme.c(i,1) = threshold-expressionRxnsIrrev(i,1); %FIX: use expression level as weight
            end
        end
    end

    for i=1:size(objectiveColIrrev,1)
        model2gimme.lb(objectiveColIrrev(i,1),1) = objectiveColIrrev(i,2) * maxObjective(i);
    end

    gimmeSolution = optimizeCbModel(model2gimme,'min');

    if (gimmeSolution.stat ~= 1)
    %No solution for the problem
        display('Failed to solve GIMME problem'); 
        gimmeSolution.x = zeros(nIrrevRxns,1);
    end

    reactionActivityIrrev = zeros(nIrrevRxns,1);
    for i=1:nIrrevRxns
        if ((expressionRxnsIrrev(i,1) > threshold) || (expressionRxnsIrrev(i,1) == -1))
            reactionActivityIrrev(i,1)=1;
        elseif (gimmeSolution.x(i,1) > 0)
            reactionActivityIrrev(i,1)=2;
        end
    end

    %Translate reactionActivity to reversible model
    reactionActivity = zeros(nRxns,1);
    for i=1:nRxns
        for j=1:size(rev2irrev{i,1},2)
            if (reactionActivityIrrev(rev2irrev{i,1}(1,j)) > reactionActivity(i,1))
                reactionActivity(i,1) = reactionActivityIrrev(rev2irrev{i,1}(1,j));
            end
        end
    end
    
    remove = model.rxns(reactionActivity == 0);
    tissueModel = removeRxns(model,remove); 
end

