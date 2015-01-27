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

%# rd is the reduced system of st using subset matrix sub; irrev_rd are the 
%# reversibilities of the subsets
%# rdind are the indices of those metabolites that remain in the
%# reduced system

function [rd, rdind, irrev_rd]= reduce(st, sub, irrev_rd)
  if isempty(sub)
    rd= [];
    rdind= [];
  else
    rd= st * sub';
    rd(abs(rd) < 1E-10)= 0;
    rdind= find(any(rd, 2));
    rd= rd(rdind, :);
    if isempty(rd) % this happens when rd was a null matrix before removing null rows
      rd= zeros(1, size(rd, 2));
    end
  end
  if nargin > 2 % delete zero columns
    ind= find(any(rd));
    fprintf('Deleting %d zero columns from reduced system.\n', size(rd, 2) - length(ind));
    rd= rd(:, ind);
    irrev_rd= irrev_rd(ind);
  else
    irrev_rd= [];
  end

