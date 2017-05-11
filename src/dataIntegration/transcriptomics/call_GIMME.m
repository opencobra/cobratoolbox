function tissueModel = call_GIMME(model, expressionRxns, threshold, tol, obj_frac)
%Use the GIMME algorithm (Becker and Palsson, 2008*) to extract a context
%specific model using data. GIMME minimizes usage of low-expression
%reactions while keeping the objective (e.g., biomass) above a certain
%value. Note that this algorithm does not favor the inclusion of reactions
%not related to the objective.
%
%INPUTS
%
%   model               input model (COBRA model structure)
%   expressionRxns      expression data, corresponding to model.rxns (see
%                       mapGeneToRxn.m)
%   threshold           expression threshold, reactions below this are
%                       minimized
%   tol                 tolerance by which reactions are defined inactive
%                       after model extraction (recommended lowest value
%                       1e-8 since solver tolerance is 1e-9)%% TO
%                       SET - default value for parameter
%   obj_frac            minimum fraction of the objective(s) of model %% TO
%                       SET - default value for parameter to 0.9
%
%OUTPUTS
%
%   tissueModel         extracted model
%
%* Becker and Palsson (2008). Context-specific metabolic networks are
%consistent with experiments. PLoS Comput. Biol. 4, e1000082.
%
%Originally written by Becker and Palsson, adapted by S. Opdam and A. Richelle -
%May 2017


    objectiveCol = [find(model.c) obj_frac]; 
    [reactionActivity, reactionActivityIrrev, model2gimme, gimmeSolution] = solveGimme(model, objectiveCol, expressionRxns, threshold);
    
    remove = model.rxns(reactionActivity == 0);
    tissueModel = removeRxns(model,remove); 
    
    inactiveRxns = findBlockedReaction(tissueModel); %% TO DO - need to provide a way to modulate the tolerance of this function (set at 10e-10)
    %inactiveRxns = findBlockedReaction(tissueModel,tol)%% should be write like that
    tissueModel = removeRxns(tissueModel,inactiveRxns);
    tissueModel = removeNonUsedGenes(tissueModel);
end

