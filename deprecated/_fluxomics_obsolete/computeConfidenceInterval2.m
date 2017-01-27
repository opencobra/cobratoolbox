function [vs, output, v0] = computeConfidenceInterval2(v0, expdata, model, max_score)

majorIterationLimit = 2000;  %max number of iterations
minorIterationLimit = 1e7;   % essentially infinity
diffInterval = 1e-5;         %gradient step size.
feasibilityTolerance = max_score/20; % how close you need to be to the max score.

v0 = fitC13Data(v0,expdata,model);

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


nalpha = size(model.N, 2);
x_L = -1000*ones(nalpha,1);
x_U = 1000*ones(nalpha,1);
Name = 't2';
[A, b_L, b_U] = defineLinearConstraints(model);


numpoints = size(x0,2);
scores = zeros(numpoints,1);

% compute scores for all points.
tProb.user.expdata = expdata;
tProb.user.model = model;
for i = 1:numpoints
    scores(i) = errorComputation2(x0(:,i),tProb);
end
valid_index = scores < max_score + feasibilityTolerance;
fprintf('found %d valid points\n', sum(valid_index));

x0_valid = x0(:,valid_index);
x0_invalid = x0;
scores_valid = scores(valid_index);

c = []; c_L = []; c_U = []; HessPattern = [];
f = 'errorComputation2'; 
g = 'errorComputation2_grad'; H = [];
%c = 'errorComputation2';
%c_L = 0;
%c_U = max_score; 

dc = []; d2c = []; ConsPattern = [];
pSepFunc = [];
x_min = []; x_max = []; f_opt = []; x_opt = [];
Solver = 'snopt';


% pre-compute unnecesary directions.  
% if checkedbefore(i) ~= 0 then direction i is redundant
% checkedbefore(i) < 0 means that the sign of all computations should be
% switched.
checkedbefore = zeros(length(model.lb),1);
for i = 2:length(model.lb)
    d = objective_coefficient(i, model);
    for j = 1:i-1
        dj = objective_coefficient(j, model);
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
numpoints = size(x0, 2);

outputminv = 222*ones(length(model.lb), numpoints);
outputminexitflag = -222*ones(length(model.lb), numpoints);
outputminfinalscore = -222*ones(length(model.lb), numpoints);
outputmaxv = -222*ones(length(model.lb), numpoints);
outputmaxexitflag = -222*ones(length(model.lb), numpoints);
outputmaxfinalscore = -222*ones(length(model.lb), numpoints);
outputminstruct = cell(length(model.lb), numpoints);
outputmaxstruct = cell(length(model.lb), numpoints);
    
%iterate through directions
parfor i = 1:length(model.lb)
    if checkedbefore(i) ~= 0
        continue;
    end
    for j = -1:2:1 % max and min    
        d = objective_coefficient(i,model)*j;
        lbprob = lpAssign(d, A, b_L, b_U, x_L, x_U, [], 'linear_bound', [],[],[],[],[],[],[]);
        lbresult = tomRun('cplex', lbprob, 0);
        fLowBnd = lbresult.f_k;
        fprintf('reaction %d of %d, direction %d, lowerbound %f\n', i,length(model.lb), j, fLowBnd);

        % short circuit if x0 already close to a bound.
        obj1 = d'*x0_valid;
        if(any(abs(obj1-fLowBnd)<.0001))
            display('short circuiting');
            [nil, index1] = min(obj1);
            if (j > 0)
                outputminv(i,:) = j*fLowBnd; % multiply by j to correct sign.
                outputminexitflag(i,:) = 111;
                outputminfinalscore(i,:) = scores_valid(index1);
            else
                outputmaxv(i,:) = j*fLowBnd; % multiply by j to correct sign.
                outputmaxexitflag(i,:) = 111;
                outputmaxfinalscore(i,:) = scores_valid(index1);
            end
        else % gotta actually do the computation.
            all_ds = d'*x0_invalid;
            [nil, index2] = sort(all_ds);
            
            % initialize temp variables to make parfor work.
            v = j*222*ones(1,numpoints);
            exitflag = -222*ones(1,numpoints);
            finalscore = 222*ones(1,numpoints);
            ostruct = cell(1,numpoints);
            
            for k = 1:length(index2)
                if exist('ttt.txt', 'file')
                    fprintf('quitting due to file found\n');
                    continue;
                end
                xinitial = x0_invalid(:,index2(k));
