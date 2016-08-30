function [rd, sub, irrev_rd, rdind, sub_irr_viol]= subsets_reduction(st, irr, remove, keep_single)
% looks for reactions that are blocked according to nullspace analysis and
% determines the reaction subsets (rows of matrix sub); all computations
% are on floating point basis 
% remove are indices of reactions that will be removed from the system
% (these can be known blocked reactions or reactions which are to be
% excluded)
% keep_single are indices of reactions that are not to be combined into
% subsets with other reactions

if nargin < 4
  keep_single= [];
  if nargin < 3
    remove= [];
  end
end
num_reac= size(st, 2);

tmp= false(1, num_reac);
tmp(keep_single)= true;
keep_single= tmp;

kept_reac= 1:num_reac; % indices refer to columns of st
kept_reac(remove)= [];

kn= null(st(:, kept_reac));
tol= eps*length(kept_reac);
blocked= ~any(abs(kn) > tol, 2);
if any(blocked)
  fprintf('Removed %d blocked reactions through nullspace analysis.\n', sum(blocked));
  kept_reac(blocked)= [];
%   kn(blocked, :)= [];
  kn= null(st(:, kept_reac)); % recalculate without blocked reactions for better accuracy
end

cr= subset_candidates(kn);
[sub, irrev_rd, sub_irr_viol]= subsets_cr(st(:, kept_reac), kn, irr(kept_reac), cr, find(keep_single(kept_reac)));
if length(kept_reac) < num_reac
  % integrate removed reactions as zero columns in sub to simplify later expansion
  tmp= spalloc(size(sub, 1), num_reac, nnz(sub));
  tmp(:, kept_reac)= sub;
  sub= tmp;
  if ~isempty(sub_irr_viol) % also adapt sub_irr_viol
    tmp= spalloc(size(sub_irr_viol, 1), num_reac, nnz(sub_irr_viol));
    tmp(:, kept_reac)= sub_irr_viol;
    sub_irr_viol= tmp;
  end
end

[rd, rdind]= reduce(st, sub);
