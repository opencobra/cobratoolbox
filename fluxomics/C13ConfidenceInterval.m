function [vs, output, v0] = C13ConfidenceInterval(v0, expdata, model, max_score, directions, majorIterationLimit)

% v0 - set of flux vectors to be used as initial guesses.  They may be
% valid or not.
% expdata - experimental data.
% model - The standard model.  Additional field .N (= null(S)) should also
% be provided.  This is a basis of the flux space.
% max score - maximum allowable data fit error.  
% directions (optional) - ones and zeros of which reactions to compute (size = n
% x 1).  
%   OR
% numbers of reactions to use  aka.  [1;5;7;8;200]
%   OR
% reaction strings  aka.  {'GPK', 'PGL'}.  Ratios are possible with this
% input only.  Default = [] meaning do FVA with no ratios.
% majorIterationLimit (optional) - default = 10000
if nargin < 5
    directions = ones(size(v0,1),1);
end
if isempty(directions)
    directions = ones(size(v0,1),1);
end
t_start = clock;
printLevel = 3; 
if nargin < 6
    majorIterationLimit = 1000;  %max number of iterations
end
diffInterval = 1e-5;         %gradient step size.
feasibilityTolerance = max_score/20; % how close you need to be to the max score.
logdirectory = strcat('temp', filesep);

% isratio(i):  >0 indicates not a ratio and points to reaction#
%              <0 indicates -numerator of ratio fraction.  In this case,
%              denom(i) stores the denominator
%
denom = zeros(size(directions));
if isnumeric(directions) %cannot be an actual ratio
    if max(directions) == 1
        isratio = find(directions);
    else
        isratio = directions;
    end
else % might be a ratio.  Gotta process strings
    isratio = zeros(size(directions));
    for i = 1:length(directions)
        if findstr(directions{i}, '/')
            [rxn1,rest] = strtok(directions{i}, '/');
            rxnID = findRxnIDs(model,rxn1);
            if rxnID == 0
                display('unable to process rxn from list');
                display(directions{i});
                return;
            else
                isratio(i) = -rxnID;
            end
            rxn2 = rest(2:end);
            rxnID = findRxnIDs(model,rxn2);
            if rxnID == 0
                display('unable to process rxn from list');
                display(rest(2:end));
                return;
            else
                denom(i) = rxnID;
            end
        else
            rxnID = findRxnIDs(model,directions{i});
            if rxnID == 0
                display('unable to process rxn from list');
                display(directions{i});
                return;
            else
                isratio(i) = rxnID;
            end
        end
    end
end

numdirections = length(isratio);
numpoints = size(v0,2);

numiterations = numdirections*numpoints*2; % total number of iterations.

x0 = model.N\v0; % back substitute
scores = zeros(numpoints,1);

tProb.user.expdata = expdata;
tProb.user.model = model;
for i = 1:numpoints
    scores(i) = errorComputation2(x0(:,i),tProb);
end

% fit points if they are not currently feasible
v0(:,scores> max_score) = fitC13Data(v0(:,scores > max_score),expdata,model, majorIterationLimit);

if ~isfield(model, 'N')
   model.N = null(model.S); 
end

x0 = model.N\v0; % back substitute

% safety check:
if (max(abs(model.S*v0))> 1e-6)
    display('v0 not quite in null space');
    pause;
end
if(max(abs(model.N*x0 - v0)) > 1e-6)
    display('null basis is weird');
    pause;
end

Name = 't2';
nalpha = size(model.N, 2);

x_L = -1000*ones(nalpha,1);
x_U = 1000*ones(nalpha,1);
[A, b_L, b_U] = defineLinearConstraints(model);

scores = zeros(numpoints,1);
% compute scores for all points.
for i = 1:numpoints
    scores(i) = errorComputation2(x0(:,i),tProb);
end
valid_index = scores < max_score + feasibilityTolerance;
fprintf('found %d valid points\n', sum(valid_index));

x0_valid = x0(:,valid_index);
x0_invalid = x0;
scores_valid = scores(valid_index);


% pre-compute unnecesary directions.  
% if checkedbefore(i) ~= 0 then direction i is redundant
% if checkedbefore(i) = j then direction i and j are identical and do not
% need to be recomputed.  
% checkedbefore(i) = j < 0 means that direction j is the same as i except
% for a sign switch.

checkedbefore = zeros(length(isratio),1);
for i = 2:length(isratio)
    if(isratio(i) < 0) % meaning it actually IS a ratio and no simplification possible
        continue
    end
    d = objective_coefficient(isratio(i), model);
    for j = 1:i-1
        if(isratio(j) < 0) % meaning it actually IS a ratio and no simplification possible
            continue
        end
        dj = objective_coefficient(isratio(j), model);
        if max(abs(dj - d))< 1e-4
            checkedbefore(i) = j;
            break;
        elseif max(abs(dj + d))< 1e-4
            checkedbefore(i) = -j;
            break;
        end
    end
end

