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

%% int_calc ~= 0 turns on integer calculation; this is slow!
%% prior_cols are the indices of the columns that are searched before
%% any remaining columns

function [K, unused] = kernel_fp(A, prior_cols, int_calc)
if nargin < 3
  int_calc= 0;
end
%#  K= kernel_fpo([eye(size(A, 2)); A], zeros(1, size(A, 2)));
%###  K= kernel_fpo([eye(size(A, 2)); A], 1:size(A, 2));
%#  return;

if isempty(A)
  K= A'; % to get "dimensions" right
  unused= [];
  return;
end

[m, n]= size(A);
% set up tableau
tab= [A; eye(n)];
tab_m= m + n;

if nargin < 2
  prior_cols=[];
end
if int_calc
  tol= 0;
else
  tol= eps * max (m, n) * norm (A, inf); %# same tolerance as used in rref
end
max_int_in_double= 2^53 - 1; %# needed to determine overflows when using integer calculation

re_rows= 1:m;
re_cols= 1:n;
%#re_cols(prior_cols)= [];
unused= ones(1, n);

while ~isempty(re_rows) && ~isempty(re_cols)
  %    t=cputime
  if isempty(prior_cols)
    search_cols= re_cols;
  else
    search_cols= prior_cols;
  end

  if int_calc
    tmp= abs(tab(re_rows, search_cols));
    tmp(tmp == 0)= +Inf;
    [mc, ic]= min(tmp);
    [piv_el, piv_c_ind]= min(mc);
    piv_r_ind= ic(piv_c_ind);
    if piv_el == +Inf
      piv_el= 0;
    end
  else
    [mc, ic]= max(abs(tab(re_rows, search_cols))); % maximums of the columns in _remaining_ part of tab
    [piv_el, piv_c_ind]= max(mc);
    piv_r_ind= ic(piv_c_ind);
  end

  if (length(re_rows) == 1) % necessary to get correct indices
    piv_r_ind= 1;
    piv_c_ind= ic;
  end

  piv_c= search_cols(piv_c_ind);
  piv_r= re_rows(piv_r_ind);
  %%    if (piv_el <= tol) % nothing left to do
  %%      tab(re_rows, re_cols)= 0; % make the remaining entries zero
  %%      break;
  %%    end
  % remove current pivot postions and update pivot row and column
  %re_cols(piv_c_ind)= [];
  if ~isempty(prior_cols)
    prior_cols(piv_c_ind)= [];
  end
  j= find(re_cols == piv_c);
  re_cols(j)= [];
  if (piv_el <= tol)
    tab(re_rows, piv_c)= 0;
    continue;
  end

  unused(piv_c)= 0;
  piv_el= tab(piv_r, piv_c); % assign again to get sign of piv_el right
  rws= [re_rows, (m+1):tab_m];
  if ~int_calc
    tab(rws, piv_c)= tab(rws, piv_c)/piv_el;
  end
  re_rows(piv_r_ind)= [];
  %disp(tab);
  unused(piv_c)= 0;
  %    cputime-t
  %    t=cputime;
  for j=1:length(re_cols) % it should be possible to avoid this loop
    col= re_cols(j);
    if int_calc
      g= fast_gcd(abs([tab(piv_r, col), piv_el]));
      %#        fp= tab(piv_r, col)/g;
      %#        fo= piv_el/g;
      %#        tab(rws, col)= fo * tab(rws, col) - fp * tab(rws, piv_c);
      fp= tab(piv_r, col)/g * tab(rws, piv_c);
      fo= piv_el/g * tab(rws, col);
      if any(fp >= max_int_in_double) || any(fo >= max_int_in_double)
        error('integer resolution exceeded');
      end
      tab(rws, col)= fo - fp;
      g= fast_gcd(abs(tab(rws, col)));
      tab(rws, col)= tab(rws, col)/g;
    else
      tab(rws, col)= tab(rws, col) - tab(piv_r, col) * tab(rws, piv_c);
      tab(rws(find(abs(tab(rws, col)) <= tol)), col)= 0; % make small values zero
    end
  end
  %    cputime-t
  %    disp(tab);
end
if m == 1
  K= tab(2:tab_m, ~tab(1, :));
else
  K= tab((m+1):tab_m, ~any(tab(1:m, :)));
end
unused= find(unused);
