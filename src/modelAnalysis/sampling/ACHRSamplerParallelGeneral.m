function [sampleStruct] = ACHRSamplerParallelGeneral(sampleStruct,nLoops,stepsPerPoint, maxtime, proc, fdirectory)
% Artificial Centering Hit-and-Run sampler with in place (memory) point
% management
%
% USAGE:
%
%    sampleStruct = ACHRSamplerParallelGeneral(sampleStruct, nLoops, stepsPerPoint, maxtime, proc, fdirectory)
%
% INPUTS:
%    sampleStruct:      Sampling structure
%    nLoops:            Number of iterations
%    stepsPerPoint:     Number of sampler steps per point saved
%    maxtime:           Amount of time to spend on calculation (in seconds)
%
% OPTIONAL INPUTS:
%    proc:              Number of processes if > 0.  Otherwise, the proces #.
%    fdirectory:        Do not use this parameter when calling function directly.
%
% OUTPUT:
%    sampleStruct:      Sampling structure with sample points
%
% .. Author: - Jan Schellenberger 1/29/07

warning off MATLAB:divideByZero;
% (vaguely) based on code by:
% Markus Herrgard, Gregory Hannum, Ines Thiele, Nathan Price 4/14/06

%proc == 0 means master
%proc greater than 1 means slave.
if nargin < 5 % not parallel at all.
    parallel = 0;
    proc = 0;
elseif nargin >= 5 && proc == 1 % not parallel (explicit)
    parallel = 0;
    proc = 0;
else % parallel.
    parallel = 1;
    if proc < 0 % an indication that this is a slave process
        proc = -proc;
    else % indicator that you are a master process
        numproc = proc;
        proc = 0;
        % clear all files that may exist
        delete('xxMasterfil*.mat');
        delete('xxRound*.mat');
        delete('xxRoundDonePrint*.mat');
        delete('xxRoundAck*.mat');
        delete('xxDoneRound*.mat');
        delete('xxDoneP*.mat');
        delete('xxGlobalDone*.mat*');
    end
end

% Minimum allowed distance to the closest constraint
maxMinTol = 1e-10;
% Ignore directions where u is really small
uTol = 1e-10;
safetycheck = false; % checks the direction of u for fixed directions.

totalStepCount = 0;
t0 = clock;


