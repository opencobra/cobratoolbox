%% Copyright (C) 2005 Axel von Kamp
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [kn, subsys_cols, nopiv] = kernel(A)

  [m,n] = size(A);

  [R, pivcol]= rref(A);
  tol= eps * max (m, n) * norm (A, inf); %# same tolerance as used in rref
  r = length(pivcol); % should be rank of A
  if r~= 0 % protect from error in rank
    if r ~= rank(A)
      warning('rref in kernel calculation gives wrong rank, trying workaround...');
      [kn, pivcol]= rref(null(A)');
      kn= kn';
      nopiv= 1:size(kn, 2);
      subsys_cols= [];
      return;
    end
  end
  nopiv = 1:n;
  nopiv(pivcol) = [];
  R(abs(R) < tol)= 0;

%A# failed idea to get a similar effect to what Matlab's rref tries with
%A# 'pseudo-rational' numbers
%   [uq, ind_map, ind]= unique(R(:)); % falls mit abs -> Vorzeichen beachten!
%   rng= equal_range(uq, tol);
%   for i= 1:length(rng)-1
%     first= rng(i);
%     last= rng(i+1)-1;
%     if first < last %A# there is a range of values
%       rep_val= mean(uq(first:last))
%       if abs(round(rep_val) - rep_val) < tol
%         rep_val= round(rep_val)
%         disp('replace');
%         if rep_val - uq(first) >= tol || uq(last) - rep_val >= tol
%           fprintf('Some original values differ by more than the tolerance, rep_val is %e\n', rep_val);
%         end
%         for j= first:last
%           R(ind(ind_map(j)) == ind)= rep_val;
%         end
%       end  
%     end
%   end

  kn = zeros(n,n-r);
  if n > r
    kn(nopiv,:) = eye(n-r,n-r);
    if r > 0
      kn(pivcol,:) = -R(1:r,nopiv);
    end
  end

  %# set up subsys_cols so that kn(1:i, 1:subsys_cols(i)) is a kernel of A(:, 1:i)
  isnopiv= ones(1, n);
  isnopiv(pivcol)= 0;
  subsys_cols= cumsum(isnopiv);
