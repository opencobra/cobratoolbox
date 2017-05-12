function warmupPts= createHRWarmup(model,nPoints,verbFlag,bias,nPointsCheck)
% Creates a warmup point set for hit-and-run sampling by
% combining orthogonal and random points
%
% USAGE:
%
%    warmupPts= createHRWarmup(model, nPoints, verbFlag, bias, nPointsCheck)
%
% INPUTS:
%    model:     Model structure
%
% OPTIONAL INPUTS:
%    nPoints:   Number of warmup points (Default = 5000);
%    verbFlag:  Verbose flag (Default = false)
%    bias:      Structure with fields:
%
%                 * method - Biasing distribution: 'uniform', 'normal'
%                 * index - The reaction indexes which to bias (`nBias` total)
%                 * param - nBias x 2 matrix of parameters (for uniform it's min max, for normal it's `mu`, `sigma`).
%
% OUTPUT:
%    warmupPts: Set of warmup points
%
% .. Authors:
%       - Markus Herrgard 4/21/06
%       - Richard Que 11/23/09 integrated subfunctions into script

if (nargin < 2)||isempty(nPoints), nPoints = 5000; end
if (nargin < 3)||isempty(verbFlag), verbFlag = false; end
if (nargin < 4), bias = []; end
if (nargin < 5)||isempty(nPointsCheck), nPointsCheck = true; end

if isfield(model,'A')
    [nMets,nRxns] = size(model.A);
else
    [nMets,nRxns] = size(model.S);
    model.A=model.S;
end
if ~isfield(model,'csense')
    model.csense(1:size(model.S,1)) = 'E';
end

if nPointsCheck && (nPoints < nRxns*2)
    warning(['Need a minimum of ' num2str(nRxns*2) ' warmup points']);
    nPoints = nRxns*2;
end
warmupPts = sparse(nRxns,nPoints);

% Generate the correct parameters for the biasing reactions
if ~isempty(bias)
    if (~ismember(bias.method,{'uniform','normal'}))
        error('Biasing method not implemented');
    end
    for k = 1:size(bias.index)
        ind = bias.index(k);
        % Find upper & lower bounds for bias rxns to ensure that no
        % problems arise with values out of bounds
        model.c = zeros(nRxns,1);
        model.c(ind) = 1;
        model.osense = -1;
        sol = solveCobraLP(model);
        maxFlux = sol.obj;
        model.osense = 1;
        sol = solveCobraLP(model);
        minFlux = sol.obj;

        if strcmp(bias.method, 'uniform')
            upperBias = bias.param(k,2);
            lowerBias = bias.param(k,1);
            if (upperBias > maxFlux || upperBias < minFlux)
                upperBias = maxFlux;
                disp('Invalid bias bounds - using default bounds instead');
            end
            if (lowerBias < minFlux || lowerBias > maxFlux)
                lowerBias = minFlux;
                disp('Invalid bias bounds - using default bounds instead');
            end
            bias.param(k,1) = lowerBias;
            bias.param(k,2) = upperBias;
        elseif strcmp(bias.method, 'normal')
            biasMean = bias.param(k,1);
            if (biasMean > maxFlux || biasMean < minFlux)
                 bias.param(k,1) = (minFlux + maxFlux)/2;
                disp('Invalid bias mean - using default mean instead');
            end
            biasFluxMin(k) = minFlux;
            biasFluxMax(k) = maxFlux;
        end
    end
end

i = 1;
showprogress(0, 'Creating warmup points ...');
%Generate the points
while i <= nPoints/2
    showprogress(2*i/nPoints);
    if ~isempty(bias)
        for k = 1:size(bias.index)
            ind = bias.index(k);
            if strcmp(bias.method, 'uniform')
                diff = bias.param(k,2) - bias.param(k,1);
                fluxVal = diff*rand() + bias.param(k,1);
            elseif strcmp(bias.method, 'normal')
                valOK = false;
                % Try until get points inside the space
                while (~valOK)
                    fluxVal = randn()*bias.param(k,2)+bias.param(k,1);
                    if (fluxVal <= biasFluxMax(k) && fluxVal >= biasFluxMin(k))
                        valOK = true;
                    end
                end
            end
            model.lb(ind) = 0.99999999*fluxVal;
            model.ub(ind) = 1.00000001*fluxVal;
        end
    end
    % Create random objective function
    model.c = rand(nRxns,1)-0.5;

    for maxMin = [1, -1]
        % Set the objective function
        if i <= nRxns
            model.c = zeros(nRxns,1);
            model.c(i) = 1;
        end
        model.osense = maxMin;

        % Determine the max or min for the rxn
        sol = solveCobraLP(model);
        x = sol.full;
        status = sol.stat;
        if status == 1
            validFlag = true;
        else
            display ('invalid solution')
            validFlag = false;
            display(status)
            pause;
        end

        % Continue if optimal solution is found

        % Move points to within bounds
        x(x > model.ub) = model.ub(x > model.ub);
        x(x < model.lb) = model.lb(x < model.lb);

        % Store point
        if (maxMin == 1)
            warmupPts(:,2*i-1) = x;
        else
            warmupPts(:,2*i) = x;
        end

        if (verbFlag)
            if mod(i,100)==0
                fprintf('%4.1f\n',i/nPoints*100);
            end
        end


    end
    if validFlag
        i = i+1;
    end
end
centerPoint = mean(warmupPts,2);
% Move points in
if isempty(bias)
    warmupPts = warmupPts*.33 + .67*centerPoint*ones(1,nPoints);
else
    warmupPts = warmupPts*.99 + .01*centerPoint*ones(1,nPoints);
end

% % Create orthogonal warmup points
% warmupPts1= createHRWarmupOrth(model,true,verbFlag);
%
% % Create warmup points using random directions
% warmupPts2 = createHRWarmupRand(model,1000,verbFlag);
%
% [nRxns,nPts1] = size(warmupPts1);
% [nRxns,nPts2] = size(warmupPts2);
% warmupPts = zeros(nRxns,nPoints);
%
% pointOrder = randperm(nPts1);
%
% if (nPoints < nPts1)
%     warning(['Need a minimum of ' num2str(nPts1) ' warmup points']);
%     nPoints = nPts1;
% end
%
% % Combine point sets
% for i = 1:nPoints
%   if (i <= nPts1)
%       % Ensure that each direction is used at least once
%       x1 = warmupPts1(:,pointOrder(i));
%   else
%       % All direction already used
%       x1 = warmupPts1(:,ceil(rand*nPts1));
%   end
%   x2 = warmupPts2(:,ceil(rand*nPts2));
%   r = rand;
%   thisPoint = sparse((x1*r + x2*(1-r)));
%   % Make sure points stay within bounds
%   thisPoint(thisPoint > model.ub) = model.ub(thisPoint ...
%                                              > ...
%                                              model.ub);
%   thisPoint(thisPoint < model.lb) = model.lb(thisPoint ...
%                                              < model.lb);
%   warmupPts(:,i) = thisPoint;
%
% end