if proc == 0 % if master thread
    if( ~ isfield(sampleStruct, 'points'))
        points = sampleStruct.warmupPts; % start with warmup points
    else
        points = sampleStruct.points; % continue with points
    end
    offset = sampleStruct.internal.offset;

    [dimX,nPoints] = size(points);

    points = points - offset*ones(1, nPoints);

    ub = sampleStruct.internal.ubnew;
    lb = sampleStruct.internal.lbnew;
    A = sampleStruct.internal.Anew;
    C = sampleStruct.internal.Cnew;
    D = sampleStruct.internal.Dnew;
    fixed = union(sampleStruct.internal.fixed,find(ub==lb));
    if (~isfield(sampleStruct.internal,'N'))
        if size(A,1)==0
            N=[];
            sampleStruct.internal.N=N;
        else
            if issparse(A)
                N = null(full(A));
            else
                N = null(A);
            end
            sampleStruct.internal.N = N;
        end
    else
        N = sampleStruct.internal.N;
    end

    movable = (1:dimX)';
    movable(fixed) = [];
    if safetycheck
        Nsmall = null(full(A(:, movable)));
    else
        Nsmall = [];
    end

    % Find the center of the space
    centerPoint = mean(points, 2);

    fidErr = fopen('ACHRParallelError.txt','w');

    pointRange = 1:nPoints;
    totalloops = nLoops;

    if parallel
        blah = 1;
        display('saving master file.');
        save('xxMasterfile', 'ub', 'lb', 'A', 'C', 'D', 'fixed', 'N', 'movable', 'Nsmall', 'numproc', 'nPoints' );
        display('finished saving master file.  spawning processes');
        for i = 1:(numproc - 1) % goes from 1 to 7 if proc == 8
            command = strcat('matlab -singleCompThread -automation -nojvm -r ACHRSamplerParallelGeneral([],',num2str(nLoops),',',num2str(stepsPerPoint),',0,', num2str(-i) ,',''' ,pwd, ''');exit; &' );
            display(command)
            system(command);
        end
        display('finished spawning processes');
    end
end

if proc > 0 %slave threads only
    cd (fdirectory);
    load('xxMasterfile', 'ub', 'lb', 'A', 'C', 'D', 'fixed', 'N', 'movable', 'Nsmall', 'numproc', 'nPoints');
    blah = 1;
end

for i = 1:nLoops
    if parallel % this whole block only gets executed in parallel mode.
        if proc == 0 %master thread does this.
            % save points
            display(strcat('distributing points round ', num2str(i)));
            save(strcat('xxRound', num2str(i)), 'points', 'centerPoint');
            save(strcat('xxRoundDonePrint', num2str(i)), 'blah');
            display(strcat('finished distributing points round ', num2str(i)));
        else  % if slave threads do this.
            display(strcat('reading in points round ', num2str(i)));
            while exist(strcat('xxRoundDonePrint', num2str(i), '.mat'), 'file') ~= 2; % wait for other thread to finish.
                %display(strcat('waiting for round ', num2str(i)));
                fprintf(1, '.');
                if exist('xxGlobalDone.mat', 'file') == 2
                    exit;
                end
                pause(.25);
            end
            fprintf(1,'\nloading files four next round.\n');
            try
              load(strcat('xxRound', num2str(i)), 'points', 'centerPoint'); % load actual points
            catch
              pause(15) % for some reason at round 64 it needs extra time to load
              load(strcat('xxRound', num2str(i)), 'points', 'centerPoint'); % load actual points
            end
            save(strcat('xxRoundAck', num2str(i),'x', num2str(proc) ), 'blah'); % save acknowledgement
            display(strcat('finished reading input and acknowledgment sent ', num2str(i)));
        end
        % divide up points.  master thread (proc = 0) gets first chunk.
        pointRange = subparts(nPoints, numproc, proc);
    end

    % actual sampling over pointRange
    for pointCount = pointRange
        % Create the random step size vector
        randVector = rand(stepsPerPoint,1);
        prevPoint = points(:,pointCount);
        curPoint = prevPoint;
        if mod(pointCount,200) == 0
            display(pointCount);
        end
        saveCoords = prevPoint(fixed);
        for stepCount = 1:stepsPerPoint
            % Pick a random warmup point
            randPointID = ceil(nPoints*rand);
            randPoint = points(:,randPointID);

            % Get a direction from the center point to the warmup point
            u = (randPoint-centerPoint);
            if ~isempty(fixed) % no need to reproject if there are no fixed reactions.
                %ubefore = u;
                if safetycheck
                    u(movable) = Nsmall * (Nsmall' * u(movable));
                end
                %uafter = u;

                u(fixed) = 0; % takes care of biasing.
            end
            u = u/norm(u);

            % Figure out the distances to upper and lower bounds
            distUb = (ub - prevPoint);
            distLb = (prevPoint - lb);
            distD = (D-C*prevPoint);

            % Figure out positive and negative directions
            posDirn = (u > uTol);
            negDirn = (u < -uTol);
            move = C*u;
            posDirn2 = (move > uTol);
            negDirn2 = (move < -uTol);

            % Figure out all the possible maximum and minimum step sizes
            maxStepTemp = distUb./u;
            minStepTemp = -distLb./u;
            StepD = distD./move;
            maxStepVec = [maxStepTemp(posDirn);minStepTemp(negDirn);StepD(posDirn2 )];
            minStepVec = [minStepTemp(posDirn);maxStepTemp(negDirn);StepD(negDirn2 )];

            % Figure out the true max & min step sizes
            maxStep = min(maxStepVec);
            minStep = max(minStepVec);

            % Find new direction if we're getting too close to a constraint
            if (abs(minStep) < maxMinTol && abs(maxStep) < maxMinTol) || (minStep > maxStep)
                fprintf('Warning small step: %f %f\n',minStep,maxStep);
                continue;
            end

            % Pick a rand out of list_of_rands and use it to get a random
            % step distance
            stepDist = minStep + randVector(stepCount)*(maxStep-minStep);

            %fprintf('%d %d %d %f %f\n',i,pointCount,stepCount,minStep,maxStep);
            % Advance to the next point
            curPoint = prevPoint + stepDist*u;

            % Reproject the current point into the null space
            if mod (stepCount, 25) == 0
                if ~isempty(N)
                    curPoint = N* (N' * curPoint);
                end
                curPoint(fixed) = saveCoords;
            end

            % Print out amount of constraint violation
            if (mod(totalStepCount,1000)==0) && proc == 0 % only do for master thread
              fprintf(fidErr,'%10.8f\t%10.8f\t',max(curPoint-ub),max(lb-curPoint));
            end

            % Move points inside the space if reprojection causes problems
            overInd = (curPoint > ub);
            underInd = (curPoint < lb);
            if (sum(overInd)>0) || (sum(underInd)>0)
              curPoint(overInd) = ub(overInd);
              curPoint(underInd) = lb(underInd);
            end

            % Print out amount of constraint violation
            if (mod(totalStepCount,1000) == 0) && proc == 0 % only do for master thread
              fprintf(fidErr,'%10.8f\n',full(max(max(abs(A*curPoint)))));
            end

            prevPoint = curPoint;

            % Count the total number of steps
            totalStepCount = totalStepCount + 1;

        end % Steps per point

        % Final reprojection
        if ~isempty(N)
            curPoint = N* (N' * curPoint);
        end
        curPoint(fixed) = saveCoords;
        centerPoint = centerPoint + (curPoint - points(:,pointCount))/nPoints; % only swapping one point... it's trivial.

        % Swap current point in set of points.
        points(:,pointCount) = curPoint;
    end % Points per cycle

    if parallel % do this block if in parallel mode (regather points)
        if proc == 0 % if master
            % look for acknowledgements.
            display(strcat ('waiting for acknowledgement', num2str(i)));
            donewaiting = 0;
            while ~donewaiting
                donewaiting = 1;
                for k = 1:(numproc-1);
                    if exist(strcat('xxRoundAck',num2str(i), 'x', num2str(k),'.mat'), 'file') ~= 2
                        donewaiting = 0;
                    end
                end
                %display('waiting for acknowledgement');
                fprintf(1, '.');
                pause(.25)
            end
            % all other processes have received their information.  delete temporary files.
            fprintf(1, '\n');
            for k = 1:(numproc-1)
                delete (strcat('xxRoundAck', num2str(i), 'x', num2str(k), '.mat'));
            end
            delete(strcat('xxRound', num2str(i), '.mat'));
            delete(strcat('xxRoundDonePrint', num2str(i), '.mat'));

            % look for return values.
            display(strcat ('waiting for return files ', num2str(i)));
            donewaiting = 0;
            while ~donewaiting
                donewaiting = 1;

                for k = 1:(numproc-1);
                    if exist(strcat('xxDoneP',num2str(i), 'x', num2str(k),'.mat'), 'file') ~= 2
                        donewaiting = 0;
                    end
                end
                pause(.25)
                fprintf(1,'.');
            end
            fprintf(1, '\nAll processes finished.  reading\n');
            for k = 1:(numproc-1)
                load (strcat('xxDoneRound', num2str(i), 'x', num2str(k)), 'points2');
                r2 = subparts(nPoints, numproc, k);
                points(:,r2) = points2;
                delete (strcat('xxDoneRound', num2str(i), 'x', num2str(k), '.mat') );
                delete (strcat('xxDoneP',num2str(i), 'x', num2str(k), '.mat'));
            end
            centerPoint = mean(points, 2); % recalculate center point after gathering all data.
            display(strcat('done with round ', num2str(i)));
        else % if slave
            points2 = points(:, pointRange);
            save (strcat('xxDoneRound', num2str(i), 'x', num2str(proc)), 'points2');
            save (strcat('xxDoneP',num2str(i), 'x', num2str(proc)), 'blah');
        end
    end

    t1 = clock();
    fprintf('%10.0f s %d steps\n',etime(t1, t0),i*stepsPerPoint);
    if etime(t1, t0) > maxtime && proc == 0 % only master thread can terminate due to time limits.
        totalloops = i;
        break;
    end
end

if proc > 0 % slave threads terminate here.
    return;
end
points = points + offset*ones(1, nPoints);
sampleStruct.points = points;
if ~ isfield(sampleStruct, 'steps')
    sampleStruct.steps = 0;
end

sampleStruct.steps = sampleStruct.steps + stepsPerPoint*totalloops;
% flag for all other handles to terminate.
if parallel
    save('xxGlobalDone', 'blah');
    delete('xxMaster*.mat');
end

fclose(fidErr);

function out = subparts(nPoints, n, k)
    out = (floor(nPoints*k/n)+1) : (floor(nPoints*(k+1)/n));
return
