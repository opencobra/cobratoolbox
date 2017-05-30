function precisionRequirementEstimate = checkScaling(model, estLevel, printLevel)
% checks the scaling of the stoichiometric matrix and provids a recommendation on the precision of the solver
%
% USAGE:
%
%     [precisionRequirementEstimate] = checkScaling(model, printLevel)
%
% INPUTS:
%
%    S:                             stoichiometric matrix S [m x n]
%    estLevel:                      level of estimation: 'crude', 'medium', 'fine' (default)
%    printLevel:                    level of verbose
%
% OUTPUT:
%
%    precisionRequirementEstimate:  estimation of precision (string, `double` or `quad`, default: `double`)

    if nargin < 2
        estLevel = 'fine';
    end

    if nargin < 3
        printLevel = 1;
    end

    % set the
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
    minS = min(min(S));
    maxS = max(max(S));
    if abs(minS) > 0
        ratioS = maxS / minS;
    else
        ratioS = maxS;
    end

    % determine extrema of bounds
    if isfield(model, 'lb')
        minLB = min(model.lb);
        maxLB = max(model.lb);

        if abs(minLB) > 0
            ratioL = maxLB / minLB;
        else
            ratioL = minLB;
        end
    end
    if isfield(model, 'ub')
        minUB = min(model.ub);
        maxUB = max(model.ub);

        if abs(minUB) > 0
            ratioU = maxUB / minUB;
        else
            ratioU = maxUB;
        end
    end
    % print out a summary report
    if printLevel > 0
        fprintf('\n ------------------------ Scaling summary report ------------------------\n\n');
        if isfield(model, 'description')
            fprintf(' Name of model:                              %s (scltol = %s)\n', model.description);
        end
        fprintf(' Estimation level:                             %s (scltol = %s)\n', estLevel, num2str(scltol));
        fprintf(' Name of matrix:                               %s\n', matrixAS);
        fprintf(' Size of matrix:\n');
        fprintf('        * metabolites:                         %s\n', num2str(size(S, 1)));
        fprintf('        * reactions:                           %s\n', num2str(size(S, 2)));
        fprintf(' Stoichiometric coefficients:\n');
        fprintf('        * Minimum:                             %s\n', num2str(minS));
        fprintf('        * Maximum:                             %s\n', num2str(maxS));
        if isfield(model, 'lb')
            fprintf(' Lower bound coefficients:\n');
            fprintf('        * Minimum:                             %s\n', num2str(minLB));
            fprintf('        * Maximum:                             %s\n', num2str(maxLB));
        end
        if isfield(model, 'ub')
            fprintf(' Upper bound coefficients:\n');
            fprintf('        * Minimum:                             %s\n', num2str(minUB));
            fprintf('        * Maximum:                             %s\n', num2str(maxUB));
        end
        fprintf(' Row scaling coefficients:\n');
        fprintf('        * Minimum:                             %s (row #: %s)\n', num2str(rmin), num2str(imin));
        fprintf('        * Maximum:                             %s (row #: %s)\n', num2str(rmax), num2str(imax));
        fprintf(' Column scaling coefficients:\n');
        fprintf('        * Minimum:                             %s (column #: %s)\n', num2str(cmin), num2str(jmin));
        fprintf('        * Maximum:                             %s (column #: %s)\n\n', num2str(cmax), num2str(jmax));
        fprintf(' ---------------------------------- Ratios --------------------------------\n\n');
        if abs(minS) > 0 && abs(ratioS) > 0
            fprintf(' Ratio of stoichiometric coefficients:         %s\n', num2str(ratioS));
        end
        if abs(ratioS) > 0
            fprintf(' Order of magnitude diff. (stoich. coeff.):    %s\n\n', num2str(abs(floor(log10(abs(ratioS))))));
        end

        % lower bounds
        if isfield(model, 'lb')
            if abs(minLB) > 0 && abs(ratioL) > 0
                fprintf(' Ratio of lower bounds:                        %s\n', num2str(ratioL));
            end
            if abs(ratioL) > 0
                fprintf(' Order of magnitude diff. (lower bounds):      %s\n\n', num2str(abs(floor(log10(abs(ratioL))))));
            end
        end

        % upper bounds
        if isfield(model, 'ub')
            if abs(minUB) > 0 && abs(ratioU) > 0
                fprintf(' Ratio of upper bounds:                        %s\n', engn(ratioU));
            end
            if abs(ratioU) > 0
                fprintf(' Order of magnitude diff. (upper bounds):      %s\n\n', num2str(abs(floor(log10(abs(ratioU))))));
            end
        end

        % row scaling
        if abs(rmin) > 0 && abs(ratioR) > 0
            fprintf(' Ratio of row scaling coefficients:            %s\n', engn(ratioR));
        end
        if abs(ratioR) > 0
            fprintf(' Order of magnitude diff. (row scaling):       %s\n\n', num2str(abs(floor(log10(abs(ratioR))))));
        end

        % column scaling
        if abs(cmin) > 0 && abs(ratioC) > 0
            fprintf(' Ratio of column scaling coefficients:         %s\n', engn(ratioC));
        end
        if abs(ratioC) > 0
            fprintf(' Order of magnitude diff. (column scaling):    %s\n', num2str(abs(floor(log10(abs(ratioC))))));
        end
        fprintf('\n --------------------------------------------------------------------------\n');
    end

    % print out a recommendation and set the precisionRequirementEstimate variable
    precisionRequirementEstimate = 'quad';

    % provide a precision requirement estimate
    if ratioR > 1e6 && ratioC > 1e6
        if printLevel > 0
            fprintf('\n -> The model has badly scaled rows and columns. Quad precision is strongly recommended.\n\n');
        end
    elseif ratioR > 1e6
        if printLevel > 0
            fprintf('\n -> The model has badly-scaled rows, but the column scaling ratio is not that high. Quad-precision is recommended, but you may try first with <double precision>.\n\n');
        end
    elseif ratioC > 1e6
        if printLevel > 0
            fprintf('\n -> The model has badly-scaled columns, but the row scaling ratio is not that high. Quad-precision is recommended, but you may try first with <double precision>.\n\n');
        end
    else
        if printLevel > 0
            fprintf('\n -> The model is well scaled. Double precision is recommended.\n\n');
        end
        precisionRequirementEstimate = 'double';
    end
end

function sNum = engn(value)
exp= floor(log10(abs(value)));
if ( (exp < 3) && (exp >=0) )
    exp = 0; % Display without exponent
else
    while (mod(exp, 3))
        exp= exp - 1;
    end
end
frac=value/(10^exp); % Adjust fraction to exponent
if (exp == 0)
    sNum = sprintf('%2.4G', frac);
else
    sNum = sprintf('%2.4GE%+.2d', frac, exp);
end
end
