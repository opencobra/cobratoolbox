function tissueModel = fastcore(core, model, epsilon, expressionRxns, threshold, printlevel)
% Use the FASTCORE algorithm (`Vlassis et al, 2014`) to extract a context
% specific model using data. FASTCORE algorithm defines one set of core
% reactions that is guaranteed to be active in the extracted model and find
% the minimum of reactions possible to support the core.
%
% USAGE:
%
%    tissueModel = fastcore(core, model, epsilon, expressionRxns, threshold, printlevel)
%
% INPUTS:
%    core:              indices of reactions in cobra model that are part of the
%                       core set of reactions (called `C` in `Vlassis et al,
%                       2014`)
%    model:             input model (COBRA model structure)
%
% OPTIONAL INPUTS:
%    epsilon:           smallest flux value that is considered nonzero
%                       (default 1e-8)
%    expressionRxns:    expression data, corresponding to model.rxns (see
%                       mapGeneToRxn.m)
%    threshold:         expression threshold (reactions with expression
%                       above this threshold are put in the set of core
%                       reactions
%    printLevel:        0 = silent, 1 = summary, 2 = debug
%
% OUTPUT:
%   tissueModel:         extracted model
%
%
% `Vlassis, Pacheco, Sauter (2014). Fast reconstruction of compact
% context-specific metbolic network models. PLoS Comput. Biol. 10, e1003424.`
%
% .. Authors:
%       - Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013 LCSB / LSRU, University of Luxembourg
%       - Ronan Fleming, commenting of code and inputs/outputs
%       - Anne Richelle, code adaptation to fit with createTissueSpecificModel


    if ~exist('printLevel','var')
        %For Compatability with the original fastcore syntax
        printlevel = 1;
    end

    %Define the set of core reactions
    if ~isempty(expressionRxns) && ~isempty(threshold)
        %additional option to extend the core set of reaction depending on
        %a threshold on the gene expression data
        coreSetRxn = find(expressionRxns >= threshold);
        coreSetRxn= union(coreSetRxn, find(ismember(model.rxns, core)));
    else
        coreSetRxn = core;
    end

    if ~isempty(epsilon)
        epsilon=1e-8;
    end

    model_orig = model;

    %Find irreversible reactions
    irrevRxns = find(model.lb==0); %% could be called irrevRxns

    A = [];
    flipped = false;
    singleton = false;

    % Find irreversible core reactions
    J = intersect(coreSetRxn, irrevRxns);

    if printlevel > 0
        fprintf('|J|=%d  ', length(J));
    end

    %Find all the reactions that are not in the core
    nbRxns = 1:numel(model.rxns);
    P = setdiff(nbRxns, coreSetRxn);

    % Find the minimum of reactions from P that need to be included to
    % support the irreversible core set of reactions
    [Supp, basis] = findSparseMode(J, P, singleton, model, epsilon);

    if ~isempty(setdiff(J, Supp))
      fprintf ('fastcore.m Error: Inconsistent irreversible core reactions.\n');
      return;
    end

    A = Supp;
    if printlevel > 0
        fprintf('|A|=%d\n', length(A));
    end

    % J is the set of irreversible reactions
    J = setdiff(coreSetRxn, A);
    if printlevel > 0
        fprintf('|J|=%d  ', length(J));
    end

    % Main loop that reduce at each iteration the number of reactions from P that need to be included to
    % support the complete core set of reactions
    while ~isempty(J)

        P = setdiff(P, A);
        %reuse the basis from the previous solve if it exists
        [Supp, basis] = findSparseMode(J, P, singleton, model, epsilon, basis);

        A = union(A, Supp);
        if printlevel > 0
            fprintf('|A|=%d\n', length(A));
        end

        if ~isempty( intersect(J, A))
            J = setdiff(J, A);
            if printlevel > 0
                fprintf('|J|=%d  ', length(J));
            end
            flipped = false;
        else
            if singleton
                JiRev = setdiff(J(1),irrevRxns);
            else
                JiRev = setdiff(J,irrevRxns);
            end
            if flipped || isempty(JiRev)
                if singleton
                    fprintf('\n fastcore.m Error: Global network is not consistent.\n');
                    return
                else
                  flipped = false;
                  singleton = true;
                end
            else
                model.S(:,JiRev) = -model.S(:,JiRev);
                tmp = model.ub(JiRev);
                model.ub(JiRev) = -model.lb(JiRev);
                model.lb(JiRev) = -tmp;
                flipped = true;

                if printlevel > 0
                    fprintf('(flip)  ');
                end
            end
        end
    end
    if printlevel > 0
        fprintf('|A|=%d\n', length(A)); % A : indices of reactions in the new model
    end

    if printlevel > 1
        toc
    end

    toRemove = setdiff(model.rxns,model.rxns(A));
    tissueModel = removeRxns(model_orig, toRemove);
    tissueModel = removeNonUsedGenes(tissueModel);
