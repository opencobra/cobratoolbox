% R3 validation from the ACCURATE side: start from an exact left-nullspace basis,
% perturb by controlled amounts, and locate where the rank stops being unambiguous.
% Compare the located crossing against the DERIVED target. Tasks T009, T010.
rng(20260914, 'twister');
d = load('/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat');
N = d.iDopaNeuroC.S(:, d.iDopaNeuroC.SConsistentRxnBool);
nMet = size(N, 1);
R = load(fullfile(fileparts(mfilename('fullpath')), 'R3R4.mat'));

% exact left nullspace basis (orthonormal; sign-unrestricted -- this validates the RANK
% property, which is what R3 is about; non-negativity is FR-004's separate concern)
W = null(full(N'));          % 1244 x 105
Lex = W';
fprintf('exact basis: %d x %d | ||Lex*N||_2 = %.3e\n', size(Lex,1), size(Lex,2), norm(Lex*full(N), 2));

rStruct = nMet + size(Lex,1) - size(Lex,1);   % = nMet = 1244
taus = [1e-9 1e-10 1e-11 1e-12 R.tauMin];
fprintf('\nDERIVED TARGET: ||L*N||_2 <= %.4e  (scaled %.4e)\n\n', R.target2, R.target2/(R.normL*R.normN));
fprintf('%-10s %-12s %-12s %-28s %-8s\n', 'pert', '||L*N||_2', 'scaled', 'ranks(1e-9..eps*max)', 'correct?');
for p = [0 1e-16 1e-15 1e-14 1e-13 1e-12 1e-11 1e-10]
    Lp = Lex + p*randn(size(Lex));
    Mp = [N, -speye(nMet); sparse(size(Lp,1), size(N,2)), Lp];
    sp = svd(full(Mp));
    ranks = arrayfun(@(t) sum(sp > t*sp(1)), taus);
    res2 = norm(Lp*full(N), 2);
    ok = all(ranks == rStruct);
    fprintf('%-10.0e %-12.3e %-12.3e %-28s %-8s\n', p, res2, ...
        res2/(norm(Lp,2)*R.normN), mat2str(ranks), string(ok));
end

% does the derived target reproduce the two KNOWN outcomes from the seed?
fprintf('\n=== validation against the seed''s two known outcomes ===\n');
seedScaled = 2.218e-09; exactScaled = 1e-16; tgtScaled = R.target2/(R.normL*R.normN);
fprintf('  seed basis  scaled %.3e vs target %.3e -> %s (expected FAIL)\n', ...
    seedScaled, tgtScaled, string(seedScaled <= tgtScaled));
fprintf('  exact basis scaled %.3e vs target %.3e -> %s (expected PASS)\n', ...
    exactScaled, tgtScaled, string(exactScaled <= tgtScaled));
