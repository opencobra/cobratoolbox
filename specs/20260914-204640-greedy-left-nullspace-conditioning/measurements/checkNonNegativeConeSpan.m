% Does the NON-NEGATIVE cone span the whole left nullspace, or is part of it
% unreachable with non-negative weights?
initCobraToolbox(false); changeCobraSolver('gurobi','LP',0);
d=load('/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat');
N = d.iDopaNeuroC.S(:, d.iDopaNeuroC.SConsistentRxnBool);
[m,n] = size(N); [~, r] = getNullSpace(N',0);
fprintf('N %d x %d, rank %d, dim ker(N'''') = %d\n', m, n, r, m-r);

% Is there a STRICTLY POSITIVE x with x'*N = 0 ?  (stoichiometric consistency)
% Feasibility LP: N'*x = 0, x >= 1.
LP.A = sparse(N'); LP.b = zeros(n,1); LP.csense = repmat('E', n, 1);
LP.lb = ones(m,1); LP.ub = inf(m,1); LP.c = zeros(m,1); LP.osense = 1;
sol = solveCobraLP(LP, 'printLevel', 0);
fprintf('strictly positive left-nullspace vector exists: stat=%d (%s)\n', sol.stat, sol.origStat);
if sol.stat == 1
    x = sol.full;
    fprintf('  min(x) = %.4g   max(x) = %.4g   ||x''N||_inf = %.3e\n', min(x), max(x), norm(N'*x, inf));
    fprintf('  => span(K) = ker(N'''') : ALL %d directions reachable with x >= 0\n', m-r);
else
    fprintf('  => no strictly positive conservation vector; some directions need negative weights\n');
end
