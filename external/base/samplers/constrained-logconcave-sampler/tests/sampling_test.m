% Known issue:
% We cannot sample netlib/ken_11 because we are not able to find all the
% collapsed dimension

clc

%% prepare the printout
print_opts = [];
print_opts.properties = {};
print_opts.properties{end+1} = struct('var', 'id', 'title', 'id', 'format', '5i');
print_opts.properties{end+1} = struct('var', 'name', 'title', 'name', 'format', '50s');
print_opts.properties{end+1} = struct('var', 'm', 'title', 'm', 'format', '8i');
print_opts.properties{end+1} = struct('var', 'n', 'title', 'n', 'format', '8i');
print_opts.properties{end+1} = struct('var', 'nnz', 'title', 'nnz', 'format', '10i');
print_opts.properties{end+1} = struct('var', 'mixing', 'title', 'mix (min)', 'format', '10f');
print_opts.properties{end+1} = struct('var', 'mixing_random', 'title', 'mix (random)', 'format', '10f');
print_opts.properties{end+1} = struct('var', 'p_val', 'title', 'p_val', 'format', '10f');
print_opts.properties{end+1} = struct('var', 'time', 'title', 'time', 'format', '10f');
output = {};
printTable([], print_opts);

%% Tests
success = 0; total_time = 0;
total_steps = 500;

l = problemList();
parfor k = 1:length(l)
%for k = 1
    % the warning setting should be inside in the loop for parfor
    warning('off', 'MATLAB:nearlySingularMatrix');
    warning('off', 'MATLAB:singularMatrix');
    warning('off', 'stats:adtest:OutOfRangePLow');
    warning('off', 'stats:adtest:OutOfRangePHigh');
    warning('off', 'stats:adtest:SmallSampleSize');
    warning('off', 'stats:adtest:NotEnoughData');
    warning('off', 'unifScaleTest:size');
    warning('off', 'unifScaleTest:nonzero_grad');
    
    o = {}; plan = [];
    o.total_time = tic;
    
    name = l{k};
    o.name = name;
    o.id = k;
    
    P0 = loadProblem(name);
    
    opts = [];
    try
        %warning('running k = %i\n', k);
        o.time = tic;
        plan = prepare(P0, opts);
        o.m = size(plan.domain.A,1); o.n = size(plan.domain.A,2); o.nnz = nnz(plan.domain.A);
        
        % if df ~= 0, make the distribution uniform and the body bounded
        if sum(abs(plan.ham.grad(plan.initial))) ~= 0
            P1 = Problem;
            c_new = plan.domain.T' * P0.df; 
            c_new(plan.domain.lb == -Inf) = c_new(plan.domain.lb == -Inf) - 1e-6 * mean(abs(c_new));
            c_new(plan.domain.ub == Inf) = c_new(plan.domain.ub == Inf) + 1e-6 * mean(abs(c_new));
            P1.Aeq = [plan.domain.A zeros(size(plan.domain.A,1),1); c_new' 1];
            P1.beq = [plan.domain.b; c_new'*plan.initial];
            K = max(abs(plan.initial));
            P1.lb = [max(plan.domain.lb,-2*K);0];
            P1.ub = [min(plan.domain.ub,2*K);+Inf];
            opts.scaleLP = 0;
            plan = prepare(P1, opts);
        end
        
        rng(1234); % to make the test reproducible
        out = sample(plan, total_steps);
        o.time = toc(o.time);
        
        s = out.samples;
        [ess] = effectiveSampleSize(s);
        
        v = randn(1,size(s,1));
        [ess_random] = effectiveSampleSize(v*s);
        
        o.p_val = unifScaleTest(out, plan, opts);
        
        o.mixing = total_steps/min(ess);
        o.mixing_random = total_steps/min(ess_random);
        
        if (o.mixing < 60 && o.p_val > 0.05)
        	success = success + 1;
        end
        
        total_time = total_time + o.mixing;
    catch s
        o.time = 0;
        warning(s.identifier, 'k = %i\n%s', k, s.message);
    end
    
    
    
    printTable(o, print_opts);
    output{k} = o;
end

fprintf('%i/%i success\n', success, numel(output))
fprintf('Total time: %f\n', total_time)