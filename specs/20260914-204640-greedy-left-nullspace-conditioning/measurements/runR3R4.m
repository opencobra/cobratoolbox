% R3: derive the accuracy target and VALIDATE it by controlled perturbation.
% R4: locate the regime boundary. Tasks T009, T010.
rng(20260914, 'twister');
d = load('/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat');
N = d.iDopaNeuroC.S(:, d.iDopaNeuroC.SConsistentRxnBool);
nMet = size(N, 1);
Lm = load(fullfile(fileparts(mfilename('fullpath')), 'R1c_mosek.mat'), 'Zpos'); L0 = Lm.Zpos;

% ---- quantities the derivation needs ----
sN = svd(full(N));
rN = sum(sN > eps*max(size(N))*sN(1));
sigMinPlusN = sN(rN);
normN = norm(full(N), 2); normL = norm(full(L0), 2);
M0 = [N, -speye(nMet); sparse(size(L0,1), size(N,2)), L0];
sM = svd(full(M0)); sig1M = sM(1);
r = size(M0,1) - size(L0,1);
tauMin = eps*max(size(M0));

fprintf('=== R3 inputs ===\n');
fprintf('  sigma_1(M)        = %.6e\n', sig1M);
fprintf('  sigma_min+(N)     = %.6e   (rank %d of %d)\n', sigMinPlusN, rN, min(size(N)));
fprintf('  ||N||_2           = %.6e\n', normN);
fprintf('  ||L||_2           = %.6e\n', normL);
fprintf('  tau_min = eps*max(size(M)) = %.6e\n', tauMin);

target2 = tauMin * sig1M * sigMinPlusN;
fprintf('\n=== R3 DERIVED TARGET ===\n');
fprintf('  ||L*N||_2      <= tau_min * sigma_1(M) * sigma_min+(N) = %.6e\n', target2);
fprintf('  scaled form    <= %.6e\n', target2/(normL*normN));

% ---- validate by controlled perturbation: where does the rank become ambiguous? ----
fprintf('\n=== R3 VALIDATION: perturb L, find where rank stops agreeing ===\n');
fprintf('  %-12s %-12s %-12s  ranks at tau = 1e-9 1e-10 1e-11 1e-12 eps*max\n', 'pert', '||L*N||_2', 'scaled');
taus = [1e-9 1e-10 1e-11 1e-12 tauMin];
Lexact = L0;                      % start from the best basis available
pertList = [0, 1e-16, 1e-14, 1e-12, 1e-10, 1e-8, 1e-6];
for p = pertList
    E = p * randn(size(L0));
    Lp = Lexact + E;
    Mp = [N, -speye(nMet); sparse(size(Lp,1), size(N,2)), Lp];
    sp = svd(full(Mp));
    res2 = norm(full(Lp*N), 2);
    ranks = arrayfun(@(t) sum(sp > t*sp(1)), taus);
    agree = all(ranks == ranks(1));
    fprintf('  %-12.1e %-12.3e %-12.3e  %s  %s\n', p, res2, res2/(norm(full(Lp),2)*normN), ...
        mat2str(ranks), string(agree));
end
save(fullfile(fileparts(mfilename('fullpath')), 'R3R4.mat'), 'target2', 'sig1M', 'sigMinPlusN', 'normN', 'normL', 'tauMin', 'r');