%                 Prob  = lpconAssign(d, x_L, x_U, Name, xinitial,...
%                                       A, b_L, b_U,...
%                                       c, dc, d2c, ConsPattern, c_L, c_U,...
%                                       fLowBnd, x_min, x_max, f_opt, x_opt);
                Prob = conAssign(f, g, H, HessPattern, x_L, x_U, Name, xinitial, ...
                                pSepFunc, fLowBnd, ...
                                A, b_L, b_U, c, dc, d2c, ConsPattern, c_L, c_U, ...
                                x_min, x_max, f_opt, x_opt);
                %Prob.NumDiff = 2; % central diff
                %Prob.optParam.CentralDiff = 1e-5;
                %pause;
                Prob.user.expdata = expdata;
                Prob.user.model = model;
                Prob.user.objective = d;
                Prob.user.max_error = max_score;
                Prob.user.diff_interval = diffInterval;
                Prob.user.multiplier = 10;
                
                Prob.optParam.IterPrint = 0;
                %Prob.optParam.cTol = .1*feasibilityTolerance;
                
                Prob.PriLevOpt = 0;
                Prob.SOL.PrintFile = strcat('temp/snoptp', num2str(i), 'x', num2str(j), 'x', num2str(k),'.txt');
                Prob.SOL.SummFile = strcat('temp/snopts', num2str(i), 'x', num2str(j), 'x', num2str(k),'.txt');
                Prob.SOL.optPar(35) = majorIterationLimit; %This is major iteration count.
                Prob.SOL.optPar(30) = minorIterationLimit; %total iteration limit;
                %Prob.SOL.optPar(11) = feasibilityTolerance; % feasibility tolerance

                Result = tomRun(Solver, Prob, 5);
                tscore = errorComputation2(Result.x_k, tProb);
                tbest = Result.f_k;

                fprintf('reaction %d (%d), x %d; x=%f (%f); score=%f (%f)\n', i,length(model.lb),j, tbest,fLowBnd, tscore, max_score)

                v(k) = j*tbest;
                exitflag(k) = Result.Inform;
                finalscore(k) = tscore;
                ostruct{k} = Result;
            end
            if (j > 0) %minimizing
                outputminv(i,:) = v; % multiply by j to correct sign.
                outputminexitflag(i,:) = exitflag;
                outputminfinalscore(i,:) = finalscore;
                outputminstruct(i,:) = ostruct;
            else
                outputmaxv(i,:) = v; % multiply by j to correct sign.
                outputmaxexitflag(i,:) = exitflag;
                outputmaxfinalscore(i,:) = finalscore;
                outputmaxstruct(i,:) = ostruct;
            end
        end
    end
end

output.minv = outputminv;
output.maxv = outputmaxv;
output.minexitflag = outputminexitflag;
output.maxexitflag = outputmaxexitflag;
output.minfinalscore = outputminfinalscore;
output.maxfinalscore = outputmaxfinalscore;
output.minstruct = outputminstruct;
output.maxstruct = outputmaxstruct;

for i = 1:length(model.lb)
    if checkedbefore(i) > 0 %short circuit if seen before.
        output.minv(i,:) = output.minv(checkedbefore(i),:);
        output.maxv(i,:) = output.maxv(checkedbefore(i),:);
        output.minexitflag(i,:) = output.minexitflag(checkedbefore(i),:);
        output.maxexitflag(i,:) = output.maxexitflag(checkedbefore(i),:);
        output.minfinalscore(i,:) = output.minfinalscore(checkedbefore(i),:);
        output.maxfinalscore(i,:) = output.maxfinalscore(checkedbefore(i),:);
        output.minstruct(i,:) = output.minstruct(checkedbefore(i),:);
        output.maxstruct(i,:) = output.maxstruct(checkedbefore(i),:);
    elseif checkedbefore(i) < 0
        output.minv(i,:) = -output.maxv(-checkedbefore(i),:);
        output.maxv(i,:) = -output.minv(-checkedbefore(i),:);
        output.minexitflag(i,:) = output.maxexitflag(-checkedbefore(i),:);
        output.maxexitflag(i,:) = output.minexitflag(-checkedbefore(i),:);
        output.minfinalscore(i,:) = output.maxfinalscore(-checkedbefore(i),:);
        output.maxfinalscore(i,:) = output.minfinalscore(-checkedbefore(i),:);
        output.minstruct(i,:) = output.maxstruct(-checkedbefore(i),:);
        output.maxstruct(i,:) = output.minstruct(-checkedbefore(i),:);
    end
end

vs = zeros(length(model.lb), 2);
for i = 1:length(model.lb)
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