% initialize variables;
outputv = 222*ones(numiterations,1);
outputexitflag = -222*ones(numiterations,1);
outputfinalscore = -222*ones(numiterations,1);
outputstruct = cell(numiterations,1);

csense = '';
for mm = 1:length(b_L),csense(mm,1) = 'L';end
for mm = 1:length(b_L),csense(mm+length(b_L),1) = 'G';end

fLowBnds = zeros(length(isratio), 2); %initialize but fill in later.
for rxn = 1:length(isratio)
    for direction = -1:2:1
        if isratio(rxn) < 0
            ration = objective_coefficient(-isratio(rxn),model);
            ratiod = objective_coefficient(denom(rxn),model);
            
            % in case RXN is a ratio
            Result = solveCobraNLP(...
                struct('lb', x_L, 'ub', x_U,...
                'name', Name,...
                'A', A,...
                'b_L', b_L, 'b_U', b_U,...
                'objFunction', 'ratioScore', 'g', 'ratioScore_grad',...
                'userParams', struct(...
                     'ration', direction*ration, 'ratiod', ratiod,... % set direction here too.
                     'diff_interval', diffInterval,'useparfor', true)...
                ),...
                'printLevel', 1, ...
                'iterationLimit', 1000);
        else
            d = objective_coefficient(isratio(rxn),model);
            Result = solveCobraLP(...
             struct('A', [A;A],'b',[b_U;b_L],'csense', csense, ...
                    'c', direction*d, ...
                    'lb', x_L,'ub', x_U, ...
                    'osense', 1),...
                    'feasTol',1e-7,'optTol',1e-7);
            if Result.stat ~= 1
                Result
                pause
            end
        end
        fLowBnds(rxn, (direction+3)/2) = direction*Result.obj; % fill in
    end
end

if ~exist (logdirectory, 'dir')
    if ~mkdir(logdirectory)
        display('unable to create logdirectory');
        return;
    end
