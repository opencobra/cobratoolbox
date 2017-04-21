function ACBSampler(model,warmupPoints,fileName,nFiles,pointsPerFile,nMixPts,nWarmupNeeded,saveMatFlag,biasOpt)
% Artificial centering boundary sampler
%
% USAGE:
%
%    ACBSampler(model, warmupPoints, fileName, nFiles, pointsPerFile, nMixPts, nWarmupNeeded, saveMatFlag, biasOpt)
%
% INPUTS:
%    model:           Model structure
%    warmupPoints:    Warmup points
%    fileName:        Base `fileName` for saving results
%    nFiles:          Number of sample point files created
%    pointsPerFile:   Number of points per file saved
%    nMixPts:         Number of steps initially used for mixing (not saved)
%
% OPTIONAL INPUTS:
%    nWarmupNeeded:   Number of warmup points needed (Default = 20000)
%    saveMatFlag:     Save points in mat format vs txt format (Default = true)
%    biasOpt:         Options for biasing sampler (Default = no bias)
%
% .. Authors:
%       - Christian Barrett 8/24/06
%       - Markus Herrgard 8/24/06

if (nargin < 7)
    % Expands the number of warmup points if the initially provided set is too
    % small
    nWarmupNeeded = 20000;
end
if (nargin < 8)
    saveMatFlag = true;
end
if (nargin < 9)
    biasFlag = false;
else
    biasFlag = true;
end

warning off MATLAB:divideByZero;

% Minimum allowed distance to the closest constraint
maxMinTol = 1e-9;
% Ignore directions where u is really small
uTol = 1e-9;
% Project out of directions that are too close to the boundary
dTol = 1e-10;

% Number of initial warmup points
[nRxns,nWarmup] = size(warmupPoints);

% Find indices for fluxes to be biased
if (biasFlag)
    [tmp,biasInd] = ismember(biasOpt.rxns,model.rxns);
    if (length(biasInd) > 1)
        biasDist = sum((warmupPoints(biasInd,:)-repmat(biasOpt.values,1,nWarmup)).^2./repmat(biasOpt.stds.^2,1,nWarmup));
    else
        biasDist = (warmupPoints(biasInd,:)-repmat(biasOpt.values,1,nWarmup)).^2./repmat(biasOpt.stds.^2,1,nWarmup);
    end
end

totalPointCount = 0;

fidErr = fopen([fileName '.err'],'w');

