function diffDup(realFiles)
cobra = '/home/farid/Projects/cobratoolbox-f-develop';
cd(cobra); initCobraToolbox(false); 
addpath('/tmp/claude-1000/-home-farid-Projects-reconxkg/e854ce54-e2a8-4121-baee-4a5dbf3a5092/scratchpad/prof/ref');
rng(12345); nBad = 0; nCases = 0;
% ---- random models with planted duplicates
for trial = 1:300
  nMet = randi([3 12]); nBase = randi([1 30]);
  B = full(sprand(nMet, nBase, 0.3)); B(B~=0) = randi([1 3], nnz(B), 1) .* sign(randn(nnz(B),1));
  cols = B;
  nExtra = randi([0 20]);
  for k = 1:nExtra
    j = randi(size(B,2)); c = B(:,j);
    switch randi(4), case 1, cols(:,end+1) = c; case 2, cols(:,end+1) = -c; case 3, cols(:,end+1) = 2*c; case 4, cols(:,end+1) = zeros(nMet,1); end
  end
  nR = size(cols,2); perm = randperm(nR); cols = cols(:,perm);
  m.S = sparse(cols); m.mets = arrayfun(@(i) sprintf('m%d_[c]',i), 1:nMet, 'UniformOutput', false)';
  m.rxns = arrayfun(@(i) sprintf('r%d',i), 1:nR, 'UniformOutput', false)'; m.rxnNames = m.rxns;
  m.lb = -randi([0 2], nR, 1)*100; m.ub = randi([1 2], nR, 1)*100;
  for method = {'S','FR',2}
   for bf = 0:1
    for rf = 0:1
     for full_ = 0:1
      mm = m; if full_, mm.S = full(mm.S); end
      lastwarn(''); [a1,b1,c1] = checkDuplicateRxnRef(mm, method{1}, rf, 0, bf); w1 = lastwarn;
      lastwarn(''); [a2,b2,c2] = checkDuplicateRxn(mm, method{1}, rf, 0, bf); w2 = lastwarn;
      nCases = nCases + 1;
      if ~(isequaln(a1,a2) && isequaln(b1,b2) && isequaln(c1,c2) && strcmp(w1,w2) && isequal(class(b1),class(b2)) && issparse(a1.S)==issparse(a2.S))
        nBad = nBad + 1; fprintf('MISMATCH trial %d method %s bounds %d remove %d full %d\n', trial, string(method{1}), bf, rf, full_);
      end
     end
    end
   end
  end
  % printed output
  ws = warning('off','all'); t1 = evalc('checkDuplicateRxnRef(m,''FR'',0,1);'); t2 = evalc('checkDuplicateRxn(m,''FR'',0,1);');
  t3 = evalc('checkDuplicateRxnRef(m,''S'',0,1);'); t4 = evalc('checkDuplicateRxn(m,''S'',0,1);');
  warning(ws); nCases = nCases + 2; if ~strcmp(t1,t2) || ~strcmp(t3,t4), nBad = nBad + 1; fprintf('PRINT MISMATCH trial %d\n', trial); end
end
% ---- edge: empty / single reaction models
e.S = sparse(3,0); e.mets={'a';'b';'c'}; e.rxns = cell(0,1); e.lb = zeros(0,1); e.ub = zeros(0,1);
o.S = sparse([1;-1;0]); o.mets={'a';'b';'c'}; o.rxns={'x'}; o.lb=0; o.ub=1;
for mm = {e, o}
  for method = {'S','FR'}
    try, [a1,b1,c1] = checkDuplicateRxnRef(mm{1}, method{1}, 1); r1 = {a1,b1,c1}; catch ME1, r1 = ME1.identifier; end
    try, [a2,b2,c2] = checkDuplicateRxn(mm{1}, method{1}, 1); r2 = {a2,b2,c2}; catch ME2, r2 = ME2.identifier; end
    nCases = nCases + 1; if ~isequaln(r1,r2), nBad = nBad + 1; fprintf('EDGE MISMATCH %s\n', method{1}); end
  end
end
fprintf('synthetic: %d cases, %d mismatches\n', nCases, nBad);
% ---- real models
for f = realFiles
  S0 = load(f{1}); fn = fieldnames(S0); m = S0.(fn{1}); m.S = sparse(m.S);
  fprintf('%s: %d x %d\n', f{1}(end-40:end), size(m.S,1), size(m.S,2));
  for method = {'S','FR'}
    for bf = 0:1
      lastwarn(''); t=tic; [a1,b1,c1] = checkDuplicateRxnRef(m, method{1}, 0, 0, bf); t1=toc(t); w1 = lastwarn;
      lastwarn(''); t=tic; [a2,b2,c2] = checkDuplicateRxn(m, method{1}, 0, 0, bf); t2=toc(t); w2 = lastwarn;
      same = isequaln(a1,a2) && isequaln(b1,b2) && isequaln(c1,c2) && strcmp(w1,w2);
      fprintf('  %-3s bounds %d: removed %5d  identical=%d   ref %.2fs  new %.2fs\n', method{1}, bf, numel(b1), same, t1, t2);
    end
  end
  clear m a1 a2
end
end
