clc

%% prepare the printout
print_opts = [];
print_opts.properties = {};
print_opts.properties{end+1} = struct('var', 'id', 'title', 'id', 'format', '5i');
print_opts.properties{end+1} = struct('var', 'name', 'title', 'name', 'format', '50s');
print_opts.properties{end+1} = struct('var', 'm', 'title', 'm', 'format', '8i');
print_opts.properties{end+1} = struct('var', 'n', 'title', 'n', 'format', '8i');
print_opts.properties{end+1} = struct('var', 'nnz', 'title', 'nnz', 'format', '10i');
print_opts.properties{end+1} = struct('var', 'nnz_new', 'title', 'nnz(new)', 'format', '10i');
print_opts.properties{end+1} = struct('var', 'opt', 'title', 'opt', 'format', '14e');
print_opts.properties{end+1} = struct('var', 'opt_new', 'title', 'opt(new)', 'format', '14e');
print_opts.properties{end+1} = struct('var', 'err', 'title', 'err', 'format', '10.3e');
print_opts.properties{end+1} = struct('var', 'total_time', 'title', 'time', 'format', '10f');
output = {};
printTable([], print_opts);

%% Tests
success = 0; total_time = 0;

l = problemList();
for k = 1:length(l)
    % the warning setting should be inside in the loop for parfor
    warning('off', 'MATLAB:nearlySingularMatrix');
    warning('off', 'MATLAB:singularMatrix');
    
    o = {};
    o.total_time = tic;
    
    name = l{k};
    o.name = name;
    
    o.id = k; o.opt = NaN; o.opt_new = NaN;
    opts = optimoptions('linprog','Display','none');%,'Algorithm','interior-point');
    
    try
        o.time = tic;
        Pro = loadProblem(name);
        P0 = Polytope(Pro);
        o.time = toc(o.time);
        
        x0 = linprog(P0.T' * Pro.df,[],[],P0.A,P0.b,P0.lb,P0.ub,opts);
        if numel(x0) ~= 0
            o.opt = Pro.df' * (P0.T * x0 + P0.y);
        end

        o.time_new = tic;
        P1 = Polytope(Pro);
        P1.simplify();
        o.time_new = toc(o.time_new);

        x1 = linprog(P1.T' * Pro.df,[],[],P1.A,P1.b,P1.lb,P1.ub,opts);
        if numel(x1) ~= 0
            o.opt_new = Pro.df' * (P1.T * x1 + P1.y);
        end

        o.err = abs(o.opt-o.opt_new)/(abs(o.opt)+1e-4);

        if (o.err < 1e-4)
            success = success + 1;
        end
        
        o.m = size(P0.A,1); o.n = size(P0.A,2); o.nnz = nnz(P0.A);
        o.m_new = size(P1.A,1); o.n_new = size(P1.A,2); o.nnz_new = nnz(P1.A);
    catch s
        warning(s.identifier, 'k = %i\n%s', k, s.message);
    end
    
    % print out
    o.total_time = toc(o.total_time);
    total_time = total_time + o.total_time;
    
    printTable(o, print_opts);
    output{k} = o;
end

fprintf('%i/%i success\n', success, numel(output))
fprintf('Total time: %f\n', total_time)