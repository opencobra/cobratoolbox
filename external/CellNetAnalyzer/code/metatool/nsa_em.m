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

% subscript for metatool

function [rd_ems, rd_cb, err, wrd, irrev_wrd, wkr, ind]= nsa_em(rd, irrev_rd, req_reacts, cb_calc)
  if nargin < 4
    cb_calc= 0;
    if nargin < 3
      req_reacts= [];
    end
%#  else
%#    if cb_calc && ~isempty(req_reacts)
%#      error('Calculation of convex basis with obligatory reactions not supported yet');
%#    end
  end

  normal= ones(1, size(rd, 2));
  normal(req_reacts)= 0;
%#  rev_ind= [find(~irrev_rd & ~normal), find(~irrev_rd & normal)];
%#  if length(rev_ind) > 0
%#    if rank(rd(:, rev_ind)) < length(rev_ind)
%#      disp('Linear dependencies in reversible subsets.');
%#    end
%#  end
  
  order= zeros(1, size(rd, 2));
  max_reg_val= 2^50; %# maximal order value for normal reactions
  id_req= [];
  if isempty(req_reacts)
    req_reacts= 0;
    ind= [find(~irrev_rd & normal), find(irrev_rd & normal)];
    wrd= rd(:, ind);
    irrev_wrd= irrev_rd(ind);
    if all_integer(wrd)
      [wkr, diag_part]= kernel_fp(wrd, find(~irrev_wrd), 1); %# cannot handle req_reacts properly
    else
      [wkr, dummy, diag_part]= kernel(wrd);
    end
  else
%#    ind= [find(irrev_rd & normal), find(~irrev_rd & normal), req_reacts];
    ind= [req_reacts, find(~irrev_rd & normal), find(irrev_rd & normal)];
    wrd= rd(:, ind);
    irrev_wrd= irrev_rd(1, ind);
    [wkr, dummy, diag_part]= kernel(wrd); % kernel of the reduced system
%#    wkr= null(wrd);
%#    [wkr, diag_part]= rref(wkr');
%#    wkr= wkr';
%#    tol= eps * max(size(wrd)) * norm(wrd, inf);
%#    wkr(abs(wkr) <= tol)= 0;
    if all_integer(wrd)
      dummy= make_integer_cols(wkr);
      if any(any(wrd * dummy)) % transformation to integers didn't work
	disp('Continuing calculations with floating point numbers');
      else
	wkr= dummy;
      end
      clear dummy;
    end
    req_reacts= length(req_reacts);
    id_req= diag_part(diag_part <= req_reacts);
    order(1:req_reacts)= max_reg_val;
    if cb_calc
      order(~irrev_wrd)= +Inf;
    end
    %#order(id_req) will be set to -Inf implicitly later
  end
  unperm(ind)= 1:size(wrd, 2);

  if ~isempty(id_req)
    is_req_react= zeros(1, length(irrev_wrd));
    is_req_react(1:req_reacts)= 1;
%#    if cb_calc
%#      is_req_react(irrev_wrd == 0)= 0; # req_reacts must not be reversible with cb_calc
%#    end
    is_req_react= is_req_react ~= 0; %# make this a bool vector
    %#ind= find(~any(wkr((req_reacts+1):end, :))); % columns that only consist of obligatory reactions
    ind= find(~any(wkr(~is_req_react, :), 1)); % columns that only consist of obligatory reactions
    if length(ind) > 0 %# here we can directly decide if there is an elementary mode
      disp('Direct test for elementary mode');
      %#if length(ind) == 1 && all(wkr(1:req_reacts, ind))
      if length(ind) == 1 && all(wkr(is_req_react, ind))
	%#if any(wkr(find(irrev_wrd(1:req_reacts)), ind) < 0)
	if any(wkr(find(irrev_wrd(is_req_react)), ind) < 0)
	  wkr(:, ind)= -wkr(:, ind); % this block is unnecessary when calculating kernel via rref
	end
	%#if all(wkr(find(irrev_wrd(1:req_reacts)), ind) > 0)
	if all(wkr(find(irrev_wrd(is_req_react)), ind) > 0)
	  err= 0;
	  rd_cb= wkr(unperm, ind);
	  rd_ems= rd_cb;
	  return;
	end
      else %# if length(ind) == 1 && all(wkr(1:req_reacts, ind))
	wkr= zeros(size(wkr, 1), 0);
      end
    else %# if length(ind) > 0
