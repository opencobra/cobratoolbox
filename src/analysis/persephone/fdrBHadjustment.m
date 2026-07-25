function q = fdrBHadjustment(p)
% Perform Benjamini-Hochberg FDR correction on a vector of p-values
%
% Returns the FDR-corrected p-values for the input vector, in the same order
% as the input. The result matches `mafdr(p, 'BHFDR', true)` from the
% Bioinformatics Toolbox. The procedure follows Benjamini, Y. and Hochberg,
% Y. (1995), Controlling the false discovery rate: a practical and powerful
% approach to multiple testing.
%
% USAGE:
%
%    q = fdrBHadjustment(p)
%
% INPUT:
%    p:    vector of p-values, assumed to lie in the interval [0, 1]
%
% OUTPUT:
%    q:    vector of FDR-corrected p-values, in the same order as `p`
%
% EXAMPLE:
%
%    pvals = [0.01, 0.04, 0.03, 0.002, 0.07];
%    qvals = fdrBHadjustment(pvals);
%
% NOTE:
%    Part of this function was drafted with assistance from an LLM and then
%    manually tested and corrected.

p = p(:);

% Number of hypotheses/tests
m = length(p);

% Sort the p-values in ascending order and keep track of the original indices
[p_sorted, sortIdx] = sort(p);

% Compute the BH adjusted p-values for the sorted list.
% For each rank i, the adjusted p-value is p_sorted(i) * m / i.
q_sorted = p_sorted .* m ./ (1:m)';

% Ensure the adjusted p-values are monotonic non-decreasing.
% We do this by iterating backwards and taking the minimum with the next p-value.
for i = m-1:-1:1
    q_sorted(i) = min(q_sorted(i), q_sorted(i+1));
end

% Ensure that no adjusted p-value exceeds 1.
q_sorted(q_sorted > 1) = 1;

% Return the adjusted p-values to the original order.
q = zeros(m, 1);
q(sortIdx) = q_sorted;

end