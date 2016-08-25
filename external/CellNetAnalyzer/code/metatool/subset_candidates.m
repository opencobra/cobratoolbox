function cr= subset_candidates(kn, tol)
% calculates subset candidates based on the correlations between the rows
% of kn
% the columns in cr are the subset candidates; only the upper triangle of
% this matrix is kept

if nargin < 2
  tol= size(kn, 1)*eps;
end

cr= kn * kn';
for i= 1:size(kn, 1)
  for j= i+1:size(kn, 1)
    cr(i, j)= cr(i, j) / sqrt(cr(i, i)*cr(j, j));
  end
  cr(i, i)= 1; % the reaction i itself belongs to the subset candidate
end
cr= triu(cr); % only keep upper triangle
cr(abs(abs(cr) - 1) >= tol)= 0; % only keep correlations close to 1
cr= sign(sparse(cr));