end
clear d
%iterate through directions
parfor itnum = 1:numiterations
    if exist('ttt.txt', 'file') % abort w/o crashing if file 'ttt.txt' found in current directory
        fprintf('quitting due to file found\n');
        continue;
    end
    [rxn, direction, point] = getValues(itnum, numpoints); % translate itnum to rxn, direction and point
    % direction == 1 means minimize.  direction == -1 means maximize
    % (opposite of what you might think.
    
    if checkedbefore(rxn) ~= 0 %if this reaction maps to a previous reaction, we can skip
        continue;
    end
    
    
    fLowBnd = fLowBnds(rxn, (direction+3)/2); %get the absolute bound in the space w/o regards to C13 constraints.
    fprintf('reaction %d of %d, direction %d, lowerbound %f point %d of %d\n', rxn ,length(isratio), direction, fLowBnd, point, numpoints);
     % short circuit if x0 already close to a bound.
    if isratio(rxn) > 0
        di = objective_coefficient(isratio(rxn),model);
        obj1 = di'*x0_valid;
    else
        rationi = objective_coefficient(-isratio(rxn),model);
        ratiodi = objective_coefficient(denom(rxn),model);
        obj1 = (rationi'*x0_valid) ./ (ratiodi'*x0_valid);
    end

    if(any(abs(obj1-fLowBnd)<.0001))
        display('short circuiting');
        [nil, min_index] = min(obj1);
        outputv(itnum,1) = fLowBnd; % multiply by direction to correct sign.
        outputexitflag(itnum,1) = 111;
        outputfinalscore(itnum,1) = scores_valid(min_index);

    else % gotta actually do the computation.
        xinitial = x0_invalid(:,point);
        if isratio(rxn) > 0
            NLPsolution = solveCobraNLP(...
                struct('x0', xinitial, ...
                'lb', x_L, 'ub', x_U,...
                'name', Name,...
                'A', A, 'b_L', b_L, 'b_U', b_U,...
                'd', 'errorComputation2', 'dd', 'errorComputation2_grad',...
                'd_L', 0, 'd_U', max_score,...
                'c', di*direction, ... % direction of optimization
                'userParams', struct(...
                     'expdata', expdata,'model', model,'max_error', max_score,...
                     'diff_interval', diffInterval,'useparfor', true)...
                ),...
                'printLevel', printLevel, ...
                ...%'intTol', 1e-7, ...
                'iterationLimit', majorIterationLimit, ...
                'logFile', strcat(logdirectory, 'ci_', num2str(rxn),'x',num2str(direction),'x', point, '.txt'));
        else
            NLPsolution = solveCobraNLP(...
                struct('x0', xinitial, ...
                'lb', x_L, 'ub', x_U,...
                'name', Name,...
                'A', A, 'b_L', b_L, 'b_U', b_U,...
                'd', 'errorComputation2', 'dd', 'errorComputation2_grad',...
                'd_L', 0, 'd_U', max_score,...
                'objFunction', 'ratioScore', 'g', 'ratioScore_grad',...
                'userParams', struct(...
                     'expdata', expdata,'model', model,'max_error', max_score,...
                     'ration', direction*rationi,...
                     'ratiod', ratiodi,...
                     'diff_interval', diffInterval,'useparfor', false)...
                ),...
                'printLevel', printLevel, ...
                ...%'intTol', 1e-7, ...
                'iterationLimit', majorIterationLimit, ...
                'logFile', strcat(logdirectory, 'ci_', num2str(rxn),'x',num2str(direction),'x', point, '.txt'));
        end
       
        tscore = errorComputation2(NLPsolution.full, tProb);
        tbest = NLPsolution.obj;

        fprintf('reaction %d (%d), x %d; x=%f (%f); score=%f (%f)\n', rxn, length(isratio),direction, tbest,fLowBnd, tscore, max_score)

        outputv(itnum,1) = direction*tbest; % multiply by direction to correct sign.
        outputexitflag(itnum,1) = NLPsolution.origStat;
        outputfinalscore(itnum,1) = tscore;
        outputstruct{itnum,1} = NLPsolution;
    end
end

for itnum = 1:numiterations
    [rxn, direction, point] = getValues(itnum,numpoints);
    if direction == 1;
        output.minv(rxn,point) = outputv(itnum);
        output.minexitflag(rxn,point) = outputexitflag(itnum);
        output.minfinalscore(rxn,point) = outputfinalscore(itnum);
        output.minstruct(rxn,point) = outputstruct(itnum);
    else
        output.maxv(rxn,point) = outputv(itnum);
        output.maxexitflag(rxn,point) = outputexitflag(itnum);
        output.maxfinalscore(rxn,point) = outputfinalscore(itnum);
        output.maxstruct(rxn,point) = outputstruct(itnum);
    end
end

for i = 1:length(isratio)
    if checkedbefore(i) > 0 %short circuit if seen before.
        output.minv(i) = output.minv(checkedbefore(i));
        output.maxv(i) = output.maxv(checkedbefore(i));
        output.minexitflag(i) = output.minexitflag(checkedbefore(i));
        output.maxexitflag(i) = output.maxexitflag(checkedbefore(i));
        output.minfinalscore(i) = output.minfinalscore(checkedbefore(i));
        output.maxfinalscore(i) = output.maxfinalscore(checkedbefore(i));
        output.minstruct(i) = output.minstruct(checkedbefore(i));
        output.maxstruct(i) = output.maxstruct(checkedbefore(i));
    elseif checkedbefore(i) < 0
        output.minv(i) = -output.maxv(-checkedbefore(i));
        output.maxv(i) = -output.minv(-checkedbefore(i));
        output.minexitflag(i) = output.maxexitflag(-checkedbefore(i));
        output.maxexitflag(i) = output.minexitflag(-checkedbefore(i));
        output.minfinalscore(i) = output.maxfinalscore(-checkedbefore(i));
        output.maxfinalscore(i) = output.minfinalscore(-checkedbefore(i));
        output.minstruct(i) = output.maxstruct(-checkedbefore(i));
        output.maxstruct(i) = output.minstruct(-checkedbefore(i));
    end
end

vs = zeros(length(isratio), 2);
for i = 1:length(isratio)
    validindex = output.minfinalscore(i,:) < max_score + feasibilityTolerance;
    if any(validindex)
        vs(i,1) = min(output.minv(i,validindex));
    else
        vs(i,1) = 222;
    end
    validindex = output.maxfinalscore(i,:) < max_score + feasibilityTolerance;
    if any(validindex)
        vs(i,2) = max(output.maxv(i,validindex));
    else
        vs(i,2) = -222;
    end   
end

elapsed_time = etime(clock, t_start)
return;



% function [index] = getIndex(rxn, direction, point, numpoints)
% % point goes from 1 .. NUMPOINTS
% % rxn goes from 1 .. NUMRXNS
% % direction is -1 or 1
% % index goes from 1 to NUMPOINTS*NUMRXNS*2
% 
% rxn = rxn - 1;
% point = point -1;
% direction = (direction + 1)/2; 
% 
% 
% index = rxn*numpoints*2 + direction*numpoints + point;
% index = index+1;
% 
% return;

function [rxn, direction, point] = getValues(index, numpoints)
% point goes from 1 .. NUMPOINTS
% rxn goes from 1 .. NUMRXNS
% direction is -1 or 1
% index goes from 1 to NUMPOINTS*NUMRXNS*2
index = index - 1;
point = mod(index, numpoints);
index = index - point;
index = index/numpoints;
direction = mod(index,2);
index = index - direction;
index = index/2;
rxn = index;

point = point +1; % remap to 1..NUMPOINTS
direction = direction*2-1; % remap to -1,1
rxn = rxn+1; % remap to 1 .. number of rxns;
return;

% function that returns the proper objective coefficient for each reaction
% takes into account the reversibility of reactinos etc.
function [d] =  objective_coefficient(i, model)
d = zeros(length(model.lb),1);
d(i) = 1;
if (model.match(i))
    d(model.match(i)) = -1;
end
d = (d'*model.N)'; % transform to null space;
return