function [reactionActivity,reactionActivityIrrev,model2gimme,gimmeSolution] = solveGimme(model,objectiveCol,expressionRxns,cutoff)
% Code implementation from the cobra toolbox (createTissueSpecificModel.m)
% "FIX" indicates changes made
    nRxns = size(model.S,2);

    %first make model irreversible
    [modelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(model); %% CHECK with the last version of this function in cobra v3 to see if we can remove the modified version included in this script

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
            display('Failed to solve initial FBA problem');
            return
        end
        maxObjective(i)=FBAsolution.f;
    end

    model2gimme = modelIrrev;
    model2gimme.c = zeros(nIrrevRxns,1);


    for i=1:nIrrevRxns
        if (expressionRxnsIrrev(i,1) > -1)   %if not absent reaction
            if (expressionRxnsIrrev(i,1) < cutoff)
                model2gimme.c(i,1) = cutoff-expressionRxnsIrrev(i,1); %FIX: use expression level as weight
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
        if ((expressionRxnsIrrev(i,1) > cutoff) | (expressionRxnsIrrev(i,1) == -1))
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

end

function [modelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(model)
%convertToIrreversible Convert model to irreversible format
%
% Copied from the cobra toolbox with some fixes.
%
% [modelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(model)
%
%INPUT
% model         COBRA model structure
%
%OUTPUTS
% modelIrrev    Model in irreversible format
% matchRev      Matching of forward and backward reactions of a reversible
%               reaction
% rev2irrev     Matching from reversible to irreversible reactions
% irrev2rev     Matching from irreversible to reversible reactions
%
% Uses the reversible list to construct a new model with reversible
% reactions separated into forward and backward reactions.  Separated
% reactions are appended with '_f' and '_b' and the reversible list tracks
% these changes with a '1' corresponding to separated forward reactions.
% Reactions entirely in the negative direction will be reversed and
% appended with '_r'.
%
% written by Gregory Hannum 7/9/05
%
% Modified by Markus Herrgard 7/25/05
% Modified by Jan Schellenberger 9/9/09 for speed.
%
% Some fixes by Daniel Machado, 2013.

    %declare variables
    modelIrrev.S = spalloc(size(model.S,1),0,2*nnz(model.S));
    modelIrrev.rxns = [];
    modelIrrev.rev = zeros(2*length(model.rxns),1);
    modelIrrev.lb = zeros(2*length(model.rxns),1);
    modelIrrev.ub = zeros(2*length(model.rxns),1);
    modelIrrev.c = zeros(2*length(model.rxns),1);
    matchRev = zeros(2*length(model.rxns),1);

    nRxns = size(model.S,2);
    irrev2rev = zeros(2*length(model.rxns),1);

    %loop through each column/rxn in the S matrix building the irreversible
    %model
    cnt = 0;
    for i = 1:nRxns
        cnt = cnt + 1;

        %expand the new model (same for both irrev & rev rxns  
        modelIrrev.rev(cnt) = model.rev(i);
        irrev2rev(cnt) = i;

        % Check if reaction is declared as irreversible, but bounds suggest
        % reversible (i.e., having both positive and negative bounds
        if (model.ub(i) > 0 && model.lb(i) < 0) && model.rev(i) == false
            model.rev(i) = true;
            warning(cat(2,'Reaction: ',model.rxns{i},' is classified as irreversible, but bounds are positive and negative!'))

        end


    % FIX Daniel M. 2013-01-11 - Temporary fix
    % This causes problems when comparing two models under different environmental
    % conditions, because they can end up with flux vectors of different sizes.  

    % Reaction entirely in the negative direction
    %    if (model.ub(i) <= 0 && model.lb(i) < 0)
    %         % Retain original bounds but reversed
    %         modelIrrev.ub(cnt) = -model.lb(i);
    %         modelIrrev.lb(cnt) = -model.ub(i);
    %         % Reverse sign
    %         modelIrrev.S(:,cnt) = -model.S(:,i);
    %         modelIrrev.c(cnt) = -model.c(i);
    %         modelIrrev.rxns{cnt} = [model.rxns{i} '_r'];
    %         model.rev(i) = false;
    %         modelIrrev.rev(cnt) = false;
    %     else
            % Keep positive upper bound
            modelIrrev.ub(cnt) = model.ub(i);
            %if the lb is less than zero, set the forward rxn lb to zero 

    %         if model.lb(i) < 0
    %            modelIrrev.lb(cnt) = 0;
    %         else
    %            modelIrrev.lb(cnt) = model.lb(i);
    %         end
            modelIrrev.lb(cnt) = max(0, model.lb(i));
            modelIrrev.ub(cnt) = max(0, model.ub(i));

            modelIrrev.S(:,cnt) = model.S(:,i);
            modelIrrev.c(cnt) = model.c(i);
            modelIrrev.rxns{cnt} = model.rxns{i};
    %    end


        %if the reaction is reversible, add a new rxn to the irrev model and
        %update the names of the reactions with '_f' and '_b'
        if model.rev(i) == true
            cnt = cnt + 1;
            matchRev(cnt) = cnt - 1;
            matchRev(cnt-1) = cnt;
            modelIrrev.rxns{cnt-1} = [model.rxns{i} '_f'];
            modelIrrev.S(:,cnt) = -model.S(:,i);
            modelIrrev.rxns{cnt} = [model.rxns{i} '_b'];
            modelIrrev.rev(cnt) = true;

    % FIX Daniel M. 2013-01-09 - if original reaction has a positive lb,
    % backwards reaction should have nonnegative upper bound.
    %        modelIrrev.lb(cnt) = 0;
    %        modelIrrev.ub(cnt) = -model.lb(i);    
            modelIrrev.lb(cnt) = max(0, -model.ub(i));
            modelIrrev.ub(cnt) = max(0, -model.lb(i));

            modelIrrev.c(cnt) = 0;
            rev2irrev{i} = [cnt-1 cnt];
            irrev2rev(cnt) = i;
        else
            matchRev(cnt) = 0;
            rev2irrev{i} = cnt;
        end
    end

    rev2irrev = columnVector(rev2irrev);
    irrev2rev = irrev2rev(1:cnt);
    irrev2rev = columnVector(irrev2rev);

    % Build final structure
    modelIrrev.S = modelIrrev.S(:,1:cnt);
    modelIrrev.ub = columnVector(modelIrrev.ub(1:cnt));
    modelIrrev.lb = columnVector(modelIrrev.lb(1:cnt));
    modelIrrev.c = columnVector(modelIrrev.c(1:cnt));
    modelIrrev.rev = modelIrrev.rev(1:cnt);
    modelIrrev.rev = columnVector(modelIrrev.rev == 1);
    modelIrrev.rxns = columnVector(modelIrrev.rxns); 
    modelIrrev.mets = model.mets;
    matchRev = columnVector(matchRev(1:cnt));
    modelIrrev.match = matchRev;
    if (isfield(model,'b'))
        modelIrrev.b = model.b;
    end
    if isfield(model,'description')
        modelIrrev.description = [model.description ' irreversible'];
    end
    if isfield(model,'subSystems')
        modelIrrev.subSystems = model.subSystems(irrev2rev);
    end
    if isfield(model,'genes')
        modelIrrev.genes = model.genes;
        genemtxtranspose = model.rxnGeneMat';
        modelIrrev.rxnGeneMat = genemtxtranspose(:,irrev2rev)';
        modelIrrev.rules = model.rules(irrev2rev);
        modelIrrev.grRules = model.grRules(irrev2rev);
    end
    modelIrrev.reversibleModel = false;
end