%#      if cb_calc
%#	%# only substract irreversible id_req; reversible ones are subtracted before elmo call
%#	req_reacts= req_reacts - sum(irrev_wrd(id_req)); %# sollte mit dem unteren zusammenfallen
%#      else
	req_reacts= req_reacts - length(id_req); %# do elmo calculation and post-filtering 
%#     end
    end
  end 

  if isempty(wkr) % prevents possible errors during onward calculation
    disp('Kernel is empty, no elementary modes in this system');
    err= 0;
    rd_cb= wkr;
    rd_ems= wkr;
    return;
  end

  %# find a permutation for efficient calculation
  rev_ind= find(irrev_wrd == 0);
  order(rev_ind)= order(rev_ind) + prod(size(wkr)); % process reversible reactions last
  order= order + sum(wkr' ~= 0); % process columns with most entries last
%#  cs= sum(wkr ~= 0); % number of entries in each column
%#  for j= 1:size(wkr, 1)
%#    order(1, j)= order(1, j) + sum(cs(find(wkr(j, :)))); %# sum number of entries in columns
%#  end
  order(diag_part)= -Inf; %# place the part that composes the identity matrix at the _very_ beginning
  [X, ind]= sort(order);
%#  ind= 1:size(wkr, 1) %# no sorting
  unperm2(ind)= 1:size(wkr, 1);
  id_req= unperm2(id_req);
  unperm= unperm2(unperm);
  wrd= wrd(:, ind);
  wkr= wkr(ind, :);
  irrev_wrd= irrev_wrd(1, ind) * 1.0; % force this to be a scalar vector for elmo with Matlab

  [ersatz_rd, subsys_rows]= kernel(wkr');
  if isempty(subsys_rows)
    error('Cannot not calculate ersatz_rd and subsys_rows because of numerical problems');
  end
  ersatz_rd= ersatz_rd';

  if cb_calc % calculate convex basis and from these the elementary modes
    if req_reacts == 0 && cb_calc > 0
      [rd_cb, err]= elmo(wkr, irrev_wrd, 0, -1, ersatz_rd, subsys_rows);
      if ~err && cb_calc == 1
        [rd_ems, err]= elmo(rd_cb, irrev_wrd, 0, size(wkr, 2), ersatz_rd, subsys_rows);
      else
        rd_ems(1:size(wkr, 1), 1)= NaN;
      end
      rd_cb= rd_cb(unperm, :);
    else %# distributed calculation of convex basis only; !! result is then stored in ems matrix !!
      [rd_ems, err]= elmo(wkr, irrev_wrd, 0, -1, ersatz_rd, subsys_rows, req_reacts, 1);
      if ~isempty(id_req) %#&& any(irrev_wrd(id_req)) %# 'any' because all([]) = 1 leads to an error below
	disp('Post-filtering obligatory irreversible reactions in identity submatrix');
	rd_ems= rd_ems(:, all(rd_ems(id_req(irrev_wrd(id_req) == 1), :), 1));
	%pause(); # kann man mit dem ems Fall zusammenfassen
      end
      rd_cb(1:size(wkr, 1), 1)= NaN;
    end
  else %# only calculate elementary modes
    rd_cb(1:size(wkr, 1), 1)= NaN;
    %rd_ems= cdd_list(wkr, wrd);
    [rd_ems, err]= elmo(wkr, irrev_wrd, 0, 0, ersatz_rd, subsys_rows, req_reacts, 1);
    %rd_ems= elementary_modes_fast(wkr, irrev_wrd, ersatz_rd, subsys_rows, wrd, req_reacts);
    %rd_ems= elementary_modes_nc2(wkr, irrev_wrd, ersatz_rd, subsys_rows, wrd, req_reacts);
    %rd_ems= elementary_modes_perm(wkr, irrev_wrd);
    if ~isempty(id_req)
      disp('Post-filtering obligatory reactions in identity submatrix');
      rd_ems= rd_ems(:, all(rd_ems(id_req, :), 1));
    end
  end
  rd_ems= rd_ems(unperm, :);
