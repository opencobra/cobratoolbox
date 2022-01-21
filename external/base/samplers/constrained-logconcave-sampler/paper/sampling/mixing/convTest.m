function [ mt_avg, mt_cond, step_time ] = convTest( P, walkType, testType, options)
%CONVTEST The input should be an isotropic convex body specified by {P.A*x >=
%P.b} This function will take steps of the random wall until the ratio
%lambda_max / lambda_min is <= s_cutoff * target_ratio

dim = getDimP(P);
% dim = size(P.A,2);
max_steps = 8*dim^2;

if nargin < 2
    error('Must specify type of walk');
end

if nargin < 3
    testType = 'halfspaceGood';
end

if nargin < 4
    options = [];
end

% if strcmp(walkType,'CHAR')==1
%     
%     %switch from Ax>=b to Ax<=b
%     Q = P;
%     Q.A = -Q.A;
%     Q.b = -Q.b;
%     
%     K = ConvexBody(Q,[],.1,'');
% end

if strcmp(testType,'halfspaceGood')==1
    
    if ~isfield(options,'num_samples')
        if strcmp(walkType,'HMC')==1
            options.numSamples = 500;
        else
            options.numSamples = 100*dim+200;
        end
    end
    tic;
    options.walkType = walkType;
    options.numSteps = 1;
    samples = sample(P,options);
%     samples = zeros(dim,options.numSamples);
%     
%     
%     tic;
%     if strcmp(walkType,'HMC')==1
%         %         ham = Hamiltonian(P.A,P.b,P.c);
%         samples = sample(P,options);
%     else
%         x = P.p;
%         if strcmp(walkType,'CHAR')==1
%             resetSlacks(K,x);
%         end
%         samples(:,1) = x;
%         %     h = waitbar(0,'Computing samples...');
%         for i=1:options.numSamples-1
%             if strcmp(walkType,'CHAR')==1
%                 samples(:,i+1) = getNextPoint(K,samples(:,i),0,1);
%             end
%         end
%     end
    step_time = toc/(options.numSamples-1);
    
    if isfield(P,'p')
        [mt_avg,~,mt_cond] = halfspaceTest(samples,P.p);
    else
        [mt_avg,~,mt_cond] = halfspaceTest(samples);
    end
    
    
elseif strcmp(testType,'covariance')==1
    
    s_cutoff = 1.5;
    
    step_size = 1;
    
    target_ratio=1;
    
    steps = 0;
    lambda_max = 10;
    lambda_min = 1;
    x = P.p;
    if strcmp(walkType,'CHAR')==1
        resetSlacks(K,x);
    end
    
    samples = zeros(dim,max_steps);
    
    while (steps < dim || lambda_max / lambda_min > s_cutoff*target_ratio) && steps <= max_steps
        steps = steps+1;
        
        if strcmp(walkType,'HMC')==1
            options.trajLength = 0.1;
            [x] = walkHMC(P, step_size,x);
        elseif strcmp(walkType,'CHAR')==1
            [x] = getNextPoint(K,x,0,1);
        end
        samples(:,steps) = x;
        if steps>=dim && mod(steps,dim)==0
            s = svd(samples(:,1:steps));
            %        fprintf('hi\n');
            %        s = diag(S);
            lambda_max = max(s);
            lambda_min = min(s);
            
            if mod(steps,20*dim)==0
                fprintf('Taken %d steps, s_ratio =%e\n', steps*step_size, lambda_max/lambda_min);
            end
        end
        
    end
    
    total_steps = steps*step_size;
    
    mixing_time = total_steps/dim;
    
elseif strcmp(testType,'halfspace')==1
    
    trials = 5;
    step_size = 1;
    
    %get an estimate for the centroid if it's not given
    if isfield(P,'p') && ~isempty(P.p)
        mu = P.p;
    else
        %need to implement these functions
        mu = getCentroid(getInteriorPoint(P));
    end
    
    total_steps = 0;
    
    for i=1:trials
        
        x = mu;
        if strcmp(walkType,'CHAR')==1
            resetSlacks(K,x);
        end
        SCT = newSCT('sliding_window', dim, eps,0);
        
        while ~SCT.converged
            %             if mod(SCT.steps,20)==0
            %                 fprintf('Current: %e\n', max(SCT.last_W)/min(SCT.last_W));
            %             end
            if strcmp(walkType,'HMC')==1
                [x] = walkHMC(P, step_size,x);
            elseif strcmp(walkType,'CHAR')==1
                [x] = getNextPoint(K,x,0,1);
            end
            SCT = updateSCT(SCT,x-mu);
        end
        total_steps = total_steps + SCT.steps;
        fprintf('Trial %d done: %d steps\n', i, SCT.steps);
    end
    mixing_time = total_steps/trials;
else
    error('Test not defined');
end

end


function [ SCT ] = newSCT(type, dim, eps, to_plot)
%create the convergence test for generating a random sample

if strcmp(type,'sliding_window')==1
    %creating a new sliding window test
    SCT.W = 50;
    SCT.min_val=0;
    SCT.max_val=1;
    SCT.min_index=SCT.W;
    SCT.max_index=SCT.W;
    SCT.last_W = zeros(SCT.W,1);
    SCT.index = 1;
    %a random halfspace
    SCT.h = randn(dim,1);
    %the number which lie on one side of the halfspace
    SCT.h_num = 0;
    %number of steps we've taken
    SCT.steps = 0;
    %whether this test has converged
    SCT.converged = 0;
    SCT.eps = eps;
    SCT.type = 'sliding_window';
elseif strcmp(type,'mix')==1
    %creating a new test, mix for 8n^2 steps
    SCT.num_steps = 0;
    SCT.target_steps = 8*dim^2;
    SCT.converged = 0;
else
    error('Convergence test %s undefined.\n', type);
end

SCT.plotting = to_plot;

end

function [SCT] = updateSCT(SCT, pt)

if strcmp(SCT.type,'sliding_window')==1
    SCT.h_num = SCT.h_num + (dot(pt,SCT.h)>0);
    SCT.steps = SCT.steps + 1;
    val = SCT.h_num/SCT.steps;
    SCT.last_W(SCT.index)=val;
    if val<=SCT.min_val
        SCT.min_val=val;
        SCT.min_index=SCT.index;
    elseif SCT.min_index==SCT.index
        [SCT.min_val,SCT.min_index]=min(SCT.last_W);
    end
    
    if val>=SCT.max_val
        SCT.max_val=val;
        SCT.max_index=SCT.index;
    elseif SCT.max_index==SCT.index
        [SCT.max_val,SCT.max_index]=max(SCT.last_W);
    end
    
    %check to see if the last W points are within sufficiently
    %small relative error. if so, stop this volume phase
    %     SCT.plot_data = (SCT.max_val-SCT.min_val)/min(SCT.max_val,1-SCT.max_val);
    SCT.plot_data = val;
    if (SCT.max_val-SCT.min_val)/min(SCT.max_val,1-SCT.max_val)<=SCT.eps
        SCT.converged=1;
    end
    
    SCT.index = mod(SCT.index,SCT.W)+1;
elseif strcmp(SCT.type,'mix')==1
    SCT.num_steps = SCT.num_steps+1;
    if SCT.num_steps == SCT.target_steps
        SCT.converged = 1;
    end
    SCT.plot_data = SCT.num_steps;
else
    error('Convergence test %s undefined.\n', type);
end

end