for fileNo = 1:nFiles

    if (~saveMatFlag)
        fid = fopen([fileName '_' num2str(fileNo) '.fls'],'w');
    else
        % Allocate memory for all points
        points = zeros(nRxns,pointsPerFile);
    end

    pointCount = 1;
    while (pointCount <= pointsPerFile)

        if (mod(totalPointCount,500) == 0)
            fprintf('%d %d %d\n',fileNo,pointCount,totalPointCount);
        end

        % Pick two random points
        if (biasFlag)
           [tmp,sortInd] = sort(biasDist);
            randPoint1 = warmupPoints(:,sortInd(ceil(biasOpt.percThr*nWarmup*rand)));
            randPoint2 = warmupPoints(:,sortInd(ceil(biasOpt.percThr*nWarmup*rand)));
        else
            randPoint1 = warmupPoints(:,ceil(nWarmup*rand));
            randPoint2 = warmupPoints(:,ceil(nWarmup*rand));
        end

        % Get a line formed by the two
        u = (randPoint2-randPoint1);
        u = u/norm(u);

        % This gets randPoint1 away from the boundary, which causes problems
        % when trying to move from randPoint1
        % randPoint1 = randPoint1 + tol*u;

        % Figure out the distances to upper and lower bounds
        distUb = (model.ub - randPoint1);
        distLb = (randPoint1 - model.lb);

        % Figure out if we are too close to a boundary
        validDir = ((distUb > dTol) & (distLb > dTol));

        % Figure out positive and negative directions
        posDirn = find(u(validDir) > uTol);
        negDirn = find(u(validDir) < -uTol);

        if (isempty(posDirn) & isempty(negDirn))
            continue
        end

        % Figure out all the possible maximum and minimum step sizes
        maxStepTemp = distUb(validDir)./u(validDir);
        minStepTemp = -distLb(validDir)./u(validDir);
        maxStepVec = [maxStepTemp(posDirn);minStepTemp(negDirn)];
        minStepVec = [minStepTemp(posDirn);maxStepTemp(negDirn)];

        % Figure out the true max & min step sizes
        maxStep = min(maxStepVec);
        minStep = max(minStepVec);

        % Compute the boundary points along this line
        boundaryPoint1 = randPoint1 + minStep*u;
        boundaryPoint2 = randPoint1 + maxStep*u;

        % Move on if the points left the null space for some reason
        error1 = full(max(max(abs(model.S*boundaryPoint1))));
        error2 = full(max(max(abs(model.S*boundaryPoint2))));
        if (error1 > 1e-7 | error2 > 1e-7)
          fprintf('Point out of N-space: %g %g\n',error1,error2);
          continue;
        end

        % Get the center point
        centerPoint = (boundaryPoint1 + boundaryPoint2)/2.0;

        % Check if we want to add this point to warmup points or replace a
        % previous point

        if (biasFlag)
            % Calculate distance to bias flux values
            [maxBiasDist,maxInd] = max(biasDist);

            if (length(biasInd) > 1)
                biasDistThisStep = sum((centerPoint(biasInd)-biasOpt.values).^2./biasOpt.stds.^2);
            else
                biasDistThisStep = (centerPoint(biasInd)-biasOpt.values).^2./biasOpt.stds.^2;
            end

            if (mod(totalPointCount,100) == 0)
              minBiasDist = min(biasDist);
              fprintf('%d\t%f\t%f\t%f\t%f\t%d\n',totalPointCount, ...
                      biasDistThisStep,minBiasDist,maxBiasDist,mean(biasDist),nWarmup);
              fprintf(fidErr,'%d\t%f\t%f\t%f\t%f\t%d\n',totalPointCount, ...
                      biasDistThisStep,minBiasDist,maxBiasDist,mean(biasDist),nWarmup);

            end

            if (biasDistThisStep < maxBiasDist)
                replaceWarmup = true;
            else
                replaceWarmup = false;
            end
        else
            replaceWarmup = true;
        end

        nWarmup = size(warmupPoints,2);
        if (replaceWarmup)
            if (biasFlag)
                % Add warmup point
                replaceInd = max(find(biasDistThisStep > ...
                                      biasDist));
                if (nWarmup < nWarmupNeeded)
                    biasDist(end+1) = biasDistThisStep;
                    warmupPoints(:,end+1) = centerPoint;
                    nWarmup = nWarmup+1;
                else
                    % Replace warmup point
                    biasDist(maxInd) = biasDistThisStep;
                    warmupPoints(:,maxInd) = centerPoint;
                end
            else
                if (nWarmup < nWarmupNeeded)
                    warmupPoints(:,end+1) = centerPoint;
                    nWarmup = nWarmup+1;
                end
            end
        end

        % Count the total number of points generated
        totalPointCount = totalPointCount + 1;

        % Check if it is time to start saving points
        if (totalPointCount > nMixPts)
            if (rand < 0.5)
                pointToSave = boundaryPoint2;
            else
                pointToSave = boundaryPoint1;
            end

            if (saveMatFlag)
                points(:,pointCount) = pointToSave;
            else
                % Print out point
                for i = 1:length(pointToSave)
                    fprintf(fid,'%g ',pointToSave(i));
                end
                fprintf(fid,'\n');
            end

            pointCount = pointCount + 1;
        end
    end

    % Save current points within the cycle to a file
    if (saveMatFlag)
        file = [fileName '_' num2str(fileNo) '.mat'];
        save (file,'points');
    else
        fclose(fid);
    end

end % Files

fclose(fidErr);
