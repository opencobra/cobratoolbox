function [sub, irrev_sub, sub_irr_viol]= subsets_cr(st, kn, irrev_react, cr, keep_single)
% find subsets from subset candidates
% keep_single is a vector of indices; reactions specified here are not
% placed into a subset even if they belong to one

if nargin < 5
  keep_single= zeros(0, 1);
end
sub_irr_viol= [];
sub= spalloc(length(keep_single), size(st, 2), size(st, 2));
for i= 1:length(keep_single)
  sub(i, keep_single(i))= 1;
end
irrev_react= logical(irrev_react);
irrev_sub= irrev_react(keep_single);
in_subset= false(1, size(st, 2));
in_subset(keep_single)= true;

for i= size(cr, 1):-1:1 % have to start at the end of cr because of its triangular form
  reacs= find(cr(:, i))';
  reacs(in_subset(reacs))= [];
  if isempty(reacs)
    continue;
  end
  in_subset(reacs)= true;
  irrev_sub(end+1)= any(irrev_react(reacs));
  if length(reacs) == 1 % subset with only one reaction
    sub(length(irrev_sub), reacs)= 1;
  else
    len= zeros(size(reacs)); % lengths of the corresponding kernel row vectors
    for k= 1:length(reacs)
      len(k)= norm(kn(reacs(k), :));
    end
    [dummy, ind]= min(abs(len - mean(len)));
    len= len/len(ind);
    sub(length(irrev_sub), reacs)= len .* cr(reacs, i)';
  end
end

ind= find(any(sub(:, irrev_react) < 0, 2)); % subsets that violate irreversibility constraints
if ~isempty(ind)
  sub(ind, :)= -sub(ind, :); % there can be reversible and irreversible reactions in a subset
  ind= find(any(sub(:, irrev_react) < 0, 2)); % check whether the constraints are still violated
  if ~isempty(ind)
    sub_irr_viol= sub(ind, :);
    sub(ind, :)= [];
    irrev_sub(ind)= [];
  end
end
  