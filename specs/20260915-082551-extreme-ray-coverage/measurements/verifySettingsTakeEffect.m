% R4/T013: does each candidate setting TAKE EFFECT? The toolbox reports no algorithm
% (its gurobi Method label is off by one AND never returned), so effect is demonstrated
% from observables: the returned vertex itself, basis presence, and solve time.
initCobraToolbox(false); changeCobraSolver('gurobi','LP',0); rng(20260915,'twister');
root='/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';
d=load([root '/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat']); m=d.iDopaNeuroC;
N = m.S(:, m.SConsistentRxnBool);
mm = struct('S', N, 'SConsistentRxnBool', true(size(N,2),1));
obj = rand(size(N,1),1);        % ONE objective, reused for every setting

base = [];
fprintf('%-34s %-10s %-12s %-8s %-8s\n','setting','differs?','residual','basis','t(s)');
cands = { struct(), ...
          struct('Seed', 1), struct('Seed', 2), struct('Seed', 12345), ...
          struct('Method', 0), struct('Method', 1), struct('Method', 2), ...
          struct('NumericFocus', 3), struct('Presolve', 0), struct('Crossover', 0) };
names = {'(defaults)','Seed=1','Seed=2','Seed=12345','Method=0','Method=1','Method=2', ...
         'NumericFocus=3','Presolve=0','Crossover=0'};
for k = 1:numel(cands)
    try
        t=tic; [x, sol] = findExtremePool(mm, obj, 0, 1, 0, cands{k}); el=toc(t);
        hasB = isfield(sol,'basis') && ~isempty(sol.basis) && ...
               (isfield(sol.basis,'vbasis') || isfield(sol.basis,'cbasis'));
        if k==1, base = x; dif = 'baseline'; else
            dif = string(~isequal(full(base), full(x)));
        end
        fprintf('%-34s %-10s %-12.3e %-8d %-8.3f\n', names{k}, dif, norm(N'*x,inf), hasB, el);
    catch ME
        fprintf('%-34s REJECTED: %s\n', names{k}, ME.message(1:min(60,end)));
    end
end
