function [kn, wkr, irrev, pivcol, sys]= mcs_kernel4(st, irr, targets)
% no I_irr

[m, n]= size(st);
if nargin < 3
  targets= -irr;
else
  targets= -targets;
end
if any(targets & ~irr)
  error('Can only select irreversible reactions as targets');
end
targets= targets(:);

t= [eye(n), targets, st']; % kernel for this
kn= [-[targets, st']; eye(m+1)]; % could there be subset rows in here?
irrev= [zeros(1, n), 1, zeros(1, m)];
if strcmp(class(kn), 'sym')
   %A# symbolic rref does not return pivcol so we steal it from the fp
   %A# implementation and check if the selection is correct
  [wkr, pivcol]= rref(double(kn)');
  wkr= rref(kn');
  if ~all(all(wkr(:, pivcol) == eye(m+1)))
    error('Symbolic calculations glitch occured');
  end
else
  [wkr, pivcol]= rref(kn'); %rref(kn(1:num_irr+n+1, :)')';
  tol= eps * max(size(kn)) * norm(kn, inf); %A# same tolerance as used in rref
  wkr(abs(wkr) < tol)= 0; %A# make tiny values 0 for correct operation of elmo
end
wkr= wkr';
if all_integer(st)
  wkr= make_integer_cols_zero_tol(wkr);
  if any(any(t*wkr)) || rank(wkr) ~= size(kn, 2) %A# overprotective?
    error('Incorrect nullspace');
  end
else
  if any(any(double(t*kn))) || rank(kn) ~= size(kn, 2)
    error('Incorrect nullspace');
  end
end
sys.st= t;
sys.irrev_react= irrev;
sys.rd= t;
sys.irrev_rd= irrev;
% sys.req_reacts= n + 1; %A# references columns in 'rd'
sys.react_name= default_names('R', n + 1, 1);
fprintf('w is at position %d\n', n + 1);
fprintf('I is at %d:%d\n', 1, n);
