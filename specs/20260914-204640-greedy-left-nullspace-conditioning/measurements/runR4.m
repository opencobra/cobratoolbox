% R4: locate the A/B regime boundary on a graded scaling family. Task T010.
% Grounding: Regime B is where the R3 target cannot be met EVEN IN PRINCIPLE, i.e.
% where the target falls below the measured solver residual floor. The target is
%   target = tau_min * sigma_1(M) * sigma_min+(Nop)
% so as Nop becomes badly scaled, sigma_min+(Nop) -> 0 and the target becomes
% unreachable against a fixed solver floor.
rng(20260914, 'twister');
d = load('/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat');
N0 = d.iDopaNeuroC.S(:, d.iDopaNeuroC.SConsistentRxnBool);
R = load(fullfile(fileparts(mfilename('fullpath')), 'R3R4.mat'));

rhoFloor = 1e-16;    % measured in R2: best attainable raw residual (gurobi/glpk)
fprintf('measured solver floor rho = %.1e (R2: gurobi/glpk)\n', rhoFloor);
fprintf('tau_min = %.4e\n\n', R.tauMin);
fprintf('%-10s %-14s %-14s %-14s %-10s\n', 'rowScale', 'sigma_min+(N)', 'target', 'target/rho', 'regime');

for f = [1 1e1 1e2 1e3 1e4 1e5 1e6 1e7 1e8]
    % graded family: scale a fixed 10% of rows by f (controlled, known factor)
    Nf = N0;
    idx = 1:10:size(N0,1);
    Nf(idx, :) = Nf(idx, :) / f;
    sNf = svd(full(Nf));
    rk = sum(sNf > eps*max(size(Nf))*sNf(1));
    sMinPlus = sNf(rk);
    sig1 = sNf(1);                       % sigma_1(M) ~ sigma_1(N) to within the identity block
    target = R.tauMin * max(sig1, 1) * sMinPlus;
    ratio = target/rhoFloor;
    regime = "A (target reachable)";
    if ratio < 1, regime = "B (target UNREACHABLE)"; end
    fprintf('%-10.0e %-14.4e %-14.4e %-14.4e %-10s\n', f, sMinPlus, target, ratio, regime);
end
fprintf('\nBoundary condition: sigma_min+(Nop) < rho / (tau_min * sigma_1) => Regime B\n');
fprintf('  threshold sigma_min+ = %.4e\n', rhoFloor/(R.tauMin*R.sig1M));
fprintf('  iDopaNeuroC actual   = %.4e  (margin %.1fx)\n', R.sigMinPlusN, ...
    R.sigMinPlusN/(rhoFloor/(R.tauMin*R.sig1M)));
