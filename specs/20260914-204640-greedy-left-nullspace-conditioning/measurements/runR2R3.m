% R2 (solver residual floor) + R3 (accuracy target from the augmented matrix's
% singular-value separation) + R5 bound-clipping check. Tasks T005, T009, T006.
rng(20260914, 'twister');
addpath(fileparts(mfilename('fullpath')));
d = load('/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat');
model = d.iDopaNeuroC;
N = model.S(:, model.SConsistentRxnBool);
nMet = size(N, 1);

% ---------- R2: attainable residual floor per solver, on RAW solutions ----------
fprintf('=== R2: raw (untruncated) residual floor by solver ===\n');
for solver = {'gurobi', 'mosek', 'glpk'}
    if ~changeCobraSolver(solver{1}, 'LP', 0), fprintf('  %s unavailable\n', solver{1}); continue; end
    r = nan(20, 1); clip = 0;
    for k = 1:20
        o = probeRayResidual(N, rand(nMet, 1), 1);
        r(k) = o.residualRawAbs;
        clip = clip + nnz(abs(o.xRaw) >= 100 - 1e-9);   % R5: do the +-100 bounds bind?
    end
    fprintf('  %-8s raw residual: median %.3e  max %.3e | rays hitting the +-100 bound: %d\n', ...
        solver{1}, median(r, 'omitnan'), max(r), clip);
end

% ---------- R3: what separation does a rank determination actually need? ----------
fprintf('\n=== R3: singular-value structure of the augmented matrix ===\n');
L = load(fullfile(fileparts(mfilename('fullpath')), 'R1c_mosek.mat'), 'Zpos');
L = L.Zpos;
fprintf('  basis L: %d x %d | residual abs %.3e\n', size(L,1), size(L,2), norm(full(L*N), inf));

% the augmented matrix a caller forms:  M = [N, -I ; 0, L]
M = [N, -speye(nMet); sparse(size(L,1), size(N,2)), L];
fprintf('  augmented M: %d x %d\n', size(M,1), size(M,2));
structuralRank = size(M,1) - size(L,1);
fprintf('  structural rank if L spans the left nullspace: %d - %d = %d\n', size(M,1), size(L,1), structuralRank);

s = svd(full(M));
fprintf('  sigma_1            = %.6e\n', s(1));
fprintf('  sigma_r   (r=%4d) = %.6e   <- smallest RETAINED\n', structuralRank, s(structuralRank));
fprintf('  sigma_r+1          = %.6e   <- largest that OUGHT to be zero\n', s(structuralRank+1));
fprintf('  sigma_end          = %.6e\n', s(end));
fprintf('  GAP ratio sigma_r/sigma_r+1 = %.3e\n', s(structuralRank)/s(structuralRank+1));
fprintf('  sigma_r   / sigma_1 = %.3e\n', s(structuralRank)/s(1));
fprintf('  sigma_r+1 / sigma_1 = %.3e\n', s(structuralRank+1)/s(1));

% rank reported across the tolerance span the spec requires
fprintf('\n  rank across relative tolerances:\n');
for tau = [1e-9 1e-10 1e-11 1e-12 1e-13 eps*max(size(M))]
    fprintf('    tau = %10.3e -> rank %d\n', tau, sum(s > tau*s(1)));
end
save(fullfile(fileparts(mfilename('fullpath')), 'R3_svd.mat'), 's', 'structuralRank');
