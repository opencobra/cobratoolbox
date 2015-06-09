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

function [sub, irrev_sub, blocked_react, sub_irr_viol]= subsets(kn, irrev_react, all_int, keep_single)
% kn is a nullspace matrix, irrev_react are reaction reversibilities
% all_int activates integer calculation and is only usefule when kn
% contains integers
% keep_single is a vector of indices; reactions specified here are not
% placed into a subset even if they belong to one; these reactions must
% be at the beginning of kn
if nargin < 4
  keep_single= [];
end
  sub= [kn, eye(size(kn, 1))];
  kncols= size(kn, 2);
  %in_subset= ~any([kn, zeros(size(kn, 1))]'); % effectively removes blocked reactions from the reduced system
  if all_int
    in_subset= ~any(kn, 2)'; % effectively removes blocked reactions from the reduced system
  else
    in_subset= ~any(abs(kn) > 1e-12, 2)'; % in case kn was determined by 'null' residual values may still be present
  end
  %in_subset= zeros(1, size(kn, 1)); % don't remove blocked reactions
  blocked_react= find(in_subset);
  in_subset(keep_single)= true;
  fprintf('Removing %d blocked reactions from subsets\n', length(blocked_react));
  if all_int
    for i= find(~in_subset)
      g= fast_gcd(abs(sub(i, 1:kncols)));
      sub(i, 1:kncols)= sub(i, 1:kncols) / g;
      sub(i, kncols + i)= g;
    end
    tol= 0; % probably better to use a dedicated row comparison test for integer cases
  else
    tol= 1E-10;
  end
  count= length(keep_single); % subset number count
  if count > 0
    irrev_sub(1, 1:count)= irrev_react(keep_single);
  end
  for i = 1:size(sub, 1) % iterate all the way because the last reaction itself could be a subset
    if in_subset(i) % this reaction is already included in another subset
      continue;
    end
    count= count + 1; % new subset
    irrev_sub(1, count)= irrev_react(i);
    for j = i+1:size(sub, 1)
      if in_subset(j)
        continue;
      end
      %# ensure that both rows have non-zero entries only in the same columns
      %# last condition is not necessary when blocked reactions were removed above
      %A#      if (length(ind) == length(ind2) && length(ind) > 0)
      %A#	if (all(ind == ind2)) %# cannot use & here because of eager evaluation in octave
      %A#	  erg= sqrt(var(sub(j, ind) ./ sub(i, ind))); % standard error
      %A#	  if (erg <= tol)
      if abs(sub(j, 1:kncols) * sub(i, 1:kncols)' / (norm(sub(j, 1:kncols)) * norm(sub(i, 1:kncols)))) >= (1 - tol)
        in_subset(j)= 1;
        ind= find(sub(i, 1:kncols));
        %ind2= find(sub(j, 1:kncols));
        mn= mean(sub(j, ind) ./ sub(i, ind));
        sub(i, kncols+1:end)= sub(i, kncols+1:end) + mn * sub(j, kncols+1:end);
        %# if one reaction in the subset is irreversible then so is the whole subset
        irrev_sub(1, count) = irrev_sub(1, count) | irrev_react(j);
      end
      %A#	end
    end
    %A#    end
  end
  in_subset(keep_single)= false;
  sub= sub(~in_subset, kncols+1:end);
  if all_int
    for i= 1:size(sub, 1)
      g= fast_gcd(abs(sub(i, :)));
      sub(i, :)= sub(i, :) / g;
    end
  end
  ind= find(any(sub(:, find(irrev_react)) < 0, 2)); % subsets that violate irreversibility constraints
  if length(ind) > 0
    sub(ind, :)= -sub(ind, :); % there can be revesible and irreversible reactions in a subset
    ind= find(any(sub(:, find(irrev_react)) < 0, 2)); % check whether the constraints are still violated
    fprintf('%d subsets violate irreversibility constraints; removed.\n', length(ind));
    sub_irr_viol= sub(ind, :);
    sub(ind, :)= [];
    irrev_sub(ind)= []; % irrev_sub(1, ind) produced error in Matlab
  else
    sub_irr_viol= [];
  end
  if isempty(sub)
    irrev_sub= [];
  end
