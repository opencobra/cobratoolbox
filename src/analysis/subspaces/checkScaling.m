function [precisionEstimate, solverRecommendation, scalingProperties] = checkScaling(model, estLevel, printLevel)
% checks the scaling of the stoichiometric matrix and provides a recommendation on the precision of the solver
%
% USAGE:
%
%     [precisionEstimate, scalingProperties] = checkScaling(model, estLevel, printLevel)
%
% INPUTS:
%
%    model:                       COBRA model structure
%
% OPTIONAL INPUTS:
%
%    estLevel:                level of estimation: `crude`, `medium`, `fine` (default)
%    printLevel:              verbose level (default: 1). Level 0 is quiet.
%
% OUTPUTS:
%
%    precisionEstimate:       estimation of precision (string, `double` or `quad`, default: `double`)
%    solverRecommendation:    cell array with recommendation of solver(s) to be used (default: {'glpk'})
%    scalingProperties:       structure with properties of scaling
%
%                               * .estLevel: `crude`, `medium`, `fine` (default)
%                               * .scltol: value between 0 and 1 (column or row ratio as large as possible)
%                               * .matrixAS: name of matrix
%                               * .nMets: number of metabolites
%                               * .nRxns: number of reactions
%                               * .minS: minimum of all stoichiometric coefficients
%                               * .maxS: maximum of all stoichiometric coefficients
%                               * .rmin: minimum of all row scaling coefficients
%                               * .imin: index of the minimum of all row scaling coefficients
%                               * .rmax: maximum of all row scaling coefficients
%                               * .imax: index of the maximum of all row scaling coefficients
%                               * .cmin: minimum of all column scaling coefficients
%                               * .jmin: index of the minimum of all column scaling coefficients
%                               * .cmax: maximum of all column scaling coefficients
%                               * .jmax: index of the maximum of all column scaling coefficients
%                               * .minLB: minimum of the lower bound vector
%                               * .maxLB: maximum of the lower bound vector
%                               * .minUB: minimum of the upper bound vector
%                               * .maxUB: maximum of the upper bound vector
%                               * .ratioS: ratio of the maximum and minimum stoichiometric coefficients
%                               * .ratioS_orderOfMag: order of magnitude of the ratio of the
%                                 maximum and minimum stoichiometric coefficients
%                               * .ratioL: ratio of the maximum and minimum values of the lower bound vector
%                               * .ratioL_orderOfMag: order of magnitude of the ratio of the
%                                 maximum and minimum values of the lower bound vector
%                               * .ratioU: ratio of the maximum and minimum values of the upper bound vector
%                               * .ratioU_orderOfMag: order of magnitude of the ratio of the
%                                 maximum and minimum values of the upper bound vector
%                               * .ratioR: ratio of the maximum and minimum row scaling coefficients
%                               * .ratioR_orderOfMag: order of magnitude of the ratio of the
%                                 maximum and minimum row scaling coefficients
%                               * .ratioC: ratio of the maximum and minimum column scaling coefficients
%                               * .ratioC_orderOfMag: order of magnitude of the ratio of the
%                                 maximum and minimum column scaling coefficients

    global SOLVERS

    if nargin < 2
        estLevel = 'fine';
    end

    if nargin < 3
        printLevel = 1;
    end

    % set the scltol parameter based of the estimation level
    if strcmp(estLevel, 'crude')
        scltol = 0.0;
    elseif strcmp(estLevel, 'medium')
        scltol = 0.5;
    else
        scltol = 1.0;
    end

    % assume constraint matrix is S if no A provided.
    if ~isfield(model, 'A') && isfield(model, 'S')
        S = model.S;
        matrixAS = 'S';
    else
        S = model.A;
        matrixAS = 'A';
    end

    % determine the number of metabolites and reactions
    [nMets, nRxns] = size(S);

    % determine the row and column scaling factors
    [cscale, rscale] = gmscale(S, 0, scltol);

    % determine the minimum and maximum scaling factors
    [rmin, imin] = min(rscale);
    [rmax, imax] = max(rscale);
    [cmin, jmin] = min(cscale);
    [cmax, jmax] = max(cscale);

    % determine the row and column scaling ratios
    if abs(rmin) > 0
        ratioR = rmax / rmin;
    else
        if abs(rmin) > abs(rmax)
            ratioR = rmin;
        else
            ratioR = rmax;
        end
    end
    if abs(cmin) > 0
        ratioC = cmax / cmin;
    else
        if abs(cmin) > abs(cmax)
            ratioC = cmin;
        else
            ratioC = cmax;
        end
    end

    % determine the extrema of stoichiometric coefficients
    minS = full(min(min(abs(S(S ~= 0)))));
    maxS = full(max(max(abs(S))));
    ratioS = maxS / minS;

    % determine extrema of bounds
    if isfield(model, 'lb')
        minLB = min(abs(model.lb(model.lb ~= 0)));
        maxLB = max(abs(model.lb));

        ratioL = maxLB / minLB;
    end
    if isfield(model, 'ub')
        minUB = min(abs(model.ub(model.ub ~= 0)));
        maxUB = max(abs(model.ub));

        ratioU = maxUB / minUB;
    end

    % save all calculated scaling quantities as a structure
    scalingProperties = [];

    vars = {'estLevel', 'scltol', 'matrixAS', 'nMets', 'nRxns', 'minS', 'maxS', ...
            'rmin', 'imin', 'rmax', 'imax', 'cmin', 'jmin', 'cmax', 'jmax'};

    % fill the structure with the properties
    for i = 1:length(vars)
        scalingProperties.(vars{i}) = eval(vars{i});
    end

    % print out a summary report
    if printLevel > 0
        fprintf('\n ------------------------ Scaling summary report ------------------------\n\n');
        if isfield(model, 'description')
            fprintf(' Name of model:                                %s\n', model.description);
        end
        fprintf(' Estimation level:                             %s (scltol = %1.2f)\n', estLevel, scltol);
        fprintf(' Name of matrix:                               %s\n', matrixAS);
        fprintf(' Size of matrix:\n');
        fprintf('        * metabolites:                         %d\n', nMets);
        fprintf('        * reactions:                           %d\n', nRxns);
        fprintf(' Stoichiometric coefficients:\n');
        fprintf('        * Minimum (absolute non-zero value):   %1.2e\n', minS);
        fprintf('        * Maximum (absolute non-zero value):   %1.2e\n', maxS);
    end

    if isfield(model, 'lb')
        scalingProperties.minLB = minLB;
        scalingProperties.maxLB = maxLB;

        if printLevel > 0
            fprintf(' Lower bound coefficients:\n');
            fprintf('        * Minimum (absolute non-zero value):   %1.2e\n', minLB);
            fprintf('        * Maximum (absolute non-zero value):   %1.2e\n', maxLB);
        end
    end

    if isfield(model, 'ub')
        scalingProperties.minUB = minUB;
        scalingProperties.maxUB = maxUB;

        if printLevel > 0
            fprintf(' Upper bound coefficients:\n');
            fprintf('        * Minimum (absolute non-zero value):   %1.2e\n', minUB);
            fprintf('        * Maximum (absolute non-zero value):   %1.2e\n', maxUB);
        end
    end

    if printLevel > 0
        fprintf(' Row scaling coefficients:\n');
        fprintf('        * Minimum:                             %1.2e (row #: %d)\n', rmin, imin);
        fprintf('        * Maximum:                             %1.2e (row #: %d)\n', rmax, imax);
        fprintf(' Column scaling coefficients:\n');
        fprintf('        * Minimum:                             %1.2e (column #: %d)\n', cmin, jmin);
        fprintf('        * Maximum:                             %1.2e (column #: %d)\n\n', cmax, jmax);
        fprintf(' ---------------------------------- Ratios --------------------------------\n\n');
    end

    if abs(minS) > 0 && abs(ratioS) > 0
        scalingProperties.ratioS = ratioS;
        if printLevel > 0
            fprintf(' Ratio of stoichiometric coefficients:         %1.2e\n', ratioS);
        end
    end
    if abs(ratioS) > 0
        scalingProperties.ratioS_orderOfMag = abs(floor(log10(abs(ratioS))));
        if printLevel > 0
            fprintf(' Order of magnitude diff. (stoich. coeff.):    %d\n\n', scalingProperties.ratioS_orderOfMag);
        end
    end

    % lower bounds
    if isfield(model, 'lb')
        if abs(minLB) > 0 && abs(ratioL) > 0
            scalingProperties.ratioL = ratioL;
            if printLevel > 0
                fprintf(' Ratio of lower bounds:                        %1.2e\n', ratioL);
            end
        end
        if abs(ratioL) > 0
            scalingProperties.ratioL_orderOfMag = abs(floor(log10(abs(ratioL))));
            if printLevel > 0
                fprintf(' Order of magnitude diff. (lower bounds):      %d\n\n', scalingProperties.ratioL_orderOfMag);
            end
        end
    end

    % upper bounds
    if isfield(model, 'ub')
        if abs(minUB) > 0 && abs(ratioU) > 0
            scalingProperties.ratioU = ratioU;
            if printLevel > 0
                fprintf(' Ratio of upper bounds:                        %1.2e\n', ratioU);
            end
        end
        if abs(ratioU) > 0
            scalingProperties.ratioU_orderOfMag = abs(floor(log10(abs(ratioU))));
            if printLevel > 0
                fprintf(' Order of magnitude diff. (upper bounds):      %d\n\n', scalingProperties.ratioU_orderOfMag);
            end
        end
    end

    % row scaling
    if abs(rmin) > 0 && abs(ratioR) > 0
        scalingProperties.ratioR = ratioR;
        if printLevel > 0
            fprintf(' Ratio of row scaling coefficients:            %1.2e\n', ratioR);
        end
    end
    if abs(ratioR) > 0
        scalingProperties.ratioR_orderOfMag = abs(floor(log10(abs(ratioR))));
        if printLevel > 0
            fprintf(' Order of magnitude diff. (row scaling):       %d\n\n', scalingProperties.ratioR_orderOfMag);
        end
    end

    % column scaling
    if abs(cmin) > 0 && abs(ratioC) > 0
        scalingProperties.ratioC = ratioC;
        if printLevel > 0
            fprintf(' Ratio of column scaling coefficients:         %1.2e\n', ratioC);
        end
    end
    if abs(ratioC) > 0
        scalingProperties.ratioC_orderOfMag = abs(floor(log10(abs(ratioC))));
        if printLevel > 0
            fprintf(' Order of magnitude diff. (column scaling):    %d\n', scalingProperties.ratioC_orderOfMag);
        end
    end

    % print out a line to close the summary report
    if printLevel > 0
        fprintf('\n --------------------------------------------------------------------------\n');
    end

    % print out a recommendation and set the precisionEstimate variable
    precisionEstimate = 'quad';

    % provide a precision requirement estimate
    if ratioR > 1e6 && ratioC > 1e6
        if printLevel > 0
            fprintf('\n -> The model has badly scaled rows and columns. Quad precision is strongly recommended.\n');
            fprintf('\n    Set the Quad MINOS solver with: >> changeCobraSolver(\''quadMinos\'', \''LP\'')\n\n');
        end
    elseif ratioR > 1e6
        if printLevel > 0
            fprintf('\n -> The model has badly-scaled rows, but the column scaling ratio is not that high. Quad-precision is recommended, but you may try first with <double precision>.\n\n');
            fprintf('\n    You may set the Quad MINOS solver with: >> changeCobraSolver(\''quadMinos\'', \''LP\'')\n\n');
        end
    elseif ratioC > 1e6
        if printLevel > 0
            fprintf('\n -> The model has badly-scaled columns, but the row scaling ratio is not that high. Quad-precision is recommended, but you may try first with <double precision>.\n\n');
            fprintf('\n    You may set the Quad MINOS solver with: >> changeCobraSolver(\''quadMinos\'', \''LP\'')\n\n');
        end
    else
        if printLevel > 0
            fprintf('\n -> The model is well scaled. Double precision is recommended.\n\n');
        end
        precisionEstimate = 'double';
    end

    % return a solver recommendation
    solverRecommendation = {};
    supportedSolversNames = fieldnames(SOLVERS);
    solverNamesLP = {};
    for i = 1:length(supportedSolversNames)
        types = SOLVERS.(supportedSolversNames{i}).type;
        solverNamesLP{end + 1} = supportedSolversNames{i};
    end

    % fill the list with solvers that are installed already
    for i = 1:length(solverNamesLP)
        if SOLVERS.(solverNamesLP{i}).installed
            if ~strcmp(solverNamesLP{i}, 'dqqMinos') && ~strcmp(solverNamesLP{i}, 'quadMinos')
                solverRecommendation{end + 1} = solverNamesLP{i};
            end
        end
    end

    if strcmp(precisionEstimate, 'quad')
        solverRecommendation = {'dqqMinos', 'quadMinos'};
    end
end
