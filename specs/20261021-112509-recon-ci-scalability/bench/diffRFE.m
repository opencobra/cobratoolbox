function diffRFE(realModels)
cobra = '/home/farid/Projects/cobratoolbox-f-develop'; cd(cobra); initCobraToolbox(false); warning off all
addpath('/tmp/claude-1000/-home-farid-Projects-reconxkg/e854ce54-e2a8-4121-baee-4a5dbf3a5092/scratchpad/prof/ref');
rng(777); nBad = 0; nCases = 0; nMatch = 0;
for trial = 1:400
  nG = randi([3 40]); nR = randi([2 50]);
  m.mets = {'a[c]'}; m.genes = arrayfun(@(i) sprintf('g%d',i), 1:nG, 'UniformOutput', false)';
  m.rxns = arrayfun(@(i) sprintf('r%d',i), 1:nR, 'UniformOutput', false)';
  m.S = sparse(ones(1,nR)); m.lb = zeros(nR,1); m.ub = ones(nR,1); m.c = zeros(nR,1);
  m.rules = cell(nR,1); m.grRules = cell(nR,1);
  for r = 1:nR
    [rule, gr] = genRule(randi([0 4]), nG);
    m.rules{r} = rule; m.grRules{r} = gr;
  end
  m = buildRxnGeneMat(m);
  nRem = randi([1 max(1,floor(nG/2))]); rem = randperm(nG, nRem);
  for useLogical = 0:1
    idx = rem; if useLogical, idx = false(nG,1); idx(rem) = true; end
    err1 = ''; err2 = '';
    try, a = removeFieldEntriesForTypeRef(m, idx, 'genes', nG); catch ME, err1 = ME.message; end
    try, b = removeFieldEntriesForType(m, idx, 'genes', nG); catch ME, err2 = ME.message; end
    nCases = nCases + 1;
    if ~strcmp(err1, err2) || (isempty(err1) && ~isequaln(a, b)), nBad = nBad + 1; fprintf('MISMATCH trial %d logical %d (%s | %s)\n', trial, useLogical, err1, err2); end
    if isempty(err1), nMatch = nMatch + any(~strcmp(a.rules, m.rules(:))); end
  end
  % removal of reactions and metabolites goes through the same function
  a = removeFieldEntriesForTypeRef(m, 1, 'rxns', nR); b = removeFieldEntriesForType(m, 1, 'rxns', nR);
  nCases = nCases + 1; if ~isequaln(a,b), nBad = nBad + 1; fprintf('MISMATCH rxns trial %d\n', trial); end
end
fprintf('synthetic: %d cases (%d with rules changed), %d mismatches\n', nCases, nMatch, nBad);
for f = realModels
  S0 = load(f{1}); fn = fieldnames(S0); mm = S0.(fn{1});
  if ~isfield(mm,'rules'), fprintf('%s has no rules\n', f{1}(end-30:end)); continue; end
  mm = buildRxnGeneMat(mm); nG = numel(mm.genes);
  for pct = [0.01 0.1]
    rem = randperm(nG, max(1,round(pct*nG)));
    t=tic; a = removeFieldEntriesForTypeRef(mm, rem, 'genes', nG); t1=toc(t);
    t=tic; b = removeFieldEntriesForType(mm, rem, 'genes', nG); t2=toc(t);
    fprintf('%s %d genes (%d removed): identical=%d  ref %.1fs  new %.1fs\n', f{1}(end-30:end), nG, numel(rem), isequaln(a,b), t1, t2);
  end
end
end
function [rule, gr] = genRule(depth, nG)
if depth == 0 && rand < 0.2, rule = ''; gr = ''; return; end
[rule, gr] = genExpr(depth, nG);
end
function [e, g] = genExpr(depth, nG)
if depth <= 0 || rand < 0.3
  i = randi(nG); sp = {'', ' '}; e = ['x(' num2str(i) ')']; g = sprintf('g%d', i);
  if rand < 0.2, e = ['(' e ')']; g = ['(' g ')']; end
  return
end
[e1,g1] = genExpr(depth-1, nG); [e2,g2] = genExpr(depth-1, nG);
if rand < 0.5, op = '&'; gop = 'and'; else, op = '|'; gop = 'or'; end
sepc = {' ', ''}; s = sepc{randi(2)};
e = [e1 s op s e2]; g = [g1 ' ' gop ' ' g2];
if rand < 0.5, e = ['(' e ')']; g = ['(' g ')']; end
end
