function [vs, output, v0] = computeRatioConfidenceInterval(v0, expdata, model, max_score, ratio)

% v0 - set of flux vectors to be used as initial guesses.  They may be
% valid or not.
% expdata - experimental data.
% model - The standard model.  Additional field .N (= null(S)) should also
% be provided.  This is a basis of the flux space.
% max score - maximum allowable data fit error.  
% ratio - which reactions to take the ratio of.  positive values indicate
% reactions in the numerator and negative values, reactions in the
% denominator.  

majorIterationLimit = 2000;  %max number of iterations
minorIterationLimit = 1e7;   % essentially infinity
diffInterval = 1e-5;         %gradient step size.
feasibilityTolerance = max_score/20; % how close you need to be to the max score.

x0 = model.N\v0; % back substitute
numpoints = size(v0,2);
numratios = size(ratio,2);

scores = zeros(numpoints,1);

tProb.user.expdata = expdata;
tProb.user.model = model;
for i = 1:numpoints
    scores(i) = errorComputation2(x0(:,i),tProb);
end

v0(:,scores > max_score) = fitC13Data(v0(:,scores > max_score),expdata,model);

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


scores = zeros(numpoints,1);
% compute scores for all points.
for i = 1:numpoints
    scores(i) = errorComputation2(x0(:,i),tProb);
end
valid_index = scores < max_score + feasibilityTolerance;
fprintf('found %d valid points\n', sum(valid_index));


c = 'errorComputation2'; 
c_L = 0; c_U = max_score; 

dc = 'errorComputation2_grad'; 
d2c = []; ConsPattern = [];
%pSepFunc = [];
x_min = []; x_max = []; f_opt = []; x_opt = [];
H = [];  HessPattern = []; pSepFunc = [];  fLowBnd = [];
Solver = 'snopt';

outputminv = 222*ones(numratios, numpoints);
outputminexitflag = -222*ones(numratios, numpoints);
outputminfinalscore = -222*ones(numratios, numpoints);
outputmaxv = -222*ones(numratios, numpoints);
outputmaxexitflag = -222*ones(numratios, numpoints);
outputmaxfinalscore = -222*ones(numratios, numpoints);
outputminstruct = cell(numratios, numpoints);
outputmaxstruct = cell(numratios, numpoints);
    
%iterate through directions
for i = 1:numratios
%for i = 10:200
    for j = -1:2:1 % max and min    
        ration = zeros(size(objective_coefficient(1,model)));
        ratiod = zeros(size(objective_coefficient(1,model)));
        for m = 1:size(ratio,1);
            if(ratio(m,i) > 0)
                ration = ration + objective_coefficient(m,model)*j;
            elseif(ratio(m,i) < 0)
                ratiod = ratiod + objective_coefficient(m,model);
            end
        end


        % initialize temp variables to make parfor work.
        v = j*222*ones(1,numpoints);
        exitflag = -222*ones(1,numpoints);
        finalscore = 222*ones(1,numpoints);
        ostruct = cell(1,numpoints);

        for k = 1:numpoints
            if exist('ttt.txt', 'file')
                fprintf('quitting due to file found\n');
                continue;
            end
            xinitial = x0(:,k);
%                 Prob  = lpconAssign(d, x_L, x_U, Name, xinitial,...
%                                       A, b_L, b_U,...
%                                       c, dc, d2c, ConsPattern, c_L, c_U,...
%                                       fLowBnd, x_min, x_max, f_opt,
%                                       x_opt);


            Prob = conAssign('ratioScore', 'ratioScore_grad', H, HessPattern, x_L, x_U, Name, xinitial, ...
                            pSepFunc, fLowBnd, ...
                            A, b_L, b_U, c, dc, d2c, ConsPattern, c_L, c_U, ...
                            x_min, x_max, f_opt, x_opt);
            %Prob.NumDiff = 2; % central diff
            %Prob.optParam.CentralDiff = 1e-5;
            %pause;
            Prob.user.expdata = expdata;
            Prob.user.model = model;
            Prob.user.ration = ration;
            Prob.user.ratiod = ratiod;

            Prob.user.max_error = max_score;
            Prob.user.diff_interval = diffInterval;
            Prob.user.useparfor = true;

            Prob.optParam.IterPrint = 0;
            %Prob.optParam.cTol = .1*feasibilityTolerance;

            Prob.PriLevOpt = 1;
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

output.minv = outputminv;
output.maxv = outputmaxv;
output.minexitflag = outputminexitflag;
output.maxexitflag = outputmaxexitflag;
output.minfinalscore = outputminfinalscore;
output.maxfinalscore = outputmaxfinalscore;
output.minstruct = outputminstruct;
output.maxstruct = outputmaxstruct;

vs = zeros(numratios, 2);
for i = 1:numratios
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
